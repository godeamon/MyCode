global with sharing class CustomAgentSelector implements Charket.WeChatAgentSelector
{
    public String customLabelUserId;
    
    public CustomAgentSelector()
    {
        customLabelUserId = System.Label.CustomAgentUserId;
    }

    global String getAgentId(Charket.WeChatAgentSelectorContext context)
    {  
        String userId = setUserId(context.MsgType, context.FollowerOpenId);    
        String accountId = getWeChatAccountId(context.followerOpenId);

        if(String.isNotBlank(userId) && accountId != null)
        {
            List<Charket__WeChatAgent__c> agents = [select Id from Charket__WeChatAgent__c 
                    where Charket__WeChatAccount__c = :accountId
                    and Charket__User__c = :userId];
            
            if(agents.size() > 0)
            {
                return agents[0].Id; 
            }
        }

        return null;
    }

    public String setUserId(String msgType, String followerOpenId)
    {
        String userId = '';
        
        if(msgType == 'Scan')
        {
            List<Charket__WeChatEvent__c> events = [select Charket__WeChatQRCode__r.Charket__WhatId__c, Charket__Type__c
                    from Charket__WeChatEvent__c 
                    where Charket__WeChatFollower__r.Charket__OpenId__c = :followerOpenId
                    order by CreatedDate desc limit 1];
            
            if(events.size() > 0  
                && (events[0].Charket__Type__c == 'Scan' || events[0].Charket__Type__c == 'Subscribe')
                && events[0].Charket__WeChatQRCode__r.Charket__WhatId__c != null)
            {
                List<Campaign> campaigns = [select OwnerId from Campaign where Id = :events[0].Charket__WeChatQRCode__r.Charket__WhatId__c];
                
                if(campaigns.size() > 0)
                {
                    userId = campaigns[0].OwnerId;
                }
            }
        }
        else
        {
            userId = customLabelUserId;
        }

        return userId;
    }

    public String getWeChatAccountId(String followerOpenId)
    {
        List<Charket__WeChatFollower__c> followers = [select Charket__WeChatAccount__c from Charket__WeChatFollower__c
                where Charket__OpenId__c = :followerOpenId]; 

        if(followers.size() > 0)
        {
            return followers[0].Charket__WeChatAccount__c;
        }

        return null;
    }
}