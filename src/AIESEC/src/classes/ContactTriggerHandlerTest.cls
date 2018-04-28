@isTest
private class ContactTriggerHandlerTest
{
    private static String openId = 'ASSIGN_AGENT_OPENID';

    @isTest
    static void testContactInsert()
    {
        Charket__WeChatAccount__c wechatAccount = new Charket__WeChatAccount__c(
                Name = 'Test Account', Charket__Type__c = 'Service Account',
                Charket__WeChatOriginId__c = 'ASSIGN_AGENT_ORIGIN_ID', IsCustomAgentAssignmentRuleEnabled__c = true
            );

        insert wechatAccount;
        Profile p = [select Id from Profile where Name = 'System Administrator'];

        User user = new User(
                Alias = 'user', Email = 'testuseragent@varian.sfqa.com', EXPA_LC_NAME__c = 'AHU',
                EmailEncodingKey = 'UTF-8', LastName = 'user', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testuseragent@varian.sfqa.com'
            );

        insert user;

        List<Charket__WeChatAgent__c> agents = new List<Charket__WeChatAgent__c>();

        agents.add(new Charket__WeChatAgent__c(
                Name = 'agent1', Charket__User__c = user.Id,
                Charket__WeChatAccount__c = wechatAccount.Id, Charket__IsActive__c = true, Charket__LastDesktopActiveTime__c = Datetime.now(),
                Charket__Status__c = 'online'
            ));

        insert agents;

        List<Charket__WeChatFollower__c> followers = new List<Charket__WeChatFollower__c>();

        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(City_of_University__c = '上海', University__c = '上海交通大学',
                Charket__OpenId__c = openId, Charket__WeChatAccount__c = wechatAccount.Id, Interested_Product__c = 'GT',
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = Datetime.now()
            );

        followers.add(follower);

        insert followers;

        Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c();
        transcript.Charket__WeChatAgent__c = agents[0].Id;
        transcript.Charket__Status__c = 'In Progress';
        transcript.Charket__WeChatFollower__c = followers[0].Id;
        transcript.Charket__DeliveredMethod__c = 'Direct';
        transcript.Charket__UnreadCount__c = 0;
        transcript.Charket__StartedBy__c = 'Follower';
        transcript.Charket__FollowerOpenId__c = followers[0].Charket__OpenId__c;
        transcript.Charket__IsActive__c = true;

        upsert transcript transcript.Charket__FollowerOpenId__c;

        Charket__WeChatFollower__c wechatFollower = new Charket__WeChatFollower__c();
        wechatFollower.City_of_University__c = '上海';
        wechatFollower.University__c = '上海交通大学';
        wechatFollower.Interested_Product__c = 'GT';
        wechatFollower.Charket__Gender__c = '女';

        insert wechatFollower;

        system.assertEquals('上海', weChatFollower.City_of_University__c);
        system.assertEquals('上海交通大学', weChatFollower.University__c);

        Contact contact = new Contact();
        contact.LastName = 'Test';
        contact.FirstName = 'Test';
        contact.Password__c = 'Testpassword1';
        contact.Contact_assign_owner_trigger__c = true;
        contact.Interested_Product__c = 'GV';
        contact.City_of_LC__c = '上海';
        contact.University__c = '上海交通大学';

        insert contact;

        system.assertEquals('GV', contact.Interested_Product__c);
    }

