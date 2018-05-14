@isTest
public class SynTimecardDataTest implements HttpCalloutMock
{
    @isTest
    static void test()
    {
        String ret = 'user' + Math.rint(Math.random() * 100000);
        Profile p = [select Id from Profile where Name = 'Standard User'];
        User u = new User();
        u.Email = ret + '@qwer1.com';
        u.Username = ret + '@qwer1.com';
        u.LastName = 'Lee';
        u.FirstName = 'Ray';
        u.Alias = 'qwer1';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Chicago';
        u.EmailEncodingKey = 'UTF-8';
        u.ManagerId = UserInfo.getUserId();
        u.IsActive = true;
        u.IsPayrollUser__c = false;
        u.IsSuperUser__c = false;
        u.ProfileId = p.Id;
        u.EnrollmentDate__c = Date.today() + 30;
        u.GraduateDate__c = Date.today() - 389;
        u.BirthdayType__c = 'Lunar';
        insert u;
        Test.startTest();
        SynTimecardData.TimeCardMetadata  = (List<SynTimeCardSettings__mdt>) JSON.deserialize(
                '[{"ClientId__c ":"testClientId",' +
                '"ClientSecret__c ":"testClientSecret",' +
                '"Username__c ":"testUsername",' +
                '"Password__c":"testPassword",' +
                '"EndPoint__c":"testEndPoint"}]', List<SynTimeCardSettings__mdt>.class);
        Test.setMock(HttpCalloutMock.class, new SynTimecardDataTest());
        SynTimecardData batch = new SynTimecardData();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    public HTTPResponse respond(HTTPRequest request)
    {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('test');
        response.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://raylee-dev-ed.my.salesforce.com",'
                + '"id":"https://login.salesforce.com/id/00D6F000001uKWzUAM/0056F000006DbNcQAK","token_type":"Bearer",'
                + '"issued_at":"1520215418115","signature":"QKVZzUJzlN+cqX95GwwPosISKRZc0X8b5ZsGMq900FU=","totalSize":2,"done":true,'
                + '"records":[{"attributes":{"type":"Moblor_Tack__TimeCard__c","url":"/services/data/v22.0/sobjects/Moblor_Tack__TimeCard__c/a076F00000n2japQAA"},'
                + '"Id":"a076F00000n2japQAA","Moblor_Tack__Description__c":"第二个测试","Moblor_Tack__Hours__c":9.0,"Moblor_Tack__TeamMember__c":"a066F00001CX5kgQAD",'
                + '"Moblor_Tack__Date__c":"2018-03-01","Moblor_Tack__TeamMember__r":{"attributes":{"type":"Moblor_Tack__TeamMember__c","url":"/services/data/v22.0/sobjects/Moblor_Tack__TeamMember__c/a066F00001CX5kgQAD"},'
                + '"Name":"Ray","Moblor_Tack__User__r":{"attributes":{"type":"User","url":"/services/data/v22.0/sobjects/User/0056F000006DbNcQAK"},"Name":"Lee Ray"}},"Moblor_Tack__Task__r":null},'
                + '{"attributes":{"type":"Moblor_Tack__TimeCard__c","url":"/services/data/v22.0/sobjects/Moblor_Tack__TimeCard__c/a076F00000n2ivzQAA"},"Id":"a076F00000n2ivzQAA",'
                + '"Moblor_Tack__Description__c":"测试，第一个timecard。","Moblor_Tack__Hours__c":8.0,"Moblor_Tack__TeamMember__c":"a066F00001CX5kgQAD",'
                + '"Moblor_Tack__Date__c":"2018-03-01","Moblor_Tack__TeamMember__r":{"attributes":{"type":"Moblor_Tack__TeamMember__c",'
                + '"url":"/services/data/v22.0/sobjects/Moblor_Tack__TeamMember__c/a066F00001CX5kgQAD"},"Name":"Ray","Moblor_Tack__User__r":{"attributes":{"type":"User",'
                + '"url":"/services/data/v22.0/sobjects/User/0056F000006DbNcQAK"},"Name":"Lee Ray","FirstName":"Ray","LastName":"Lee"}},"Moblor_Tack__Task__r":{"attributes":{"type":"Moblor_Tack__Task__c",'
                + '"url":"/services/data/v22.0/sobjects/Moblor_Tack__Task__c/a056F00000iMyjSQAS"},"Name":"test","Moblor_Tack__Project__r":{"attributes":{"type":"Moblor_Tack__Project__c",'
                + '"url":"/services/data/v22.0/sobjects/Moblor_Tack__Project__c/a006F00002wtkqYQAQ"},"Name":"test"}}}]}');

        return response;
    }
}