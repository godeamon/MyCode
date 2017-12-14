public class UnsubscribeEmailController 
{
    private String leadOrContactId;
    
    public UnsubscribeEmailController()
    {
        leadOrContactId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public void updateLeadOrContact()
    {
        if(leadOrContactId != null)
        {
            List<Contact> contacts = [select Id, HasOptedOutOfEmail from Contact where Id = :leadOrContactId];
            List<Lead> leads = [select Id, HasOptedOutOfEmail from Lead where Id = :leadOrContactId];
            if(contacts.size() > 0)
            {
                contacts[0].HasOptedOutOfEmail = true;
                update contacts[0];
            }
            if(leads.size() > 0)
            {
                leads[0].HasOptedOutOfEmail = true;
                update leads[0];
            }
        } 
    }  
}