@IsTest
public class DomainRecordControllerTest implements HttpCalloutMock
{
    @testSetup
    static void setup()
    {
        Account account = new Account(Name = 'TestAccountName', Alias__c = 'TestAlias');
        insert account;
        
        sfLma__License__c license = new sfLma__License__c(sfLma__Account__c = account.Id, sfLma__Subscriber_Org_ID__c = account.Id);
        insert license;
        
        DoaminRecordSettings__c setting = new DoaminRecordSettings__c();
        setting.Name = 'DoaminRecordSettings';
        setting.AccessKeyId__c = 'test1';
        setting.IPAddress__c = 'test2';
        setting.SecretKey__c = 'test3';
        setting.DomainName__c = 'test;test';
        setting.Value__c = 'test;test';
        insert setting;
    }
    
    @IsTest
    static void testTypeA()
    {
        queryDataAndSetParameters();
        test.startTest();
        DomainRecordController a = new DomainRecordController();
        a.SelectedRecordType = 'A';
        a.getDomainNames();
        a.confirmHostAndValue();
        a.getType();
        a.save();
        a.cancel();
        system.assert(ApexPages.getMessages().size() != 0);
        test.stopTest();
    }
    
    @IsTest
    static void testTypeCname()
    {
        queryDataAndSetParameters();
        test.startTest();
        DomainRecordController a = new DomainRecordController();
        a.SelectedRecordType = 'CNAME';
        a.getDomainNames();
        a.confirmHostAndValue();
        a.getType();
        a.save();
        a.cancel();
        system.assert(ApexPages.getMessages().size() != 0);
        test.stopTest();
    }
    
    //Select account and license.
    //Set pageReference parameters and set mock response.
    public static void queryDataAndSetParameters()
    {
        Account account = [select Id from Account where Name = 'TestAccountName'];
        List<sfLma__License__c> licenses = [select Id from sfLma__License__c where sfLma__Account__c = :account.Id];
        PageReference pageReference = ApexPages.currentPage();
        pageReference.getParameters().put('id', licenses[0].Id);
        Test.setMock(HttpCalloutMock.class, new DomainRecordControllerTest());
    }
    
    //Override respond method of HttpCalloutMock interface.
    public HTTPResponse respond(HTTPRequest request)
    {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('test');
        response.setBody('{"RequestId":"85F1A24E-75E8-47E7-8ED4-6D40B7F38F1A","HostId":"alidns.aliyuncs.com","Code":"DomainRecordConflict","Message":"Unable to add the record because it conflicts with other records."}');
        return response;
    }
}