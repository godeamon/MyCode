@isTest
private class WeChatFollowerTriggerTest 
{
    @testSetup 
    static void init() 
    {
        Profile gusetProfile = [SELECT Id, Name, UserLicenseId, UserType FROM Profile where UserLicense.LicenseDefinitionKey = 'PID_Guest_User' limit 1];
        Profile sfProfile = [SELECT Id, Name, UserLicenseId, UserType FROM Profile where UserLicense.LicenseDefinitionKey = 'SFDC' limit 1];
        
        User user1 = new User(LastName = 'Site Guest User', Alias = 'llau', Email = 'Lynn.Lau=@meginfo.com',
                             UserName = 'Lynn.Lau=@meginfo.com', CommunityNickname = 'Lynn.Lau=',
                             TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
                             ProfileId = gusetProfile.Id, LanguageLocaleKey = 'en_US');
        insert user1;
       
        User user2 = new User(LastName = 'TestUser', Alias = 'test', Email = 'test@meginfo.com',
                             UserName = 'test@meginfo.com', CommunityNickname = 'test',
                             TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
                             ProfileId = sfProfile.Id, LanguageLocaleKey = 'en_US');
        insert user2;
        
        Charket__WeChatAccount__c acc = new Charket__WeChatAccount__c(Name = 'LynnAccount', Charket__WeChatOriginId__c = 'a0JO0000006snsvMAA');
        insert acc;
    }

    @isTest 
    static void testSingleInsertWeChatFollower() 
    {
        User user1 = [select Id, ProfileId from User where LastName = 'Site Guest User' and Alias = 'llau' and Email = 'Lynn.Lau=@meginfo.com'];
        User user2 = [select Id from User where LastName = 'TestUser' limit 1];
        
        Lead lead = new Lead(LastName = 'leadToAddOwner', Company = 'Meginfo', OwnerId = user1.Id);
        insert lead;
        
        Charket__WeChatAccount__c acc = [select Id from Charket__WeChatAccount__c where Name = 'LynnAccount' limit 1];
        
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Name = lead.Name, Charket__WeChatAccount__c = acc.Id);
        insert follower;

        Charket__WeChatAgent__c agent = new Charket__WeChatAgent__c(Name = 'Lynn', Charket__User__c = user2.Id);
        insert agent;

        Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c(Charket__WeChatFollower__c = follower.Id, Charket__WeChatAgent__c = agent.Id);
        insert transcript;

        Charket__WeChatFollower__c followerToUpdate = [select Id, Charket__Lead__c from Charket__WeChatFollower__c where Id = :follower.Id];
        
        if(followerToUpdate.Charket__Lead__c == null)
        {
            followerToUpdate.Charket__Lead__c = lead.Id;
        }

        update followerToUpdate;

        Lead leadToTest = [select OwnerId from Lead where Id = :lead.Id];
        Charket__WeChatAgent__c agentToTest = [select Charket__User__c from Charket__WeChatAgent__c where Id = :agent.Id];

