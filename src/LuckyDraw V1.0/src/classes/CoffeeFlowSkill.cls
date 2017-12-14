global class CoffeeFlowSkill implements Charket.CharketSkillHandler
{
    global Flow.Interview.FreeDrink skillFlow;
    
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

                String qq = session.Attributes.get('QuestionNameToValues');
                String lastQuestionName = session.Attributes.get('QuestionName');
                Map<String, String> lastQuestionAnswerValues;
                String lastQuestionAnswer;
                if(String.isNotBlank(qq))
                {
                    Map<String, Map<String, String>> pp = (Map<String, Map<String, String>>)JSON.deserialize(qq, Map<String, Map<String, String>>.class);
                    lastQuestionAnswerValues = pp.get(lastQuestionName);
                    lastQuestionAnswer = lastQuestionAnswerValues.get(content);
                    
                    questionNameToAnswer.put(lastQuestionName, lastQuestionAnswer);

                    inputs.put(lastQuestionName, lastQuestionAnswer);

                    if(String.isBlank(lastQuestionAnswer))
                    {
                        inputs.put('InputException', 'Invalid option selected, please reply with a valid bullet item number');
                    }
                }

                skillFlow = new Flow.Interview.FreeDrink(inputs);
                
                skillFlow.start();
                
                wechatAsk = (String)skillFlow.getVariableValue('WeChatAsk');
                questionName = (String)skillFlow.getVariableValue('QuestionName');
                String askAnswers = (String)skillFlow.getVariableValue('QuestionAnswer');
                String wechatTell = (String)skillFlow.getVariableValue('WeChatTell');
                String inputException = (String)skillFlow.getVariableValue('InputException');
               
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