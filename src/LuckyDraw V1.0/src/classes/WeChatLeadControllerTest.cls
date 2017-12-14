@isTest
public class WeChatLeadControllerTest
{
    private static Lead lead = createLead('12345678901', 'aa');
    private static Contact contact = createContact('12345678901', 'aa');
    private static Charket__WeChatAccount__c account = getWeChatAccount();
    private static Charket__WeChatFollower__c follower = getWeChatFollower(account.Id, lead.Id);
    private static Charket__WeChatQRCode__c qrCode = createQRCode(account.Id, 'test ticket');

    @isTest
    static void testInit()
    {
        WeChatLeadController controller = getWeChatLeadController();

        // openId is null
        String result = WeChatLeadController.init(null, '123', account.Id, '');
        System.assertEquals('{\"oauth_url\": \"\"}', result);

        // follower with lead
        result = WeChatLeadController.init(controller.EncryedOpenId, '123', account.Id, '');
        System.assert(result.contains(lead.LastName));

        // follower with contact
        follower.Charket__Lead__c = null;
        follower.Charket__Contact__c = contact.Id;
        update follower;
        result = WeChatLeadController.init(controller.EncryedOpenId, '123', account.Id, '');
        System.assert(result.contains(contact.LastName));

    }

    @isTest
    static void testSave()
    {
        WeChatLeadController controller = getWeChatLeadController();
        Campaign campaign = new Campaign(Name = 'acme', IsActive = true);
        insert campaign;

        CampaignMember member = new CampaignMember(
                CampaignId = campaign.Id, LeadId = lead.Id,
                Status = 'Sent');
        insert member;

        Charket__WeChatNotificationTemplate__c template = new Charket__WeChatNotificationTemplate__c(
            Charket__TemplateId__c = 'templateId'
        );
        insert template;
        
        // follower with lead
        String result = WeChatLeadController.save('bb', lead.LastName, 'acme@charket.com', 'companyStr', '0', campaign.Id,
        'Responded', controller.EncryedOpenId, template.Id, '', true, account.Id, qrCode.Id);
        System.assertEquals(null, result);

        // follower with contact
        follower.Charket__Lead__c = null;
        follower.Charket__Contact__c = contact.Id;
        update follower;

        result = WeChatLeadController.save('bb', lead.LastName, 'acme@charket.com', 'companyStr', '0', campaign.Id,
        'Responded', controller.EncryedOpenId, template.Id, '', true, account.Id, qrCode.Id);
        System.assertEquals(null, result);
    }
    
    @isTest
    static void testSaveWithContactEmail()
    {
        Contact contact2 = new Contact(AccountId = contact.AccountId, Email = 'acme.contact@charket.com',
            LastName = 'Test');
        insert contact2;
        
        WeChatLeadController controller = getWeChatLeadController();
        Campaign campaign = new Campaign(Name = 'acme', IsActive = true);
        insert campaign;
        
        contact.Email = '';
        update contact;
        
        follower.Charket__Lead__c = null;
        follower.Charket__Contact__c = contact.Id;
        update follower;
       
        String result = WeChatLeadController.save('bb', lead.LastName, 'acme.contact@charket.com', 'companyStr', '0', campaign.Id,
        'Responded', controller.EncryedOpenId, '', '', true, account.Id, qrCode.Id);
        
        Charket__WeChatFollower__c newFollower = [select Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c
                where Id = :follower.Id limit 1];
        System.assertEquals(newFollower.Charket__Contact__c, contact2.Id);
    }
    
    @isTest
    static void testSaveWithLeadEmail()
    {
        Lead lead2 = new Lead(Company = 'Charket', Email = 'acme.contact@charket.com',
            LastName = 'Test');
        insert lead2;
        
        WeChatLeadController controller = getWeChatLeadController();
        Campaign campaign = new Campaign(Name = 'acme', IsActive = true);
        insert campaign;
        
        contact.Email = '';
        update contact;
        
        follower.Charket__Lead__c = null;
        follower.Charket__Contact__c = contact.Id;
        update follower;
       
        String result = WeChatLeadController.save('bb', lead.LastName, 'acme.contact@charket.com', 'companyStr', '0', campaign.Id,
        'Responded', controller.EncryedOpenId, '', '', true, account.Id, qrCode.Id);
        
        Charket__WeChatFollower__c newFollower = [select Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c
                where Id = :follower.Id limit 1];
        System.assertEquals(newFollower.Charket__Contact__c, null);
        System.assertEquals(newFollower.Charket__Lead__c, lead2.Id);
    }

