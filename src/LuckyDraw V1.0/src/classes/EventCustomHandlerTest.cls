@isTest
private class EventCustomHandlerTest
{
    @isTest
    static void onFollowerScanTest()
    {
        Charket.WeChatApiEvent.Scan scan = new Charket.WeChatApiEvent.Scan();
        scan.FromUserId = 'test user id';
        scan.Ticket = 'test ticket';
        scan.ToUserId = 'test to user Id';
        
        Lead lead = new Lead(LastName = 'acme',
                Company = 'acme',
                LeadSource = 'WeChat',
                Email = 'acme@acme.com'
            );
        insert lead;

        Charket__WeChatAccount__c account = new Charket__WeChatAccount__c(
                Name = 'test account',
                Charket__WeChatOriginId__c = 'test to user id',
                Charket__Type__c = 'subscribe'
            );
        insert account;
        
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
                Charket__OpenId__c = 'test user id',
                Charket__Lead__c = lead.Id,
                Charket__WeChatAccount__c = account.Id,
                Charket__IsFollowing__c = true
            );
        insert follower;

        Campaign campaign = new Campaign(
                Name = 'test',
                IsActive = true
            );
        insert campaign;
        
        CampaignMember member = new CampaignMember(CampaignId = campaign.Id, LeadId = lead.Id, Status = 'Attended');
        insert member;

        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(
            Charket__Ticket__c = 'test ticket',
            Charket__IsActive__c = true,
            Charket__WhatId__c = campaign.Id,
            Charket__CampaignMemberStatus__c = member.Status,
            MoreInfo__c = '{"IsAttended":true,"CampaignMemberStatus":"Attended","MessageId":null,"IsPrint":true,"FormBanner":"abc.jpg","FormTitle":"Charket"}'
        );
        insert qrcode;
        
        Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c(
            Charket__DeliveredMethod__c = 'Direct',
            Charket__FollowerOpenId__c = 'test user id',
            Charket__StartedBy__c = 'Follower',
            Charket__UnreadCount__c = 1,
            Charket__WeChatFollower__c = follower.Id,
            Charket__IsActive__c = true,
            Charket__Status__c = 'New'
        );
        
        insert transcript;

        Test.startTest();
        EventCustomHandler handler = new EventCustomHandler();
        handler.onFollowerScan(scan);
        Charket.WeChatApiMessage.Text text = (Charket.WeChatApiMessage.Text)handler.onFollowerScan(scan);
        Test.stopTest();
    }
    
    @isTest
    static void notFollowerScanTest()
    {
        Charket.WeChatApiEvent.Scan scan = new Charket.WeChatApiEvent.Scan();
        scan.FromUserId = 'test user id';
        scan.Ticket = 'test ticket';
        scan.ToUserId = 'test to user Id';
        
        Lead lead = new Lead(LastName = 'acme',
                Company = 'acme',
                LeadSource = 'WeChat',
                Email = 'acme@acme.com'
            );
        insert lead;

        Charket__WeChatAccount__c account = new Charket__WeChatAccount__c(
                Name = 'test account',
                Charket__WeChatOriginId__c = 'test to user id',
                Charket__Type__c = 'subscribe'
            );
        insert account;
        
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
                Charket__OpenId__c = 'test user id',
                Charket__Lead__c = lead.Id,
                Charket__WeChatAccount__c = account.Id,
                Charket__IsFollowing__c = false
            );
        insert follower;

        Campaign campaign = new Campaign(
                Name = 'test',
                IsActive = true
            );
        insert campaign;
        
        CampaignMember member = new CampaignMember(CampaignId = campaign.Id, LeadId = lead.Id, Status = 'Attended');
        insert member;

        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(
            Charket__Ticket__c = 'test ticket',
            Charket__IsActive__c = true,
            Charket__WhatId__c = campaign.Id,
            Charket__CampaignMemberStatus__c = member.Status,
            MoreInfo__c = '{"IsAttended":true,"CampaignMemberStatus":"Attended","MessageId":null,"IsPrint":true,"FormBanner":"abc.jpg","FormTitle":"Charket"}'
        );
        insert qrcode;
        
        Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c(
            Charket__DeliveredMethod__c = 'Direct',
            Charket__FollowerOpenId__c = 'test user id',
            Charket__StartedBy__c = 'Follower',
            Charket__UnreadCount__c = 1,
            Charket__WeChatFollower__c = follower.Id,
            Charket__IsActive__c = true,
            Charket__Status__c = 'New',
            Charket__Body__c = 'abcd'
        );
        
        insert transcript;
        
        Test.startTest();
        EventCustomHandler handler = new EventCustomHandler();
        handler.onNotFollowerScan(scan);
        Charket.WeChatApiMessage.Text text = (Charket.WeChatApiMessage.Text)handler.onNotFollowerScan(scan);
        Test.stopTest();
        
        List<Charket__WeChatTranscript__c> transcripts = [select Charket__Body__c from Charket__WeChatTranscript__c];
        System.assertEquals(transcripts[0].Charket__Body__c, null);
    }
    
    @isTest
    static void testNoMemberCampaign()
    {
        Charket.WeChatApiEvent.Scan scan = new Charket.WeChatApiEvent.Scan();
        scan.FromUserId = 'test user id';
        scan.Ticket = 'test ticket';
        scan.ToUserId = 'test to user Id';
        
        Contact contact = new Contact(LastName = 'acme', Email = 'acme@acme.com');
        insert contact;

        Charket__WeChatAccount__c account = new Charket__WeChatAccount__c(
            Name = 'test account',
            Charket__WeChatOriginId__c = 'test to user id',
            Charket__Type__c = 'subscribe'
        );
        insert account;
        
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
                Charket__OpenId__c = 'test user id',
                Charket__Contact__c = contact.Id,
                Charket__WeChatAccount__c = account.Id,
                Charket__IsFollowing__c = true
            );
        insert follower;

        Campaign campaign = new Campaign(
            Name = 'test',
            IsActive = true
        );
        insert campaign;
        
        Campaign campaign1 = new Campaign(
            Name = 'test1',
            IsActive = true
        );
        insert campaign1;
        
        CampaignMember member = new CampaignMember(CampaignId = campaign1.Id, ContactId = contact.Id, Status = 'Attended');
        insert member;

        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(
            Charket__Ticket__c = 'test ticket',
            Charket__IsActive__c = true,
            Charket__WhatId__c = campaign.Id,
            Charket__CampaignMemberStatus__c = member.Status,
            MoreInfo__c = '{"IsAttended":true,"CampaignMemberStatus":"Attended","MessageId":null,"IsPrint":true,"FormBanner":"abc.jpg","FormTitle":"Charket"}'
        );
        insert qrcode;
        
        Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c(
            Charket__DeliveredMethod__c = 'Direct',
            Charket__FollowerOpenId__c = 'test user id',
            Charket__StartedBy__c = 'Follower',
            Charket__UnreadCount__c = 1,
            Charket__WeChatFollower__c = follower.Id,
            Charket__IsActive__c = true,
            Charket__Status__c = 'New'
        );
        
        insert transcript;

        Test.startTest();
        EventCustomHandler handler = new EventCustomHandler();
        handler.onFollowerScan(scan);
        Charket.WeChatApiMessage.Text text = (Charket.WeChatApiMessage.Text)handler.onFollowerScan(scan);
        Test.stopTest();
        
        List<CampaignMember> members = [select CampaignId from CampaignMember];
        System.assertEquals(members[1].CampaignId, campaign.Id);
    }
}