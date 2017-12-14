global class NewCaseSkillHandler implements Charket.CharketSkillHandler
{
    private final String ERROR_MESSAGE = 'Invalid option selected, please reply with a valid bullet item number';

    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage returnMessage;
        String returnText = '';
        
        if(context.WeChatMessage != null)
        {
            if(context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text)
            {
                String content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content.trim();
                
                if(!session.IsNew)
                {
                    if(session.Sequences.size() > 0)
                    {
                        String lastSession = session.Sequences.get(session.Sequences.size() - 1);
                        try
                        {
                            if(lastSession == 'enterSubject')
                            {
                                session.Attributes.put('Subject', content);
                                returnText = 'Could you please provide more information about this issue?';
                                session.Sequences.add('enterDescription');
                            }
                            else if(lastSession == 'enterDescription')
                            {
                                session.Attributes.put('Description', content);
                                returnText = 'Please choose the Type of the issue:\n' + getFieldValuesStr('Type') + 'Please reply with the number along with each option';
                                session.Sequences.add('chooseType');
                            }
                            else if(lastSession == 'chooseType')
                            {
                                String caseType = getFieldValue('Type', content);
                                if(caseType == null)
                                {
                                    throw new OrderCoffeeSkillHandlerException(ERROR_MESSAGE);
                                }
                                session.Attributes.put('Type', getFieldValue('Type', content));
                                returnText = 'Please choose the Priority of this case:\n' + getFieldValuesStr('Priority') + 'Please reply with the number along with each option';
                                session.Sequences.add('choosePriority');
                            }
                            else if(lastSession == 'choosePriority')
                            {
                                String casePriority = getFieldValue('Priority', content);
                                if(casePriority == null)
                                {
                                    throw new OrderCoffeeSkillHandlerException(ERROR_MESSAGE);
                                }
                                session.Attributes.put('Priority', getFieldValue('Priority', content));
                                returnText = 'Do you have image(s) to upload?\n1. Yes\n2. No';
                                session.Sequences.add('isNeedToUploadImage');
                            }
                            else if(lastSession == 'isNeedToUploadImage')
                            {
                                if(content == '1')
                                {
                                    returnText = 'Please upload all images through this chat window and reply "0" after you finish uploading them';
                                    session.Sequences.add('uploadImage');
                                }
                                else if(content == '2')
                                {
                                    returnText = createCase(session);
                                }
                                else
                                {
                                    throw new OrderCoffeeSkillHandlerException(ERROR_MESSAGE);   
                                }
                            }
                            else if(lastSession == 'uploadImage' && content == '0')
                            {
                                returnText = createCase(session);
                            }
                        }
                        catch(Exception ex)
                        {
                            returnText = ex.getMessage();
                        }
                    }
                }
                else
                {
                    session.Sequences.add('enterSubject');
                    session.Attributes.put('FollowerId', context.WeChatFollowerId);
                    returnText = 'What is this case about?';
                }
            }
            else if(context.WeChatMessage instanceOf Charket.WeChatApiMessage.Image)
            {
                Charket.WeChatApiMessage.Image uploadImage = (Charket.WeChatApiMessage.Image)context.WeChatMessage;
                List<String> imageMediaIds = new List<String>();
                if(session.Attributes.get('ImageMediaIds') != null)
                {
                    List<String> oldMediaIds = (List<String>)JSON.deserialize(session.Attributes.get('ImageMediaIds'), List<String>.class);
                    imageMediaIds.addAll(oldMediaIds);
                }
                imageMediaIds.add(uploadImage.MediaId + '.jpg');
                session.Attributes.put('ImageMediaIds', JSON.serialize(imageMediaIds));
                session.Attributes.put('AttachmentsSize', String.valueOf(imageMediaIds.size()));
            }
        }

        if(context.WeChatEvent != null && context.WeChatEvent instanceOf Charket.WeChatApiEvent.Scan)
        {
            session.Sequences.add('enterSubject');
            session.Attributes.put('FollowerId', context.WeChatFollowerId);
            returnText = 'What is this case about?';
        }
        
        if(String.isNotBlank(returnText))
        {
            returnMessage = new Charket.WeChatApiMessage.Text(returnText);
        }
        return new Charket.SkillResponse(returnMessage);
    }

    private String createCase(Charket.SkillSession session)
    {

        String subject = session.Attributes.get('Subject');
        String description = session.Attributes.get('Description');
        String caseType = session.Attributes.get('Type');
        String priority = session.Attributes.get('Priority');
        String attachmentsSize = session.Attributes.get('AttachmentsSize');
        String attachmentsStr = '';
        String accountName;

        if(attachmentsSize != null)
        {
            Integer attachmentsSizeInt = Integer.valueOf(attachmentsSize);
            attachmentsStr = '\nAttachments: ' + attachmentsSize + ' image' + (attachmentsSizeInt > 1 ? 's were' : ' was') + ' attached.';
        }

        String followerId = session.Attributes.get('FollowerId');
        Charket__WeChatFollower__c follower = [select Id, Charket__Lead__c, Charket__Contact__c, Charket__Contact__r.Account.Name from Charket__WeChatFollower__c where Id =:followerId];
        String contactId;
        if(String.isNotBlank(follower.Charket__Lead__c))
        {
            accountName = 'Auto Converted';
            Lead newLead = new Lead(Id = follower.Charket__Lead__c, Company = 'Auto Converted');
            update newLead;
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(follower.Charket__Lead__c);
            lc.setDoNotCreateOpportunity(true);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            if(lcr.isSuccess())
            {
                contactId = lcr.getContactId();
            }
        }
        else if(String.isNotBlank(follower.Charket__Contact__c))
        {
            contactId = follower.Charket__Contact__c;
            accountName = follower.Charket__Contact__r.Account.Name;
        }

        if(String.isNotBlank(contactId))
        {
            Case newCase = new Case(
                ContactId = contactId,
                Subject = subject,
                Description = description,
                Type = caseType,
                Priority = priority
            );

            insert newCase;

            if(session.Attributes.get('ImageMediaIds') != null)
            {
                List<String> allImageMediaIds = (List<String>)JSON.deserialize(session.Attributes.get('ImageMediaIds'), List<String>.class);
                List<Attachment> attachments = new List<Attachment>();
                for(Attachment attachment : [select Id, ParentId, Name, ContentType, BodyLength, Body, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Description from Attachment where Name in :allImageMediaIds])
                {
                    Attachment newAttachment = attachment.clone(false, false, false, false);
                    newAttachment.parentId = newCase.Id;
                    attachments.add(newAttachment);
                }

                insert attachments;
            }
        }

        String returnText = 'Your case was logged. Here are the details of the case:\nSubject: ' + subject 
                + (String.isNotBlank(accountName) ? '\nAccount Name: ' + accountName : '')
                + '\nPriority: ' + priority
                + '\nType: ' + caseType
                + '\nDescription: ' + description
                + attachmentsStr
                + '\n\nYou will be updated through WeChat when progress is made.';

        session.ShouldEndSession = true;

        return returnText;
    }

    private String getFieldValue(String fieldName, String orderNumber)
    {
        Map<String, String> orderNumberToFieldValue = new Map<String, String>();
        Schema.DescribeFieldResult descriptionResult = SObjectType.Case.fields.getMap().get(fieldName).getDescribe();
        Integer i = 0;
        for(Schema.PicklistEntry entry : descriptionResult.getPicklistValues())
        {
            i = i + 1;
            orderNumberToFieldValue.put(String.valueOf(i), entry.getValue());
        }

        return orderNumberToFieldValue.get(orderNumber);
    }

    private static String getFieldValuesStr(String fieldName)
    {
        Schema.DescribeFieldResult descriptionResult = SObjectType.Case.fields.getMap().get(fieldName).getDescribe();
        Integer i = 0;
        String returnText = '';
        for(Schema.PicklistEntry entry : descriptionResult.getPicklistValues())
        {
            i = i + 1;
            returnText += i + '. ' + entry.getValue() + '\n';
        }

        return returnText;
    }

    public class OrderCoffeeSkillHandlerException extends Exception {}
}