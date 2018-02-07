@RestResource(urlMapping='/mini-program/sessions/*')
global class WeChatMiniProgramSessionRestResource
{
    private static String appId = 'wx75b31003a694e9c2';
    private static String appSecret = '067034f224d8974dcfe4b1b322b37355';

    @HttpGet
    global static String doGet()
    {
        try
        {
            Pattern msgPattern = Pattern.compile('/mini-program/sessions/(.*)');
            Matcher msgMatch = msgPattern.matcher(RestContext.request.requestURI);

            if(!msgMatch.matches())
            {
                return '{"success":false, "errorMessage":"url not match"}';
            }

            List<WeChatMiniProgramSession__c> sessions = [select Id, ExpireAt__c from WeChatMiniProgramSession__c
                    where SessionKey__c = :msgMatch.group(1)];

            if(sessions.size() == 0)
            {
                return '{"success":false, "errorMessage":"invalid SessionKey", "errorCode":"invalid_session"}';
            }
            
            if(sessions[0].ExpireAt__c > Datetime.now())
            {
                sessions[0].ExpireAt__c = Datetime.now().addDays(30);
                update sessions;

                return '{"success":true, "expired":false}';
            }

            return '{"success":true, "expired":true}';
        }
        catch(Exception e)
        {
            return '{"success":false, "errorMessage":"exception occured"}';
        }
    }

    @HttpPost
    global static String doPost()
    {
        try
        {
            Pattern msgPattern = Pattern.compile('/mini-program/sessions(.*)');
            Matcher msgMatch = msgPattern.matcher(RestContext.request.requestURI);

            if(!msgMatch.matches() || RestContext.request.requestBody == null)
            {
                return '{"success":false, "errorMessage":"url not match"}';
            }

            if(msgMatch.matches())
            {
                HttpResponse response = getSessionKey(RestContext.request.requestBody.toString());
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(response.getBody()));

                if(responseMap.get('openid') != null && responseMap.get('session_key') != null && responseMap.get('unionid') != null)
                {
                    Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());

                    return insertSession(String.valueOf(requestBodyMap.get('ClientID')), String.valueOf(responseMap.get('openid')), String.valueOf(responseMap.get('unionid')));
                }

                if(responseMap.get('errmsg') != null)
                {
                    return '{"success":false,"errorMessage":"' + String.valueOf(responseMap.get('errmsg')) + '"}';
                }
            }

            return '{"success":false, "errorMessage":"WeChat has no response"}';
        }
        catch(Exception ex)
        {
            return '{"success":false, "errorMessage":"exception occured"}';
        }
    }

    private static HttpResponse getSessionKey(String requestBody)
    {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        String code = (String)m.get('code');
        

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.weixin.qq.com/sns/jscode2session?appid=' + appId + '&secret=' + appSecret + '&js_code=' + code + '&grant_type=authorization_code');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse response = http.send(request);

        return response;
    }

    private static String insertSession(String clientid, String openId, String unionId)
    {
        WeChatMiniProgramSession__c wxmpSession = new WeChatMiniProgramSession__c();
        wxmpSession.ClientID__c = clientid;
        wxmpSession.ExpireAt__c = Datetime.now().addDays(30);
        
        wxmpSession.WeChatOpenID__c = openId;
        wxmpSession.WeChatUnionID__c = unionId;

        Blob key = Crypto.generateAesKey(256);
        Blob source = Blob.valueOf(String.valueOf(Datetime.now()));
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, source);
        String encrypted64 = EncodingUtil.base64Encode(encrypted);

        wxmpSession.SessionKey__c = encrypted64;

        insert wxmpSession;

        if(getFollowerInfo(openId))
        {
            return '{"success":true, "hasFollowerInfo":true, "sessionKey":"' + encrypted64 + '"}';
        }

        return '{"success":true, "hasFollowerInfo":false, "sessionKey":"' + encrypted64 + '"}';
    }

    private static Boolean getFollowerInfo(String openId)
    {
        List<Charket__WeChatFollower__c> followers = [select Id, Name, Charket__Gender__c, Charket__Contact__c, Charket__Lead__c,
                Charket__WeChatAccount__c, Charket__Alias__c, Charket__State__c, Charket__City__c, Charket__Country__c, Charket__IsFollowing__c,
                Charket__Language__c, Charket__UniqueCode__c, Charket__WeChatProfilePhotoUrl__c from Charket__WeChatFollower__c
                where Charket__OpenId__c = :openId limit 1];

        if(followers.size() == 0)
        {
            return false;
        }

        Charket__WeChatFollower__c newFollower = followers[0].clone(false, true, false, false);
        Charket__WeChatAccount__c wechatAccount = [select Id from Charket__WeChatAccount__c where Charket__AppId__c = :appId];
        newFollower.Charket__WeChatAccount__c = wechatAccount.Id;
        insert newFollower;

        return true;
    }
}