global class TestSkillHandler implements Charket.CharketSkillHandler
{
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage returnMsg = new Charket.WeChatApiMessage.Text('');

        if(context.WeChatEvent != null && (context.WeChatEvent instanceOf Charket.WeChatApiEvent.Scan))
        {
            Charket.WeChatApiEvent.Scan event = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
            
            Charket__WeChatQRCode__c qrCode = [select Id from Charket__WeChatQRCode__c 
                where Charket__Ticket__c = :event.Ticket limit 1];
                
            Charket__WeChatFollower__c follower = [select Id, Charket__OpenId__c, Charket__Lead__c, Charket__Lead__r.Name, Charket__Lead__r.Company,
                Charket__Contact__c, Charket__Contact__r.Name, Charket__Contact__r.Account.Name 
                from Charket__WeChatFollower__c where Id = :context.WeChatFollowerId];
                
            
            String badgeName = follower.Charket__Lead__c != null ? follower.Charket__Lead__r.Name : follower.Charket__Contact__r.Name;
            String badgeCompany = follower.Charket__Lead__c != null ? follower.Charket__Lead__r.Company : follower.Charket__Contact__r.Account.Name;
                
            
            updateFollower(follower.Id, badgeName, badgeCompany, qrCode.Id);
            insert (new Charket__Log__c(Charket__ApexCodeName__c = 'test skill', Charket__Data__c = follower.Id + '**' + badgeName + badgeCompany + qrCode.Id));
            
            returnMsg = new Charket.WeChatApiMessage.Text('PRINT');
            session.ShouldEndSession = true;
            
        }
        
        return new Charket.SkillResponse(returnMsg);
    }
    
    @future
    private static void updateFollower(String followerId, String badgeName, String badgeCompany, String qrCodeId )
    {
        WeChatLeadController.updateFollowerPrintFields(true, followerId, badgeName, badgeCompany, qrCodeId);
        insert (new Charket__Log__c(Charket__ApexCodeName__c = 'test skill', Charket__Data__c = followerId + '**' + badgeName + badgeCompany + qrCodeId));
    }
   
}