global without sharing class EventCustomHandler extends Charket.CharketEventHandler
{
    global override Charket.WeChatApiMessage onFollowerScan(Charket.WeChatApiEvent.Scan event)
    {
        List<Charket__WeChatQRCode__c> qrCodes = [select Charket__WhatId__c,
                Charket__WeChatResponse__c, Charket__WeChatAccount__c, MoreInfo__c
                from Charket__WeChatQRCode__c
                where Charket__Ticket__c != null and Charket__Ticket__c = :event.Ticket
                and Charket__IsActive__c = true and Charket__WhatId__c != null limit 1];
        if(qrCodes.size() > 0 && String.isNotBlank(qrCodes[0].MoreInfo__c) && qrCodes[0].MoreInfo__c.contains('{'))
        {
            Map<String, Object> moreInfo = (Map<String, Object>) JSON.deserializeUntyped(qrCodes[0].MoreInfo__c);
            
            Boolean isAccpeted = moreInfo.containsKey('IsAccepted') ? (Boolean)moreInfo.get('IsAccepted') : false;
            Boolean isAttended = moreInfo.containsKey('IsAttended') ? (Boolean)moreInfo.get('IsAttended') : false;
            if(isAccpeted || isAttended)
            {
                return dealScanEventToRegister(event, moreInfo, qrCodes[0], isAccpeted);
            }
        }

        return null;
    }

    global override Charket.WeChatApiMessage onNotFollowerScan(Charket.WeChatApiEvent.Scan event)
    {
        return onFollowerScan(event);
    }

    private static Charket.WeChatApiMessage dealScanEventToRegister(Charket.WeChatApiEvent.Scan event, Map<String, Object> moreInfo, Charket__WeChatQRCode__c qrCode, Boolean isAccepted)
    {
        String text = '';
        List<Charket__WeChatTranscript__c> transcripts = [select Id, Charket__Body__c, Charket__FollowerOpenId__c, Charket__WeChatFollower__c,
                 Charket__WeChatFollower__r.Charket__Lead__c, Charket__WeChatFollower__r.Charket__Contact__c,
                Charket__WeChatFollower__r.Charket__OpenId__c, Charket__WeChatFollower__r.Charket__IsFollowing__c,
                Charket__WeChatFollower__r.Charket__Lead__r.Email, Charket__WeChatFollower__r.Charket__Lead__r.FirstName,
                Charket__WeChatFollower__r.Charket__Lead__r.LastName, Charket__WeChatFollower__r.Charket__Contact__r.FirstName,
                Charket__WeChatFollower__r.Charket__Contact__r.Email, Charket__WeChatFollower__r.Charket__Contact__r.LastName,
                Charket__WeChatFollower__r.Charket__Lead__r.Company, Charket__WeChatFollower__r.Charket__Contact__r.Account.Name
                from Charket__WeChatTranscript__c
                where Charket__IsClosed__c = false and Charket__DeliveredMethod__c = 'Direct'
                and Charket__FollowerOpenId__c = :event.FromUserId limit 1];
        if(transcripts.size() > 0)
        {
            String leadId = transcripts[0].Charket__WeChatFollower__r.Charket__Lead__c;
            String contactId = transcripts[0].Charket__WeChatFollower__r.Charket__Contact__c;
            String leadOrContactId = String.isNotBlank(contactId) ? contactId : leadId;
            
            String campaignMemberStatus = moreInfo.containsKey('CampaignMemberStatus') ? (String)moreInfo.get('CampaignMemberStatus') : (isAccepted ? 'Accepted' : 'Attended');
            String hasLabel = isAccepted ? '您已报名成功' : '您已签到成功';
            String messageId = moreInfo.containsKey('MessageId') ? (String)moreInfo.get('MessageId') : null;
            String templateId = moreInfo.containsKey('TemplateId') ? (String)moreInfo.get('TemplateId') : null;
            Boolean isPrint = moreInfo.containsKey('IsPrint') ? (Boolean)moreInfo.get('IsPrint') : false;

            if((leadId != null && transcripts[0].Charket__WeChatFollower__r.Charket__Lead__r.Email != null)
                || (contactId != null && transcripts[0].Charket__WeChatFollower__r.Charket__Contact__r.Email != null))
            {
                if(!transcripts[0].Charket__WeChatFollower__r.Charket__IsFollowing__c)
                {
                    Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
                            Charket__IsFollowing__c = true, Charket__OpenId__c = event.FromUserId);
                    upsert follower Charket__OpenId__c;
                }
                
                String firstName = contactId != null ? transcripts[0].Charket__WeChatFollower__r.Charket__Contact__r.FirstName 
                         : transcripts[0].Charket__WeChatFollower__r.Charket__Lead__r.FirstName;
                String lastName = contactId != null ? transcripts[0].Charket__WeChatFollower__r.Charket__Contact__r.LastName
                         : transcripts[0].Charket__WeChatFollower__r.Charket__Lead__r.LastName;
                String badgeName = String.isNotBlank(firstName) && String.isNotBlank(lastName) ?
                        (WeChatLeadController.containsChineseCharacters(firstName) && WeChatLeadController.containsChineseCharacters(lastName)
                            ? (lastName + firstName) : (firstName + ' ' + lastName)) : null;
                        
                String badgeCompany = contactId != null ? transcripts[0].Charket__WeChatFollower__r.Charket__Contact__r.Account.Name 
                        : transcripts[0].Charket__WeChatFollower__r.Charket__Lead__r.Company;
                        
                
                List<CampaignMember> members = [Select Id, Name, Status, LeadId, ContactId from CampaignMember
                        where CampaignId =: qrCode.Charket__WhatId__c
                        and ((LeadId =: leadId and LeadId != null)
                            or (ContactId =: contactId and ContactId != null))];
                if(members.size() > 0)
                {
                    emptyTranscriptBody(transcripts[0]);

                    if(members[0].Status == campaignMemberStatus)
                    {
                        text = hasLabel;
                        return new Charket.WeChatApiMessage.Text(text);
                    }
                    else
                    {
                        members[0].Status = campaignMemberStatus;
                        update members[0];

                        WeChatLeadController.sendTemplateNotification(members[0].Id, templateId, messageId, leadOrContactId);
                        WeChatLeadController.updateFollowerPrintFields(isPrint, transcripts[0].Charket__WeChatFollower__c, badgeName, badgeCompany, qrCode.Id);
                        return new Charket.WeChatApiMessage.Text('');
                    }
                }
                else
                {
                    emptyTranscriptBody(transcripts[0]);

                    CampaignMember member = new CampaignMember(
                        Status = campaignMemberStatus,
                        CampaignId = qrCode.Charket__WhatId__c,
                        LeadId = leadId,
                        ContactId = contactId
                    );
                    insert member;
                    WeChatLeadController.sendTemplateNotification(member.Id, templateId, messageId, leadOrContactId);
                    WeChatLeadController.updateFollowerPrintFields(isPrint, transcripts[0].Charket__WeChatFollower__c, badgeName, badgeCompany, qrCode.Id);
                    return new Charket.WeChatApiMessage.Text('');
                }
            }
        }
        return null;
    }

    private static void emptyTranscriptBody(Charket__WeChatTranscript__c transcript)
    {
        if(String.isNotBlank(transcript.Charket__Body__c))
        {
            transcript = new Charket__WeChatTranscript__c(
                    Charket__Body__c = null,
                    Charket__FollowerOpenId__c = transcript.Charket__FollowerOpenId__c
            );
            upsert transcript Charket__FollowerOpenId__c;
        }
    }
    
    public class Session
    {
        public Session() {}

        public Session(String sessionSequence, Map<String, String> sessionData)
        {
            this.SessionSequence = sessionSequence;
            this.SessionData = sessionData;
        }

        public String SessionSequence { get; set; }
        public Map<String, String> SessionData { get; set; }
    }
}