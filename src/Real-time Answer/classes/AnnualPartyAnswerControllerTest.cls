@isTest
public class AnnualPartyAnswerControllerTest implements HttpCalloutMock
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

        Campaign camp = new Campaign(Name = 'test');
        insert camp;

        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(Name = 'test', Charket__WhatId__c = camp.Id, MoreInfo__c = survey.Id);
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

        Charket__Skill__c skill = new Charket__Skill__c(Charket__Handler__c = 'AnnualPartyAnswerHandler', Charket__ValidFor__c = 5.00);
        insert skill;

        Charket__CharketContext__c charketContext = new Charket__CharketContext__c(Charket__CurrentSkill__c = skill.Id);
        insert charketContext;

        Charket__SkillContext__c skillContext = new Charket__SkillContext__c(Charket__Skill__c = skill.Id, Charket__CharketContext__c = charketContext.Id,
            Charket__Status__c = 'In Progress', Charket__LastRunTime__c = datetime.now(), 
            Charket__Body__c = '{"ShouldLogout":false,"ShouldEndSession":true,"Sequences":[],"IsNew":false,"Attributes":{"qrCodId":"a0y0l000000Ak8CAAS","questionCount":"3","currentQuestionNum":"0","surveyId":"a1H0l0000009ZUHEA2","status":"ttt","test":"test","0question":"no","question0":"3","question1":"3","question2":"3"}}');
        insert skillContext;

        Test.startTest();
        PageReference pageRef = Page.AnnualPartyAnswerRedPackage;
        pageRef.getParameters().put('qrCodeId', qrcode.Id);

        Test.setCurrentPage(pageRef);

        AnnualPartyAnswerController.updateCurrentQuestionStatus(surveyQuestions[0].Id);

        List<String> testList = new List<String>();
        AnnualPartyAnswerController.sendTimeoutAndWinMessage(follower.Id, '', testList);
        testList.add(follower.Id);
        AnnualPartyAnswerController.sendTimeoutAndWinMessage('', 'test', testList);

        AnnualPartyAnswerController controller = new AnnualPartyAnswerController();

        controller.FirstQuestionId = surveyQuestions[0].Id;

        controller.next();

        Test.stopTest();
    }

    // test for red package
    @isTest
    public static void testTotalNumLessThanOne()
    {
        Lead l = new Lead(LastName = 'test', Company = 'test');
        insert l;

        Charket__WeChatAccount__c acc = new Charket__WeChatAccount__c(Name = 'test', Charket__WeChatOriginId__c = 'test');
        insert acc;

        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Charket__Lead__c = l.Id, Charket__WeChatAccount__c = acc.Id, Charket__OpenId__c = 'test');
        insert follower;

        Campaign camp = new Campaign(Name = 'test');
        insert camp;

        CampaignMemberStatus status = new CampaignMemberStatus(Label = 'Answered', CampaignId = camp.Id);
        insert status;

        CampaignMember member = new CampaignMember(CampaignId = camp.Id, LeadId = l.Id, Status = 'Answered');
        insert member;

        Test.setMock(HttpCalloutMock.class, new AnnualPartyAnswerControllerTest());
        test.startTest();
        AnnualPartyAnswerController sendRedPackController = new AnnualPartyAnswerController();

        sendRedPackController.TotalNum = 1;
        sendRedPackController.Wishing = 'Wishing';

        ApexPages.currentPage().getHeaders().put('True-Client-IP', '1.1.1.1');
        List<String> followIds = new List<String>();
        followIds.add(follower.Id);

        AnnualPartyAnswerController.sendWeChatRedPack(followIds, '10', 'test', false, camp.Id, acc.Id);
        AnnualPartyAnswerController.sendWeChatRedPack(followIds, '10', 'test', true, camp.Id, acc.Id);

        test.stopTest();
    }

    //To simulation a situation that send a request to service and return a response.
    public HTTPResponse respond(HTTPRequest request)
    {
        HttpResponse response = new HttpResponse();
        return response;
    }
}