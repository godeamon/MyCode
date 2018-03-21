public class WeChatFollowerTriggerHandler extends TriggerHandler
{
    List<Charket__WeChatFollower__c> newFollowers;
    List<Charket__WeChatFollower__c> oldFollowers;

    public WeChatFollowerTriggerHandler()
    {
        newFollowers = (List<Charket__WeChatFollower__c>)Trigger.new;
        oldFollowers = (List<Charket__WeChatFollower__c>)Trigger.old;
    }
    public override void afterUpdate()
    {
        String agentId;
        String wechatAccountId = newFollowers[0].Charket__WeChatAccount__c;
        String agentStatus = 'Don\'t Accept Chats';
        String university = newFollowers[0].University__c;
        String product = newFollowers[0].Interested_Product__c;

        Charket__WeChatFollower__c newFollower = newFollowers[0];
        Charket__WeChatFollower__c oldFollower = oldFollowers[0];

        if(newFollowers.size() > 1 || String.isBlank(newFollower.Interested_Product__c) || String.isBlank(newFollower.University__c))
        {
            return;
        }

        if(!newFollower.Interested_Product__c.equals(oldFollower.Interested_Product__c) ||
            !newFollower.University__c.equals(oldFollower.University__c))
        {
            agentId = WeChatAgentCustomAssigmentUtil.getAgentId(newFollower);
        }

        if(String.isNotBlank(agentId))
        {
            List<Charket__WeChatTranscript__c> wechatTranscripts = [select Id, Charket__Status__c, Charket__WeChatAgent__c,
                    Charket__WeChatAgent__r.Name, Charket__WeChatFollower__r.Charket__WeChatAccount__c, Charket__FollowerOpenId__c
                    from Charket__WeChatTranscript__c
                    where Charket__Status__c != 'Completed'
                    and Charket__IsClosed__c = false
                    and Charket__WeChatFollower__r.Charket__WeChatAccount__c = :newFollower.Charket__WeChatAccount__c
                    and Charket__WeChatFollower__r.Charket__OpenId__c = :newFollower.Charket__OpenId__c order by LastModifiedDate desc limit 1];

            try
            {
                String query = 'select Id,(select Id, WeChatAgent__c from WeChatAgentAssignments__r where WeChatAgent__r.Charket__IsActive__c = true ' +
                            'and WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId and WeChatAgent__r.Charket__Status__c != :agentStatus) from WeChatAgentSkill__c ' +
                            'where University__c = :university and Product__c = :product';
                List<WeChatAgentSkill__c> skills = Database.query(query);
                if(skills.size() > 0)
                {
                    for(WeChatAgentAssignment__c assignment : skills[0].WeChatAgentAssignments__r)
                    {
                        if(wechatTranscripts.size() > 0 && wechatTranscripts[0].Charket__WeChatAgent__c != null &&
                            (wechatTranscripts[0].Charket__WeChatAgent__c).equals(assignment.WeChatAgent__c))
                        {
                            system.debug('return::' + 'return');
                            return;
                        }
                    }
                }

                if(wechatTranscripts.size() > 0)
                {
                    wechatTranscripts[0].Charket__Status__c = 'Completed';
                    upsert wechatTranscripts;
                }

                Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c();
                transcript.Charket__WeChatAgent__c = agentId;
                system.debug('agentId1::' + agentId);
                transcript.Charket__Status__c = 'In Progress';
                transcript.Charket__WeChatFollower__c = newFollower.Id;
                transcript.Charket__DeliveredMethod__c = 'Direct';
                transcript.Charket__UnreadCount__c = 0;
                transcript.Charket__StartedBy__c = 'Follower';
                transcript.Charket__FollowerOpenId__c = newFollower.Charket__OpenId__c;
                transcript.Charket__IsActive__c = true;

                upsert transcript transcript.Charket__FollowerOpenId__c;
                system.debug('transcriptid::' + transcript);
            }
            catch(Exception e)
            {
                System.debug(e.getMessage() + e.getLineNumber());
            }
        }
    }
}