trigger CustomAssignment on Charket__WeChatFollower__c (after update)
{
    new WeChatFollowerTriggerHandler().run();
}