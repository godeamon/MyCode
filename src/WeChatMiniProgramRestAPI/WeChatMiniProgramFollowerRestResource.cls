@RestResource(urlMapping='/mini-program/followers/*')
global class WeChatMiniProgramFollowerRestResource
{
    private static String appId = 'wx75b31003a694e9c2';
    private static String appSecret = '067034f224d8974dcfe4b1b322b37355';
    
    @HttpPost
    global static String doPost()
    {
        try
        {
            Pattern msgPattern = Pattern.compile('/mini-program/followers(.*)');
            Matcher msgMatch = msgPattern.matcher(RestContext.request.requestURI);

            if(!msgMatch.matches() || RestContext.request.requestBody == null)
            {
                return '{"success":false, "errorMessage":"url not match"}';
            }

            if(msgMatch.matches())
            {
                try
                {
                    insertNewFollower(RestContext.request.requestBody.toString());
                }
                catch(Exception e)
                {
                    return '{"success":false, "errorCode": "insert_follower_exception", "errorMessage": "insert new follower exception"}';
                }

                return '{"success":true}';
            }

            return '{"success":false, "errorMessage":"WeChat has no response"}';
        }
        catch(Exception ex)
        {
            return '{"success":false, "errorMessage":"exception occured"}';
        }
    }

    private static void insertNewFollower(String followerInfoStr)
    {
        WeChatMiniProgramFollowerRestResource.NewFollowerInfo newFollowerInfo = (WeChatMiniProgramFollowerRestResource.NewFollowerInfo)JSON.deserialize(followerInfoStr, WeChatMiniProgramFollowerRestResource.NewFollowerInfo.class);

        List<WeChatMiniProgramSession__c> weChatSessions = [select WeChatUnionID__c, WeChatOpenID__c from
            WeChatMiniProgramSession__c where SessionKey__c = :newFollowerInfo.sessionKey limit 1];

        if(weChatSessions.size() > 0)
        {
            Lead newLead = new Lead();
            newLead.LastName = newFollowerInfo.nickName;
            newLead.Company = 'From WeChat mini-program';

            insert newLead;

            Charket__WeChatAccount__c wechatAccount = [select Id from Charket__WeChatAccount__c where Charket__AppId__c = :appId];

            Charket__WeChatFollower__c newFollower = new Charket__WeChatFollower__c();
            newFollower.Charket__WeChatProfilePhotoUrl__c = newFollowerInfo.avatarUrl;
            newFollower.Charket__City__c = newFollowerInfo.city;
            newFollower.Charket__Country__c = newFollowerInfo.country;
            newFollower.Charket__Language__c = newFollowerInfo.language;
            newFollower.Name = newFollowerInfo.nickName;
            newFollower.Charket__State__c = newFollowerInfo.province;

            newFollower.Charket__OpenId__c = weChatSessions[0].WeChatOpenID__c;
            newFollower.Charket__UniqueCode__c = weChatSessions[0].WeChatUnionID__c;
            newFollower.Charket__IsFollowing__c = false;
            newFollower.Charket__Lead__c = newLead.Id;

            if(wechatAccount != null)
            {
                newFollower.Charket__WeChatAccount__c = wechatAccount.Id;
            }

            if(newFollowerInfo.gender == 1)
            {
                newFollower.Charket__Gender__c = 'Male';
            }
            else if(newFollowerInfo.gender == 0)
            {
                newFollower.Charket__Gender__c = 'Female';
            }
            else
            {
                newFollower.Charket__Gender__c = 'Unknown';
            }
            insert newFollower;
        }
    }

    public class NewFollowerInfo
    {
        public String sessionKey { get; set; }
        public String avatarUrl { get; set; }
        public String city { get; set; }
        public String country { get; set; }
        public Integer gender { get; set; }
        public String language { get; set; }
        public String nickName { get; set; }
        public String province { get; set; }
    }
}