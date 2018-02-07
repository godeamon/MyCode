public class RealTimeVoteController
{
    private List<Charket__SurveyQuestion__c> SurveyQuestions = new List<Charket__SurveyQuestion__c>();
    
    public RealTimeVoteController()
    {
        QRCodeId = ApexPages.currentPage().getParameters().get('qrCodeId');
        SurveyId = ApexPages.currentPage().getParameters().get('surveyId');
        IsShowPersonNum = ApexPages.currentPage().getParameters().get('isShowPersonNum');
        AnswersRates = '';
        CurrentQuestionText = '';
        CurrentAnswerText = '';
        
        if(String.isNotBlank(QRCodeId))
        {
            QRCodeId = (String) Id.valueOf(QRCodeId);
            List<Charket__WeChatQRCode__c> WeChatQRCodes = [select Id, Charket__WhatId__c from Charket__WeChatQRCode__c where Id = :QRCodeId];
            if(WeChatQRCodes.size() > 0)
            {
                List<Attachment> atts = [select Id, ParentId from Attachment where ParentId = :QRCodeId limit 1];
                if(atts.size() > 0)
                {
                    AttachmentId = atts[0].Id;
                }
                
                CurrentNum = 1;
                if(getSurveyQuestions().size() > 0)
                {
                    QuestionsCount = getSurveyQuestions().size();
                    system.debug('firstQuestionsCount:::'+QuestionsCount);
                    IsLastQuestion = true;
                    IsFirstQuestion = false;
                    if(CurrentNum == getSurveyQuestions().size())
                    {
                        IsLastQuestion = false;
                    }
                    SurveyQuestions = getSurveyQuestions();
                    CurrentQuestion = SurveyQuestions[CurrentNum - 1];
                    CurrentQuestionText = CurrentQuestion.Charket__Question__c;
                    CurrentQuestionType = CurrentQuestion.Charket__Type__c;
                    CurrentAnswersCount = CurrentQuestion.CharKet__SurveyAnswers__r.size();
                    
                    for(Integer i = 1; i <= CurrentQuestion.CharKet__SurveyAnswers__r.size(); i++)
                    {
                        CurrentAnswerText += '\\n' + i + '. ' + CurrentQuestion.CharKet__SurveyAnswers__r[i-1].Charket__Choice__c;
                    }
                }
            }
        }
        AnswersRates = getResponsesOfCurrentQuestion(CurrentQuestion.Id);
    }
    
    public Integer CurrentNum { get; set; }
    public Integer QuestionsCount { get; set; }
    public Integer CurrentAnswersCount { get; set; }

    public Boolean IsLastQuestion { get; set; }
    public Boolean IsFirstQuestion { get; set; }

    public String QRCodeId { get; set; }
    public String IsShowPersonNum { get; set; }
    public String AttachmentId { get; set; }
    public String AnswersRates { get; set; }
    public String CurrentQuestionType { get; set; }
    public String SurveyId { get; set; }
    public String CurrentAnswerText { get; set; }
    public String CurrentQuestionText { get; set; }

    public static Charket__SurveyQuestion__c CurrentQuestion { get; set; }
    
    // insert responses and takens of current vote question.
    public static Boolean insertResponseAndSurveyTaken(String surveyId, String wechatFollowerId, String CurrentQuestionText, String CurrentAnswers, String userSendMessage, String CurrentQuestionType, List<String> userSendMessages)
    {
        String surveyTakenId;
        Boolean canInsertResponse = true;
        system.debug('surveyId:::'+surveyId);
        system.debug('wechatFollowerId:::'+wechatFollowerId);

        try
        {
            if(String.isNotBlank(surveyId) && String.isNotBlank(wechatFollowerId))
            {
                List<Charket__SurveyTaken__c> surveyTakens = [select Id from Charket__SurveyTaken__c where Charket__WeChatFollower__c = :wechatFollowerId and Charket__Survey__c = :surveyId];
                
                if(surveyTakens.size() < 1)
                {
                    Charket__SurveyTaken__c surveyTaken = new Charket__SurveyTaken__c(Charket__WeChatFollower__c = wechatFollowerId, Charket__Survey__c = surveyId);
                    insert surveyTaken;
                    surveyTakenId = surveyTaken.Id;
                }
                else
                {
                    surveyTakenId = surveyTakens[0].Id;
                }
            }

            List<Charket__SurveyQuestion__c> questions = [select Id, Charket__Type__c, (select Id, Charket__Choice__c from CharKet__SurveyAnswers__r order by Charket__Order__c, CreatedDate), (select Id from Charket__SurveyResponses__r where Charket__SurveyTaken__c = :surveyTakenId order by CreatedDate) from Charket__SurveyQuestion__c where Charket__Question__c = :CurrentQuestionText order by Charket__Order__c, CreatedDate limit 1];
            
            if(CurrentQuestionType.equals('Multiple Choice'))
            {
                List<Charket__SurveyResponse__c> SurveyResponses = new List<Charket__SurveyResponse__c>();
                for(String s : userSendMessages)
                {
                    if(String.isNotBlank(surveyTakenId) && questions.size() > 0 && questions[0].CharKet__SurveyAnswers__r.size() > 0)
                    {
                        if(questions[0].Charket__SurveyResponses__r.size() == 0)
                        {
                            Charket__SurveyResponse__c SurveyResponse = new Charket__SurveyResponse__c(Charket__SurveyQuestion__c = questions[0].Id, Charket__SurveyTaken__c = surveyTakenId, Charket__SurveyAnswer__c = questions[0].CharKet__SurveyAnswers__r[Integer.valueOf(s)-1].Id, Charket__Response__c = questions[0].CharKet__SurveyAnswers__r[Integer.valueOf(s)-1].Charket__Choice__c);
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
            else if(CurrentQuestionType.equals('Single Choice'))
            {
                if(String.isNotBlank(surveyTakenId) && questions.size() > 0 && questions[0].CharKet__SurveyAnswers__r.size() > 0)
                {
                    if(questions[0].Charket__SurveyResponses__r.size() == 0)
                    {
                        Charket__SurveyResponse__c SurveyResponse = new Charket__SurveyResponse__c(Charket__SurveyQuestion__c = questions[0].Id, Charket__SurveyTaken__c = surveyTakenId, Charket__SurveyAnswer__c = questions[0].CharKet__SurveyAnswers__r[Integer.valueOf(userSendMessage)-1].Id, Charket__Response__c = questions[0].CharKet__SurveyAnswers__r[Integer.valueOf(userSendMessage)-1].Charket__Choice__c);
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

    // deal with message of every WeChat follower vote.
    @RemoteAction
    public static Boolean dealWithWeChatMessage(String surveyId, String wechatFollowerId, String currentQuestionText, String currentAnswers, String userSendMessage, String currentAnswersCount, String currentQuestionType, String currentNum, String questionsCount)
    {
        try
        {   
            Boolean isUpdatePage = true;
            String wechatMessageId;
            String currentQuestionMessage = currentQuestionText + '\n' + currentAnswers + '\n\n' + '请回复选项对应数字进行投票，回复“0”退出';
            
            if(userSendMessage.equals('NoAnswer'))
            {
                if(currentQuestionType.equals('Multiple Choice'))
                {
                    currentQuestionMessage = currentQuestionText +'（多选）' + '\n' + currentAnswers + '\n\n' + '请回复选项对应数字进行投票（例：1，2，3），回复“0”退出';
                }
                else if(currentQuestionType.equals('Single Choice'))
                {
                    currentQuestionMessage = currentQuestionText +'（单选）' + '\n' + currentAnswers + '\n\n' + '请回复选项对应数字进行投票，回复“0”退出';
                }
            }
            else
            {
                List<String> userSendMessages = userSendMessage.split('，');
                currentQuestionMessage = '感谢您的回答！';

                if(currentQuestionType.equals('Multiple Choice'))
                {
                    Set<String> messageSet = new Set<String>();
                    for(String s : userSendMessages)
                    {
                        messageSet.add(s);
                    }

                    if(messageSet.size() == userSendMessages.size())
                    {
                        for(String s : userSendMessages)
                        {
                            try
                            {
                                Integer inte = Integer.valueOf(s);
                                Integer indexInt = Integer.valueOf(currentAnswersCount);
                                system.debug('IntegervalurOf:::::'+inte +'AND'+'   Index::::'+indexInt);
                                if(inte > indexInt)
                                {
                                    isUpdatePage = false;
                                    currentQuestionMessage = '请输入正确的数字！';
                                    break;
                                }
                            }
                            catch(Exception e)
                            {
                                System.debug(e.getMessage());
                                isUpdatePage = false;
                                currentQuestionMessage = '请输入正确的数字！';
                                break;
                            }
                        }
                    }
                    else
                    {
                        isUpdatePage = false;
                        currentQuestionMessage = '请输入正确的数字！';
                    }
                }
                else if(currentQuestionType.equals('Single Choice'))
                {
                    try
                    {
                        Integer userSendMessageInt = Integer.valueOf(userSendMessage);
                        Integer indexInt = Integer.valueOf(currentAnswersCount);
                        if(userSendMessageInt > indexInt)
                        {
                            isUpdatePage = false;
                            currentQuestionMessage = '请输入正确的数字！';
                        }
                    }
                    catch(Exception e)
                    {
                        isUpdatePage = false;
                        currentQuestionMessage = '请输入正确的数字！';
                        System.debug(e.getMessage());
                    }
                }
                
                if(isUpdatePage)
                {
                    system.debug('CurrentNum:::'+currentNum);
                    system.debug('QuestionsCount:::'+questionsCount);
                    if(currentNum.equals(questionsCount))
                    {
                        currentQuestionMessage = '感谢您的回答！本次投票已结束，祝您生活愉快！';
                        emptyCurrentSkill(wechatFollowerId);
                    }
                    if(!RealTimeVoteController.insertResponseAndSurveyTaken(surveyId, wechatFollowerId, currentQuestionText, currentAnswers, userSendMessage, currentQuestionType, userSendMessages))
                    {
                        isUpdatePage = false;
                        currentQuestionMessage = '请勿重复投票！';
                    }
                }
            }

            RealTimeVoteController.sendWeChatMessage(wechatFollowerId, currentQuestionMessage, null, CurrentQuestionText, false);
            return isUpdatePage;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage()+e.getLineNumber());
            return false;
        }
    }

    // previous question action.
    public void previous()
    {
        if(CurrentNum > 1 && CurrentNum <= SurveyQuestions.size())
        {
            CurrentNum -= 1;
        }
        CurrentQuestion = SurveyQuestions[CurrentNum - 1];
        CurrentQuestionText = CurrentQuestion.Charket__Question__c;
        CurrentQuestionType = CurrentQuestion.Charket__Type__c;
        IsFirstQuestion = true;
        IsLastQuestion = true;

        CurrentAnswerText = '';
        for(Integer i = 1; i <= CurrentQuestion.CharKet__SurveyAnswers__r.size(); i++)
        {
            CurrentAnswerText += '\\n' + i + '. ' + CurrentQuestion.CharKet__SurveyAnswers__r[i-1].Charket__Choice__c;
        }

        if(CurrentNum == SurveyQuestions.size())
        {
            IsLastQuestion = false;
        }

        if(CurrentNum == 1)
        {
            IsFirstQuestion = false;
        }
        
        CurrentAnswersCount = CurrentQuestion.CharKet__SurveyAnswers__r.size();
        AnswersRates = getResponsesOfCurrentQuestion(CurrentQuestion.Id);
    }

    // next question button action.
    public void next()
    {
        List<Charket__CharketContext__c> charketContexts = getCharketContexts('');

        if(CurrentNum < SurveyQuestions.size() && CurrentNum > 0)
        {
            CurrentNum += 1;
        }
        CurrentQuestion = SurveyQuestions[CurrentNum - 1];
        CurrentQuestionText = CurrentQuestion.Charket__Question__c;
        CurrentQuestionType = CurrentQuestion.Charket__Type__c;
        IsFirstQuestion = true;
        
        if(CurrentNum == SurveyQuestions.size())
        {
            IsLastQuestion = false;
        }

        CurrentAnswerText = '';
        for(Integer i = 1; i <= CurrentQuestion.CharKet__SurveyAnswers__r.size(); i++)
        {
            CurrentAnswerText += '\\n' + i + '. ' + CurrentQuestion.CharKet__SurveyAnswers__r[i-1].Charket__Choice__c;
        }

        AnswersRates = getResponsesOfCurrentQuestion(CurrentQuestion.Id);

        CurrentAnswersCount = CurrentQuestion.CharKet__SurveyAnswers__r.size();

        List<String> contextFollowerIds = new List<String>();

        if(String.isBlank(AnswersRates) && charketContexts.size() > 0)
        {
            for(Charket__CharketContext__c context : charketContexts)
            {
                contextFollowerIds.add(context.Charket__WeChatFollower__c);
            }
            RealTimeVoteController.sendWeChatMessage('', '', contextFollowerIds, CurrentQuestionText, true);
        }
    }

    // empty current skill of charket context to end vote.
    private static void emptyCurrentSkill(String wechatFollowerId)
    {
        List<Charket__CharketContext__c> charketContexts = getCharketContexts(wechatFollowerId);
        if(charketContexts.size() > 0)
        {
            system.debug('charketContexts[0].Charket__CurrentSkill__c:::'+charketContexts[0].Charket__CurrentSkill__c);
            charketContexts[0].Charket__CurrentSkill__c = null;
        }
        
        update charketContexts;
    }

    private static List<Charket__CharketContext__c> getCharketContexts(String wechatFollowerId)
    {
        // query skill that it's name is RealTimeVoteSkillHandler.
        List<Charket__Skill__c> skills = [select Id, (select Id, Charket__CharketContext__c from Charket__SkillContexts__r where Charket__IsValid__c = true) from Charket__Skill__c where Charket__Handler__c = 'RealTimeVoteSkillHandler' limit 1];
        List<String> charketContextIds = new List<String>();
        if(skills.size() > 0)
        {
            for(Charket__SkillContext__c skillContext : skills[0].Charket__SkillContexts__r)
            {
                charketContextIds.add(skillContext.Charket__CharketContext__c);
            }
        }

        // return charketContext to empty Charket__CurrentSkill__c field.
        if(String.isEmpty(wechatFollowerId))
        {
            return [select Id, Charket__WeChatFollower__c from Charket__CharketContext__c where Charket__CurrentSkill__c = :skills[0].Id and Id in :charketContextIds];
        }
        else
        {
            return [select Id, Charket__WeChatFollower__c, Charket__CurrentSkill__c from Charket__CharketContext__c where Charket__CurrentSkill__c = :skills[0].Id and Id in :charketContextIds and Charket__WeChatFollower__c = :wechatFollowerId limit 1];
        }
    }

    // send message to WeChat follower.
    private static void sendWeChatMessage(String wechatFollowerId, String currentQuestionMessage, List<String> wechatFollowerIds, String CurrentQuestionText, Boolean isNextQuestion)
    {
        List<Charket__WeChatFollower__c> wechatFollowers = new List<Charket__WeChatFollower__c>();
        if(isNextQuestion && wechatFollowerIds != null)
        {
            String s = '';
            for(Integer i = 1; i <= CurrentQuestion.CharKet__SurveyAnswers__r.size(); i++)
            {
                s += '\n' + i + '. ' + CurrentQuestion.CharKet__SurveyAnswers__r[i-1].Charket__Choice__c;
            }

            if(CurrentQuestion.Charket__Type__c.equals('Multiple Choice'))
            {
                currentQuestionMessage = CurrentQuestionText +'（多选）' + '\n' + s + '\n\n' + '请回复选项对应数字进行投票（例：1，2，3），回复“0”退出';
            }
            else if(CurrentQuestion.Charket__Type__c.equals('Single Choice'))
            {
                currentQuestionMessage = CurrentQuestionText +'（单选）' + '\n' + s + '\n\n' + '请回复选项对应数字进行投票，回复“0”退出';
            }
            wechatFollowers = [select Id, Charket__WeChatAccount__c, Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c where Id in :wechatFollowerIds];
        }
        else if(String.isNotBlank(wechatFollowerId))
        {
            wechatFollowers = [select Id, Charket__WeChatAccount__c, Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c where Id = :wechatFollowerId];
        }
        
        if(wechatFollowers.size() > 0)
        {
            String wechatMessageId = '';
            List<Charket__WeChatMessage__c> wechatMessagesExist = [select Charket__TextBody__c, Id
                                                                   from Charket__WeChatMessage__c
                                                                   where Charket__WeChatAccount__c = :wechatFollowers[0].Charket__WeChatAccount__c
                                                                   and Name = 'RealTime Vote Current Question Messages'
                                                                   order by CreatedDate desc];
            if(wechatMessagesExist.size() > 0)
            {
                wechatMessageId = wechatMessagesExist[0].Id;
            }
            
            if(String.isBlank(wechatMessageId))
            {
                Charket__WeChatMessage__c wechatMessage = new Charket__WeChatMessage__c(Name = 'RealTime Vote Current Question Messages', Charket__WeChatAccount__c = wechatFollowers[0].Charket__WeChatAccount__c, Charket__TextBody__c = currentQuestionMessage);
                wechatMessage.Charket__Type__c = 'Text Message';
                insert wechatMessage;
                wechatMessageId = wechatMessage.Id;
            }
            else
            {
                wechatMessagesExist[0].Charket__TextBody__c = currentQuestionMessage;
                update wechatMessagesExist;
            }
            try
            {
                for(Charket__WeChatFollower__c follower : wechatFollowers)
                {
                    Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest messageRequest = new Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest();
                    messageRequest.objectId = follower.Id;
                    messageRequest.messageId = wechatMessageId;
                    messageRequest.whoId = String.isNotEmpty(follower.Charket__Lead__c) ? follower.Charket__Lead__c : follower.Charket__Contact__c;
                    List<Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest> messageRequests = new List<Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest>();
                    messageRequests.add(messageRequest);
                    Charket.CharketSendWeChatMessageAction.sendWeChatMessage(messageRequests);
                }
            }
            catch(Exception e)
            {
                System.debug(e.getMessage() + '---' + e.getLineNumber());
            }
        }
    }

    private List<Charket__SurveyQuestion__c> getSurveyQuestions()
    {
        return [select Id, Charket__Question__c, Charket__Type__c, (select Id, Charket__Choice__c from CharKet__SurveyAnswers__r order by Charket__Order__c, CreatedDate) from Charket__SurveyQuestion__c where Charket__Survey__c = :SurveyId order by Charket__Order__c, CreatedDate];
    }

    // if current question has responses and takens, return JSON format string to vote page.
    private String getResponsesOfCurrentQuestion(String currentQuestionId)
    {
        String answersRateStr = '';
        if(String.isNotBlank(currentQuestionId))
        {
            List<CharKet__SurveyAnswer__c> currentAns = [select Id, (select Id from CharKet__SurveyResponses__r) from CharKet__SurveyAnswer__c  where Charket__SurveyQuestion__c = :currentQuestionId order by Charket__Order__c, CreatedDate];
            List<CharKet__SurveyResponse__c> currentRes = [select Id from CharKet__SurveyResponse__c where Charket__SurveyQuestion__c = :currentQuestionId];

            Decimal sumResponse = currentRes.size();
            List<Decimal> responseOfEveryAnswer = new List<Decimal>();

            if(currentAns.size() > 0 && currentRes.size() > 0)
            {
                for(CharKet__SurveyAnswer__c answer : currentAns)
                {
                    responseOfEveryAnswer.add(answer.CharKet__SurveyResponses__r.size());
                }

                for(Integer i = 1; i <= responseOfEveryAnswer.size(); i++)
                {
                    Decimal rate = (responseOfEveryAnswer[i-1]/sumResponse).setScale(4);
                    answersRateStr = answersRateStr + '"' + 'a' + i + '"' + ':' + '"' + rate + '"' + (i == responseOfEveryAnswer.size() ? '' : ',');
                }
                if(String.isNotBlank(answersRateStr))
                {
                    answersRateStr = '{' + answersRateStr + '}';
                }
            }
        }

        return AnswersRateStr;
    }
}