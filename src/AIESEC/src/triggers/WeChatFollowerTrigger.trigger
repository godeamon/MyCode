trigger WeChatFollowerTrigger on Charket__WeChatFollower__c (after update, before insert, before update)
{
    new WeChatFollowerTriggerHandler().run();
}