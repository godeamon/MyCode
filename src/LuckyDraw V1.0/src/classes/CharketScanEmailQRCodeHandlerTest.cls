@isTest
private class CharketScanEmailQRCodeHandlerTest
{
    @testSetup static void setup() 
    {
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Charket__OpenId__c = 'client_abc123');
        insert follower;
    }

    @isTest
    private static void testLeadCharketScanEmailQRCodeHandler()
    {
        Lead lead = new Lead(LastName = 'anna', Company = 'Hello');
        insert lead;

        Charket__WeChatQRCode__c qrCode = new Charket__WeChatQRCode__c(Charket__Ticket__c = '00000000000000000', Charket__WhatId__c = lead.Id);
        insert qrCode;

        CharketScanEmailQRCodeHandler testHandler = new CharketScanEmailQRCodeHandler();

        testHandler.handleQRCode(null);

        List<Charket__WeChatFollower__c> followers = [select Id from Charket__WeChatFollower__c where Charket__Lead__c = :lead.Id];
        System.assert(followers.size() > 0);
    }

    @isTest
    private static void testContactCharketScanEmailQRCodeHandler()
    {
        Contact contact = new Contact(LastName = 'anna');
        insert contact;

        Charket__WeChatQRCode__c qrCode = new Charket__WeChatQRCode__c(Charket__Ticket__c = '00000000000000000', Charket__WhatId__c = contact.Id);
        insert qrCode;
        
        CharketScanEmailQRCodeHandler testHandler = new CharketScanEmailQRCodeHandler();

        testHandler.handleQRCode(null);

        List<Charket__WeChatFollower__c> followers = [select Id from Charket__WeChatFollower__c where Charket__Contact__c = :contact.Id];
        System.assert(followers.size() > 0);
    }
}