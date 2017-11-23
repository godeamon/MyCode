/**
 * Show all answers of the survey.
 */
public class SurveyAnswersController
{
    private static String surveyId = ApexPages.currentPage().getParameters().get('id');
    private static List<Charket__SurveyTaken__c> surveyTakens;
    
    public SurveyAnswersController()
    {
        Survey = [select Id, Name, CreatedBy.Id, CreatedBy.Name, CreatedDate from Charket__Survey__c where Id = :surveyId limit 1];
        SurveyQuestions = Database.query('select Id, Charket__Question__c, Charket__Order__c, (select Id, CharKet__SurveyAnswer__r.Charket__Choice__c, CharKet__SurveyAnswer__r.Id, Charket__SurveyQuestion__c from CharKet__SurveyResponses__r) from Charket__SurveyQuestion__c where Charket__Survey__c = :' + 'surveyId' + ' order by Charket__Order__c ASC');
        WeChatFollowerAndAnswers = queryWrapperWeChatFollowerAndAnswers();
    }
    
    public static List<String> FieldsShow { get; set; }
    public List<Charket__SurveyQuestion__c> SurveyQuestions { get; set; }
    public Charket__Survey__c Survey { get; set; }
    public List<WrapperWeChatFollowerAndAnswers> WeChatFollowerAndAnswers { get; set; }
    
    @RemoteAction
    @ReadOnly
    public static void querySurveyTakens()
    {
        String queryString = queryFieldsMethod();
        surveyTakens = Database.query('select Id, Charket__WeChatFollower__c, ' + queryString + ' Charket__WeChatFollower__r.Charket__Lead__r.Name, Charket__Survey__r.Name, (select Id, CharKet__SurveyAnswer__r.Id, CharKet__SurveyAnswer__r.Charket__SurveyQuestion__c, CharKet__SurveyAnswer__r.Charket__Choice__c, Charket__Response__c, Charket__SurveyQuestion__c from CharKet__SurveyResponses__r) from Charket__SurveyTaken__c where Charket__Survey__c = :' + 'surveyId' + ' order by CreatedDate ASC');
    }
    
    private static String queryFieldsMethod()
    {
        List<String> fields = new List<String>();
        String queryFields = '';
        
        if(SObjectType.Charket__WeChatFollower__c.FieldSets.Survey_Answers.getFields().size() > 0)
        {
            for(Schema.FieldSetMember field : SObjectType.Charket__WeChatFollower__c.FieldSets.Survey_Answers.getFields())
            {
                queryFields += 'Charket__WeChatFollower__r.' + field.getFieldPath() + ', ';
                fields.add(field.getLabel());
            }
        }
        
        FieldsShow = fields;
        return queryFields;
    }

    private List<WrapperWeChatFollowerAndAnswers> queryWrapperWeChatFollowerAndAnswers()
    {
        querySurveyTakens();
        List<WrapperAnswerAndQuestionId> wrapperAnswerAndQuestionIds = new List<WrapperAnswerAndQuestionId>();
        List<WrapperWeChatFollowerAndAnswers> wrapperWeChatFollowerAndAnswers = new List<WrapperWeChatFollowerAndAnswers>();
        
        if(surveyTakens.size() > 0)
        {
            for(Charket__SurveyTaken__c taken : surveyTakens)
            {
                Charket__WeChatFollower__c weChatFollower = taken.Charket__WeChatFollower__r;
                for(CharKet__SurveyResponse__c response : taken.CharKet__SurveyResponses__r)
                {
                    if(response.Charket__SurveyAnswer__c != null)
                    {
                        wrapperAnswerAndQuestionIds.add(new WrapperAnswerAndQuestionId(response.Charket__SurveyAnswer__r.Charket__Choice__c, response.CharKet__SurveyAnswer__r.Charket__SurveyQuestion__c));
                        if(String.isNotEmpty(response.Charket__Response__c))
                        {
                            wrapperAnswerAndQuestionIds.add(new WrapperAnswerAndQuestionId(response.Charket__Response__c, response.CharKet__SurveyAnswer__r.Charket__SurveyQuestion__c));
                        }
                    }
                    else if(response.Charket__Response__c != null)
                    {
                        wrapperAnswerAndQuestionIds.add(new WrapperAnswerAndQuestionId(response.Charket__Response__c, response.Charket__SurveyQuestion__c));
                    }
                }
                
                List<String> showAnswers = new List<String>();
                for(Integer i = 0; i < SurveyQuestions.size(); i++)
                {
                    showAnswers.add('No_Answer');
                    for(WrapperAnswerAndQuestionId answerAndQuestionId : wrapperAnswerAndQuestionIds)
                    {
                        if(answerAndQuestionId.questionId == SurveyQuestions[i].Id)
                        {
                            showAnswers[i] = answerAndQuestionId.answer + (showAnswers[i] == 'No_Answer' ? '' : ';' + showAnswers[i]);
                        }
                    }
                }
                
                wrapperWeChatFollowerAndAnswers.add(new WrapperWeChatFollowerAndAnswers(weChatFollower, showAnswers));
                wrapperAnswerAndQuestionIds.clear();
            }
        }
        return wrapperWeChatFollowerAndAnswers;
    }
    
    public class WrapperWeChatFollowerAndAnswers
    {
        public Charket__WeChatFollower__c WeChatFollower {get; set;}
        public List<String> Answers {get; set;}
        
        WrapperWeChatFollowerAndAnswers(Charket__WeChatFollower__c weChatFollower, List<String> answers)
        {
            this.WeChatFollower = weChatFollower;
            this.Answers = answers;
        }
    }
    
    public class WrapperAnswerAndQuestionId
    {
        private String answer;
        private String questionId;
        
        WrapperAnswerAndQuestionId(String answer, String questionId)
        {
            this.answer = answer;
            this.questionId = questionId;
        }
    }
}