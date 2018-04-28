@isTest
public class CharketCustomAssignmentHandlerTest
{
    private static Charket__WeChatAccount__c wechatAccount;
    private static Id wechatAccountId;
    private static String openId = 'ASSIGN_AGENT_OPENID';
    private static String openId1 = 'ASSIGN_AGENT_OPENID1';
    private static String openId2 = 'ASSIGN_AGENT_OPENID2';
    private static String openId3 = 'ASSIGN_AGENT_OPENID3';

    @TestSetup
    static void setUp()
    {
        wechatAccount = new Charket__WeChatAccount__c(
                Name = 'Test Account', Charket__Type__c = 'Service Account',
                Charket__WeChatOriginId__c = 'gh_e8c4857297b0', IsCustomAgentAssignmentRuleEnabled__c = true
            );
        insert wechatAccount;
        wechatAccountId = wechatAccount.Id;

        Contact contact = new Contact();
        contact.LastName = 'Test';
        contact.FirstName = 'Test';
        contact.Password__c = 'Testpassword1';
        contact.Contact_assign_owner_trigger__c = true;
        contact.City_of_LC__c = '上海';
        contact.University__c = '上海交通大学';

        insert contact;

        List<Charket__WeChatFollower__c> followers = new List<Charket__WeChatFollower__c>();

        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(City_of_University__c = '上海', University__c = '上海交通大学',
                Charket__OpenId__c = openId, Charket__WeChatAccount__c = wechatAccount.Id, Interested_Product__c = 'GT',
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = Datetime.now()
            );

        Charket__WeChatFollower__c follower1 = new Charket__WeChatFollower__c(
                Charket__OpenId__c = openId1, Charket__WeChatAccount__c = wechatAccount.Id,
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = Datetime.now()
            );

        Charket__WeChatFollower__c follower2 = new Charket__WeChatFollower__c(City_of_University__c = '长沙', University__c = '中南大学',
                Charket__OpenId__c = openId2, Charket__WeChatAccount__c = wechatAccount.Id, Interested_Product__c = 'GT',Charket__Contact__c = contact.Id,
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = Datetime.now()
            );

        Charket__WeChatFollower__c follower3 = new Charket__WeChatFollower__c(City_of_University__c = '南京', University__c = '东南大学',
                Charket__OpenId__c = openId3, Charket__WeChatAccount__c = wechatAccount.Id, Interested_Product__c = null,
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = Datetime.now()
            );
        followers.add(follower);
        followers.add(follower2);
        followers.add(follower3);
        followers.add(follower1);
        insert followers;

        Profile p = [select Id from Profile where Name = 'System Administrator'];

        List<User> users = new List<User>();
        for(Integer i = 0; i < 2; i++)
        {
            User user = new User(
                    Alias = 'user' + i, Email = 'testuseragent' + i + '@varian.sfqa.com', EXPA_LC_NAME__c = 'AHU',
                    EmailEncodingKey = 'UTF-8', LastName = 'user' + i, LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US', ProfileId = p.Id,
                    TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testuseragent' + i + '@varian.sfqa.com'
                );
            users.add(user);
        }
        insert users;

        List<Charket__WeChatAgent__c> agents = new List<Charket__WeChatAgent__c>();

        agents.add(new Charket__WeChatAgent__c(
                Name = 'agent1', Charket__User__c = users[1].Id,
                Charket__WeChatAccount__c = wechatAccount.Id, Charket__IsActive__c = true, Charket__LastDesktopActiveTime__c = Datetime.now(),
                Charket__Status__c = 'online'
            ));
        
        agents.add(new Charket__WeChatAgent__c(
                Name = 'agent2', Charket__User__c = users[0].Id,
                Charket__WeChatAccount__c = wechatAccount.Id, Charket__IsActive__c = true, Charket__LastDesktopActiveTime__c = Datetime.now(),
                Charket__Status__c = 'online'
            ));
        insert agents;

        List<WeChatAgentSkill__c> skills = new List<WeChatAgentSkill__c>();
        skills.add(new WeChatAgentSkill__c(Product__c = 'GT', University__c = '上海交通大学'));
        skills.add(new WeChatAgentSkill__c(Product__c = 'GT', University__c = '其他'));
        skills.add(new WeChatAgentSkill__c(Product__c = 'GT', University__c = '中山大学'));
        skills.add(new WeChatAgentSkill__c(Product__c = null, University__c = null));
        insert skills;

        List<WechatAgentAssignment__c> assignments = new List<WechatAgentAssignment__c>();
        assignments.add(new WechatAgentAssignment__c(WeChatAgent__c = agents[0].Id, WeChatAgentSkill__c = skills[0].Id));
        assignments.add(new WechatAgentAssignment__c(WeChatAgent__c = agents[1].Id, WeChatAgentSkill__c = skills[0].Id));
        assignments.add(new WechatAgentAssignment__c(WeChatAgent__c = agents[1].Id, WeChatAgentSkill__c = skills[1].Id));
        assignments.add(new WechatAgentAssignment__c(WeChatAgent__c = agents[1].Id, WeChatAgentSkill__c = skills[2].Id));
        insert assignments;
    }

