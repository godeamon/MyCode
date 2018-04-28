public class WeChatAgentCustomAssigmentUtil
{
    private static String agentStatus = 'Don\'t Accept Chats';
    private static String university;
    private static String product;
    private static String wechatAccountId;
    private static Charket__WeChatFollower__c newFollower;

    public static String getAgentId(Charket__WeChatFollower__c follower)
    {
        try
        {
            newFollower = follower;
            wechatAccountId = follower.Charket__WeChatAccount__c;

            List<Charket__WeChatAccount__c> wechatAccounts = [select Id from Charket__WeChatAccount__c where 
                    id =:wechatAccountId and Charket__WeChatOriginId__c = 'gh_e8c4857297b0' limit 1];

            if(wechatAccounts.size() == 0)
            {
                //return getAgentIdNotMatchOriginId(wechatAccountId);
            }

            university = follower.University__c;
            product = follower.Interested_Product__c;

            String query = 'select Id, (select Id, WeChatAgent__c from WeChatAgentAssignments__r where ' +
                    'WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId) from WeChatAgentSkill__c ' +
                    'where University__c = :university and Product__c = :product';
            List<WeChatAgentSkill__c> skills = Database.query(query);

            if(skills.size() == 0)
            {
                query = 'select Id, (select Id, WeChatAgent__c from WeChatAgentAssignments__r where ' +
                        'WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId) from WeChatAgentSkill__c ' +
                        'where University__c = \'其他\' and Product__c = :product';
                List<WeChatAgentSkill__c> otherSkills = Database.query(query);

                if(otherSkills.size() > 0)
                {
                    return getOtherAgents(otherSkills);
                }

                query = 'select Id, (select Id, WeChatAgent__c from WeChatAgentAssignments__r where ' +
                        'WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId) from WeChatAgentSkill__c ' +
                        'where University__c = null and Product__c = null';
                List<WeChatAgentSkill__c> adminSkills = Database.query(query);

                if(adminSkills.size() > 0)
                {
                    return getAgents(adminSkills);
                }
            }

            return getAgents(skills);
        }
        catch(Exception e)
        {
            return null;
        }
    }

    public static void updateFollowerOwner(List<Charket__WeChatFollower__c> followers)
    {
        Map<String, String> followerIdToUP = new Map<String, String>();
        Map<String, Charket__WeChatFollower__c> followerIdTofollower = new Map<String, Charket__WeChatFollower__c>();
        Set<String> universities = new Set<String>();
        Set<String> products = new Set<String>();

        for(Charket__WeChatFollower__c follower : followers)
        {
            system.debug('followerId:::' + follower.Id);
            followerIdTofollower.put(follower.Id, follower);
            system.debug('followerIdTofollowerMap1:::' + followerIdTofollower);
            universities.add(follower.University__c);
            products.add(follower.Interested_Product__c);
            if(String.isNotEmpty(follower.University__c))
            {
                followerIdToUP.put(follower.Id, follower.University__c + follower.Interested_Product__c);
            }
            else
            {
                followerIdToUP.put(follower.Id, '其他' + follower.Interested_Product__c);
            }
        }
        universities.add('其他');
        List<WeChatAgentSkill__c> skills = [select Id, University__c, Product__c,
                (select Id, WeChatAgent__c from WeChatAgentAssignments__r) from WeChatAgentSkill__c
                where Product__c in :products and University__c in :universities];

        List<String> agentIds = new List<String>();
        Map<String, List<String>> skillIdToagentIds = new Map<String, List<String>>();

        for(WeChatAgentSkill__c skill : skills)
        {
            List<String> agentIdsOfOneSkill = new List<String>();
            for(WeChatAgentAssignment__c assignment : skill.WeChatAgentAssignments__r)
            {
                agentIds.add(assignment.WeChatAgent__c);
                agentIdsOfOneSkill.add(assignment.WeChatAgent__c);
            }
            skillIdToagentIds.put(skill.Id, agentIdsOfOneSkill);
        }

        List<Charket__WeChatAgent__c> wechatAgnets = [select Id, Charket__WeChatAccount__c, Charket__User__c
                from Charket__WeChatAgent__c where Id in :agentIds];

        Map<String, List<String>> skillIdToAgentOwnerId = new Map<String, List<String>>();

        Map<String, Charket__WeChatAgent__c> agentIdToAgent = new Map<String, Charket__WeChatAgent__c>();
        for(Charket__WeChatAgent__c agent : wechatAgnets)
        {
            agentIdToAgent.put(agent.Id, agent);
        }

        Map<String, String> followerIdToSkillId = new Map<String, String>();

        for(WeChatAgentSkill__c skill : skills)
        {
            for(String followerId : followerIdToUP.keySet())
            {
                if(followerIdToUP.get(followerId) != null && 
                    (followerIdToUP.get(followerId)).equals(skill.University__c + skill.Product__c))
                {
                    followerIdToSkillId.put(followerId, skill.Id);
                }
            }
        }

        Map<String, String> followerToOwnerId = new Map<String, String>();

        for(String followerId : followerIdToSkillId.keySet())
        {
            String skillId = followerIdToSkillId.get(followerId);
            if(skillIdToagentIds.get(skillId) != null)
            {
                for(String agentId : skillIdToagentIds.get(skillId))
                {
                    if(agentIdToAgent.get(agentId) != null 
                        && followerIdTofollower.get(followerId) != null
                        && agentIdToAgent.get(agentId).Charket__WeChatAccount__c.equals(
                            followerIdTofollower.get(followerId).Charket__WeChatAccount__c))
                    {
                        followerToOwnerId.put(followerId, agentIdToAgent.get(agentId).Charket__User__c);
                    }
                }
            }
        }

        system.debug('followerIdTofollower-Mappp:::' + followerIdTofollower);
        Set<String> otherFollowerIds = new Set<String>();
        for(String followerId : followerIdTofollower.keySet())
        {
            otherFollowerIds.add(followerId);
        }
        system.debug('otherFollowerIds-Set:::' + otherFollowerIds);
        otherFollowerIds.removeAll(followerToOwnerId.keySet());
        system.debug('followerIdTofollower-Mapp:::' + followerIdTofollower);
        if(otherFollowerIds.size() > 0)
        {
            List<WeChatAgentSkill__c> otherskills = [select Id, Product__c,
                    (select Id, WeChatAgent__c from WeChatAgentAssignments__r)
                    from WeChatAgentSkill__c where Product__c in :products
                    and University__c = '其他'];

            Map<String, String> otherFollowerIdToSkillId = new Map<String, String>();

            for(WeChatAgentSkill__c skill : otherskills)
            {
                for(String followerId : otherFollowerIds)
                {
                    if(followerIdTofollower.get(followerId) != null
                        && (followerIdTofollower.get(followerId).Interested_Product__c).equals(skill.Product__c))
                    {
                        otherFollowerIdToSkillId.put(followerId, skill.Id);
                    }
                }
            }

            List<String> otherAgentIds = new List<String>();
            Map<String, List<String>> otherSkillIdToagentIds = new Map<String, List<String>>();

            for(WeChatAgentSkill__c skill : otherskills)
            {
                List<String> agentIdsOfOneSkill = new List<String>();
                for(WeChatAgentAssignment__c assignment : skill.WeChatAgentAssignments__r)
                {
                    otherAgentIds.add(assignment.WeChatAgent__c);
                    agentIdsOfOneSkill.add(assignment.WeChatAgent__c);
                }
                otherSkillIdToagentIds.put(skill.Id, agentIdsOfOneSkill);
            }

            Map<String, String> otherFollowerToOwnerId = new Map<String, String>();

            for(String followerId : otherFollowerIds)
            {
                String skillId = otherFollowerIdToSkillId.get(followerId);
                if(otherSkillIdToagentIds.get(skillId) != null)
                {
                    for(String agentId : otherSkillIdToagentIds.get(skillId))
                    {
                        system.debug('agentId:::' + agentId);
                        system.debug('agentIdToAgent:::' + agentIdToAgent);
                        system.debug('followerIdTofollower01:::' + followerIdTofollower);
                        if(agentIdToAgent.get(agentId) != null && followerIdTofollower.get(followerId) != null
                            && agentIdToAgent.get(agentId).Charket__WeChatAccount__c != null
                            && agentIdToAgent.get(agentId).Charket__WeChatAccount__c.equals(
                                followerIdTofollower.get(followerId).Charket__WeChatAccount__c))
                        {
                            otherFollowerToOwnerId.put(followerId, agentIdToAgent.get(agentId).Charket__User__c);
                        }
                    }
                }
                
            }

            for(String followerId : otherFollowerToOwnerId.keySet())
            {
                if(followerIdTofollower.get(followerId) != null)
                {
                    followerIdTofollower.get(followerId).OwnerId = otherFollowerToOwnerId.get(followerId);
                }
            }
        }

        system.debug('followerIdTofollower--Map:::' + followerIdTofollower);
        for(String followerId : followerToOwnerId.keySet())
        {
            system.debug('followerId:::' + followerId);
            if(followerIdTofollower.get(followerId) != null)
            {
                followerIdTofollower.get(followerId).OwnerId = followerToOwnerId.get(followerId);
            }
        }

        List<Charket__WeChatFollower__c> followersForUpdate = new List<Charket__WeChatFollower__c>();
        for(String followerId : followerIdTofollower.keySet())
        {
            followersForUpdate.add(followerIdTofollower.get(followerId));
        }
        system.debug('followersForUpdate:::   ' + followersForUpdate);
        update followersForUpdate;
    }

    private static String getAgentIdNotMatchOriginId(String accountId)
    {
        Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c();
        List<Id> onlineUserIds = new List<Id>();

        for(Charket__WeChatAgent__c agent : [select Charket__User__c from Charket__WeChatAgent__c
            where Charket__IsAway__c = false and Charket__WeChatAccount__c = :accountId and Charket__IsActive__c = true
            and Charket__Status__c != 'Don\'t Accept Chats'])
        {
            onlineUserIds.add(agent.Charket__User__c);
        }

        if(onlineUserIds.size() > 0)
        {
            String query = 'select Charket__User__c user, sum(Charket__ChatCount__c) num, ' +
                'min(Charket__LastChatCompletedTime__c) from Charket__WeChatAgent__c ' +
                'where Charket__User__c in :onlineUserIds and Charket__IsAway__c = false ' +
                'and Charket__WeChatAccount__c = :accountId ' + 'group by Charket__User__c ' +
                'order by sum(Charket__ChatCount__c), min(Charket__LastChatCompletedTime__c) limit 1';
            List<AggregateResult> agentResults = Database.query(query);

            if(agentResults.size() > 0)
            {
                String userId = String.valueOf(agentResults[0].get('user'));
                List<Charket__WeChatAgent__c> assignedAgents = [select Id, Charket__ChatCount__c, Charket__IsAway__c
                        from Charket__WeChatAgent__c where Charket__User__c = :userId
                        and Charket__WeChatAccount__c = :accountId and Charket__IsActive__c = true
                        and Charket__Status__c != 'Don\'t Accept Chats' limit 1];

                if(assignedAgents.size() > 0)
                {
                    return assignedAgents[0].Id;
                }
            }
        }
        else
        {
            List<Charket__WeChatAgent__c> offAgents = [select Id from Charket__WeChatAgent__c
                where Charket__IsAway__c = true and Charket__WeChatAccount__c = :accountId and Charket__IsActive__c = true
                and Charket__Status__c != 'Don\'t Accept Chats'
                order by Charket__ChatCount__c, Charket__LastChatCompletedTime__c];

            if(offAgents.size() > 0)
            {
                return offAgents[0].Id;
            }
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
            String preAgentId = getPreviousAgentId(newFollower.Id);
            if(agentIds.contains(preAgentId))
            {
                return preAgentId;
            }

            return getLeastActiveAgentId(agentIds, wechatAccountId);
        }

        String query = 'select Id, (select Id, WeChatAgent__c from WeChatAgentAssignments__r where ' +
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
            String preAgentId = getPreviousAgentId(newFollower.Id);
            if(agentIds.contains(preAgentId))
            {
                return preAgentId;
            }

            return getLeastActiveAgentId(agentIds, wechatAccountId);
        }

        return null;
    }

    private static String getPreviousAgentId(String followerId)
    {
        List<Charket__WeChatTranscript__c> wechatTranscripts = [select Id, Charket__WeChatAgent__c
                from Charket__WeChatTranscript__c
                where Charket__IsClosed__c = true and Charket__WeChatFollower__c = :followerId
                and Charket__WeChatAgent__c != null
                and Charket__WeChatAgent__r.Charket__Status__c != :agentStatus
                and Charket__WeChatAgent__r.Charket__IsActive__c = true
                and Charket__WeChatAgent__r.Charket__IsAway__c = false
                order by Charket__EndTime__c desc limit 1];

        if(wechatTranscripts.size() > 0)
        {
            return wechatTranscripts[0].Charket__WeChatAgent__c;
        }

        return null;
    }

    private static String getLeastActiveAgentId(List<String> agentIds, String wechatAccountId)
    {
        String agentStatus = 'Don\'t Accept Chats';
        String query = 'select Charket__User__c user, sum(Charket__ChatCount__c) num, min(Charket__LastChatCompletedTime__c) '+
                'from Charket__WeChatAgent__c where Charket__IsAway__c = false '+
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
                        and Id in :agentIds
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