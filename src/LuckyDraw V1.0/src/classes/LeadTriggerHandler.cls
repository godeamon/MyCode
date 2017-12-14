public class LeadTriggerHandler 
{
    /**
     *  1. Get contacts through the filter condition
     *  if a new Lead has some fields which are the same to Contact(FirstName, LastName, Email, Company),
     *  then converting the Lead and merge with the existing contact
     *
     *  2. Get old leads through the filter condition
     *  Get the matching new Lead by Email of old Lead
     *  They are the same Lead if the following value of fields are the same (FirstName, LastName, Company)
     *  Assign the value of the new Lead to the corresponding Old Lead if the value of the old Lead field is blank
     *  then merge duplicated leads
     */
    public static void handleDuplicateLeads(List<Lead> newLeads)
    {
        Map<String, Lead> newLeadMap = new Map<String, Lead>();
        Set<Id> newLeadIds = new Set<Id>();
        
        for(Lead lead : newLeads)
        {
            if(String.isNotEmpty(lead.Email))
            {
                newLeadMap.put(lead.Email, lead);
                newLeadIds.add(lead.Id);
            }      
        }
       
        if(newLeadMap.isEmpty())
        {
            return; 
        }

        Map<Id, String> idToEmail = convertLeadToExistingContact(newLeadMap);

        for(String email : idToEmail.values())
        {
            newLeadMap.remove(email);
        }

        newLeadIds.removeAll(idToEmail.keySet());

        if(newLeadIds.size() > 0)
        {
           mergeDuplicateLeads(newLeadMap, newLeadIds);
        }
    }
    
    private static Map<Id, String> convertLeadToExistingContact(Map<String, Lead> newLeadMap)
    {
        Map<Id, String> idToEmail = new Map<Id, String>();
        List<Contact> contacts = [select FirstName, LastName, Email, AccountId, Account.Name from Contact 
                where Email in :newLeadMap.keySet() and AccountId != null and Email != null]; 
        
        if(contacts.size() > 0)
        {
            Database.LeadConvert[] converts = new Database.LeadConvert[0];
            String convertedStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1].MasterLabel;
            
            for(Contact contact : contacts)
            {
                Database.LeadConvert lc = new database.LeadConvert();
                Lead newLead = newLeadMap.get(contact.Email);

                if(newLead != null && newLead.FirstName == contact.FirstName && newLead.LastName == contact.LastName
                        && newLead.Company == contact.Account.Name)
                {
                    lc.setLeadId(newLead.id);
                    lc.setAccountId(contact.AccountId);
                    lc.setContactId(contact.Id);                     
                    lc.setDoNotCreateOpportunity(true);
                    lc.setOverwriteLeadSource(true);
                    lc.setConvertedStatus(convertedStatus);
                    converts.add(lc);
                    idToEmail.put(newLead.Id, newLead.Email);
                }
            }

            Database.LeadConvertResult[] result =  Database.convertLead(converts, false);
        } 

        return idToEmail;
    }

    private static void mergeDuplicateLeads(Map<String, Lead> newLeadMap, Set<Id> newLeadIds)
    {
        Map<Lead, Lead> leadToMerge = getDuplicateLeads(newLeadIds, newLeadMap.keySet(), newLeadMap);
        
        for(Lead oldLead : leadToMerge.keySet())
        {
            try
            {
                merge oldLead leadToMerge.get(oldLead);
            }
            catch(Exception ex) 
            {
                // Do not break the current transaction, the limit of DML operation is 150
            }
        }
    }

    private static Map<Lead, Lead> getDuplicateLeads(Set<Id> newLeadIds, Set<String> newLeadEmails, Map<String, Lead> newLeadMap)
    {
        List<String> fields = getFields();
        List<Lead> oldLeads = Database.query('select ' + String.join(fields, ',') 
                    + ' from Lead where IsConverted = false and Id not in :newLeadIds and Email in :newLeadEmails and Email != null');
        
        Map<Lead, Lead> leadToMerge = new Map<Lead, Lead>();
    
        for(Lead oldLead : oldLeads)
        {
            Lead newLead = newLeadMap.get(oldLead.Email);

            if(newLead != null && oldLead.FirstName == newLead.FirstName && oldLead.LastName == newLead.LastName 
                    && oldLead.Company == newLead.Company)
            {
                for(String field : fields)
                {
                    if(oldLead.get(field) == null && newLead.get(field) != null)
                    {
                        oldLead.put(field, newLead.get(field));
                    }
                }
                
                leadToMerge.put(oldLead, newLead);
            }
        }
         
        return leadToMerge;   
    }

    private static List<String> getFields()
    {
        List<String> fields = new List<String>();
        
        for(Schema.FieldSetMember f : SObjectType.Lead.FieldSets.DuplicateLeadFieldsBeKept.getFields()) 
        {
            fields.add(f.getFieldPath());
        }
        
        return fields;
    }
}