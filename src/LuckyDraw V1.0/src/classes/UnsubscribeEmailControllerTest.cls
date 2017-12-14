@isTest 
public with sharing class UnsubscribeEmailControllerTest 
{
    @isTest 
    public static void testUpdateLead()
    {
        Lead lead = new Lead(LastName='Test', Company='Test');
        insert lead;
        
        ApexPages.currentPage().getParameters().put('id', lead.Id);
        UnsubscribeEmailController controller = new UnsubscribeEmailController();
        controller.updateLeadOrContact();
        Lead newLead = [select Id, HasOptedOutOfEmail from Lead where Id = :lead.Id limit 1];
        System.assertEquals(true, newLead.HasOptedOutOfEmail);
    }
    
    @isTest
    public static void testUpdateContact()
    {
        Contact contact = new Contact(LastName='Test');
        insert contact;

        ApexPages.currentPage().getParameters().put('id', contact.Id);
        UnsubscribeEmailController controller = new UnsubscribeEmailController();
        controller.updateLeadOrContact();
        Contact newContact = [select Id, HasOptedOutOfEmail from Contact where Id = :contact.Id limit 1];
        System.assertEquals(true, newContact.HasOptedOutOfEmail);
    }
}