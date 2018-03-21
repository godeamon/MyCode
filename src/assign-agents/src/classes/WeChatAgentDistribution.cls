global without sharing class WeChatAgentDistribution implements Charket.WeChatAgentSelector
{
    public String getAgentId(Charket.WeChatAgentSelectorContext context)
    {
        String wechatAccountId;
        List<String> productFamily = new List<String>();

        if(context.MsgType == 'Scan')
        {
            List<Charket__WeChatQRCode__c> qrCodes = [select Charket__WhatId__c, Charket__WeChatAccount__c
                    from Charket__WeChatQRCode__c where Charket__Ticket__c = :context.MsgContent];

            if(qrCodes.size() > 0 && String.isNotBlank(qrCodes[0].Charket__WhatId__c)
               && String.isNotBlank(qrCodes[0].Charket__WeChatAccount__c)
               && qrCodes[0].Charket__WhatId__c instanceOf Id
               && Id.valueOf(qrCodes[0].Charket__WhatId__c).getSobjectType() == Campaign.sObjectType)
            {
                List<Campaign> campaigns = [select ProductFamily__c from Campaign where Id = :qrCodes[0].Charket__WhatId__c];

                if(campaigns.size() > 0)
                {
                    wechatAccountId = qrCodes[0].Charket__WeChatAccount__c;
                    productFamily.add(campaigns[0].ProductFamily__c);
                }
            }
        }

        // Use the Charket default rule to assgin this follower
        if(wechatAccountId == null)
        {
            List<Charket__WeChatFollower__c> wechatFollowers = [select Charket__WeChatAccount__c from Charket__WeChatFollower__c
                    where Id = :context.FollowerOpenId];

            if(wechatFollowers.size() > 0)
            {
                wechatAccountId = wechatFollowers[0].Charket__WeChatAccount__c;

                // TODO: need to use Schema method to get all product families
                productFamily = new List<String> { null, 'Computer Science', 'Data Science' };
            }
        }

        return getLeastActiveAgentId(wechatAccountId, productFamily);
    }

    private static String getLeastActiveAgentId(String wechatAccountId, List<String> productFamily)
    {
        List<Id> onlineUserIds = new List<Id>();

        for(Charket__WeChatAgent__c agent : [select Charket__User__c from Charket__WeChatAgent__c
               where Charket__IsAway__c = false and Charket__WeChatAccount__c = :wechatAccountId
               and Charket__IsActive__c = true and ProductFamily__c in :productFamily])
        {
            onlineUserIds.add(agent.Charket__User__c);
        }

        if(onlineUserIds.size() > 0)
        {
            List<AggregateResult> agentResults = [select Charket__User__c user, sum(Charket__ChatCount__c) num,
                        min(Charket__LastChatCompletedTime__c)
                    from Charket__WeChatAgent__c
                    where Charket__User__c in :onlineUserIds
                        and Charket__IsAway__c = false
                        and ProductFamily__c in :productFamily
                        and Charket__WeChatAccount__c = :wechatAccountId
                        group by Charket__User__c order by sum(Charket__ChatCount__c),
                        min(Charket__LastChatCompletedTime__c) limit 1];

            if(agentResults.size() > 0)
            {
                String userId = String.valueOf(agentResults[0].get('user'));
                Integer count = Integer.valueOf(agentResults[0].get('num'));
                List<Charket__WeChatAgent__c> assignedAgents = [select Id
                        from Charket__WeChatAgent__c
                        where Charket__User__c = :userId and ProductFamily__c in :productFamily
                            and Charket__WeChatAccount__c = :wechatAccountId
                            and Charket__IsActive__c = true limit 1];

                if(assignedAgents.size() > 0)
                {
                    return assignedAgents[0].Id;
                }
            }
        }
        else
        {
            List<Charket__WeChatAgent__c> offAgents = [select Id from Charket__WeChatAgent__c
                    where Charket__IsAway__c = true and Charket__WeChatAccount__c = :wechatAccountId
                        and Charket__IsActive__c = true and ProductFamily__c in :productFamily
                        order by Charket__ChatCount__c, Charket__LastChatCompletedTime__c limit 1];

            if(offAgents.size() > 0)
            {
                return offAgents[0].Id;
            }
        }

        return null;
    }
}