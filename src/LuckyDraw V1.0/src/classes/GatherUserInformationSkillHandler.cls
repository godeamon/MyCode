global class GatherUserInformationSkillHandler implements Charket.CharketSkillHandler
{
    private final String END_MESSAGE = 'Your badge will be ready momentarily.';

    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage returnMsg;
        String returnText = '';

        if(context.WeChatEvent != null && (context.WeChatEvent instanceOf Charket.WeChatApiEvent.Scan))
        {
            Charket.WeChatApiEvent.Scan event = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
            Charket__WeChatQRCode__c qrCode = [select Id from Charket__WeChatQRCode__c where Charket__Ticket__c = :event.Ticket limit 1];
            Charket__WeChatFollower__c follower = [select Id, Charket__OpenId__c, Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c where Id = :context.WeChatFollowerId];
            session.Attributes.put('QRCodeId', qrCode.Id);
            String badgeName;
            String badgeCompany;
            String email;

            if(String.isBlank(follower.Charket__Lead__c) && String.isBlank(follower.Charket__Contact__c))
            {
                Lead lead = new Lead(
                    LastName = follower.Charket__OpenId__c,
                    Company = 'From WeChat'
                );
                insert lead;
                follower.Charket__Lead__c = lead.Id;
                update follower;
                
                session.Sequences.add('enterName');
                returnText = 'Thanks for visiting our booth! May I know your name?';
            }
            else if(String.isNotBlank(follower.Charket__Lead__c))
            {
                List<Lead> leads = [select Name, Company, Email from Lead where Id = :follower.Charket__Lead__c limit 1];

                if(leads.size() > 0)
                {
                    if(leads[0].Company != 'From WeChat' && leads[0].Company != '[not provided]')
                    {
                        badgeName = leads[0].Name;
                        badgeCompany = leads[0].Company;
                        session.Attributes.put('BadgeName', leads[0].Name);
                        session.Attributes.put('BadgeCompany', leads[0].Company);
                    }
                    else
                    {
                        session.Sequences.add('enterName');
                        returnText = 'Thanks for visiting our booth! May I know your name?';
                    }

                    if(String.isNotBlank(leads[0].Email))
                    {
                        email = leads[0].Email;
                        session.Attributes.put('Email', leads[0].Email);
                    }
                    else
                    {    
                        if(String.isBlank(returnText))
                        {
                            session.Sequences.add('enterEmail');
                            returnText = 'What’s your email address?';
                        }
                    }
                }
            }
            else if(String.isNotBlank(follower.Charket__Contact__c))
            {
                List<Contact> contacts = [select Name, Account.Name, Email from Contact where Id = :follower.Charket__Contact__c limit 1];

                if(contacts.size() > 0)
                {
                    if(String.isBlank(contacts[0].Account.Name) || contacts[0].Account.Name == 'From WeChat' || contacts[0].Account.Name == '[not provided]' || contacts[0].Account.Name == 'Auto Converted')
                    {
                        session.Sequences.add('enterName');
                        returnText = 'Thanks for visiting our booth! May I know your name?';
                    }
                    else
                    {
                        badgeName = contacts[0].Name;
                        badgeCompany = contacts[0].Account.Name;
                        session.Attributes.put('BadgeName', contacts[0].Name);
                        session.Attributes.put('BadgeCompany', contacts[0].Account.Name);    
                    }

                    if(String.isNotBlank(contacts[0].Email))
                    {
                        email = contacts[0].Email;
                        session.Attributes.put('Email', contacts[0].Email);
                    }
                    else
                    {    
                        if(String.isBlank(returnText))
                        {
                            session.Sequences.add('enterEmail');
                            returnText = 'What’s your email address?';
                        }
                    }
                }
            }

            String leadOrContactId = String.isNotBlank(follower.Charket__Lead__c) ? follower.Charket__Lead__c : follower.Charket__Contact__c;
            session.Attributes.put('LeadOrContactId', leadOrContactId);

            if(String.isNotBlank(badgeName) && String.isNotBlank(badgeCompany))
            {
                if(String.isNotBlank(email))
                {
                    returnText = END_MESSAGE;
                    session.ShouldEndSession = true;
                }
                updateFollowerBadgeInfo(follower.Id, qrCode.Id, badgeName, badgeCompany);
            }

        }
        else if(context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text)
        {
            String content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content.trim();
            
            if(!session.IsNew)
            {
                if(session.Sequences.size() > 0)
                {
                    String lastSession = session.Sequences.get(session.Sequences.size() - 1);
                    String badgeName = session.Attributes.get('BadgeName');
                    String badgeCompany = session.Attributes.get('BadgeCompany');
                    String email = session.Attributes.get('Email');

                    if(lastSession == 'enterName')
                    {
                        badgeName = content;
                        session.Attributes.put('BadgeName', content);

                        if(String.isNotBlank(badgeName) && String.isNotBlank(badgeCompany))
                        {
                            updateFollowerBadgeInfo(context.WeChatFollowerId, session.Attributes.get('QRCodeId'), badgeName, badgeCompany);
                        }
                    }
                    else if(lastSession == 'enterCompany')
                    {
                        badgeCompany = content;
                        session.Attributes.put('BadgeCompany', content);

                        if(String.isNotBlank(badgeName) && String.isNotBlank(badgeCompany))
                        {
                            updateFollowerBadgeInfo(context.WeChatFollowerId, session.Attributes.get('QRCodeId'), badgeName, badgeCompany);
                        }
                    }
                    else if(lastSession == 'enterEmail')
                    {
                        email = content;
                        session.Attributes.put('Email', content);
                    }

                    if(String.isNotBlank(badgeName) && String.isNotBlank(badgeCompany))
                    {
                        String leadOrContactId = session.Attributes.get('LeadOrContactId');
                        if(String.isNotBlank(leadOrContactId))
                        {
                            String firstName;
                            String lastName;

                            if(badgeName.contains(' '))
                            {
                                List<String> fullName = badgeName.split('\\ ', 2);
                                firstName = fullName[0];
                                lastName = fullName[1];
                            }
                            else
                            {
                                firstName = badgeName.right(badgeName.length() - 1);
                                lastName = badgeName.left(1);
                            }

                            try
                            {
                                if(Id.valueOf(leadOrContactId).getSobjectType() == Contact.sObjectType)
                                {
                                    Contact contact = new Contact(
                                        Id = leadOrContactId,
                                        FirstName = firstName,
                                        LastName = lastName
                                    );

                                    if(String.isNotBlank(email))
                                    {
                                        contact.Email = email;
                                    }
                                    update contact;
                                }
                                else
                                {
                                    Lead lead = new Lead(
                                        Id = leadOrContactId,
                                        FirstName = firstName,
                                        LastName = lastName,
                                        Company = badgeCompany
                                    );

                                    if(String.isNotBlank(email))
                                    {
                                        lead.Email = email;
                                    }
                                    update lead;
                                }
                            }
                            catch(Exception ex)
                            {
                                if(ex.getMessage().contains('INVALID_EMAIL_ADDRESS'))
                                {
                                    returnText = 'Invalid Email address, try it again please';
                                    email = '';
                                }
                            }
                        }
                    }

                    if(String.isBlank(badgeCompany))
                    {
                        returnText = 'Which company are you working for?';
                        session.Sequences.add('enterCompany');
                    }
                    else if(String.isBlank(email))
                    {
                        returnText = String.isNotBlank(returnText) ? returnText : 'What’s your email address?';
                        session.Sequences.add('enterEmail');
                    }
                    else if(String.isNotBlank(badgeName))
                    {
                        returnText = END_MESSAGE;
                        session.ShouldEndSession = true;
                    }
                }
            }
        }

        if(String.isNotBlank(returnText))
        {
            returnMsg = new Charket.WeChatApiMessage.Text(returnText);
        }
        
        return new Charket.SkillResponse(returnMsg);
    }

    @future
    private static void updateFollowerBadgeInfo(String followerId, String badgeId, String badgeName, String badgeCompany)
    {
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Id = followerId,
            BadgeId__c = badgeId,
            BadgeName__c = badgeName,
            BadgeCompany__c = badgeCompany,
            BadgePrintDate__c = Datetime.now()
        );

        update follower;
    }
}