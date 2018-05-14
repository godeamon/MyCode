/*
 * Send email util methods
 */
public class EmailUtil
{
    // Send a text body email to one recipient
    public static Boolean sendSampleEmail(String address, String subject, String body)
    {
        Messaging.SingleEmailMessage mail = setupSingleEmailMessage(new String[]{address}, subject, body);

        return sendSignleEmail(mail);
    }
	
    public static Boolean sendSampleEmail(List<String> addresses, String subject, String body)
    {
        Messaging.SingleEmailMessage mail = setupSingleEmailMessage(addresses, subject, body);

        return sendSignleEmail(mail);
    }
    
    public static Boolean sendSystemEmail(List<String> addresses, String subject, String body)
    {
        Messaging.SingleEmailMessage mail = setupSingleEmailMessage(addresses, subject, body);
		
        system.debug('Messaging.SingleEmailMessage : ' + mail);
        
        List<OrgWideEmailAddress> orgWideEmails = [select Id, DisplayName from OrgWideEmailAddress where Address='fin@meginfo.com' limit 1];
        if(orgWideEmails.size() > 0)
        {
            mail.setOrgWideEmailAddressId(orgWideEmails[0].Id);
        }
        else
        {
            mail.setSenderDisplayName('Meginfo System Administrator');
        }

        return sendSignleEmail(mail);
    }

    public static Boolean sendException(String subject, String body )
    {
        return sendSampleEmail(UserUtil.getSystemAdminEmails(), subject, body);
    }

    private static Messaging.SingleEmailMessage setupSingleEmailMessage(List<String> addresses, String subject, String body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(addresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setSaveAsActivity(false);
        return mail;
    }

    private static Boolean sendSignleEmail(Messaging.SingleEmailMessage mail)
    {
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return emailResults.get(0).isSuccess();
    }
}