    @isTest
    static void testUpdateWithGT()
    {
        Charket__WeChatAccount__c wechatAccount = new Charket__WeChatAccount__c(
                Name = 'Test Account', Charket__Type__c = 'Service Account',
                Charket__WeChatOriginId__c = 'ASSIGN_AGENT_ORIGIN_ID', IsCustomAgentAssignmentRuleEnabled__c = true
            );

        insert wechatAccount;

        Profile p = [select Id from Profile where Name = 'System Administrator'];

        User user = new User(
                Alias = 'user', Email = 'testuseragent@varian.sfqa.com', EXPA_LC_NAME__c = 'AHU',
                EmailEncodingKey = 'UTF-8', LastName = 'user', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testuseragent@varian.sfqa.com'
            );

        insert user;

        List<User> users = new List<User>();
        for(Integer i = 0; i < 2; i++)
        {
            User userr = new User(
                    Alias = 'user' + i, Email = 'testuseragent' + i + '@varian.sfqa.com', EXPA_LC_NAME__c = 'AHU',
                    EmailEncodingKey = 'UTF-8', LastName = 'user' + i, LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US', ProfileId = p.Id,
                    TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testuseragent' + i + '@varian.sfqa.com'
                );
            users.add(userr);
        }
        insert users;

        List<Charket__WeChatAgent__c> agents1 = new List<Charket__WeChatAgent__c>();

        agents1.add(new Charket__WeChatAgent__c(
                Name = 'agent1', Charket__User__c = users[1].Id,
                Charket__WeChatAccount__c = wechatAccount.Id, Charket__IsActive__c = true, Charket__LastDesktopActiveTime__c = Datetime.now(),
                Charket__Status__c = 'online'
            ));
        
        agents1.add(new Charket__WeChatAgent__c(
                Name = 'agent2', Charket__User__c = users[0].Id,
                Charket__WeChatAccount__c = wechatAccount.Id, Charket__IsActive__c = true, Charket__LastDesktopActiveTime__c = Datetime.now(),
                Charket__Status__c = 'online'
            ));
        insert agents1;

        List<WeChatAgentSkill__c> skills = new List<WeChatAgentSkill__c>();
        skills.add(new WeChatAgentSkill__c(Product__c = 'GT', University__c = '上海交通大学'));
        skills.add(new WeChatAgentSkill__c(Product__c = 'GT', University__c = '其他'));
        skills.add(new WeChatAgentSkill__c(Product__c = 'GT', University__c = '中山大学'));
        skills.add(new WeChatAgentSkill__c(Product__c = null, University__c = null));
        insert skills;

        List<WechatAgentAssignment__c> assignments = new List<WechatAgentAssignment__c>();
        assignments.add(new WechatAgentAssignment__c(WeChatAgent__c = agents1[0].Id, WeChatAgentSkill__c = skills[0].Id));
        assignments.add(new WechatAgentAssignment__c(WeChatAgent__c = agents1[1].Id, WeChatAgentSkill__c = skills[0].Id));
        assignments.add(new WechatAgentAssignment__c(WeChatAgent__c = agents1[1].Id, WeChatAgentSkill__c = skills[1].Id));
        assignments.add(new WechatAgentAssignment__c(WeChatAgent__c = agents1[1].Id, WeChatAgentSkill__c = skills[2].Id));
        insert assignments;

        Contact contact = new Contact();
        contact.LastName = 'Test';
        contact.FirstName = 'Test';
        contact.Password__c = 'Testpassword1';
        contact.Contact_assign_owner_trigger__c = true;
        contact.City_of_LC__c = '上海';
        contact.University__c = '上海交通大学';

        insert contact;

        Contact contact1 = new Contact();
        contact1.LastName = 'Test1';
        contact1.FirstName = 'Test1';
        contact1.Password__c = 'Testpassword1';
        contact1.Contact_assign_owner_trigger__c = true;
        contact1.City_of_LC__c = '上海';
        contact1.University__c = '复旦大学';

        Contact contact2 = new Contact();
        contact2.LastName = 'Test2';
        contact2.FirstName = 'Test2';
        contact2.Password__c = 'Testpassword1';
        contact2.Contact_assign_owner_trigger__c = true;
        contact2.City_of_LC__c = '上海';
        contact2.University__c = '上海交通大学';

        List<Contact> contacts = new List<Contact>();
        contacts.add(contact1);
        contacts.add(contact2);

        insert contacts;

        List<Charket__WeChatFollower__c> followers = new List<Charket__WeChatFollower__c>();

        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(City_of_University__c = '上海', University__c = '上海交通大学',
                Charket__OpenId__c = openId, Charket__WeChatAccount__c = wechatAccount.Id, Interested_Product__c = 'GT',
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = Datetime.now(), Charket__Contact__c = contact.Id
            );
        Charket__WeChatFollower__c follower1 = new Charket__WeChatFollower__c(City_of_University__c = '上海', University__c = '上海交通大学',
                Charket__OpenId__c = openId + '1', Charket__WeChatAccount__c = wechatAccount.Id, Interested_Product__c = 'GT',
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = Datetime.now(), Charket__Contact__c = contact1.Id
            );

        followers.add(follower);
        followers.add(follower1);

        insert followers;

        system.assertEquals(true, contact.Contact_assign_owner_trigger__c);

        contact.Interested_Product__c = 'GT';

        update contact;
        contact1.Interested_Product__c = 'GT';
        contact2.Interested_Product__c = 'GT';
        update contacts;

        system.assertEquals('GT', contact.Interested_Product__c);
    }

    @isTest
    static void testUpdateWithGE()
    {
        Contact contact = new Contact();
        contact.LastName = 'Test';
        contact.FirstName = 'Test';
        contact.Password__c = 'Testpassword1';
        contact.Contact_assign_owner_trigger__c = true;
        contact.City_of_LC__c = '上海';
        contact.University__c = '上海交通大学';

        insert contact;

        system.assertEquals(true, contact.Contact_assign_owner_trigger__c);

        contact.Interested_Product__c = 'GE';

        update contact;

        system.assertEquals('GE', contact.Interested_Product__c);
    }

    @isTest
    static void testUpdateWithGV()
    {
        Contact contact = new Contact();
        contact.LastName = 'Test';
        contact.FirstName = 'Test';
        contact.Password__c = 'Testpassword1';
        contact.Contact_assign_owner_trigger__c = true;
        contact.City_of_LC__c = '上海';
        contact.University__c = '上海交通大学';

        insert contact;

        system.assertEquals(true, contact.Contact_assign_owner_trigger__c);

        contact.Interested_Product__c = 'GV';

        update contact;

        system.assertEquals('GV', contact.Interested_Product__c);
    }
}