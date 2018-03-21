@isTest(SeeAllData=true)
private class QRCodeComponentControllerTest
{
    @isTest
    private static void testQRCodeComponentController()
    {
        String recordTypeId  = [select Id from RecordType where Name = 'EFEC B2C CN Account' and SobjectType = 'Account'].Id;
        Account acc= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test FName',
            LastName='Test LName'
        );
 
        insert acc;
        Account testAcc = [select Id, PersonContactId from Account where Id = :acc.Id limit 1];
        
        //Charket__WeChatAccount__c testWeChatAcc = new Charket__WeChatAccount__c(Name = 'Charket', Charket__WeChatOriginId__c = 'gh_5abba20f8544');
        //insert testWeChatAcc;
        
        QRCodeComponentController testController = new QRCodeComponentController();
        testController.ContactId = testAcc.PersonContactId;
        try
        {
            System.assertNotEquals(null, testController.QRCodeUrl);
        }
        catch(Exception ex)
        {
            System.assertEquals('The Email is required.', ex.getMessage());
        }
        
        try
        {
            testAcc.PersonEmail = 'test.devinfo@test.com';
            update testAcc;
            System.assertNotEquals(null, testController.QRCodeUrl);
        }
        catch(Exception ex)
        {
             System.assertEquals('The Member Id is required.', ex.getMessage());
        }
        
        try
        {
            testAcc.Member_Id__pc = '00001234';
            update testAcc;
            System.assertNotEquals(null, testController.QRCodeUrl);
        }
        catch(Exception ex)
        {
             System.assertEquals('The Member Id is an invalid integer.', ex.getMessage());
        }
        
        try
        {
            testAcc.Member_Id__pc = '10001234';
            update testAcc;
            System.assertNotEquals(null, testController.QRCodeUrl);
            System.assertNotEquals(null, testController.QRCodeUrl);
        }
        catch(Exception ex)
        {
            System.assertEquals('Generate the QRCode failure.', ex.getMessage());
        }
        
    }
}