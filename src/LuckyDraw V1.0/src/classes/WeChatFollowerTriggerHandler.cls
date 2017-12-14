public with sharing class WeChatFollowerTriggerHandler extends TriggerHandler
{
    public final static String SITE_GUEST_USER = 'PID_Guest_User';
    private Map<Id, Charket__WeChatFollower__c> newFollowerMap;
    
    public WeChatFollowerTriggerHandler()
    {
        this.newFollowerMap = (Map<Id, Charket__WeChatFollower__c>) Trigger.newMap;
    }
    
    public override void afterInsert()
    {
        try
        {
            assignLeadOwner(newFollowerMap.keySet());
        }
        catch(Exception ex)
        {
            insert (new Charket__Log__c(Charket__ApexCodeName__c = 'WeChatFollowerTriggerHandler', Charket__Message__c = ex.getMessage()));
        }
    }

    public override void afterUpdate() 
    {
        try
        {
            assignLeadOwner(newFollowerMap.keySet());
        }
        catch(Exception ex)
        {
            insert (new Charket__Log__c(Charket__ApexCodeName__c = 'WeChatFollowerTriggerHandler', Charket__Message__c = ex.getMessage()));
        }
    }

    public static void assignLeadOwner(Set<Id> followerIds)
    {
        List<Charket__WeChatFollower__c> followers = filterFollowers(followerIds);
        
        if(followers.isEmpty())
        {
            return;
        }
        
        Map<String, String> followerIdToLeadId = new Map<String, String>();
        Map<String, String> followerIdToUserId = new Map<String, String>();
        
        for(Charket__WeChatFollower__c follower : followers)
        {
            if(follower.Charket__WeChatTranscripts__r.size() > 0)
            {
                followerIdToLeadId.put(follower.Id, follower.Charket__Lead__c);
                followerIdToUserId.put(follower.Id, follower.Charket__WeChatTranscripts__r[0].Charket__WeChatAgent__r.Charket__User__c);
            }
        }

        List<Lead> leadsToUpdate = new List<Lead>();

        for(Id followerId : followerIdToUserId.keySet())
        {
            Lead lead = new Lead(Id = followerIdToLeadId.get(followerId), OwnerId = followerIdToUserId.get(followerId));
            leadsToUpdate.add(lead);
        }
        
        try
        {
            update leadsToUpdate;
        }
        catch(Exception ex) {}
    }

    public static List<Charket__WeChatFollower__c> filterFollowers(Set<Id> followerIds)
    {
        List<Charket__WeChatFollower__c> followers = [select Charket__Lead__r.Owner.Profile.UserLicense.LicenseDefinitionKey, 
                Charket__Lead__c, (select Id, Charket__WeChatAgent__r.Charket__User__c
                from Charket__WeChatTranscripts__r where Charket__WeChatAgent__c != null order by CreatedDate desc limit 1) 
                from Charket__WeChatFollower__c where Id in :followerIds
                and Charket__Lead__r.Owner.Profile.UserLicense.LicenseDefinitionKey = :SITE_GUEST_USER]; 

        return followers;
    }
}