        System.assertEquals(agentToTest.Charket__User__c, leadToTest.OwnerId);
    }

    @isTest 
    static void testBulkInsertWeChatFollower() 
    {
        User user1 = [select Id, ProfileId from User where LastName = 'Site Guest User' and Alias = 'llau' and Email = 'Lynn.Lau=@meginfo.com'];
        User user2 = [select Id from User where LastName = 'TestUser' limit 1];
        
        List<Lead> leads = new List<Lead>();

        for(Integer i = 0; i < 100; i++)
        {
            Lead lead = new Lead(LastName = 'leadToAddOwner' + i, Company = 'Meginfo' + i, OwnerId = user1.Id);
            leads.add(lead);
        }

        insert leads;

        List<Lead> insertedLeads = [select Id from Lead];
        Map<Integer, String> leadIdMap = new Map<Integer, String>();

        for(Integer l = 0; l < insertedLeads.size(); l++)
        {
            leadIdMap.put(l, insertedLeads[l].Id);
        }
        
        Charket__WeChatAccount__c acc = [select Id from Charket__WeChatAccount__c where Name = 'LynnAccount' limit 1];
        
        List<Charket__WeChatFollower__c> followers = new List<Charket__WeChatFollower__c>();
    
        for(Integer n = 0; n < 100; n++)
        {
            Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Name = 'Name' + n , Charket__WeChatAccount__c = acc.Id);
            followers.add(follower);
        }

        insert followers;

        List<Charket__WeChatFollower__c> insertedFollowers = [select Id from Charket__WeChatFollower__c];
        Map<Integer, String> folowerIdMap = new Map<Integer, String>();

        for(Integer f = 0; f < insertedFollowers.size(); f++)
        {
            folowerIdMap.put(f, insertedFollowers[f].Id);
        }

        Charket__WeChatAgent__c agent = new Charket__WeChatAgent__c(Name = 'Lynn', Charket__User__c = user2.Id);
        insert agent;

        List<Charket__WeChatTranscript__c> transcripts = new List<Charket__WeChatTranscript__c>();

        for(Integer k = 0; k < 100; k++)
        {
            Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c(Charket__WeChatFollower__c = folowerIdMap.get(k), Charket__WeChatAgent__c = agent.Id);
            transcripts.add(transcript);
        }
        
        insert transcripts;

        List<Charket__WeChatFollower__c> followerToUpdate = [select Id, Charket__Lead__c from Charket__WeChatFollower__c];
        List<Charket__WeChatFollower__c> updateFollowers = new List<Charket__WeChatFollower__c>();

        for(Integer u = 0; u < followerToUpdate.size(); u++)
        {
            if(followerToUpdate[u].Charket__Lead__c == null)
            {
               followerToUpdate[u].Charket__Lead__c =  leadIdMap.get(u);
            }

            updateFollowers.add(followerToUpdate[u]);
        }
        
        update updateFollowers;
        
        Charket__WeChatAgent__c agentToTest = [select Charket__User__c from Charket__WeChatAgent__c where Id = :agent.Id];
        List<Lead> leadToTest = [select OwnerId from Lead where OwnerId = :agentToTest.Charket__User__c];
        System.assertEquals(100, leadToTest.size());
    }
    
    @isTest
    static void testSingleUpdateFollower()
    {
        User user1 = [select Id, ProfileId from User where LastName = 'Site Guest User' and Alias = 'llau' and Email = 'Lynn.Lau=@meginfo.com'];
        User user2 = [select Id from User where LastName = 'TestUser' limit 1];
        
        Lead lead = new Lead(LastName = 'leadToAddOwner', Company = 'Meginfo', OwnerId = user2.Id);
        insert lead;
        
        Charket__WeChatAccount__c acc = [select Id from Charket__WeChatAccount__c where Name = 'LynnAccount' limit 1];
        
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Name = lead.Name, Charket__WeChatAccount__c = acc.Id, Charket__Lead__c = lead.Id);
        insert follower;

        Charket__WeChatAgent__c agent = new Charket__WeChatAgent__c(Name = 'Lynn', Charket__User__c = user2.Id);
        insert agent;

        Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c(Charket__WeChatFollower__c = follower.Id, Charket__WeChatAgent__c = agent.Id);
        insert transcript;

        Lead leadToAddOwner = [select Id, OwnerId from Lead];
        leadToAddOwner.OwnerId = user1.Id; 
        update leadToAddOwner;

        Charket__WeChatFollower__c followerToUpdateName = [select Id, Name from Charket__WeChatFollower__c];
        
        if(followerToUpdateName != null)
        {
            followerToUpdateName.Name = 'changedName';
        }
        
        update followerToUpdateName;

        Lead testLead = [select OwnerId from Lead];
        Charket__WeChatAgent__c agentToTest = [select Charket__User__c from Charket__WeChatAgent__c where Id = :agent.Id];
        System.assertEquals(agentToTest.Charket__User__c, testLead.OwnerId);
    }

    @isTest
    static void testBulkUpdateFollower()
    {
        User user1 = [select Id, ProfileId from User where LastName = 'Site Guest User' and Alias = 'llau' and Email = 'Lynn.Lau=@meginfo.com'];
        User user2 = [select Id from User where LastName = 'TestUser' limit 1];
        
        List<Lead> leads = new List<Lead>();

        for(Integer i = 0; i < 100; i++)
        {
            Lead lead = new Lead(LastName = 'leadToAddOwner' + i, Company = 'Meginfo' + i, OwnerId = user2.Id);
            leads.add(lead);
        }

        insert leads;

        List<Lead> insertedLeads = [select Id from Lead];
        Map<Integer, String> leadIdMap = new Map<Integer, String>();

        for(Integer l = 0; l < insertedLeads.size(); l++)
        {
            leadIdMap.put(l, insertedLeads[l].Id);
        }
        
        Charket__WeChatAccount__c acc = [select Id from Charket__WeChatAccount__c where Name = 'LynnAccount' limit 1];
        
        List<Charket__WeChatFollower__c> followers = new List<Charket__WeChatFollower__c>();
    
        for(Integer n = 0; n < 100; n++)
        {
            Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Name = 'Name' + n , Charket__WeChatAccount__c = acc.Id, Charket__Lead__c = leadIdMap.get(n));
            followers.add(follower);
        }

        insert followers;

        List<Charket__WeChatFollower__c> insertedFollowers = [select Id from Charket__WeChatFollower__c];
        Map<Integer, String> folowerIdMap = new Map<Integer, String>();

        for(Integer f = 0; f < insertedFollowers.size(); f++)
        {
            folowerIdMap.put(f, insertedFollowers[f].Id);
        }

        Charket__WeChatAgent__c agent = new Charket__WeChatAgent__c(Name = 'Lynn', Charket__User__c = user2.Id);
        insert agent;

        List<Charket__WeChatTranscript__c> transcripts = new List<Charket__WeChatTranscript__c>();

        for(Integer k = 0; k < 100; k++)
        {
            Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c(Charket__WeChatFollower__c = folowerIdMap.get(k), Charket__WeChatAgent__c = agent.Id);
            transcripts.add(transcript);
        }
        
        insert transcripts;

        List<Lead> leadToUpdate = new List<Lead>();
        
        for(Lead lead : [select Id, OwnerId from Lead])
        {
            lead.OwnerId = user1.Id;
            leadToUpdate.add(lead);
        }

        update leadToUpdate;

        List<Charket__WeChatFollower__c> testFollowers = new List<Charket__WeChatFollower__c>();
        
        for(Charket__WeChatFollower__c follower : [select Id, Name from Charket__WeChatFollower__c])
        {
            follower.Name = 'Test';
            testFollowers.add(follower);
        }

        update testFollowers;

        Charket__WeChatAgent__c agentToTest = [select Charket__User__c from Charket__WeChatAgent__c where Id = :agent.Id];
        List<Lead> leadToTest = [select OwnerId from Lead where OwnerId = :agentToTest.Charket__User__c];
        System.assertEquals(100, leadToTest.size());
    }
}