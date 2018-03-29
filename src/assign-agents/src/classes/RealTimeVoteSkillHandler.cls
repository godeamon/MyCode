global class RealTimeVoteSkillHandler implements Charket.CharketSkillHandler
{
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage.Text returnMsg;
        String content;
        list<LivePollingEvent__e> eventList = new list<LivePollingEvent__e>();

        try
        {
            LivePollingEvent__e event = new LivePollingEvent__e();
            if(session.IsNew && context.WeChatEvent != null && context.WeChatEvent instanceOf Charket.WeChatApiEvent.Scan)
            {
                Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
                List<Charket__WeChatQRCode__c> qrcodes = [select Id, Name, Charket__WhatId__c from Charket__WeChatQRCode__c
                        where Charket__Ticket__c = :scanEvent.Ticket limit 1];

                if(qrcodes.size() > 0 && String.isNotBlank(qrcodes[0].Charket__WhatId__c))
                {
                    List<Charket__Survey__c> surveies = [select CurrentPollingQuestion__c from Charket__Survey__c
                            where Id = :qrcodes[0].Charket__WhatId__c limit 1];

                    List<Charket__SurveyQuestion__c> questions = new List<Charket__SurveyQuestion__c>();
                    if(surveies.size() > 0 && String.isNotBlank(surveies[0].CurrentPollingQuestion__c))
                    {
                        questions = [select Id, Charket__Question__c, Charket__Type__c,
                            (select Id, Charket__Choice__c from CharKet__SurveyAnswers__r order by Charket__Order__c,
                            CreatedDate) from Charket__SurveyQuestion__c where Charket__Survey__c = :qrcodes[0].Charket__WhatId__c
                            and Id = :surveies[0].CurrentPollingQuestion__c limit 1];
                    }
                    else if(surveies.size() > 0)
                    {
                        questions = [select Id, Charket__Question__c, Charket__Type__c,
                            (select Id, Charket__Choice__c from CharKet__SurveyAnswers__r order by Charket__Order__c,
                            CreatedDate) from Charket__SurveyQuestion__c where Charket__Survey__c = :qrcodes[0].Charket__WhatId__c
                            order by Charket__Order__c, CreatedDate limit 1];
                    }
                    

                    session.Attributes.put('qrCodId', qrcodes[0].Id);
                    session.Attributes.put('surveyId', qrcodes[0].Charket__WhatId__c);

                    String CurrentAnswerText = '';
                    for(Integer i = 1; i <= questions[0].CharKet__SurveyAnswers__r.size(); i++)
                    {
                        CurrentAnswerText += '\n' + i + '. ' + questions[0].CharKet__SurveyAnswers__r[i-1].Charket__Choice__c;
                    }
                    String returnMessage = '';
                    if(questions[0].Charket__Type__c.equals('Multiple Choice'))
                    {
                        returnMessage = questions[0].Charket__Question__c +'（多选）' + '\n' + CurrentAnswerText + '\n\n' + '请回复选项对应数字进行投票（例：123），回复“0”退出';
                    }
                    else if(questions[0].Charket__Type__c.equals('Single Choice'))
                    {
                        returnMessage = questions[0].Charket__Question__c +'（单选）' + '\n' + CurrentAnswerText + '\n\n' + '请回复选项对应数字进行投票，回复“0”退出';
                    }

                    returnMsg = new Charket.WeChatApiMessage.Text(returnMessage);
                    return new Charket.SkillResponse(returnMsg);
                }
                else
                {
                    returnMsg = new Charket.WeChatApiMessage.Text('欢迎参加本次投票！！');
                    return new Charket.SkillResponse(returnMsg);
                }
            }
            else if(!session.IsNew && context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text )
            {
                content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content;

                if(content.equals('0'))
                {
                    session.ShouldEndSession = true;
                    returnMsg = new Charket.WeChatApiMessage.Text('您已退出本次投票，如想继续投票请扫描投票二维码。');
                    return new Charket.SkillResponse(returnMsg);
                }

                List<Charket__Survey__c> surveies = [select CurrentPollingQuestion__c, (select Id from Charket__SurveyQuestions__r
                        order by Charket__Order__c, CreatedDate desc)
                        from Charket__Survey__c where Id = :session.Attributes.get('surveyId') limit 1];
                if(String.isBlank(surveies[0].CurrentPollingQuestion__c))
                {
                    returnMsg = new Charket.WeChatApiMessage.Text('投票还未开始！请稍候。');
                    return new Charket.SkillResponse(returnMsg);
                }

                List<Charket__SurveyQuestion__c> questions = [select Id, Charket__Question__c, Charket__Type__c,
                    (select Id, Charket__Choice__c from CharKet__SurveyAnswers__r order by Charket__Order__c,
                    CreatedDate) from Charket__SurveyQuestion__c where Charket__Survey__c = :session.Attributes.get('surveyId')
                    and Id = :surveies[0].CurrentPollingQuestion__c limit 1];

                if(surveies[0].CurrentPollingQuestion__c.equals(surveies[0].Charket__SurveyQuestions__r[surveies[0].Charket__SurveyQuestions__r.size() - 1].Id))
                {
                    session.ShouldEndSession = true;
                }

                if(questions[0].Charket__Type__c.equals('Single Choice'))
                {
                    try
                    {
                        Integer userSendMessageInt = Integer.valueOf(content);
                        //Integer indexInt = Integer.valueOf(currentAnswersCount);
                        if(userSendMessageInt > questions[0].CharKet__SurveyAnswers__r.size())
                        {
                            returnMsg = new Charket.WeChatApiMessage.Text('请输入正确的数字。');
                            return new Charket.SkillResponse(returnMsg);
                        }
                    }
                    catch(Exception e)
                    {
                        returnMsg = new Charket.WeChatApiMessage.Text('请输入正确的数字。');
                        return new Charket.SkillResponse(returnMsg);
                    }

                    List<Integer> answersInt = new List<Integer>();
                    answersInt.add(Integer.valueOf(content));
                    if(!insertResponseAndSurveyTaken(context.WeChatFollowerId, session.Attributes.get('surveyId'), questions[0].Id, answersInt))
                    {
                        returnMsg = new Charket.WeChatApiMessage.Text('请勿重复投票。');
                        return new Charket.SkillResponse(returnMsg);
                    }

                    event.WeChatMessage__c = content;
                    event.WeChatFollowerId__c = context.WeChatFollowerId;
                    event.WeChatQRCodeId__c = session.Attributes.get('qrCodId');
                    eventList.add(event);
                    EventBus.publish(eventList);
                }
                else if(questions[0].Charket__Type__c.equals('Multiple Choice'))
                {
                    try
                    {
                        Integer userSendMessageInt = Integer.valueOf(content);
                        List<Integer> answersInt = new List<Integer>();
                        //Integer indexInt = Integer.valueOf(currentAnswersCount);
                        for(Integer i = 0; i < content.length(); i++)
                        {
                            String chars = content.substring(i, i + 1);
                            if(Integer.valueOf(chars) > questions[0].CharKet__SurveyAnswers__r.size())
                            {
                                returnMsg = new Charket.WeChatApiMessage.Text('请输入正确的数字。。' + Integer.valueOf(chars));
                                return new Charket.SkillResponse(returnMsg);
                            }

                            answersInt.add(Integer.valueOf(chars));
                        }

                        if(!insertResponseAndSurveyTaken(context.WeChatFollowerId, session.Attributes.get('surveyId'), questions[0].Id, answersInt))
                        {
                            returnMsg = new Charket.WeChatApiMessage.Text('请勿重复投票。');
                            return new Charket.SkillResponse(returnMsg);
                        }

                        event.WeChatMessage__c = content;// 传到页面的是‘1234’这种，所以需要改一下页面
                        event.WeChatFollowerId__c = context.WeChatFollowerId;
                        event.WeChatQRCodeId__c = session.Attributes.get('qrCodId');
                        eventList.add(event);
                        EventBus.publish(eventList);
                    }
                    catch(Exception e)
                    {
                        returnMsg = new Charket.WeChatApiMessage.Text('请输入正确的数字。');
                        return new Charket.SkillResponse(returnMsg);
                    }
                }

                if(surveies[0].CurrentPollingQuestion__c.equals(surveies[0].Charket__SurveyQuestions__r[surveies[0].Charket__SurveyQuestions__r.size() - 1].Id))
                {
                    returnMsg = new Charket.WeChatApiMessage.Text('本次投票已结束，感谢您的参与！');
                    return new Charket.SkillResponse(returnMsg);
                }
            }
            else if(context.WeChatEvent != null && context.WeChatEvent instanceOf Charket.WeChatApiEvent.Scan)
            {
                returnMsg = new Charket.WeChatApiMessage.Text('');
                return new Charket.SkillResponse(returnMsg);
            }
            else
            {
                event.WeChatMessage__c = 'NoAnswer';
                event.WeChatFollowerId__c = context.WeChatFollowerId;
                event.WeChatQRCodeId__c = session.Attributes.get('qrCodId');
                eventList.add(event);
                Database.SaveResult sr = EventBus.publish(eventList[0]);

                returnMsg = new Charket.WeChatApiMessage.Text('请输入正确的数字。');
                return new Charket.SkillResponse(returnMsg);
            }
        }
        catch(Exception e)
        {
            return new Charket.SkillResponse(new Charket.WeChatApiMessage.Text(''));
        }

        return new Charket.SkillResponse(new Charket.WeChatApiMessage.Text(''));
    }

    private Boolean insertResponseAndSurveyTaken(String followerId, String surveyId, String questionId, List<Integer> answersInt)
    {
        String surveyTakenId;
        Boolean canInsertResponse = true;
        try
        {
            if(String.isNotBlank(surveyId) && String.isNotBlank(followerId))
            {
                List<Charket__SurveyTaken__c> surveyTakens = [select Id from Charket__SurveyTaken__c
                        where Charket__WeChatFollower__c = :followerId and Charket__Survey__c = :surveyId];
                
                if(surveyTakens.size() < 1)
                {
                    Charket__SurveyTaken__c surveyTaken = new Charket__SurveyTaken__c(Charket__WeChatFollower__c = followerId, Charket__Survey__c = surveyId);
                    insert surveyTaken;
                    surveyTakenId = surveyTaken.Id;
                }
                else
                {
                    surveyTakenId = surveyTakens[0].Id;
                }
            }

            List<Charket__SurveyQuestion__c> questions = [select Id, Charket__Type__c,
                    (select Id, Charket__Choice__c from CharKet__SurveyAnswers__r order by Charket__Order__c, CreatedDate),
                    (select Id from Charket__SurveyResponses__r where Charket__SurveyTaken__c = :surveyTakenId
                    order by CreatedDate) from Charket__SurveyQuestion__c where Id = :questionId limit 1];
            
            if(questions[0].Charket__Type__c.equals('Multiple Choice'))
            {
                List<Charket__SurveyResponse__c> SurveyResponses = new List<Charket__SurveyResponse__c>();
                for(Integer s : answersInt)
                {
                    if(String.isNotBlank(surveyTakenId) && questions.size() > 0 && questions[0].CharKet__SurveyAnswers__r.size() > 0)
                    {
                        if(questions[0].Charket__SurveyResponses__r.size() == 0)
                        {
                            Charket__SurveyResponse__c SurveyResponse = new Charket__SurveyResponse__c(Charket__SurveyQuestion__c = questions[0].Id,
                                Charket__SurveyTaken__c = surveyTakenId,
                                Charket__SurveyAnswer__c = questions[0].CharKet__SurveyAnswers__r[s-1].Id,
                                Charket__Response__c = questions[0].CharKet__SurveyAnswers__r[s-1].Charket__Choice__c);
                            SurveyResponses.add(SurveyResponse);
                        }
                        else if(questions[0].Charket__SurveyResponses__r.size() > 0)
                        {
                            canInsertResponse = false;
                        }
                    }
                }
                insert SurveyResponses;
            }
            else if(questions[0].Charket__Type__c.equals('Single Choice'))
            {
                if(String.isNotBlank(surveyTakenId) && questions.size() > 0 && questions[0].CharKet__SurveyAnswers__r.size() > 0)
                {
                    if(questions[0].Charket__SurveyResponses__r.size() == 0)
                    {
                        Charket__SurveyResponse__c SurveyResponse = new Charket__SurveyResponse__c(Charket__SurveyQuestion__c = questions[0].Id,
                            Charket__SurveyTaken__c = surveyTakenId,
                            Charket__SurveyAnswer__c = questions[0].CharKet__SurveyAnswers__r[answersInt[0]-1].Id,
                            Charket__Response__c = questions[0].CharKet__SurveyAnswers__r[answersInt[0]-1].Charket__Choice__c);
                        insert SurveyResponse;
                    }
                    else if(questions[0].Charket__SurveyResponses__r.size() > 0)
                    {
                        canInsertResponse = false;
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }

        return canInsertResponse;
    }
}