global class CustomSkillHandler implements Charket.CharketSkillHandler
{
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage returnMsg;

        if(context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text)
        {
            String content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content.trim();
            
            if(!session.IsNew)
            {
                if(session.Sequences.size() > 0)
                {
                    String lastSession = session.Sequences.get(session.Sequences.size() - 1);
                    if(lastSession == 'enterName')
                    {
                        if(content.contains(' '))
                        {
                            List<String> fullName = content.split('\\ ', 2);
                            session.Attributes.put('FirstName', fullName[0]);
                            session.Attributes.put('LastName', fullName[1]);
                        }
                        else
                        {
                            session.Attributes.put('FirstName', content.right(content.length() - 1));
                            session.Attributes.put('LastName', content.left(1));
                        }
                        returnMsg = new Charket.WeChatApiMessage.Text('2. Which company does he/she work for?');
                        session.Sequences.add('enterCompany');
                    }
                    else if(lastSession == 'enterCompany')
                    {
                        session.Attributes.put('Company', content);
                        returnMsg = new Charket.WeChatApiMessage.Text('3. What\'s his/her email address? Reply 0 if you don\'t know.');
                        session.Sequences.add('enterEmail');
                    }
                    else if(lastSession == 'enterEmail')
                    {
                        session.Attributes.put('Email', content);
                        returnMsg = new Charket.WeChatApiMessage.Text('4. What\'s his/her mobile number? Reply 0 if you don\'t know.');
                        session.Sequences.add('enterPhone');
                    }
                    else if(lastSession == 'enterPhone')
                    {
                        session.Attributes.put('Phone', content);
                        Lead lead = new Lead();
                        lead.LastName = session.Attributes.get('LastName');
                        lead.FirstName = session.Attributes.get('FirstName');
                        lead.MobilePhone = session.Attributes.get('Phone') == '0' ? null : session.Attributes.get('Phone');
                        lead.Company = session.Attributes.get('Company');
                        lead.Email = session.Attributes.get('Email') == '0' ? null : session.Attributes.get('Email');
                        insert lead;

                        lead.MobilePhone = lead.MobilePhone == null ? '' : lead.MobilePhone;
                        lead.Email = lead.Email == null ? '' : lead.Email;
                        returnMsg = new Charket.WeChatApiMessage.Text('The lead was created with the following details:\n\nName: ' + lead.FirstName + ' ' + lead.LastName + '\nCompany: ' + lead.Company + '\nEmail: ' + lead.Email + '\nMobile: ' + lead.MobilePhone);
                        session.ShouldEndSession = true;
                    }
                }
            }
        }
        else
        {
            session.Sequences.add('enterName');
            returnMsg = new Charket.WeChatApiMessage.Text('1. What\'s his/her name?');
        }
        
        return new Charket.SkillResponse(returnMsg);
    }
}