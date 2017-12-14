public class LuckyDrawController
{
    private List<Charket__WeChatQRCode__c> qrCodes;

    public LuckyDrawController ()
    {
        qrCodeId = ApexPages.currentPage().getParameters().get('qrcodeid');
        qrCodes = [select Charket__WhatId__c, Charket__WeChatAccount__c from Charket__WeChatQRCode__c where Id = :qrCodeId limit 1];
        currentRound = 1;
        if(qrCodes.size() > 0)
        {
            accountId = qrCodes[0].Charket__WeChatAccount__c;
            Campaign camp = [select Id, Name from Campaign where Id = :qrCodes[0].Charket__WhatId__c];
            CampaignName = camp.Name;
            campaignId = camp.Id;
        }
        NotificationTemplatePrefix = getNotificationTemplatePrefix();
    }
    
    public String qrCodeId { get; set; }
    public String campaignId { get; set; }
    public String accountId { get; set; }
    public String logId { get; set; }
    public Boolean enableTransition { get; set; }
    public String CampaignName { get; set; }
    public Integer RoundCount { get; set; }

    public List<Round> Rounds { get; set; }
    public String LuckyDrawSettings { get; set; }
    public List<Status> StatusShow { get; set; }
    public String NotificationTemplatePrefix { get; set; }
    public Boolean HasSettings { get; set; }
    public Integer currentRound {get; set;}
    //public Boolean IsError { get; set; }
    
    public void validateSettings()
    {
        //IsError = false;
        String logName = 'LuckyDraw-' + campaignId;
        Rounds = new List<Round>();
        List<Charket__Log__c> logs = [select Id, Name, Charket__Data__c from Charket__Log__c where Charket__ApexCodeName__c = :logName limit 1];
        
        if(logs.size() > 0 && String.isNotBlank(logs[0].Charket__Data__c))
        {
            logId = logs[0].Id;
            try
            {
                LuckyDrawController.GenarateJsonWrapper genarateJsonWrapper = (LuckyDrawController.GenarateJsonWrapper)JSON.deserialize(logs[0].Charket__Data__c, LuckyDrawController.GenarateJsonWrapper.class);
                Rounds = genarateJsonWrapper.roundsArray;
                enableTransition = genarateJsonWrapper.enableTransition;
                RoundCount = genarateJsonWrapper.roundsArray.size();
                currentRound = genarateJsonWrapper.currentRound;
                
                StatusShow = getCampaignmemberStatus();
                for(String status : genarateJsonWrapper.drawStatus)
                {
                    for(Status s : StatusShow)
                    {
                        if(status.equals(s.Status))
                        {
                            s.IsAllow = true;
                            break;
                        }
                    }
                }

                if(String.isNotBlank(genarateJsonWrapper.subject))
                {
                    CampaignName = genarateJsonWrapper.subject;
                }

                HasSettings = true;
                LuckyDrawSettings = logs[0].Charket__Data__c;
            }
            catch(exception e)
            {
                initSettings();
            }
        }
        else 
        {
            initSettings();
        }
    }
    
    public void initRounds()
    {
        //Rounds = new List<Round>();
        if(RoundCount < 1)
        {
            RoundCount = 1;
        }

        Integer roundsSize = 0;
        if(Rounds.size() > 0)
        {
            roundsSize = Rounds.size();
        }
        if(RoundCount >= roundsSize)
        {
            for(Integer i = 0; i < RoundCount - roundsSize; i++)
            {
                Rounds.add(new Round(i + 1));
            }
        }
        else
        {
            for(Integer i = 0; i < roundsSize - RoundCount; i++)
            {
                Rounds.remove(Rounds.size() - 1);
            }
        }
        
        initPrizes();
    }
    
    public void initPrizes()
    {
        for(Integer j = 0; j < Rounds.size(); j++)
        {
            if(j >= CurrentRound - 1)
            {

                Integer prizesSize = Rounds[j].prizes.size();
                if(Rounds[j].count < 1)
                {
                    Rounds[j].count = 1;
                }
                
                if(Rounds[j].count >= Rounds[j].prizes.size())
                {
                    for(Integer i = 0; i < Rounds[j].count - prizesSize; i++)
                    {
                        Rounds[j].prizes.add(new Item());
                    }
                }
                else
                {
                    for(Integer i = 0; i < prizesSize - Rounds[j].count; i++)
                    {
                        Rounds[j].prizes.remove(Rounds[j].prizes.size() - 1);
                    }
                } 
            }
        }
    }

    public PageReference editSettings() 
    {
        validateSettings();
        HasSettings = false;
        return null;
    }
    
    public PageReference saveSettings() // saveSettings
    {
        LuckyDrawController.genarateJsonWrapper wrapper = new LuckyDrawController.genarateJsonWrapper();
        wrapper.subject = CampaignName;
        wrapper.currentRound = currentRound;
        wrapper.enableTransition = enableTransition;
        for(Status status : StatusShow)
        {
           if(status.IsAllow)
           {
               wrapper.drawStatus.add(status.Status);
           }
        }
        
        for(Integer i = 0; i < Rounds.size(); i++)
        {
            Rounds[i].roundOrder = i + 1;
        }

        wrapper.roundsArray = Rounds;
        wrapper.RoundCount = RoundCount;

        LuckyDrawSettings = JSON.serialize(wrapper);
        String logName = 'LuckyDraw-' + campaignId;
        system.debug(logName);
        List<Charket__Log__c> logs = [select Name, Charket__Data__c from Charket__Log__c where Charket__ApexCodeName__c = :logName limit 1];
        if(logs.size() > 0)
        {
            try
            {
                logs[0].Charket__Data__c = JSON.serialize(wrapper);
                logId = logs[0].Id;
                update logs;
            }
            catch(Exception ex)
            {
                system.debug(ex.getMessage() + ex.getLineNumber());
            }
        }
        else
        {
            Charket__Log__c log = new Charket__Log__c();
            log.Charket__ApexCodeName__c = logName;
            log.Charket__Data__c = JSON.serialize(wrapper);
            try
            {
                insert log;
                logId = log.Id;
            }
            catch(Exception ex)
            {
                system.debug(ex.getMessage() + ex.getLineNumber());
            }
        }
        
        if(qrCodes.size() > 0)
        {
            generateStatus(Rounds);
        }
        HasSettings = true;
        
        PageReference pageRef = Page.LuckyDraw;
        pageRef.getParameters().put('qrcodeid', qrCodeId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void reset()
    {
        for(Integer i = 0; i < Rounds.size(); i++)
        {
            if(i >= CurrentRound - 1)
            {
                for(Item item : Rounds[i].prizes)
                {
                    item.type = '';
                    item.count = '';
                    item.status = '';
                }
            }
        }
    }

    @RemoteAction
    public static List<Member> getMembers(String campaignId, String accountId, List<String> drawStatus)
    {
        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        Map<Id, CampaignMember> leadOrContactIdToMamber = new Map<Id, CampaignMember>(); 
        for (CampaignMember member: [select Id, Name, Status, Email, ContactId, LeadId, Lead.IsConverted from CampaignMember 
                where CampaignId = :campaignId and Status in :drawStatus])
        {
            if(String.isNotBlank(member.LeadId) && member.Lead.IsConverted == false)
            {
                leadIds.add(member.LeadId);
                leadOrContactIdToMamber.put(member.LeadId, member);
            }
            else if(String.isNotBlank(member.ContactId))
            {
                contactIds.add(member.ContactId);
                leadOrContactIdToMamber.put(member.ContactId, member);
            }
        }
        List<Member> membersResult = new List<Member>();
        for(Charket__WeChatFollower__c follower: [select Id, Charket__WeChatProfilePhotoUrl__c, Charket__ProfilePhotoUrl__c, Charket__Contact__c, Charket__Lead__c 
                from Charket__WeChatFollower__c 
                where Charket__WeChatAccount__c = :accountId and (Charket__Contact__c in :contactIds or Charket__Lead__c in :leadIds)])
        {
            Member member;
            if(String.isNotBlank(follower.Charket__Contact__c))
            {
                member = new Member(leadOrContactIdToMamber.get(follower.Charket__Contact__c), follower.Charket__WeChatProfilePhotoUrl__c);
                membersResult.add(member);
            }
            else if(String.isNotBlank(follower.Charket__Lead__c))
            {
                member = new Member(leadOrContactIdToMamber.get(follower.Charket__Lead__c), follower.Charket__WeChatProfilePhotoUrl__c);
                membersResult.add(member);
            }
        }
        return membersResult;
    }
    
    @RemoteAction
    public static String sendNotification(String campaignMemberId, String notificationId)
    {
        if(String.isNotBlank(notificationId) && Id.valueOf(notificationId).getSobjectType() == Charket__WeChatNotificationTemplate__c.sObjectType)
        {
            List<CampaignMember> members =  [select LeadOrContactId from CampaignMember where Id = :campaignMemberId];
            
            if(members.size() > 0)
            {
                System.debug(members);
                System.debug(notificationId);
                Charket.CharketSendWeChatNotificationAction.SendTemplateNotificationRequest templateRequest = new Charket.CharketSendWeChatNotificationAction.SendTemplateNotificationRequest();
                templateRequest.objectId = campaignMemberId;
                templateRequest.templateId = notificationId;
                templateRequest.whoId = members[0].LeadOrContactId;
                List<Charket.CharketSendWeChatNotificationAction.SendTemplateNotificationRequest> templateRequests = new List<Charket.CharketSendWeChatNotificationAction.SendTemplateNotificationRequest>();
                templateRequests.add(templateRequest);
                Charket.CharketSendWeChatNotificationAction.sendTemplateNotification(templateRequests);
            }
        }
        
        return '';
    }
    
    @RemoteAction
    public static String updateMemberStatus(List<String> memberIds, String status)
    {
        system.debug(memberIds);
        system.debug(status);
        List<CampaignMember> members = new List<CampaignMember>();
        try
        {
            for(String memberId : memberIds)
            {
                CampaignMember member = new CampaignMember(Id = memberId, Status = status);
                members.add(member);
            }
            
            update members;
        }
        catch(Exception ex)
        {
            return '{"ok", false, "error", ex.getMessage()}';
        }
        
        return '{"ok1", true}';
    }

    @RemoteAction
    public static String updateCampaignDescription(String campaignId, String description)
    {
        try
        {
            Campaign c = new Campaign(Id = campaignId, Description = description);
            update c;
        }
        catch(Exception ex)
        {
            return '{"ok", false, "error", ex.getMessage()}';
        }
        
        return '{"ok2", true}';
    }

    @RemoteAction
    public static String updateLogData(String logId, String data)
    {
        system.debug('logId:'+logId);
        system.debug('data:'+data);
        try
        {
            Charket__Log__c l = new Charket__Log__c(Id = logId, Charket__Data__c = data);
            update l;
        }
        catch(Exception ex)
        {
            system.debug('ex.getMessage():'+ex.getMessage());
            return '{"ok", false, "error", ex.getMessage()}';
        }
        
        return '{"ok3", true}';
    }

    private void generateStatus(List<Round> Rounds)
    {
        List<CampaignMemberStatus> statuses = new List<CampaignMemberStatus>();
        if(Rounds.size() > 0)
        {
            system.debug('Rounds:'+Rounds);
            for(Round round : Rounds)
            {
                for(Item item : round.prizes)
                {
                    Boolean founded = false;
                    for(Status s : StatusShow)
                    {
                        if(String.isNotBlank(item.status) && item.status.equals(s.Status))
                        {
                            founded = true;
                        }
                    }
                    if(!founded && String.isNotBlank(item.status))
                    {
                        statuses.add(new CampaignMemberStatus(Label = item.status, CampaignId = campaignId));
                    }
                }
            }
            if(statuses.size() > 0)
            {
                try
                {
                    upsert statuses;
                }
                catch(Exception ex)
                {
                    
                }
                
            }
        }
        
    }
    
    private List<Status> getCampaignmemberStatus ()
    {
        List<Status> result = new List<Status>();

        if(qrCodes.size() > 0 && String.isNotBlank(qrCodes[0].Charket__WhatId__c))
        {
            Schema.SObjectType sObjectType = ((Id)qrCodes[0].Charket__WhatId__c).getSobjectType();
            
            if(sObjectType == Schema.Campaign.SObjectType)
            {
                List<CampaignMemberStatus> CampaignMemberStatusList = [select Id, Label from CampaignMemberStatus where CampaignId = :qrCodes[0].Charket__WhatId__c and Label != null];
                if(CampaignMemberStatusList.size() > 0)
                {
                    for(CampaignMemberStatus campaignMemberStatus : CampaignMemberStatusList)
                    {
                        result.add(new Status(campaignMemberStatus.Label, false));
                    }
                }
            }
        }

        return result;
    }
    
    private String getNotificationTemplatePrefix()
    {
        List<Charket__WeChatNotificationTemplate__c> notificationTemplates = [select id from Charket__WeChatNotificationTemplate__c limit 1];
        if(notificationTemplates.size() > 0)
        {
            return ((String)notificationTemplates[0].Id).subString(0, 3); //NotificationTemplatePrefix
        }

        return '';
    }
    
    private void initSettings()
    {
        StatusShow = getCampaignmemberStatus();
                
        RoundCount = 1;
        initRounds();
        
        HasSettings = false;
    }
    
    public class Member
    {
        public Member(CampaignMember campaignMember, String url)
        {
            this.Id = campaignMember.Id;
            this.Name = campaignMember.Name;
            this.Url = url;
            this.Email = campaignMember.Email;
        }
        
        public String Id { get; set; }
        public String Name { get; set; }
        public String Url { get; set; }
        public String Email { get; set; }
    }

    public class Round
    {
        public Round(Integer roundOrder)
        {
            count = 1;
            this.roundOrder = roundOrder;
            prizes = new List<Item>();
        }

        //public String notificationTemplateId { get; set; }
        //public String notificationTemplateName { get; set; }
        public Integer count { get; set; }
        public List<Item> prizes { get; set; }
        public Integer roundOrder { get; set; }
    }
    
    public class Status
    {
        public Status(String status, Boolean IsAllow)
        {
            this.Status = status;
            this.IsAllow = IsAllow;
        }

        public String Status { get; set; }
        public Boolean IsAllow { get; set;}
    }
    

    public class Item
    {
        public String type { get; set; }
        public String count { get; set; }
        public String status { get; set; }
        public List<Winner> winners { get; set; }
        public String notificationTemplateId { get; set; }
        public String notificationTemplateName { get; set; }
        public Item()
        {
            winners = new List<Winner>();
        }
    }

    public class Winner
    {
        public String Email { get; set; }
        public String Id { get; set; }
        public String Name { get; set; }
        public String Url { get; set; }
        public Boolean selected { get; set; }
    }
    
    public class GenarateJsonWrapper
    {
        public List<Round> roundsArray { get; set; }
        public Integer RoundCount { get; set; }
        public List<String> drawStatus { get; set; }
        public String subject { get; set; }
        public Integer currentRound { get; set; }
        public Boolean enableTransition { get; set; }
        public GenarateJsonWrapper()
        {
            drawStatus = new List<String>();
        }
    }
}