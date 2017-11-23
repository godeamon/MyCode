@IsTest
public class SurveyAnswersControllerTest
{
    @IsTest
    static void test()
    {
        Charket__Survey__c survey = new Charket__Survey__c(Name = 'test');
        insert survey;
        
        Charket__SurveyQuestion__c surveyQuestion = new Charket__SurveyQuestion__c(Charket__Question__c = 'test', Charket__Order__c = 1, Charket__Type__c = 'text', Charket__Survey__c = survey.Id);
        insert surveyQuestion;
        
        CharKet__SurveyAnswer__c surveyAnswer = new CharKet__SurveyAnswer__c(Charket__Choice__c = 'test', Charket__SurveyQuestion__c = surveyQuestion.Id);
        insert surveyAnswer;
        
        Charket__WeChatFollower__c weChatFollower = new Charket__WeChatFollower__c();
        insert weChatFollower;
        
        Charket__SurveyTaken__c surveyTaken = new Charket__SurveyTaken__c(Charket__WeChatFollower__c = weChatFollower.Id, Charket__Survey__c = survey.Id);
        insert surveyTaken;
        
        CharKet__SurveyResponse__c surveyResponse = new CharKet__SurveyResponse__c(Charket__SurveyQuestion__c = surveyQuestion.Id, Charket__SurveyTaken__c = surveyTaken.Id, CharKet__SurveyAnswer__c = surveyAnswer.Id, Charket__Response__c = 'test');
        insert surveyResponse;
        
        PageReference pageRef = ApexPages.currentPage();
        pageRef.getParameters().put('id', survey.Id);
        
        SurveyAnswersController surveyAnswers = new SurveyAnswersController();
        system.assert(surveyAnswers.SurveyQuestions.size() == 1);
    }
}