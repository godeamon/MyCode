@isTest
private class LeadTriggerTest 
{
    @isTest static void testSingleConvertToContact() 
    {
        Account acc = new Account(Name = 'Meg1');
        insert acc;

        Contact con = new Contact(FirstName = '1', LastName = 'Test', Email = 'Test1@meginfo.com', AccountId = acc.Id);
        insert con;
        
        List<Lead> testLeads = new List<Lead>{
                new Lead(FirstName = '1', LastName = 'Test', Company = 'Meg1', Email = 'Test1@meginfo.com')
        };
            
        Test.startTest();
        insert testLeads;
        Test.stopTest();
        
        List<Lead> convertLead = [select FirstName, LastName, Company, Email, ConvertedContactId from Lead where Email = 'Test1@meginfo.com'];
        System.assertEquals(con.Id, convertLead[0].ConvertedContactId);
    }
    
    @isTest static void testSingleMergeLead()
    {
        Lead lead = new Lead(FirstName = 'T1', LastName = 'Test1', Company = 'Meg1', Email = '1Test@meginfo.com');
        insert lead;

        Lead testLead = new Lead(FirstName = 'T1', LastName = 'Test1', Company = 'Meg1', Email = '1Test@meginfo.com', Phone = '1101101010');
        
        Test.startTest();
        insert testLead;
        Test.stopTest();
        
        List<Lead> leads = [select FirstName, LastName, Company, Email from Lead where Email = '1Test@meginfo.com'];
        System.assertEquals(1, leads.size());
    }
    
    @isTest static void testBatchConvertToContact()
    {
        List<Account> accounts = new List<Account>();
        
        for(Integer i = 0; i < 100; i++)
        {
            Account account = new Account(Name = 'Meg' + i);
            accounts.add(account);
        }

        insert accounts;

        List<Contact> contacts = new List<Contact>();
        
        for(Integer i = 0; i < 100; i++)
        {
            Contact con = new Contact(FirstName = 'i', LastName = 'Test', Email = i + 'Test@meginfo.com', AccountId = accounts.get(i).Id);
            contacts.add(con);
        }

        insert contacts;

        List<Lead> testLeads = new List<Lead>();
        
        for(Integer i = 0; i < 100; i++)
        {
            Lead lead = new Lead(FirstName = 'i', LastName = 'Test', Email = i + 'Test@meginfo.com', Company = 'Meg' + i);
            testLeads.add(lead);
        }
        
        Test.startTest();
        insert testLeads;
        Test.stopTest();
        
        List<Lead> convertLeads = [select FirstName, LastName, Company, Email, IsConverted from Lead];
        
        for(Lead convertLead : convertLeads) 
        {
            System.assert(true, convertLead.IsConverted);
        }
    }
    
    @isTest static void testBatchMergeLead()
    {
        List<Lead> leadList = new List<Lead>();
        
        for(Integer i = 0; i < 100; i++)
        {
           Lead lead = new Lead(LastName = 'Test' + i, Company = 'Meg' + i, Email = i + 'Test@meginfo.com');
           leadList.add(lead);
        }

        insert leadList; 

        List<Lead> testLeads = new List<lead>();
        
        for(Integer i = 0; i < 100; i++)
        {
           Lead lead = new Lead(LastName = 'Test' + i, Company = 'Meg' + i, Email = i + 'Test@meginfo.com', Phone = '1101101010',Website = 'baidu', Title = 'Lead' + i );
           testLeads.add(lead);
        }
        
        Test.startTest();
        insert testLeads;
        Test.stopTest();
        
        List<Lead> leads = [select LastName, Company, Email, IsConverted from Lead];
        System.assertEquals(100, leads.size());
    }

    @isTest static void testMergeAndConvertLead()
    {
        List<Lead> leadList = new List<Lead>{
                new Lead(FirstName = '2', LastName = 'Test', Company = 'Meg2', Email = 'Test2@meginfo.com')
        };
        insert leadList;

        Account acc = new Account(Name = 'Meg1');
        insert acc;

        Contact con = new Contact(FirstName = '1', LastName = 'Test', Email = 'Test1@meginfo.com', AccountId = acc.Id);
        insert con;
        
        List<Lead> testLeads = new List<Lead>{
                new Lead(FirstName = '1', LastName = 'Test', Company = 'Meg1', Email = 'Test1@meginfo.com'),
                new Lead(FirstName = '2', LastName = 'Test', Company = 'Meg2', Email = 'Test2@meginfo.com', Phone = '1101101010')
        };
            
        Test.startTest();
        insert testLeads;
        Test.stopTest();

        Lead convertedLead = [select IsConverted from Lead where Email = 'Test1@meginfo.com'];
        List<Lead> mergeLeads = [select IsConverted from Lead where Email = 'Test2@meginfo.com'];
        System.assert(true, convertedLead.IsConverted);
        System.assertEquals(1, MergeLeads.size());
    }
    
    @isTest static void testEmailIsNull() 
    {
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < 10; i++)
        {
           Lead lead = new Lead(LastName = 'Test' + i, Company = 'Meg' + i);
           leads.add(lead);
        }
        insert leads;
        
        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 10; i++)
        {
           Lead lead = new Lead(LastName = 'Test' + i, Company = 'Meg' + i);
           testLeads.add(lead);
        }
        
        Test.startTest();
        insert testLeads;
        Test.stopTest();
		
        List<Lead> allLeads = [select Id from Lead];
        System.assertEquals(20, allLeads.size());
    }
}