@isTest
private class LuckyDrawControllerTest
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
    
        Lead lead = new Lead(LastName = 'acme', FirstName = 'acme',
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
        
        Charket__WeChatQRCode__c qrCode = new Charket__WeChatQRCode__c();
        qrCode.Charket__WhatId__c = campaign.Id;
        qrCode.Charket__WeChatAccount__c = account.Id;
        insert qrcode;
        
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
        PageReference pageRef = Page.LuckyDraw;
        Charket__WeChatQRCode__c qrCode = [select Id from Charket__WeChatQRCode__c limit 1];
        pageRef.getParameters().put('qrcodeid', qrCode.Id);
        Test.setCurrentPage(pageRef);
        
        Campaign campaign = [select Id from Campaign limit 1];
        //ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
        Test.startTest();
        LuckyDrawController controller = new LuckyDrawController();
        
        Charket__Log__c log = new Charket__Log__c(Charket__ApexCodeName__c = 'LuckyDraw-' + campaign.Id, Charket__Data__c = '{"subject":"Test-Campaign-ray","roundsArray":[{"roundOrder":1,"prizes":[{"winners":[],"type":"first","status":"ipx","count":"1"},{"winners":[],"type":"third","status":"ip8","count":"2"}],"notificationTemplateId":"aBR9E0000004Cpi","count":2}],"RoundCount":1,"enableTransition":false,"drawStatus":["Sent","Responded"],"currentRound":0}OKCancel');
        insert log;
        controller.validateSettings();
        
        log.Charket__Data__c = '';
        update log;
        controller.validateSettings();
        
        list<LuckyDrawController.Item> items = new list<LuckyDrawController.Item>();
        LuckyDrawController.Item item = new LuckyDrawController.Item();
        item.count = '1';
        item.status = 'test';
        item.type = 'test';
        item.winners = new List<LuckyDrawController.Winner>();
        LuckyDrawController.Winner winner = new LuckyDrawController.Winner();
        winner.Email = '';
        winner.Id = '';
        winner.Name = '';
        winner.selected = true;
        winner.Url = '';
        items.add(item);
        
        LuckyDrawController.Round round = new LuckyDrawController.Round(1);
        round.count = 1;
        round.prizes = items;
        round.roundOrder = 1;
        round.notificationTemplateId = '';
        
        List<LuckyDrawController.Round> rounds = new List<LuckyDrawController.Round>();
        rounds.add(round);
        
        
        controller.Rounds = rounds;
        PageReference pageRe = controller.saveSettings();
        LuckyDrawController.sendNotification(campaign.Id, '');
        
        Charket__WeChatAccount__c account = [select Id from Charket__WeChatAccount__c limit 1];
        List<LuckyDrawController.Member> members = LuckyDrawController.getMembers(campaign.Id, account.Id, new List<String>{'Attended'});
        System.assertEquals(members.size(), 3);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateMemberStatus()
    {
        PageReference pageRef = Page.LuckyDraw;
        Charket__WeChatQRCode__c qrCode = [select Id from Charket__WeChatQRCode__c limit 1];
        pageRef.getParameters().put('qrcodeid', qrCode.Id);
        Test.setCurrentPage(pageRef);
        
        Campaign campaign = [select Id from Campaign limit 1];
        //ApexPages.StandardController sc = new ApexPages.StandardController(campaign);
        Test.startTest();
        LuckyDrawController controller = new LuckyDrawController();
        
        Charket__Log__c log = new Charket__Log__c(Charket__ApexCodeName__c = 'LuckyDraw-' + campaign.Id, Charket__Data__c = '{"subject":"Test-Campaign-ray","roundsArray":[{"roundOrder":1,"prizes":[{"winners":[],"type":"first","status":"ipx","count":"1"},{"winners":[],"type":"third","status":"ip8","count":"2"}],"notificationTemplateId":"aBR9E0000004Cpi","count":2}],"RoundCount":1,"enableTransition":false,"drawStatus":["Sent","Responded"],"currentRound":0}OKCancel');
        insert log;
        
        LuckyDrawController.updateCampaignDescription(campaign.Id, '');
        LuckyDrawController.updateLogData(log.Id, log.Charket__Data__c);
        
        List<String> memberIds = new List<String>();
        for(CampaignMember member : [select Id from CampaignMember])
        {
            memberIds.add(member.Id);
        }
        
        String result = LuckyDrawController.updateMemberStatus(memberIds, 'Lucky Draw - Coffee');
        System.assertEquals(result, '{"ok", true}');
        Test.stopTest();
    }
}