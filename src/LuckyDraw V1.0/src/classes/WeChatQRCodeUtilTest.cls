@isTest
private class WeChatQRCodeUtilTest 
{
    @isTest
    private static void testQRCodeRequestionforContact()
    {
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

        Integer qrcodeExpirationHours = 720;

        List<String> codeURLs = new List<String>(); 

        Contact contact = new Contact(
            LastName ='Test Name',
            Email = 'hello@helo.com'
        );
        insert contact;
        
        List<Charket__WeChatAccount__c> wechatAccounts = [select Id from Charket__WeChatAccount__c where Id = :newCharketAccount.Id limit 1];
        List<sObject> contactObj = [select Id, NumberId__c, Name from Contact];

        System.debug('contactObj: '+ contactObj + 'Account ' + wechatAccounts[0].Id  + 'wechatAccountId:' + wechatAccounts[0].Id );

        codeURLs = WeChatQRCodeUtil.createQRCodeByNumberId(contactObj, wechatAccounts[0].Id, wechatMessage.Id, qrcodeExpirationHours);
        
        System.assertNotEquals(null, codeURLs);
    }
    
    @isTest
    private static void testQRCodeRequestionforLead()
    {
        List<String> codeURLs = new List<String>();

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

        Integer qrcodeExpirationHours = 720;

        Lead lead = new Lead(
            LastName ='Test Name',
            Company = 'Hello'
        );
        insert lead;

        List<Charket__WeChatAccount__c> wechatAccounts = [select Id from Charket__WeChatAccount__c where Id = :newCharketAccount.Id limit 1];
        List<sObject> leadObj = [select Id, NumberId__c, Name from Lead where Id = :lead.Id];

        codeURLs = WeChatQRCodeUtil.createQRCodeByNumberId(leadObj, wechatAccounts[0].Id, wechatMessage.Id, qrcodeExpirationHours);

        System.assertNotEquals(null, codeURLs);
    }
}