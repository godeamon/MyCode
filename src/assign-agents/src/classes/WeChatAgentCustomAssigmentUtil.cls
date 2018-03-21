public class WeChatAgentCustomAssigmentUtil
{
    private static String agentStatus = 'Don\'t Accept Chats';
    private static String university;
    private static String product;
    private static String wechatAccountId;

    public static String getAgentId(Charket__WeChatFollower__c follower)
    {
        try
        {
            university = follower.University__c;
            product = follower.Interested_Product__c;
            
            wechatAccountId = follower.Charket__WeChatAccount__c;

            String query = 'select Id,(select Id, WeChatAgent__c from WeChatAgentAssignments__r where ' +
                        'WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId) from WeChatAgentSkill__c ' +
                        'where University__c = :university and Product__c = :product';
            List<WeChatAgentSkill__c> skills = Database.query(query);

            if(skills.size() == 0)
            {
                query = 'select Id,(select Id, WeChatAgent__c from WeChatAgentAssignments__r where ' +
                        'WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId) from WeChatAgentSkill__c ' +
                        'where University__c = \'其他\' and Product__c = :product';

                List<WeChatAgentSkill__c> otherSkills = Database.query(query);

                if(otherSkills.size() > 0)
                {
                    return getOtherAgents(otherSkills);
                }

                query = 'select Id,(select Id, WeChatAgent__c from WeChatAgentAssignments__r where ' +
                        'WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId) from WeChatAgentSkill__c ' +
                        'where University__c = null and Product__c = null';
                List<WeChatAgentSkill__c> allSkills = Database.query(query);

                if(allSkills.size() > 0)
                {
                    return getAgents(allSkills);
                }
            }

            return getAgents(skills);
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }

        return null;
    }

    private static String getAgents(List<WeChatAgentSkill__c> skills)
    {
        List<String> agentIds = new List<String>();

        for(WeChatAgentSkill__c skill : skills)
        {
            if(skill.WeChatAgentAssignments__r.size() > 0)
            {
                for(Integer i = 0; i < skill.WeChatAgentAssignments__r.size(); i++)
                {
                    agentIds.add(skill.WeChatAgentAssignments__r[i].WeChatAgent__c);
                }
            }
        }

        if(agentIds.size() == 1)
        {
            return agentIds[0];
        }

        if(agentIds.size() > 1)
        {
            system.debug('agentIds::' + agentIds);
            return getLeastActiveAgentId(agentIds, wechatAccountId);
        }

        String query = 'select Id,(select Id, WeChatAgent__c from WeChatAgentAssignments__r where ' +
                'WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId) from WeChatAgentSkill__c ' +
                'where University__c = \'其他\' and Product__c = :product';

        List<WeChatAgentSkill__c> otherSkills = Database.query(query);

        return getOtherAgents(otherSkills);
    }

    private static String getOtherAgents(List<WeChatAgentSkill__c> skills)
    {
        List<String> agentIds = new List<String>();

        for(WeChatAgentSkill__c skill : skills)
        {
            for(Integer i = 0; i < skill.WeChatAgentAssignments__r.size(); i++)
            {
                agentIds.add(skill.WeChatAgentAssignments__r[i].WeChatAgent__c);
            }
        }
        if(agentIds.size() == 1)
        {
            return agentIds[0];
        }

        if(agentIds.size() > 1)
        {
            return getLeastActiveAgentId(agentIds, wechatAccountId);
        }

        return null;
    }

    private static String getLeastActiveAgentId(List<String> agentIds, String wechatAccountId)
    {
        String agentStatus = 'Don\'t Accept Chats';
        String query = 'select Charket__User__c user, sum(Charket__ChatCount__c) num, min(Charket__LastChatCompletedTime__c) '+
                'from Charket__WeChatAgent__c ' +
                'where Charket__IsAway__c = false '+
                'and Charket__WeChatAccount__c = :wechatAccountId and Charket__Status__c != :agentStatus and Id in :agentIds ' +
                'group by Charket__User__c order by sum(Charket__ChatCount__c), min(Charket__LastChatCompletedTime__c) limit 1';

        List<AggregateResult> agentResults = Database.query(query);

        if(agentResults.size() > 0)
        {
            String userId = String.valueOf(agentResults[0].get('user'));

            List<Charket__WeChatAgent__c> assignedAgents = [select Id, Charket__ChatCount__c, Charket__IsAway__c
                    from Charket__WeChatAgent__c
                    where Charket__User__c = :userId
                    and Charket__WeChatAccount__c = :wechatAccountId
                    and Charket__Status__c != 'Don\'t Accept Chats'
                    and Id in :agentIds
                    and Charket__IsActive__c = true
                    order by Charket__ChatCount__c, Charket__LastChatCompletedTime__c limit 1];

            if(assignedAgents.size() > 0)
            {
                return assignedAgents[0].Id;
            }
        }

        if(agentResults.size() == 0)
        {
            query = 'select Charket__User__c user, sum(Charket__ChatCount__c) num, min(Charket__LastChatCompletedTime__c) ' +
                    'from Charket__WeChatAgent__c ' +
                    'where Charket__IsAway__c = true '+
                    'and Charket__WeChatAccount__c = :wechatAccountId and Charket__Status__c != :agentStatus and Id in :agentIds ' +
                    'group by Charket__User__c order by sum(Charket__ChatCount__c), min(Charket__LastChatCompletedTime__c) limit 1';
            agentResults = Database.query(query);

            if(agentResults.size() > 0)
            {
                String userId = String.valueOf(agentResults[0].get('user'));

                List<Charket__WeChatAgent__c> assignedAgents = [select Id, Charket__ChatCount__c, Charket__IsAway__c
                        from Charket__WeChatAgent__c
                        where Charket__User__c = :userId
                        and Charket__WeChatAccount__c = :wechatAccountId
                        and Charket__Status__c != 'Don\'t Accept Chats'
                        and Charket__IsActive__c = true limit 1];

                if(assignedAgents.size() > 0)
                {
                    return assignedAgents[0].Id;
                }
            }
        }

        return null;
    }
}