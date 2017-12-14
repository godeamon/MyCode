public class LuckyDrawPageController
{
    private final Campaign camp;

    public LuckyDrawPageController (ApexPages.StandardController stdcontroller)
    {
        this.camp = (Campaign)stdcontroller.getRecord();
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
    public static String updateMemberStatus(List<String> memberIds, String status)
    {
        system.debug(memberIds);
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
        
        return '{"ok", true}';
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
        
        return '{"ok", true}';
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
}