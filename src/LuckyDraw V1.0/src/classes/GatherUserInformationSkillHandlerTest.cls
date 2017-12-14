@isTest
public class GatherUserInformationSkillHandlerTest
{
    @isTest
    static void testGatherUserInfoWithLead()
    {
        Lead lead = new Lead(LastName = 'acme', Company = 'Charket');
        insert lead;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Charket__OpenId__c = 'openId',
            Charket__Lead__c = lead.Id,
            Name = 'acme'
        );
        insert follower;
        
        String ticket = 'ticket';
        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(
            Charket__Ticket__c = ticket
        );
        insert qrcode;
        
        Charket.SkillContext context = new Charket.SkillContext();
        Charket.WeChatApiEvent.Scan scanEvent = new Charket.WeChatApiEvent.Scan();
        scanEvent.Ticket = ticket;
        context.WeChatEvent = scanEvent;
        context.WeChatFollowerId = follower.Id;
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
        
        GatherUserInformationSkillHandler gatherUserInfo = new GatherUserInformationSkillHandler();
        Charket.SkillResponse response = gatherUserInfo.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('What’s your email address?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme@charket.com');
        context.WeChatEvent = null;
        session.IsNew = false;
        response = gatherUserInfo.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Your badge will be ready momentarily.', textMessage.Content);
    }
    
    @isTest
    static void testGatherUserInfoWithLeadFromWeChat()
    {
        Lead lead = new Lead(LastName = 'acme', Company = 'From WeChat', Email = 'acme@charket.com');
        insert lead;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Charket__OpenId__c = 'openId',
            Charket__Lead__c = lead.Id,
            Name = 'acme'
        );
        insert follower;
        
        String ticket = 'ticket';
        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(
            Charket__Ticket__c = ticket
        );
        insert qrcode;
        
        Charket.SkillContext context = new Charket.SkillContext();
        Charket.WeChatApiEvent.Scan scanEvent = new Charket.WeChatApiEvent.Scan();
        scanEvent.Ticket = ticket;
        context.WeChatEvent = scanEvent;
        context.WeChatFollowerId = follower.Id;
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
        
        GatherUserInformationSkillHandler gatherUserInfo = new GatherUserInformationSkillHandler();
        Charket.SkillResponse response = gatherUserInfo.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Thanks for visiting our booth! May I know your name?', textMessage.Content);
    }
    
    @isTest
    static void testGatherUserInfoWithContactFromWeChat()
    {
        Account acc = new Account(Name = 'From WeChat');
        insert acc;
        Contact contact = new Contact(LastName = 'charket', AccountId = acc.Id, Email = 'acme@charket.com');
        insert contact;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Charket__OpenId__c = 'openId',
            Charket__Contact__c = contact.Id,
            Charket__Lead__c = null,
            Name = 'acme'
        );
        insert follower;
        
        String ticket = 'ticket';
        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(
            Charket__Ticket__c = ticket
        );
        insert qrcode;
        
        Charket.SkillContext context = new Charket.SkillContext();
        Charket.WeChatApiEvent.Scan scanEvent = new Charket.WeChatApiEvent.Scan();
        scanEvent.Ticket = ticket;
        context.WeChatEvent = scanEvent;
        context.WeChatFollowerId = follower.Id;
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
        
        GatherUserInformationSkillHandler gatherUserInfo = new GatherUserInformationSkillHandler();
        Charket.SkillResponse response = gatherUserInfo.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Thanks for visiting our booth! May I know your name?', textMessage.Content);
    }
    
    @isTest
    static void testGatherUserInfoWithoutLeadOrContact()
    {
        Lead lead = new Lead(LastName = 'acme', Company = 'Charket');
        insert lead;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Charket__OpenId__c = 'openId',
            Name = 'acme'
        );
        insert follower;
        
        String ticket = 'ticket';
        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(
            Charket__Ticket__c = ticket
        );
        insert qrcode;
        
        Charket.SkillContext context = new Charket.SkillContext();
        Charket.WeChatApiEvent.Scan scanEvent = new Charket.WeChatApiEvent.Scan();
        scanEvent.Ticket = ticket;
        context.WeChatEvent = scanEvent;
        context.WeChatFollowerId = follower.Id;
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
        
        GatherUserInformationSkillHandler gatherUserInfo = new GatherUserInformationSkillHandler();
        Charket.SkillResponse response = gatherUserInfo.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Thanks for visiting our booth! May I know your name?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme charket');
        context.WeChatEvent = null;
        session.IsNew = false;
        response = gatherUserInfo.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Which company are you working for?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Charket');
        context.WeChatEvent = null;
        session.IsNew = false;
        response = gatherUserInfo.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('What’s your email address?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme@charket.com');
        context.WeChatEvent = null;
        session.IsNew = false;
        response = gatherUserInfo.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Your badge will be ready momentarily.', textMessage.Content);
    }
    
    @isTest
    static void testGatherUserInfoWithContact()
    {
        Account acc = new Account(Name = 'Charket');
        insert acc;
        Contact contact = new Contact(LastName = 'charket', AccountId = acc.Id);
        insert contact;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Charket__OpenId__c = 'openId',
            Charket__Contact__c = contact.Id,
            Charket__Lead__c = null,
            Name = 'acme'
        );
        insert follower;
        
        String ticket = 'ticket';
        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(
            Charket__Ticket__c = ticket
        );
        insert qrcode;
        
        Charket.SkillContext context = new Charket.SkillContext();
        Charket.WeChatApiEvent.Scan scanEvent = new Charket.WeChatApiEvent.Scan();
        scanEvent.Ticket = ticket;
        context.WeChatEvent = scanEvent;
        context.WeChatFollowerId = follower.Id;
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
        
        GatherUserInformationSkillHandler gatherUserInfo = new GatherUserInformationSkillHandler();
        Charket.SkillResponse response = gatherUserInfo.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('What’s your email address?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme@charket.com');
        context.WeChatEvent = null;
        session.IsNew = false;
        response = gatherUserInfo.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Your badge will be ready momentarily.', textMessage.Content);
    }
}