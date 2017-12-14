@isTest
private class CustomAgentSelectorTest 
{
    @isTest 
    static void testMsgTypeNotScan() 
    {
        Charket__WeChatAccount__c acc = new Charket__WeChatAccount__c(Name = 'LynnAccount', Charket__WeChatOriginId__c = 'a0JO0000006snsvMAA');
        insert acc;

        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Name = 'test', Charket__WeChatAccount__c = acc.Id, Charket__OpenId__c = '1111111');
        insert follower;
        
        Profile sfProfile = [select Id, Name, UserLicenseId, UserType from Profile where UserLicense.LicenseDefinitionKey = 'SFDC' limit 1];
        List<User> users = new List<User>();
       
        for(Integer i = 0; i < 5; i++)
        {
            User user = new User(LastName = 'TestUser' + i, Alias = 'll' + i, Email = 'Ll=@meginfo.com' + i,
                UserName = 'Ll=@meginfo.com' + i, CommunityNickname = 'L.L=' + i,
                TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
                ProfileId = sfProfile.Id, LanguageLocaleKey = 'en_US');
            users.add(user);
        }

        insert users;
        
        List<Charket__WeChatAgent__c> agents = new List<Charket__WeChatAgent__c>();
        Integer j = 0;
        
        for(User user : users)
        {
            Charket__WeChatAgent__c agent = new Charket__WeChatAgent__c(
                Name = 'Test' + j, 
                Charket__User__c = user.Id, 
                Charket__WeChatAccount__c = acc.Id
            );
            j++;
            agents.add(agent);
        }

        insert agents;

