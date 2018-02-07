global class AnnualPartyAnswerHandler implements Charket.CharketSkillHandler
{
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage.Text returnMsg;
        String content;
        List<RealTimeAnswer__e> eventList = new List<RealTimeAnswer__e>();

        try
        {
            RealTimeAnswer__e event = new RealTimeAnswer__e();
            if(session.IsNew && context.WeChatEvent != null && context.WeChatEvent instanceOf Charket.WeChatApiEvent.Scan)
            {
                Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
                List<Charket__WeChatQRCode__c> qrcodes = [select Id, Name, Charket__WhatId__c, MoreInfo__c from Charket__WeChatQRCode__c
                        where Charket__Ticket__c = :scanEvent.Ticket limit 1];

                if(qrcodes.size() > 0 && String.isNotBlank(qrcodes[0].MoreInfo__c))
                {
                    List<Charket__SurveyQuestion__c> surveyQuestions = [select Id, Charket__Question__c, Charket__Type__c,
                            (select Id, Charket__Choice__c from CharKet__SurveyAnswers__r order by Charket__Order__c, CreatedDate)
                            from Charket__SurveyQuestion__c where Charket__Survey__c = :qrcodes[0].MoreInfo__c order by Charket__Order__c, CreatedDate];
                    String questionCount = '' + surveyQuestions.size();

                    session.Attributes.put('qrCodId', qrcodes[0].Id);
                    session.Attributes.put('questionCount', questionCount);
                    session.Attributes.put('currentQuestionNum', '0');
                    session.Attributes.put('surveyId', qrcodes[0].MoreInfo__c);
                    session.Attributes.put('status', '');

                    for(Integer i = 0; i < surveyQuestions.size(); i++)
                    {
                        String key = 'question';
                        key = key + i;
                        String answerCountValue = '' + surveyQuestions[i].CharKet__SurveyAnswers__r.size();
                        session.Attributes.put(key, answerCountValue);

                        String isCurrentQuestionHasResponed = 'Responed' + i + 'question';
                        session.Attributes.put(isCurrentQuestionHasResponed, 'no');
                    }

                    String campaignId = '';
                    String leadOrContactId = '';

                    List<Charket__WeChatFollower__c> weChatFollowers = [select Charket__Lead__c, Charket__Contact__c
                            from Charket__WeChatFollower__c where Id = :context.WeChatFollowerId];

                    if(weChatFollowers.size() > 0 && (String.isNotBlank(weChatFollowers[0].Charket__Lead__c) || String.isNotBlank(weChatFollowers[0].Charket__Contact__c)))
                    {
                        leadOrContactId = String.isNotEmpty(wechatFollowers[0].Charket__Lead__c) ?
                                wechatFollowers[0].Charket__Lead__c : wechatFollowers[0].Charket__Contact__c;
                    }

                    if(String.isNotBlank(qrcodes[0].Charket__WhatId__c))
                    {
                        if(((Id)qrcodes[0].Charket__WhatId__c).getSobjectType() == Schema.Campaign.SObjectType)
                        {
                            campaignId = qrcodes[0].Charket__WhatId__c;
                        }
                        else if(((Id)qrcodes[0].Charket__WhatId__c).getSobjectType() == Schema.Charket__WeChatCampaignFlowStep__c.SObjectType)
                        {
                            List<Charket__WeChatCampaignFlowStep__c> wechatCampaigns = [select Id, Charket__WeChatCampaignFlow__r.Charket__Campaign__c
                                    from Charket__WeChatCampaignFlowStep__c where Id = :qrcodes[0].Charket__WhatId__c];

                            if(wechatCampaigns.size() > 0 && String.isNotBlank(wechatCampaigns[0].Charket__WeChatCampaignFlow__r.Charket__Campaign__c)
                                    && ((Id)wechatCampaigns[0].Charket__WeChatCampaignFlow__r.Charket__Campaign__c).getSobjectType() == Schema.Campaign.SObjectType)
                            {
                                campaignId = wechatCampaigns[0].Charket__WeChatCampaignFlow__r.Charket__Campaign__c;
                            }
                        }

                        if(String.isNotBlank(campaignId) && String.isNotBlank(leadOrContactId))
                        {
                            List<CampaignMember> campaignMembers = [select Id, Status from CampaignMember where CampaignId = :campaignId
                                    and LeadOrContactId = :leadOrContactId limit 1];

                            CampaignMemberStatus status = new CampaignMemberStatus(Label = 'Answered', CampaignId = campaignId);

                            try
                            {
                                List<CampaignMemberStatus> statuses = [select Label from CampaignMemberStatus where CampaignId = :campaignId];
                                Boolean founded = false;
                                for(CampaignMemberStatus s : statuses)
                                {
                                    if(s.Label.equals(status.Label))
                                    {
                                        founded = true;
                                        break;
                                    }
                                }

                                if(!founded)
                                {
                                    insert status;
                                }

                                if(campaignMembers.size() > 0)
                                {
                                    campaignMembers[0].Status = status.Label;
                                    update campaignMembers;
                                }
                            }
                            catch(Exception e)
                            {
                                System.debug(e.getMessage());
                            }
                        }
                    }

                    returnMsg = new Charket.WeChatApiMessage.Text('请注意大屏幕，输入你认为正确的答案的数字，不要超时');
                    return new Charket.SkillResponse(returnMsg);
                }
            }
            else if(!session.IsNew && context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text)
            {
                content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content;
                Integer contentInt;

                // 等于0的时候结束嘛？需要确定一下！！！
                if(content.equals('0'))
                {
                    session.ShouldEndSession = true;
                    returnMsg = new Charket.WeChatApiMessage.Text('您已退出本次答题！');
                    return new Charket.SkillResponse(returnMsg);
                }

                try
                {
                    contentInt = Integer.valueOf(content);
                }
                catch(Exception e)
                {
                    returnMsg = new Charket.WeChatApiMessage.Text('请输入您选择的答案的对应数字！');
                    return new Charket.SkillResponse(returnMsg);
                }

                String currentAnswersCuntKey = 'question' + session.Attributes.get('currentQuestionNum');
                Integer currentAnswersCount = Integer.valueOf(session.Attributes.get(currentAnswersCuntKey));

                String isCurrentQuestionHasResponed = 'Responed' + session.Attributes.get('currentQuestionNum') + 'question';

                if(contentInt > 0 && contentInt <= currentAnswersCount)
                {
                    if(String.isBlank(session.Attributes.get('status')) || session.Attributes.get('status').equals('ok'))
                    {
                        List<Charket__SurveyQuestion__c> surveyQuestions = [select Id, Charket__Question__c, Charket__Type__c, ShowStatus__c, CorrectAnswer__c
                                from Charket__SurveyQuestion__c where Charket__Survey__c = :session.Attributes.get('surveyId')
                                order by Charket__Order__c, CreatedDate];

                        Charket__SurveyQuestion__c currentQuestion = surveyQuestions[Integer.valueOf(session.Attributes.get('currentQuestionNum'))];
                        
                        if(String.isBlank(session.Attributes.get('status')))
                        {
                            List<Charket__SurveyTaken__c> surveyTakens = [select Id from Charket__SurveyTaken__c
                                    where Charket__WeChatFollower__c = :context.WeChatFollowerId
                                    and Charket__Survey__c = :session.Attributes.get('surveyId')];

                            if(surveyTakens.size() > 0)
                            {
                                returnMsg = new Charket.WeChatApiMessage.Text('对不起！您不能继续答题！');
                                return new Charket.SkillResponse(returnMsg);
                            }
                            else if(surveyTakens.size() == 0 && String.isBlank(surveyQuestions[0].ShowStatus__c))
                            {
                                returnMsg = new Charket.WeChatApiMessage.Text('对不起，答题还未开始');
                                return new Charket.SkillResponse(returnMsg);
                            }
                            else if(surveyTakens.size() == 0 && surveyQuestions[0].ShowStatus__c.equals('end'))
                            {
                                returnMsg = new Charket.WeChatApiMessage.Text('对不起，您来晚了！');
                                return new Charket.SkillResponse(returnMsg);
                            }
                        }

                        if(session.Attributes.get(isCurrentQuestionHasResponed).equals('yes'))
                        {
                            returnMsg = new Charket.WeChatApiMessage.Text('请不要重复回答！');
                            return new Charket.SkillResponse(returnMsg);
                        }
                        else if(! content.equals(currentQuestion.CorrectAnswer__c))
                        {
                            session.Attributes.put(isCurrentQuestionHasResponed, 'yes');
                            session.Attributes.put('status', 'error');

                            event.UserSentMessage__c = content + 'a';
                            event.WeChatFollowerId__c = context.WeChatFollowerId;
                            event.WeChatQRCodeId__c = session.Attributes.get('qrCodId');
                            
                            Datetime createTime = ((Charket.WeChatApiMessage)context.WeChatMessage).CreateTime;

                            event.WeChatMessageCreatedDate__c = String.valueOfGmt(createTime);
                            eventList.add(event);
                            EventBus.publish(eventList);
                        }
                        else if(content.equals(currentQuestion.CorrectAnswer__c) && session.Attributes.get(isCurrentQuestionHasResponed).equals('no'))
                        {
                            if(String.isBlank(session.Attributes.get('status')))
                            {
                                session.Attributes.put('status', 'ok');
                            }

                            session.Attributes.put(isCurrentQuestionHasResponed, 'yes');
                            
                            event.UserSentMessage__c = content;
                            event.WeChatFollowerId__c = context.WeChatFollowerId;
                            event.WeChatQRCodeId__c = session.Attributes.get('qrCodId');
                            
                            Datetime createTime = ((Charket.WeChatApiMessage)context.WeChatMessage).CreateTime;

                            event.WeChatMessageCreatedDate__c = String.valueOfGmt(createTime);
                            eventList.add(event);
                            EventBus.publish(eventList);
                        }
                    }
                    else if(session.Attributes.get('status').equals('outtime'))
                    {
                        returnMsg = new Charket.WeChatApiMessage.Text('对不起！您已经失去答题资格，不能继续答题！');
                        return new Charket.SkillResponse(returnMsg);
                    }
                    else if(session.Attributes.get(isCurrentQuestionHasResponed).equals('no'))
                    {
                        returnMsg = new Charket.WeChatApiMessage.Text('对不起！您已经失去答题资格，不能继续答题！');
                        return new Charket.SkillResponse(returnMsg);
                    }
                    else if(session.Attributes.get(isCurrentQuestionHasResponed).equals('yes'))
                    {
                        returnMsg = new Charket.WeChatApiMessage.Text('请不要重复回答！');
                        return new Charket.SkillResponse(returnMsg);
                    }
                }
                else
                {
                    returnMsg = new Charket.WeChatApiMessage.Text('请输入正确范围数字！');
                    return new Charket.SkillResponse(returnMsg);
                }
            }
        }
        catch(Exception e)
        {
            return new Charket.SkillResponse(new Charket.WeChatApiMessage.Text(''));
        }

        return new Charket.SkillResponse(new Charket.WeChatApiMessage.Text(''));
    }
}