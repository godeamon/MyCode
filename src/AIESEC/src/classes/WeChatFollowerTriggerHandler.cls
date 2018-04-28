public class WeChatFollowerTriggerHandler extends TriggerHandler
{
    List<Charket__WeChatFollower__c> newFollowers;
    List<Charket__WeChatFollower__c> oldFollowers;

    public WeChatFollowerTriggerHandler()
    {
        newFollowers = (List<Charket__WeChatFollower__c>)Trigger.new;
        oldFollowers = (List<Charket__WeChatFollower__c>)Trigger.old;
    }

    public override void beforeInsert()
    {
        if(newFollowers.size() == 1 && String.isNotBlank(newFollowers[0].Charket__Contact__c))
        {
            updateSuserLCID();
        }
    }

    public override void beforeUpdate()
    {
        Charket__WeChatFollower__c newFollower = newFollowers[0];
        Charket__WeChatFollower__c oldFollower = oldFollowers[0];

        if(newFollowers.size() == 1 && String.isNotBlank(newFollower.Charket__Contact__c)
            && !newFollower.Charket__Contact__c.equals(oldFollower.Charket__Contact__c))
        {
            try
            {
                updateSuserLCID();
            }
            catch(Exception e)
            {
                System.debug(e.getMessage());
            }
        }
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

        if(newFollowers.size() > 1 || String.isBlank(newFollower.Interested_Product__c) ||
            String.isBlank(newFollower.University__c))
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
                    Charket__WeChatAgent__r.Name, Charket__WeChatFollower__r.Charket__WeChatAccount__c,
                    Charket__FollowerOpenId__c from Charket__WeChatTranscript__c where
                    Charket__Status__c != 'Completed'and Charket__IsClosed__c = false
                    and Charket__WeChatFollower__r.Charket__WeChatAccount__c = :newFollower.Charket__WeChatAccount__c
                    and Charket__WeChatFollower__r.Charket__OpenId__c = :newFollower.Charket__OpenId__c order by
                    LastModifiedDate desc limit 1];

            try
            {
                String query = 'select Id, (select Id, WeChatAgent__c from WeChatAgentAssignments__r ' +
                        'where WeChatAgent__r.Charket__IsActive__c = true ' +
                        'and WeChatAgent__r.Charket__WeChatAccount__c = :wechatAccountId ' + 
                        'and WeChatAgent__r.Charket__Status__c != :agentStatus) ' +
                        'from WeChatAgentSkill__c where University__c = :university and Product__c = :product';
                List<WeChatAgentSkill__c> skills = Database.query(query);

                if(skills.size() > 0)
                {
                    for(WeChatAgentAssignment__c assignment : skills[0].WeChatAgentAssignments__r)
                    {
                        if(wechatTranscripts.size() > 0 && wechatTranscripts[0].Charket__WeChatAgent__c != null &&
                            (wechatTranscripts[0].Charket__WeChatAgent__c).equals(assignment.WeChatAgent__c))
                        {
                            return;
                        }
                    }
                }

                if(!newFollowers[0].Charket__IsFollowing__c)
                {
                    return;
                }

                if(wechatTranscripts.size() > 0)
                {
                    wechatTranscripts[0].Charket__Status__c = 'Completed';
                    upsert wechatTranscripts;
                }

                Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c();
                transcript.Charket__WeChatAgent__c = agentId;
                transcript.Charket__Status__c = 'In Progress';
                transcript.Charket__WeChatFollower__c = newFollower.Id;
                transcript.Charket__DeliveredMethod__c = 'Direct';
                transcript.Charket__UnreadCount__c = 0;
                transcript.Charket__StartedBy__c = 'Follower';
                transcript.Charket__FollowerOpenId__c = newFollower.Charket__OpenId__c;
                transcript.Charket__IsActive__c = true;

                upsert transcript transcript.Charket__FollowerOpenId__c;
            }
            catch(Exception e)
            {
                insert (new Charket__Log__c(
                        Charket__ApexCodeName__c = 'WeChatFollowerTriggerHandler',
                        Charket__Message__c = e.getMessage() + '###' + e.getLineNumber()));
            }
        }
    }

    private void updateSuserLCID()
    {
        List<Charket__WeChatAccount__c> wechatAccounts = [select Id from Charket__WeChatAccount__c
                where IsCustomAgentAssignmentRuleEnabled__c = true and Id = :newFollowers[0].Charket__WeChatAccount__c];
        if(wechatAccounts.size() < 1)
        {
            return;
        }

        List<Contact> contacts = [select Id, City_of_LC__c, University__c, Interested_Product__c, SUser__c, Suser__r.LC_ID__c
                from Contact where Id = :newFollowers[0].Charket__Contact__c limit 1];
        system.debug('contacts:::' + contacts);
        if(contacts.size() > 0)
        {
            newFollowers[0].City_of_University__c = contacts[0].City_of_LC__c;
            newFollowers[0].University__c = contacts[0].University__c;
            newFollowers[0].Interested_Product__c = contacts[0].Interested_Product__c;

            if(String.isNotBlank(contacts[0].SUser__c) && String.isNotBlank(contacts[0].Interested_Product__c)
                && String.isNotBlank(contacts[0].University__c))
            {
                if(contacts[0].Interested_Product__c.equals('GV'))
                {
                    List<GCDPAPP__c> gcdpAPPs = [select OwnerId from GCDPAPP__c
                            where Suser__c = :contacts[0].SUser__c order by LastModifiedDate desc limit 1];
                    if(gcdpAPPs.size() > 0)
                    {
                        system.debug('gcdpAPPs:::' + gcdpAPPs);
                        String agentId = WeChatAgentCustomAssigmentUtil.getAgentId(newFollowers[0]);
                        if(String.isNotBlank(agentId))
                        {
                            List<Charket__WeChatAgent__c> wechatAgnets = [select Id, Charket__WeChatAccount__c,
                                    Charket__User__c, Charket__User__r.EXPA_LC_ID__c from Charket__WeChatAgent__c
                                    where Id = :agentId];
                            if(wechatAgnets.size() > 0 && String.isNotBlank(wechatAgnets[0].Charket__User__c))
                            {
                                newFollowers[0].OwnerId = wechatAgnets[0].Charket__User__c;
                                gcdpAPPs[0].OwnerId = wechatAgnets[0].Charket__User__c;
                                update gcdpAPPs[0];
                                if(String.isNotBlank(wechatAgnets[0].Charket__User__r.EXPA_LC_ID__c))
                                {
                                    contacts[0].Suser__r.LC_ID__c = wechatAgnets[0].Charket__User__r.EXPA_LC_ID__c;
                                    update contacts[0].Suser__r;
                                }
                            }
                        }
                    }
                }
                else if(contacts[0].Interested_Product__c.equals('GE') || contacts[0].Interested_Product__c.equals('GT'))
                {
                    List<GIPAPP__c> gipAPPs = [select OwnerId from GIPAPP__c
                            where Suser__c = :contacts[0].SUser__c order by LastModifiedDate desc limit 1];
                    if(gipAPPs.size() > 0)
                    {
                        system.debug('gipAPPs:::' + gipAPPs);
                        String agentId = WeChatAgentCustomAssigmentUtil.getAgentId(newFollowers[0]);
                        system.debug('agentId:::' + agentId);
                        if(String.isNotBlank(agentId))
                        {
                            List<Charket__WeChatAgent__c> wechatAgnets = [select Id, Charket__WeChatAccount__c,
                                    Charket__User__c, Charket__User__r.EXPA_LC_ID__c from Charket__WeChatAgent__c
                                    where Id = :agentId];
                            if(wechatAgnets.size() > 0 && String.isNotBlank(wechatAgnets[0].Charket__User__c))
                            {
                                newFollowers[0].OwnerId = wechatAgnets[0].Charket__User__c;
                                gipAPPs[0].OwnerId = wechatAgnets[0].Charket__User__c;
                                update gipAPPs[0];
                                if(String.isNotBlank(wechatAgnets[0].Charket__User__r.EXPA_LC_ID__c))
                                {
                                    contacts[0].Suser__r.LC_ID__c = wechatAgnets[0].Charket__User__r.EXPA_LC_ID__c;
                                    update contacts[0].Suser__r;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}