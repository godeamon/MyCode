@IsTest
public class WeChatMiniProgramFollowerTest
{
    @IsTest
    static void testDoPostSession()
    {
        WeChatMiniProgramSession__c wxmpSession = new WeChatMiniProgramSession__c();
        wxmpSession.ClientID__c = 'clientid';
        wxmpSession.ExpireAt__c = Datetime.now().addDays(30);

        wxmpSession.WeChatOpenID__c = 'openId';
        wxmpSession.WeChatUnionID__c = 'unionId';

        wxmpSession.SessionKey__c = 'test';

        insert wxmpSession;

        Charket__WeChatAccount__c wechatAccount = new Charket__WeChatAccount__c();
        wechatAccount.Charket__AppId__c = 'wx75b31003a694e9c2';
        wechatAccount.Charket__WeChatOriginId__c = 'test';
        insert wechatAccount;

        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c();
        follower.Charket__OpenId__c = 'OPENID';
        insert follower;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/mini-program/followers/';
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;

        req.requestBody = Blob.valueOf('{"city":"test","nickName":"test", "sessionKey":"test"}');

        Test.startTest();
        String result = WeChatMiniProgramFollowerRestResource.doPost();
        system.assertEquals(result != null, true);
        Test.stopTest();
    }
}