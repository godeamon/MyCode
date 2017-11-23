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
        
        Charket__WeChatMessage__c message = new Charket__WeChatMessage__c(Charket__TextBody__c = 'test');
        insert message;
        
        // follower with lead
        String result = WeChatLeadController.save('测试', 'test@charket.com', 'companyStr', 'industryStr', 'phoneStr', campaign.Id,
        'Responded', controller.EncryedOpenId, template.Id, message.Id, true, account.Id, qrCode.Id);
        System.assertEquals(null, result);
        
        result = WeChatLeadController.save('test', 'test@charket.com', 'companyStr', 'industryStr', 'phoneStr', campaign.Id,
        'Responded', controller.EncryedOpenId, template.Id, message.Id, true, account.Id, qrCode.Id);
        System.assertEquals(null, result);

        // follower with contact
        follower.Charket__Lead__c = null;
        follower.Charket__Contact__c = contact.Id;
        Contact contact2 = createContact('123456789011', 'aaa');
        contact2.Email = 'acme@charket.com';
        update contact2;
        update follower;

        result = WeChatLeadController.save('测试', 'acme@charket.com', 'companyStr', 'industryStr', 'phoneStr', campaign.Id,
        'Responded', controller.EncryedOpenId, template.Id, '', true, account.Id, qrCode.Id);
        System.assertEquals(null, result);
        
        result = WeChatLeadController.save('testName', 'acme@charket.com', 'companyStr', 'industryStr', 'phoneStr', campaign.Id,
        'Responded', controller.EncryedOpenId, template.Id, '', true, account.Id, qrCode.Id);
        System.assertEquals(null, result);
        
        Lead leadTest = createLead('123456789011', 'aaa');
        leadTest.Email = null;
        update leadTest;
        lead.Email = 'acmeTestCC@charket.com';
        follower.Charket__Lead__c = leadTest.Id;
        follower.Charket__Contact__c = null;
        update follower;
        contact.Email = 'acmeTestC@charket.com';
        update lead;
        update contact;
        
        result = WeChatLeadController.save('name', 'acmeTestC@charket.com', 'companyStr', 'industryStr', 'phoneStr', campaign.Id,
        'Responded', controller.EncryedOpenId, template.Id, message.Id, true, account.Id, '');
        System.assertEquals(null, result);
    }

    @isTest
    static void testSaveEmailWithAnotherLead()
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
        
        Charket__WeChatMessage__c message = new Charket__WeChatMessage__c(Charket__TextBody__c = 'test');
        insert message;
        
        Lead leadTest = createLead('123456789011', 'aaa');
        leadTest.Email = null;
        update leadTest;
        lead.Email = 'acmeTestCC@charket.com';
        follower.Charket__Lead__c = leadTest.Id;
        follower.Charket__Contact__c = null;
        update follower;
        contact.Email = 'acmeTestC@charket.com';
        update lead;
        update contact;
        String result = WeChatLeadController.save('name', 'acmeTestCC@charket.com', 'companyStr', 'industryStr', 'phoneStr', campaign.Id,
        'Responded', controller.EncryedOpenId, template.Id, message.Id, true, account.Id, '');
        System.assertEquals(null, result);
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
                Company = 'Meginfo', Title = '其他', Description = '行业:石油炼化,业务咨询:工业物联网'
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