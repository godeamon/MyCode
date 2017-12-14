@isTest
private class QRCodeGeneratorControllerTest 
{
    @isTest
    private static void testQRCodeGeneratorController()
    {
        List<Lead> leads = new List<Lead>();
        
        for(Integer i = 0; i < 50; i++)
        {
            Lead lead = new Lead(
            LastName ='Test Name',
            Company = 'hello',
            Email = 'www@teat.com'); 
            leads.add(lead);
        }
        
        insert leads;
        List<Lead> leadList = [select WeChatQRcodeURL__c, NumberId__c, Name from Lead];
        
        Charket__WeChatAccount__c newCharketAccount = new Charket__WeChatAccount__c(
            Name = 'Anna Account', Charket__WeChatOriginId__c = 'gh_f48b367e9733'
        );
        insert newCharketAccount;

        Charket__WeChatMessage__c wechatMessage = new Charket__WeChatMessage__c(
            Name = 'Hello', 
            Charket__WeChatAccount__c = newCharketAccount.Id,
            Charket__Type__c = 'Text Message',
            Charket__TextBody__c = 'Hello message world'
        );
        insert wechatMessage;

        Charket__WeChatResponse__c wechatResponse = new Charket__WeChatResponse__c();
        insert wechatResponse;

        Charket__WeChatResponseItem__c wechatResponseItem = new Charket__WeChatResponseItem__c(
            Charket__WeChatMessage__c = wechatMessage.Id,
            Charket__WeChatResponse__c = wechatResponse.Id
        );
        insert wechatResponseItem;
        
        List<Charket__WeChatAccount__c> wechatAccounts = [select Id from Charket__WeChatAccount__c where Id = :newCharketAccount.Id limit 1];

        ApexPages.StandardSetController stdHR = new ApexPages.StandardSetController(leadList);
        QRCodeGeneratorController testController = new QRCodeGeneratorController(stdHR);
        testController.WeChatAccountId =  wechatAccounts[0].id;
        testController.WeChatMessageId = wechatMessage.Id;
        testController.QRCodeExpirationHours = 720;
        testController.getWeChatAccountNames();

        Test.startTest();
        testController.generateQRCode();
        Test.stopTest();
        
        Lead lead = [select NumberId__c, WeChatQRcodeURL__c from Lead limit 1];
        System.assertNotEquals(null, lead.WeChatQRcodeURL__c);
    }
}