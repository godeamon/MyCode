@isTest
public class RealTimeVoteControllerTest
{
    @isTest
    static void test()
    {
        Lead l = new Lead(LastName = 'test', Company = 'test');
        insert l;

        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Charket__Lead__c = l.Id);
        insert follower;

        Charket__WeChatFollower__c follower1 = new Charket__WeChatFollower__c(Charket__Lead__c = l.Id);
        insert follower1;

        Charket__Survey__c survey = new Charket__Survey__c(Name = 'test');
        insert survey;

        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(Name = 'test', Charket__WhatId__c = survey.Id);
        insert qrcode;

        List<Charket__SurveyQuestion__c> surveyQuestions = new List<Charket__SurveyQuestion__c>();
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test', Charket__Type__c = 'Single Choice', Charket__Survey__c = survey.Id));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test1', Charket__Type__c = 'Single Choice', Charket__Survey__c = survey.Id));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test2', Charket__Type__c = 'Multiple Choice', Charket__Survey__c = survey.Id));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test3', Charket__Type__c = 'Multiple Choice', Charket__Survey__c = survey.Id));
        insert surveyQuestions;

        List<Charket__SurveyAnswer__c> surveyAnswers = new List<Charket__SurveyAnswer__c>();
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test', Charket__SurveyQuestion__c = surveyQuestions[0].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test1', Charket__SurveyQuestion__c = surveyQuestions[1].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test2', Charket__SurveyQuestion__c = surveyQuestions[2].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test3', Charket__SurveyQuestion__c = surveyQuestions[3].Id));
        insert surveyAnswers;

        List<Charket__SurveyTaken__c> surveyTakens = new List<Charket__SurveyTaken__c>();
        surveyTakens.add(new Charket__SurveyTaken__c(Charket__WeChatFollower__c = follower1.Id, Charket__Survey__c = survey.Id));
        insert surveyTakens;

        List<CharKet__SurveyResponse__c> surveyResponses = new List<CharKet__SurveyResponse__c>();
        surveyResponses.add(new CharKet__SurveyResponse__c(Charket__SurveyQuestion__c = surveyQuestions[0].Id, Charket__SurveyAnswer__c = surveyAnswers[0].Id, Charket__SurveyTaken__c = surveyTakens[0].Id));
        insert surveyResponses;

        Charket__Skill__c skill = new Charket__Skill__c(Charket__Handler__c = 'RealTimeVoteSkillHandler', Charket__ValidFor__c = 5.00);
        insert skill;

        Charket__CharketContext__c charketContext = new Charket__CharketContext__c(Charket__CurrentSkill__c = skill.Id);
        insert charketContext;

        Charket__SkillContext__c skillContext = new Charket__SkillContext__c(Charket__Skill__c = skill.Id, Charket__CharketContext__c = charketContext.Id, Charket__Status__c = 'In Progress', Charket__LastRunTime__c = datetime.now());
        insert skillContext;

        Test.startTest();
        PageReference pageRef = Page.RealTimeVote;
        pageRef.getParameters().put('qrCodeId', qrcode.Id);
        pageRef.getParameters().put('surveyId', survey.Id);
        pageRef.getParameters().put('isShowPersonNum', '1');
        Test.setCurrentPage(pageRef);

        RealTimeVoteController controller = new RealTimeVoteController();

        controller.previous();
        controller.next();
        Boolean b = RealTimeVoteController.dealWithWeChatMessage(survey.Id, follower.Id, 'test', 'test', '1', '1', 'Single Choice', '2', '2');
        System.assertEquals(b, true);
        b = RealTimeVoteController.dealWithWeChatMessage(survey.Id, follower.Id, 'test', 'test', '1', '1', 'Multiple Choice', '1', '2');
        System.assertEquals(b, false);
        b = RealTimeVoteController.dealWithWeChatMessage(survey.Id, follower.Id, 'test', 'test', 'NoAnswer', '1', 'Multiple Choice', '1', '2');
        System.assertEquals(b, true);
        Test.stopTest();
    }
}