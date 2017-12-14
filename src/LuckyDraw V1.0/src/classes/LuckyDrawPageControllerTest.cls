@isTest
private class LuckyDrawPageControllerTest
{
    @testSetup
    static void initData()
    {
        Profile sfProfile = [select Id, Name, UserLicenseId, UserType from Profile where Name = 'System Administrator' limit 1];      

        User user = new User(LastName = 'TestUser', Alias = 'll', Email = 'Ll=@meginfo.com',
            UserName = 'Ll=@meginfo.com', CommunityNickname = 'L.L=',
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            ProfileId = sfProfile.Id, LanguageLocaleKey = 'en_US');
        insert user;
    
        Lead lead = new Lead(LastName = 'acme',
                Company = 'acme',
                LeadSource = 'WeChat'
            );
        insert lead;
        
        Contact contact = new Contact(LastName = 'acme1');
        Contact contact1 = new Contact(LastName = 'acme2');
        insert new List<Contact>{contact, contact1};

        Charket__WeChatAccount__c account = new Charket__WeChatAccount__c(
                Name = 'test account',
                Charket__WeChatOriginId__c = 'test123',
                Charket__Type__c = 'subscribe'
            );
        insert account;
        
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
                Charket__OpenId__c = 'test',
                Charket__Lead__c = lead.Id,
                Charket__WeChatAccount__c = account.Id,
                Charket__IsFollowing__c = true
            );
        Charket__WeChatFollower__c follower1 = new Charket__WeChatFollower__c(
                Charket__OpenId__c = 'test1',
                Charket__Contact__c = contact.Id,
                Charket__WeChatAccount__c = account.Id,
                Charket__IsFollowing__c = true
            );
        Charket__WeChatFollower__c follower2 = new Charket__WeChatFollower__c(
                Charket__OpenId__c = 'test2',
                Charket__Contact__c = contact1.Id,
                Charket__WeChatAccount__c = account.Id,
                Charket__IsFollowing__c = true
            );
        insert new List<Charket__WeChatFollower__c>{follower, follower1, follower2};
        
        Campaign campaign = new Campaign(Name = 'TestName', OwnerId = user.Id);
        insert campaign;
        
     	CampaignMemberStatus newStatus = new CampaignMemberStatus(
            CampaignID=campaign.id,
            Label='Attended',
            IsDefault=false,
            HasResponded=true,
            SortOrder=3
        );
        
		insert newStatus;
        
        CampaignMember member = new CampaignMember(CampaignId = campaign.Id, LeadId = lead.Id, Status = 'Attended');
        CampaignMember member1 = new CampaignMember(CampaignId = campaign.Id, ContactId = contact.Id, Status = 'Attended');
        CampaignMember member2 = new CampaignMember(CampaignId = campaign.Id, ContactId = contact1.Id, Status = 'Attended');
        insert new List<CampaignMember>{member, member1, member2};
    }
    
    @isTest
    static void testGetMembers()
    {
        Campaign campaign = [select Id from Campaign limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
        LuckyDrawPageController controller = new LuckyDrawPageController(sc);
        
        Charket__WeChatAccount__c account = [select Id from Charket__WeChatAccount__c limit 1];
        List<LuckyDrawPageController.Member> members = LuckyDrawPageController.getMembers(campaign.Id, account.Id, new List<String>{'Attended'});
        System.assertEquals(members.size(), 3);
    }
    
    @isTest
    static void testUpdateMemberStatus()
    {
        Campaign campaign = [select Id from Campaign limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
        LuckyDrawPageController controller = new LuckyDrawPageController(sc);
        
        List<String> memberIds = new List<String>();
        for(CampaignMember member : [select Id from CampaignMember])
        {
            memberIds.add(member.Id);
        }
        
        String result = LuckyDrawPageController.updateMemberStatus(memberIds, 'Lucky Draw - Coffee');
        System.assertEquals(result, '{"ok", true}');
    }
}