global class CharketCustomAssignmentHandler implements Charket.WeChatAgentSelector
{
    global String getAgentId(Charket.WeChatAgentSelectorContext context)
    {
        List<Charket__WeChatFollower__c> followers = [select University__c, Interested_Product__c, Charket__WeChatAccount__c
                from Charket__WeChatFollower__c where Charket__OpenId__c = :context.FollowerOpenId and Charket__WeChatAccount__c != null
                limit 1];

        if(followers.size() == 1)
        {
            return WeChatAgentCustomAssigmentUtil.getAgentId(followers[0]);
        }

        return null;
    }
}