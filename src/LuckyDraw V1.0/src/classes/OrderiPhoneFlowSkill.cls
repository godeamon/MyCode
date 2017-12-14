global class OrderiPhoneFlowSkill implements Charket.CharketSkillHandler
{
    global Flow.Interview.OrderiPhone skillFlow;
    
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    { 
        String textMessage;
        if(!session.ShouldEndSession)
        {
            try
            {
                String wechatAsk = '';
                String questionName = '';
                
                String content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content.trim();
                textMessage = content;
                
                Map<String, Object> inputs = new Map<String, Object>();

                if(String.isBlank(session.Attributes.get('ContactAccountId')))
                {
                    Charket__WeChatFollower__c follower = [select Charket__Contact__r.AccountId from Charket__WeChatFollower__c where Id = :context.WeChatFollowerId limit 1];
                    if(String.isNotBlank(follower.Charket__Contact__r.AccountId))
                    {
                        session.Attributes.put('ContactAccountId', follower.Charket__Contact__r.AccountId);
                        inputs.put('OrderAccountId', session.Attributes.get('ContactAccountId'));
                    }
                }
                else
                {
                    inputs.put('OrderAccountId', session.Attributes.get('ContactAccountId'));
                }

                Map<String, String> questionNameToAnswer = new Map<String, String>();
                String questionNameToAnswerStr = session.Attributes.get('QuestionNameToAnswer');
                if(String.isNotBlank(questionNameToAnswerStr))
                {
                    questionNameToAnswer = (Map<String, String>)JSON.deserialize(questionNameToAnswerStr, Map<String, String>.class);

                    for(String name : questionNameToAnswer.keySet())
                    {
                        inputs.put(name, questionNameToAnswer.get(name));
                    }
                }

                String questionNameToValuesStr = session.Attributes.get('QuestionNameToValues');
                String lastQuestionName = session.Attributes.get('QuestionName');
                Map<String, String> lastQuestionAnswerValues;
                String lastQuestionAnswer;
                if(String.isNotBlank(questionNameToValuesStr))
                {
                    Map<String, Map<String, String>> oldQuestionNameToValues = (Map<String, Map<String, String>>)JSON.deserialize(questionNameToValuesStr, Map<String, Map<String, String>>.class);
                    lastQuestionAnswerValues = oldQuestionNameToValues.get(lastQuestionName);
                    lastQuestionAnswer = lastQuestionAnswerValues.get(content);
                    
                    questionNameToAnswer.put(lastQuestionName, lastQuestionAnswer);

                    inputs.put(lastQuestionName, lastQuestionAnswer);

                    if(String.isBlank(lastQuestionAnswer))
                    {
                        inputs.put('ExceptionMessage', 'Invalid option selected, please reply with a valid bullet item number');
                    }
                }

                skillFlow = new Flow.Interview.OrderiPhone(inputs);
                
                skillFlow.start();
                
                wechatAsk = (String)skillFlow.getVariableValue('WeChatAsk');
                questionName = (String)skillFlow.getVariableValue('QuestionName');
                String askAnswers = (String)skillFlow.getVariableValue('QuestionAnswer');
                String wechatTell = (String)skillFlow.getVariableValue('WeChatTell');
                String inputException = (String)skillFlow.getVariableValue('ExceptionMessage');
               
                Map<String, Map<String, String>> questionNameToValues = new Map<String, Map<String, String>>();
                if(String.isNotBlank(askAnswers))
                {
                    List<String> answers = askAnswers.split(',');
                    Map<String, String> keyToValues = new Map<String, String>();
                    for(String answer : answers)
                    {
                        keyToValues.put(answer.split(':')[0], answer.split(':')[1]);
                    }
                    
                    questionNameToValues.put(questionName, keyToValues);
                      
                    session.Attributes.put('QuestionName', questionName);
                    textMessage = wechatAsk;
                }

                if(!questionNameToValues.isEmpty())
                {
                    session.Attributes.put('QuestionNameToValues', JSON.serialize(questionNameToValues));
                }
                if(!questionNameToAnswer.isEmpty())
                {
                    session.Attributes.put('QuestionNameToAnswer', JSON.serialize(questionNameToAnswer));
                }

                if(String.isNotBlank(wechatTell))
                {
                    textMessage = wechatTell;
                    session.ShouldEndSession = true;
                }

                if(String.isNotBlank(inputException))
                {
                    textMessage = inputException;
                }
            }
            catch(Exception ex)
            {
                textMessage = ex.getMessage() + ex.getLineNumber();
            }
        }
        
        return new Charket.SkillResponse(new Charket.WeChatApiMessage.Text(textMessage));
    }
}