    private static Charket__WeChatAccount__c getWeChatAccount()
    {
        Charket__WeChatAccount__c wechatAccount = new Charket__WeChatAccount__c(
                Name = 'TestAcount', Charket__WeChatOriginId__c = 'test origin',
                Charket__Type__c = 'subscribe'
            );
        insert wechatAccount;
        return wechatAccount;
    }

    private static WeChatLeadController getWeChatLeadController()
    {
        PageReference WeChatLeadPage = Page.WeChatLead;
        WeChatLeadPage.getParameters().put('code', '123123');
        WeChatLeadPage.getParameters().put('accId', account.Id);
        WeChatLeadPage.getParameters().put('qrId', qrCode.Id);
        Test.setCurrentPage(WeChatLeadPage);
        WeChatLeadController controller = new WeChatLeadController();
        return controller;
    }

    private static Charket__WeChatFollower__c getWeChatFollower(Id accountId, Id leadId)
    {
        Charket__WeChatFollower__c wechatFollower = new Charket__WeChatFollower__c(
                Charket__OpenId__c = 'OPENID', Charket__WeChatAccount__c = account.Id,
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = System.now(),
                Charket__Lead__c = lead.Id
            );
        insert wechatFollower;
        return wechatFollower;
    }

    private static Charket__WeChatQRCode__c createQRCode(String accountId, String ticket)
    {
        Campaign campaign = new Campaign(Name = 'acme', IsActive = true);
        insert campaign;

        Charket__WeChatResponse__c response = new Charket__WeChatResponse__c(
                Name = 'Sign in', Charket__WeChatAccount__c = accountId,
                Charket__WhatId__c = campaign.Id, Charket__UsedFor__c = 'Welcome Message',
                Charket__IsActive__c = true
            );
        insert response;

        Charket__WeChatMessage__c message = new Charket__WeChatMessage__c(
                Name = 'Form Link', Charket__Type__c = 'Text Message',
                Charket__TextBody__c = 'https://ge.customer.charket.com.cn/wechatlead'
            );
        insert message;

        Charket__WeChatResponseItem__c responseItem = new Charket__WeChatResponseItem__c(
                Charket__WeChatResponse__c = response.Id,
                Charket__WeChatMessage__c = message.Id
            );
        insert responseItem;
        Charket__WeChatQRCode__c newQRCode = new Charket__WeChatQRCode__c(
                Charket__WeChatAccount__c = accountId, Charket__Scene__c = '123',
                Charket__Type__c = 'Temporary', Charket__WeChatResponse__c = response.Id,
                Charket__WhatId__c = campaign.Id,
                Charket__IsActive__c = true, Charket__Ticket__c = ticket,
                MoreInfo__c = '{"IsRegister":true, "HasConfirm":true, "EnterPhoneLabel":"12345678901", "CampaignMemberStatus":"Sent", "HasRegisterLabel":"111", "IsPrint":true}'
            );
        insert newQRCode;

        return newQRCode;
    }

    private static Lead createLead(String phone, String lastName)
    {
        Lead newLead = new Lead(
                FirstName = 'Test', LastName = lastName, Phone = phone, Email = 'test@meginfo.com',
                Company = 'Meginfo', Title = '其他'
            );
        insert newLead;
        return newLead;
    }

    private static Contact createContact(String phone, String lastName)
    {
        Account acc = new Account(Name = 'Meginfo');
        insert acc;
        Contact newContact = new Contact(
                FirstName = 'Test', LastName = lastName, Phone = phone, Email = 'test@meginfo.com',
                AccountId = acc.Id
            );
        insert newContact;
        return newContact;
    }
}