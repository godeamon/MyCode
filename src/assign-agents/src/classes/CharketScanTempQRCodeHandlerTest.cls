@isTest
private class CharketScanTempQRCodeHandlerTest
{
    @isTest
    private static void testCharketScanTempQRCodeHandler()
    {
        String recordTypeId  = [select Id from RecordType where Name = 'EFEC B2C CN Account' and SobjectType = 'Account'].Id;
        Account acc= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test FName',
            LastName='Test LName',
            Member_Id__pc = '10000000'
        );
 
        insert acc;
        CharketScanTempQRCodeHandler testHandler = new CharketScanTempQRCodeHandler();
        
        try
        {
            testHandler.handleQRCode(null);
        }
        catch(Exception ex)
        {
            System.assertEquals('Can not find the related account when the follower(client_abc123) scan temp QRCode.', ex.getMessage());
        }
        
        acc.Member_Id__pc = '10001234';
        update acc;
        testHandler.handleQRCode(null);
        testHandler.handleQRCode(null);
        Charket__WeChatFollower__c testFollower = [select Id, Charket__Contact__c from Charket__WeChatFollower__c where Charket__OpenId__c = 'client_abc123' limit 1];
        Account testAcc = [select Id, PersonContactId from Account where Id = :acc.Id];
        System.assertEquals(testAcc.PersonContactId, testFollower.Charket__Contact__c);
    }
}