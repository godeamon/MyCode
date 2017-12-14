@isTest
private class CharketFollowerPrintActionTest
{
    @isTest
    static void updateFollowerPrintTest()
    {
    	Lead lead = new Lead(LastName = 'acme',
	            Company = 'acme',
	            LeadSource = 'WeChat'
	        );
        insert lead;

        Charket__WeChatAccount__c account = new Charket__WeChatAccount__c(
	            Name = 'test account',
	            Charket__WeChatOriginId__c = 'test123',
	            Charket__Type__c = 'subscribe'
	        );
        insert account;
        
    	Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
    			Charket__OpenId__c = 'test',
    			Charket__Lead__c = lead.Id,
    			Charket__WeChatAccount__c = account.Id,
    			Charket__IsFollowing__c = true
    		);
    	insert follower;

        List<CharketFollowerPrintAction.UpdateFollowerPrintRequest> requests = new List<CharketFollowerPrintAction.UpdateFollowerPrintRequest>();
        CharketFollowerPrintAction.UpdateFollowerPrintRequest request  = new CharketFollowerPrintAction.UpdateFollowerPrintRequest();
        
        request.accountId = account.Id;
        request.whoId = lead.Id;
        request.objectId = follower.Id;
        requests.add(request);

        Test.startTest();
        CharketFollowerPrintAction.updateFollowerPrint(requests);
        Test.stopTest();
    }
}