    @isTest
    static void testUpdateFollowerAndAgent()
    {
        Type t = Type.forName('', 'CharketCustomAssignmentHandler');
        Charket.WeChatAgentSelector agentSelector = (Charket.WeChatAgentSelector)t.newInstance();
        Charket.WeChatAgentSelectorContext context = new Charket.WeChatAgentSelectorContext('TEXT', 'bS9xL', openId);

        Test.startTest();
        String result = agentSelector.getAgentId(context);
        system.assert(result != null);

        Charket__WeChatAccount__c account1 = [select Id from Charket__WeChatAccount__c limit 1];
        Vip__c suser = new Vip__c(GIPAPP_GE_Created__c = true);
        insert suser;

        GIPAPP__c gipApp = new GIPAPP__c();
        gipApp.Suser__c = suser.Id;
        insert gipApp;

        Contact contact1 = new Contact();
        contact1.LastName = 'Test';
        contact1.FirstName = 'Test';
        contact1.Password__c = 'Testpassword1';
        contact1.Contact_assign_owner_trigger__c = true;
        contact1.City_of_LC__c = '上海';
        contact1.University__c = '上海交通大学';
        contact1.SUser__c = suser.Id;
        contact1.Interested_Product__c = 'GT';

        insert contact1;

        Charket__WeChatFollower__c follower = [select University__c from Charket__WeChatFollower__c
                where Charket__OpenId__c = :openId2 limit 1];

        follower.City_of_University__c = '广州';
        follower.University__c = '中山大学';
        follower.Charket__Contact__c = contact1.Id;

        List<Charket__WeChatTranscript__c> wechatTranscripts = [select Id
                from Charket__WeChatTranscript__c where Charket__Status__c != 'Completed'
                and Charket__WeChatFollower__r.Charket__OpenId__c = :openId2 limit 1];
        system.assert(wechatTranscripts.size() == 0);

        update follower;

        Test.stopTest();
    }

    @isTest
    static void testAnotherUpdateFollowerAndAgent()
    {
        List<Charket__WeChatAccount__c> wechatAccounts = [select Id, Charket__WeChatOriginId__c from 
            Charket__WeChatAccount__c where Charket__WeChatOriginId__c = 'gh_e8c4857297b0' limit 1];
        
        wechatAccounts[0].Charket__WeChatOriginId__c = 'gh_e8c4857test';

        update wechatAccounts;

        Type t = Type.forName('', 'CharketCustomAssignmentHandler');
        Charket.WeChatAgentSelector agentSelector = (Charket.WeChatAgentSelector)t.newInstance();
        Charket.WeChatAgentSelectorContext context = new Charket.WeChatAgentSelectorContext('TEXT', 'bS9xL', openId);

        Test.startTest();
        String result = agentSelector.getAgentId(context);
        system.assert(result != null);

        Charket__WeChatAccount__c account1 = [select Id from Charket__WeChatAccount__c limit 1];
        Vip__c suser = new Vip__c(GIPAPP_GE_Created__c = true);
        insert suser;

        GIPAPP__c gipApp = new GIPAPP__c();
        gipApp.Suser__c = suser.Id;
        insert gipApp;

        Contact contact1 = new Contact();
        contact1.LastName = 'Test';
        contact1.FirstName = 'Test';
        contact1.Password__c = 'Testpassword1';
        contact1.Contact_assign_owner_trigger__c = true;
        contact1.City_of_LC__c = '上海';
        contact1.University__c = '上海交通大学';
        contact1.SUser__c = suser.Id;
        contact1.Interested_Product__c = 'GV';

        insert contact1;

        Charket__WeChatFollower__c follower = [select University__c from Charket__WeChatFollower__c
                where Charket__OpenId__c = :openId2 limit 1];

        follower.City_of_University__c = '广州';
        follower.University__c = '中山大学';
        follower.Charket__Contact__c = contact1.Id;

        List<Charket__WeChatTranscript__c> wechatTranscripts = [select Id
                from Charket__WeChatTranscript__c where Charket__Status__c != 'Completed'
                and Charket__WeChatFollower__r.Charket__OpenId__c = :openId2 limit 1];
        system.assert(wechatTranscripts.size() == 0);

        update follower;

        Test.stopTest();
    }

    @isTest
    static void testAssignment()
    {
        Type t = Type.forName('', 'CharketCustomAssignmentHandler');
        Charket.WeChatAgentSelector agentSelector = (Charket.WeChatAgentSelector)t.newInstance();
        Charket.WeChatAgentSelectorContext context = new Charket.WeChatAgentSelectorContext('TEXT', 'bS9xL', openId1);

        Test.startTest();
        String result = agentSelector.getAgentId(context);
        system.assert(result == null);

        Charket.WeChatAgentSelectorContext context3 = new Charket.WeChatAgentSelectorContext('TEXT', 'bS9xL', openId2);
        result = agentSelector.getAgentId(context3);
        Charket.WeChatAgentSelectorContext context2 = new Charket.WeChatAgentSelectorContext('TEXT', 'bS9xL', openId3);
        Charket.WeChatAgentSelectorContext context4 = new Charket.WeChatAgentSelectorContext('TEXT', 'bS9xL', 'test');
        result = agentSelector.getAgentId(context2);
        system.assert(result == null);

        result = agentSelector.getAgentId(context4);
        system.assert(result == null);
        Test.stopTest();
    }
}