@isTest
public class EmailUtilTest 
{
	@isTest
    public static void testSendSampleEmail()
    {	
   		EmailUtil.sendSampleEmail('test@test.com', 'subject', 'body');	    
    } 
    
    @isTest
    public static void testSendSampleEmails()
    {	
        List<String> addresses = new List<String>();
        addresses.add('test1@test1.com');
        addresses.add('test2@test2.com');
        
        EmailUtil.sendSampleEmail(addresses, 'subject', 'body');
    }
    
    @isTest
    public static void testSendSystemEmailsWithoutOrgWideEmails()
    {
        List<String> addresses = new List<String>();
        addresses.add('test1@test1.com');
        addresses.add('test2@test2.com');
        
        EmailUtil.sendSystemEmail(addresses, 'subject', 'body');
    }
}