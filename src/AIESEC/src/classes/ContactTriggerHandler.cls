public class ContactTriggerHandler extends TriggerHandler
{
    List<Vip__c> susers = new List<Vip__c>();
    List<Vip__c> susersForUpdate = new List<Vip__c>();
    List<Contact> contacts = new List<Contact>();
    List<Contact> contactsHasProductGE = new List<Contact>();
    List<Contact> contactsHasProductGT = new List<Contact>();
    List<Contact> contactsHasProductGV = new List<Contact>();
    List<Contact> allContacts = new List<Contact>();

    List<User> users = new List<User>();
    List<String> contactIds = new List<String>();
    List<String> contactEmails = new List<String>();
    List<String> contactIdsWithCriteria = new List<String>();
    List<Charket__WeChatFollower__c> followers = new List<Charket__WeChatFollower__c>();

    List<Charket__WeChatFollower__c> wechatFollowers = new List<Charket__WeChatFollower__c>();

    Map<String, String> emailToSUserId = new Map<String, String>();
    Map<String, String> contactIdToSUserId = new Map<String, String>();
    Map<String, Contact> contactIdToContact = new Map<String, Contact>();

    Map<String, Charket__WeChatFollower__c> contactIdToFollower = new Map<String, Charket__WeChatFollower__c>();
    Map<String, String> followerIdToOwnerId = new Map<String, String>();
    Map<String, String> ownerIdToLCId = new Map<String, String>();

    Set<String> suserIdsForUpdateGV = new Set<String>();
    Set<String> suserIdsForUpdateGT = new Set<String>();
    Set<String> suserIdsForUpdateGE = new Set<String>();

    public override void beforeInsert()
    {
        for(Contact contact : (List<Contact>)Trigger.new)
        {
            allContacts.add(contact);

            if(contact.Interested_Product__c != null && contact.Contact_assign_owner_trigger__c)
            {
                contacts.add(contact);
                contactEmails.add(contact.Email);
            }
        }

        executeUpsert(contacts);
    }

    public override void beforeUpdate()
    {
        for(Contact contact : (List<Contact>)Trigger.new)
        {
            allContacts.add(contact);
            contactIds.add(contact.Id);
            contactIdToContact.put(contact.Id, contact);

            if(contact.Contact_assign_owner_trigger__c)
            {
                contacts.add(contact);
                contactEmails.add(contact.Email);
                contactIdsWithCriteria.add(contact.Id);
            }
        }

        if(allContacts.size() == 1 && contactIdsWithCriteria.size() == 1)
        {
            try
            {
                updateFollowerOfThisContact();
            }
            catch(Exception e)
            {
                System.debug(e.getMessage());
                insert (new Charket__Log__c(
                            Charket__ApexCodeName__c = 'ContactTrigger',
                            Charket__Message__c = e.getMessage() + '####' + e.getLineNumber()));
            }
        }
        else
        {
            updateFollowers();
        }

        getFollowerOwnerIdAndLCId();

        executeUpsert(contacts);
    }

    private void updateFollowerOfThisContact()
    {
        List<Charket__WeChatFollower__c> followerOfContact = [select University__c, City_of_University__c,
                Charket__WeChatAccount__c, Interested_Product__c, Charket__Contact__c from Charket__WeChatFollower__c
                where Charket__Contact__c = :contactIdsWithCriteria[0]
                and Charket__WeChatAccount__r.IsCustomAgentAssignmentRuleEnabled__c = true
                order by LastModifiedDate desc limit 1];

        if(followerOfContact.size() > 0)
        {
            followerOfContact[0].City_of_University__c = allContacts[0].City_of_LC__c;
            followerOfContact[0].University__c = allContacts[0].University__c;
            followerOfContact[0].Interested_Product__c = allContacts[0].Interested_Product__c;

            String agentId = WeChatAgentCustomAssigmentUtil.getAgentId(followerOfContact[0]);

            if(String.isNotBlank(agentId))
            {
                List<Charket__WeChatAgent__c> wechatAgnets = [select Id, Charket__WeChatAccount__c, Charket__User__c
                        from Charket__WeChatAgent__c where Id = :agentId];

                if(wechatAgnets.size() > 0 && wechatAgnets[0].Charket__User__c != null)
                {
                    followerOfContact[0].OwnerId = wechatAgnets[0].Charket__User__c;
                }
            }
            system.debug('follower:::' + followerOfContact[0]);
            contactIdToFollower.put(contactIdsWithCriteria[0], followerOfContact[0]);

            update followerOfContact;
        }
    }

    private void updateFollowers()
    {
        List<Charket__WeChatFollower__c> followersOfAllContact = [select University__c, City_of_University__c,
                Charket__WeChatAccount__c, Interested_Product__c, Charket__Contact__c from Charket__WeChatFollower__c
                where Charket__Contact__c in :contactIds
                and Charket__WeChatAccount__r.IsCustomAgentAssignmentRuleEnabled__c = true];

        for(Charket__WeChatFollower__c follower : followersOfAllContact)
        {
            contactIdToFollower.put(follower.Charket__Contact__c, follower);
        }

        List<Charket__WeChatFollower__c> followersForUpdate = new List<Charket__WeChatFollower__c>();

        for(String contactId : contactIdToContact.keySet())
        {
            if(contactIdToFollower.get(contactId) != null)
            {
                Contact contact = contactIdToContact.get(contactId);
                Charket__WeChatFollower__c followerOfContact = contactIdToFollower.get(contactId);
                followerOfContact.City_of_University__c = contact.City_of_LC__c;
                followerOfContact.University__c = contact.University__c;
                followerOfContact.Interested_Product__c = contact.Interested_Product__c;
                followersForUpdate.add(followerOfContact);
            }
        }

        try
        {
            WeChatAgentCustomAssigmentUtil.updateFollowerOwner(followersForUpdate);
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            insert (new Charket__Log__c(
                        Charket__ApexCodeName__c = 'ContactTrigger--WeChatAgentCustomAssigmentUtil.updateFollowerOwner',
                        Charket__Message__c = e.getMessage() + '####' + e.getLineNumber()));
        }
    }

    private void executeUpsert(List<Contact> contacts)
    {
        try
        {
            if(contacts.size() > 0)
            {
                upsertSUser();
                linkSUserWithContact();

                if(contactsHasProductGE.size() > 0)
                {
                    createGEApps();
                }
                else if(contactsHasProductGT.size() > 0)
                {
                    createGTApps();
                }
                else if(contactsHasProductGV.size() > 0)
                {
                    createGVApps();
                }

                setAppsCreated();
            }
        }
        catch(Exception ex)
        {
            insert (new Charket__Log__c(
                        Charket__ApexCodeName__c = 'ContactTrigger',
                        Charket__Message__c = ex.getMessage() + '####' + ex.getLineNumber()));
        }
    }

    private void upsertSUser()
    {
        querySUserEmail();

        for(Contact contact : contacts)
        {
            Vip__c suser = new Vip__c();
            if(contact.Email != null && emailToSUserId.containsKey(contact.Email)
                && emailToSUserId.get(contact.Email) != null)
            {
                suser.Id = emailToSUserId.get(contact.Email);
            }
            suser.Chinese_Name__c = contact.LastName + contact.FirstName;
            suser.Last_Name__c = contact.LastName;
            suser.First_Name__c = contact.FirstName;
            suser.Gender__c = contact.Gender__c;
            suser.Email__c =  contact.Email;
            suser.Password__c = contact.Password__c;
            suser.Mobile__c = contact.MobilePhone;
            suser.All_University__c = String.isNotBlank(contact.University__c) ? contact.University__c : '';
            suser.Campus__c = contact.Campus__c;
            suser.Grade__c = contact.Grade__c;
            suser.Major_Category__c = contact.Major_Category__c;
            suser.Major1__c = contact.Major__c;
            suser.RecordTypeId = Schema.SObjectType.Vip__c.getRecordTypeInfosByName().get('Outgoing').getRecordTypeId();
            suser.Contact__c = contact.Id;

            susers.add(suser);
        }

        upsert susers;

        sortProduct(susers);
    }

    private void querySUserEmail()
    {
        for(Vip__c vip : [select Email__c from Vip__c
                    where Email__c in :contactEmails and Email__c != null])
        {
            emailToSUserId.put(vip.Email__c, vip.Id);
        }
    }

    private void sortProduct(List<Vip__c> susers)
    {
        for(Integer i = 0; i < contacts.size(); i ++)
        {
            contactIdToSUserId.put(contacts[i].Id, susers[i].Id);
            if(contacts[i].Interested_Product__c == 'GE')
            {
                contactsHasProductGE.add(contacts[i]);
            }
            else if(contacts[i].Interested_Product__c == 'GT')
            {
                contactsHasProductGT.add(contacts[i]);
            }
            else if(contacts[i].Interested_Product__c == 'GV')
            {
                contactsHasProductGV.add(contacts[i]);
            }
        }
    }

    private void linkSUserWithContact()
    {
        if(contactIdToSUserId.size() > 0)
        {
            for(Contact contact : contacts)
            {
                contact.SUser__c = contactIdToSUserId.get(contact.Id);
            }
        }
    }

    private void createGEApps()
    {
        List<GIPAPP__c> gipApps = new List<GIPAPP__c>();

        for(Contact contact : contactsHasProductGE)
        {
            String suserId = contactIdToSUserId.get(contact.Id);
            GIPAPP__c gipApp = new GIPAPP__c();

            for(Vip__c suser : susers)
            {
                if(suser.Id == suserId)
                {
                    if(contactIdToFollower.get(contact.Id) != null )
                    {
                        if(followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id) != null)
                        {
                            if(ownerIdToLCId.get(followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id)) != null)
                            {
                                suser.LC_ID__c = ownerIdToLCId.get(
                                    followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id));
                            }
                        }
                    }
                    susersForUpdate.add(suser);
                }
            }

            gipApp.Field_of_Work__c = contact.Field_of_Work__c;
            gipApp.AIESECChannel__c = contact.AIESECChannel__c;
            gipApp.Join_Reason_GT__c = contact.Join_Reason_GT__c;
            gipApp.Suser__c = suserId;

            gipApp.RecordTypeId = Schema.SObjectType.GIPAPP__c.getRecordTypeInfosByName().get('OGE').getRecordTypeId();

            if(contactIdToFollower.get(contact.Id) != null )
            {
                if(followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id) != null)
                {
                    gipApp.OwnerId = followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id);
                }
            }

            gipApps.add(gipApp);
            suserIdsForUpdateGE.add(suserId);
        }

        insert gipApps;

        update susersForUpdate;
    }

    private void createGTApps()
    {
        List<GIPAPP__c> gipApps = new List<GIPAPP__c>();

        for(Contact contact : contactsHasProductGT)
        {
            String suserId = contactIdToSUserId.get(contact.Id);
            GIPAPP__c gipApp = new GIPAPP__c();

            for(Vip__c suser : susers)
            {
                if(suser.Id == suserId)
                {
                    if(contactIdToFollower.get(contact.Id) != null )
                    {
                        if(followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id) != null)
                        {
                            if(ownerIdToLCId.get(followerIdToOwnerId.get(
                                contactIdToFollower.get(contact.Id).Id)) != null)
                            {
                                suser.LC_ID__c = ownerIdToLCId.get(
                                    followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id));
                            }
                        }
                    }
                    susersForUpdate.add(suser);
                }
            }

            gipApp.Field_of_Work__c = contact.Field_of_Work__c;
            gipApp.AIESECChannel__c = contact.AIESECChannel__c;
            gipApp.Join_Reason_GT__c = contact.Join_Reason_GT__c;
            gipApp.Suser__c = suserId;
            gipApp.RecordTypeId = Schema.SObjectType.GIPAPP__c.getRecordTypeInfosByName().get('OGT').getRecordTypeId();

            if(contactIdToFollower.get(contact.Id) != null )
            {
                if(followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id) != null)
                {
                    gipApp.OwnerId = followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id);
                }
            }

            gipApps.add(gipApp);
            suserIdsForUpdateGT.add(suserId);
        }

        insert gipApps;

        update susersForUpdate;
    }

    private void createGVApps()
    {
        List<GCDPAPP__c> gcdpAPPs = new List<GCDPAPP__c>();

        for(Contact contact : contactsHasProductGV)
        {
            String suserId = contactIdToSUserId.get(contact.Id);
            GCDPAPP__c gcdpAPP = new GCDPAPP__c();

            for(Vip__c suser : susers)
            {
                if(suser.Id == suserId)
                {
                    if(contactIdToFollower.get(contact.Id) != null )
                    {
                        if(followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id) != null)
                        {
                            if(ownerIdToLCId.get(followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id)) != null)
                            {
                                suser.LC_ID__c = ownerIdToLCId.get(
                                    followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id));
                            }
                        }
                    }
                    susersForUpdate.add(suser);
                }
            }

            gcdpAPP.SDGInterest__c = contact.SDGInterest__c;
            gcdpAPP.AIESECChannel__c = contact.AIESECChannel__c;
            gcdpAPP.Join_Reason_GV__c = contact.Join_Reason_GV__c;
            gcdpAPP.IR_Region__c = contact.IR_Region__c;
            gcdpAPP.IR_Country__c = contact.IR_Country__c;
            gcdpAPP.Suser__c = suserId;

            if(contactIdToFollower.get(contact.Id) != null )
            {
                if(followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id) != null)
                {
                    gcdpAPP.OwnerId = followerIdToOwnerId.get(contactIdToFollower.get(contact.Id).Id);
                }
            }

            gcdpAPPs.add(gcdpAPP);
            suserIdsForUpdateGV.add(suserId);
        }

        insert gcdpAPPs;

        update susersForUpdate;
    }

    private void getFollowerOwnerIdAndLCId()
    {
        List<String> followerOwnerIds = new List<String>();
        List<String> followerIds = new List<String>();
        for(String conId : contactIdsWithCriteria)
        {
            if(contactIdToFollower.get(conId) != null)
            {
                followerIds.add(contactIdToFollower.get(conId).Id);
            }
        }

        List<Charket__WeChatFollower__c> followersForOwnerId = [select OwnerId
                from Charket__WeChatFollower__c where Id in :followerIds];
        
        for(Charket__WeChatFollower__c follower : followersForOwnerId)
        {
            followerIdToOwnerId.put(follower.Id, follower.OwnerId);
            followerOwnerIds.add(follower.OwnerId);
        }

        List<User> usersOfFollower = [select Id, EXPA_LC_ID__c from User where Id in : followerOwnerIds];
        
        for(User u : usersOfFollower)
        {
            ownerIdToLCId.put(u.Id, u.EXPA_LC_ID__c);
        }
    }

    private void setAppsCreated()
    {
        List<Vip__c> vipsToUpdate = new List<Vip__c>();

        for(String gvSUserId : suserIdsForUpdateGV)
        {
            Vip__c vip = new Vip__c(Id = gvSUserId);
            vip.GCDPAPP_Created__c = true;
            vipsToUpdate.add(vip);
        }

        for(String gtSUserId : suserIdsForUpdateGT)
        {
            Vip__c vip = new Vip__c(Id = gtSUserId);
            vip.GIPAPP_GT_Created__c = true;
            vipsToUpdate.add(vip);
        }

        for(String geSUserId : suserIdsForUpdateGE)
        {
            Vip__c vip = new Vip__c(Id = geSUserId);
            vip.GIPAPP_GE_Created__c = true;
            vipsToUpdate.add(vip);
        }

        update vipsToUpdate;
    }
}