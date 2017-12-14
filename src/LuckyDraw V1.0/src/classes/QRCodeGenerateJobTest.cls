@isTest
private class QRCodeGenerateJobTest 
{   
    @isTest 
    public static void QRCodeGenerateJobTest() 
    {
        ApexPages.StandardSetController stdSetController; 
        List<Lead> Leads = new List<Lead>();
        
        for(Integer i = 0; i < 50; i++)
        {
            Lead lead = new Lead();
            lead.LastName ='Name' + i;
            lead.Company = 'Hello';
            lead.Email = 'hello@helo.com';
            leads.add(lead);
        }
        
        insert leads;
        List<Lead> leadList = [select NumberId__c, WeChatQRcodeURL__c, Name from Lead];
        stdSetController = new ApexPages.StandardSetController(leadList);
        
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
        Id wechatMessageId = 'a0wO0000005NfIV';
        Integer qrcodeExpirationHours = 720;

        Test.startTest();
        QRCodeGenerateJob qrCodeGenerateJob = new QRCodeGenerateJob(stdSetController, wechatAccounts[0].Id, wechatMessage.Id, qrcodeExpirationHours);
        String batchId = DataBase.executeBatch(qrCodeGenerateJob);
        Test.stopTest();
        
        Lead lead = [select NumberId__c, WeChatQRcodeURL__c from Lead limit 1];
        System.assertNotEquals(null, lead.WeChatQRcodeURL__c);
    }
}