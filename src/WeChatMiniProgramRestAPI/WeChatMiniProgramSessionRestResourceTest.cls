@IsTest
public class WeChatMiniProgramSessionRestResourceTest implements HttpCalloutMock
{
    @IsTest
    static void testDoGet()
    {
        WeChatMiniProgramSession__c wxmpSession = new WeChatMiniProgramSession__c();
        wxmpSession.ClientID__c = 'clientid';
        wxmpSession.ExpireAt__c = Datetime.now().addDays(30);

        wxmpSession.WeChatOpenID__c = 'openId';
        wxmpSession.WeChatUnionID__c = 'unionId';

        wxmpSession.SessionKey__c = 'test';

        insert wxmpSession;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/mini-program/sessions/test';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = WeChatMiniProgramSessionRestResource.doGet();
        system.assertEquals(result != null, true);
        Test.stopTest();
    }

    @IsTest
    static void testDoPostSession()
    {
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c();
        follower.Charket__OpenId__c = 'OPENID';
        insert follower;

        Charket__WeChatAccount__c wechatAccount = new Charket__WeChatAccount__c();
        wechatAccount.Charket__AppId__c = 'wx75b31003a694e9c2';
        wechatAccount.Charket__WeChatOriginId__c = 'test';
        insert wechatAccount;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/mini-program/sessions/test';
        req.httpMethod = 'post';
        RestContext.request = req;
        RestContext.response = res;

        req.requestBody = Blob.valueOf('{"code":"test","clientId":"test"}');

        Test.setMock(HttpCalloutMock.class, new WeChatMiniProgramSessionRestResourceTest());

        Test.startTest();
        String result = WeChatMiniProgramSessionRestResource.doPost();
        system.assertEquals(result != null, true);
        Test.stopTest();
    }

    public HTTPResponse respond(HTTPRequest request)
    {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('test');
        response.setBody('{"openid": "OPENID", "session_key": "SESSIONKEY", "unionid": "UNIONID"}');
        return response;
    }
}