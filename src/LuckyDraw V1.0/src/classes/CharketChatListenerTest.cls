@isTest
private class CharketChatListenerTest
{
    @isTest
    static void testSendMessage()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WeChatTestHttpMock('success', 'OK', 200));
        
        Charket__WeChatAccount__c account = new Charket__WeChatAccount__c(
                Name = 'Test Account', Charket__WeChatOriginId__c = 'test', Charket__Type__c = 'subscribe'
            );
        insert account;
        Charket__WeChatAgent__c agent = new Charket__WeChatAgent__c(
                Name = 'agent', Charket__WeChatAccount__c = account.Id, Charket__User__c = UserInfo.getUserId()
            );
        insert agent;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
                Charket__OpenId__c = 'oLNKJwT_or6El', Charket__WeChatAccount__c = account.Id,
                Charket__IsFollowing__c = true, Charket__SubscriptionDate__c = System.now()
            );
        insert follower;
        Charket__WeChatTranscript__c transcript = new Charket__WeChatTranscript__c(
                Charket__DeliveredMethod__c = 'Direct', Charket__FollowerOpenId__c = follower.Charket__OpenId__c,
                Charket__WeChatAgent__c = agent.Id, Charket__StartedBy__c = 'Follower',
                Charket__UnreadCount__c = 1, Charket__IsActive__c = true, 
                Charket__WeChatFollower__c = follower.Id, Charket__AgentMessageCount__c = 0
            );
        insert transcript;
        
        RestRequest req = new RestRequest();
        req.addParameter('openId', follower.Charket__OpenId__c);
        req.addParameter('accountId', account.Id);
        req.addParameter('transcriptId', transcript.Id);
        req.requestBody = Blob.valueOf('test');
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        CharketChatListener.doPost();
        CharketChatListener.updateTranscriptForAgent(transcript, 'test');
        Test.stopTest();
    }
}