        CustomAgentSelector selector = new CustomAgentSelector();
        selector.customLabelUserId = users[0].Id;
        Charket.WeChatAgentSelectorContext context = new Charket.WeChatAgentSelectorContext('text', 'hello', follower.Charket__OpenId__c);
        String agentId = selector.getAgentId(context);
        System.assertEquals(agents[0].Id, agentId);
    }

    @isTest
    static void testMsgTypeIsScanAndEventsTypeIsScanOrSubscribe()
    {
        Charket__WeChatAccount__c acc = new Charket__WeChatAccount__c(Name = 'LynnAccount', Charket__WeChatOriginId__c = 'a0JO0000006snsvMAA');
        insert acc;

        Charket__WeChatFollower__c follower1 = new Charket__WeChatFollower__c(Name = 'test', Charket__WeChatAccount__c = acc.Id, Charket__OpenId__c = '1111111');
        insert follower1;

        Charket__WeChatFollower__c follower2 = new Charket__WeChatFollower__c(Name = 'testType', Charket__WeChatAccount__c = acc.Id, Charket__OpenId__c = '243545');
        insert follower2;

        Profile sfProfile = [select Id, Name, UserLicenseId, UserType from Profile where UserLicense.LicenseDefinitionKey = 'SFDC' limit 1];
        List<User> users = new List<User>();
       
        for(Integer i = 0; i < 5; i++)
        {
            User user = new User(LastName = 'TestUser' + i, Alias = 'll' + i, Email = 'Ll=@meginfo.com' + i,
                UserName = 'Ll=@meginfo.com' + i, CommunityNickname = 'L.L=' + i,
                TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
                ProfileId = sfProfile.Id, LanguageLocaleKey = 'en_US');
            users.add(user);
        }

        insert users;

        Campaign campaign = new Campaign(Name = 'TestCampaign', OwnerId = users[0].Id);
        insert campaign;

        Charket__WeChatQRCode__c qCode = new Charket__WeChatQRCode__c(Name = 'q', Charket__WeChatAccount__c = acc.Id, Charket__WhatId__c = campaign.Id);
        insert qCode;

        Charket__WeChatEvent__c event1 = new Charket__WeChatEvent__c(Charket__WeChatAccount__c = acc.Id, Charket__WeChatFollower__c = follower1.Id,
                Charket__WeChatQRCode__c = qCode.Id, Charket__Type__c = 'Scan');
        insert event1;

        Charket__WeChatEvent__c event2 = new Charket__WeChatEvent__c(Charket__WeChatAccount__c = acc.Id, Charket__WeChatFollower__c = follower1.Id,
                Charket__WeChatQRCode__c = qCode.Id, Charket__Type__c = 'Subscribe');
        insert event2;

        Charket__WeChatEvent__c event3 = new Charket__WeChatEvent__c(Charket__WeChatAccount__c = acc.Id, Charket__WeChatFollower__c = follower2.Id,
                Charket__WeChatQRCode__c = qCode.Id, Charket__Type__c = 'text');
        insert event3;


        List<Charket__WeChatAgent__c> agents = new List<Charket__WeChatAgent__c>();
        Integer j = 0;
        
        for(User user : users)
        {
            Charket__WeChatAgent__c agent = new Charket__WeChatAgent__c(
                Name = 'Test' + j, 
                Charket__User__c = user.Id, 
                Charket__WeChatAccount__c = acc.Id
            );
            j++;
            agents.add(agent);
        }

        insert agents;

        CustomAgentSelector selector = new CustomAgentSelector();
        selector.customLabelUserId = users[1].Id;

        Charket.WeChatAgentSelectorContext context1 = new Charket.WeChatAgentSelectorContext('Scan', 'hello', follower1.Charket__OpenId__c);
        String agentId1 = selector.getAgentId(context1);
        System.assertEquals(agents[0].Id, agentId1);

        Charket__WeChatEvent__c event4 = new Charket__WeChatEvent__c(Charket__WeChatAccount__c = acc.Id, Charket__WeChatFollower__c = follower1.Id,
                Charket__WeChatQRCode__c = qCode.Id, Charket__Type__c = 'Subscribe');
        
        insert event4;

        Charket.WeChatAgentSelectorContext context2 = new Charket.WeChatAgentSelectorContext('Scan', 'hello', follower1.Charket__OpenId__c);
        String agentId2 = selector.getAgentId(context2);
        System.assertEquals(agents[0].Id, agentId2);

    }

    @isTest
    static void testReturnNull()
    {
        Charket__WeChatAccount__c acc = new Charket__WeChatAccount__c(Name = 'Account1', Charket__WeChatOriginId__c = 'a0JO0000006snsvMAA');
        insert acc;

        Charket__WeChatFollower__c follower1 = new Charket__WeChatFollower__c(Name = 'test', Charket__WeChatAccount__c = acc.Id, Charket__OpenId__c = '1111111');
        insert follower1;

        Charket__WeChatFollower__c follower2 = new Charket__WeChatFollower__c(Name = 'testType', Charket__WeChatAccount__c = acc.Id, Charket__OpenId__c = '243545');
        insert follower2;

        Profile sfProfile = [select Id, Name, UserLicenseId, UserType from Profile where UserLicense.LicenseDefinitionKey = 'SFDC' limit 1];
        List<User> users = new List<User>();
       
        for(Integer i = 0; i < 5; i++)
        {
            User user = new User(LastName = 'TestUser' + i, Alias = 'll' + i, Email = 'Ll=@meginfo.com' + i,
                UserName = 'Ll=@meginfo.com' + i, CommunityNickname = 'L.L=' + i,
                TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
                ProfileId = sfProfile.Id, LanguageLocaleKey = 'en_US');
            users.add(user);
        }

        insert users;

        Campaign campaign = new Campaign(Name = 'TestCampaign', OwnerId = users[0].Id);
        insert campaign;

        Charket__WeChatQRCode__c qCode = new Charket__WeChatQRCode__c(Name = 'q', Charket__WeChatAccount__c = acc.Id, Charket__WhatId__c = campaign.Id);
        insert qCode;

        Charket__WeChatEvent__c event1 = new Charket__WeChatEvent__c(Charket__WeChatAccount__c = acc.Id, Charket__WeChatFollower__c = follower1.Id,
                Charket__WeChatQRCode__c = qCode.Id, Charket__Type__c = 'Subscribe');
        insert event1;

        Charket__WeChatEvent__c event2 = new Charket__WeChatEvent__c(Charket__WeChatAccount__c = acc.Id, Charket__WeChatFollower__c = follower1.Id,
                Charket__WeChatQRCode__c = qCode.Id, Charket__Type__c = 'Scan');
        insert event2;

        Charket__WeChatEvent__c event3 = new Charket__WeChatEvent__c(Charket__WeChatAccount__c = acc.Id, Charket__WeChatFollower__c = follower2.Id,
                Charket__WeChatQRCode__c = qCode.Id, Charket__Type__c = 'text');
        insert event3;

        List<Charket__WeChatAgent__c> agents = new List<Charket__WeChatAgent__c>();
        Integer j = 0;
        
        for(User user : users)
        {
            Charket__WeChatAgent__c agent = new Charket__WeChatAgent__c(
                Name = 'Test' + j, 
                Charket__User__c = user.Id, 
                Charket__WeChatAccount__c = acc.Id
            );
            j++;
            agents.add(agent);
        }

        insert agents;

        CustomAgentSelector selector = new CustomAgentSelector();
        selector.customLabelUserId = users[1].Id;

        Charket.WeChatAgentSelectorContext context = new Charket.WeChatAgentSelectorContext('Scan', 'hello', '00000000000');
        String agentId = selector.getAgentId(context);
        System.assertEquals(null, agentId);
    }
}