@isTest
public class AnnualPartyAnswerHandlerTest
{
    @isTest
    static void testContext1()
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

        CampaignMember member = new CampaignMember(CampaignId = camp.Id, LeadId = l.Id);
        insert member;

        CampaignMemberStatus status = new CampaignMemberStatus(Label = 'Answered', CampaignId = camp.Id);
        insert status;

        Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(Name = 'test', Charket__WhatId__c = camp.Id, MoreInfo__c = survey.Id);
        insert qrcode;

        List<Charket__SurveyQuestion__c> surveyQuestions = new List<Charket__SurveyQuestion__c>();
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test', Charket__Type__c = 'Single Choice', Charket__Survey__c = survey.Id,
                ShowStatus__c = 'showing', CorrectAnswer__c = '1'));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test1', Charket__Type__c = 'Single Choice', Charket__Survey__c = survey.Id));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test2', Charket__Type__c = 'Multiple Choice', Charket__Survey__c = survey.Id));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test3', Charket__Type__c = 'Multiple Choice', Charket__Survey__c = survey.Id));
        insert surveyQuestions;

        List<Charket__SurveyAnswer__c> surveyAnswers = new List<Charket__SurveyAnswer__c>();
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test', Charket__SurveyQuestion__c = surveyQuestions[0].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test1', Charket__SurveyQuestion__c = surveyQuestions[0].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test2', Charket__SurveyQuestion__c = surveyQuestions[0].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test3', Charket__SurveyQuestion__c = surveyQuestions[3].Id));
        insert surveyAnswers;

        List<Charket__SurveyTaken__c> surveyTakens = new List<Charket__SurveyTaken__c>();
        surveyTakens.add(new Charket__SurveyTaken__c(Charket__WeChatFollower__c = follower1.Id, Charket__Survey__c = survey.Id));
        insert surveyTakens;

        List<CharKet__SurveyResponse__c> surveyResponses = new List<CharKet__SurveyResponse__c>();
        surveyResponses.add(new CharKet__SurveyResponse__c(Charket__SurveyQuestion__c = surveyQuestions[0].Id,
                Charket__SurveyAnswer__c = surveyAnswers[0].Id, Charket__SurveyTaken__c = surveyTakens[0].Id));
        insert surveyResponses;

        Charket__Skill__c skill = new Charket__Skill__c(Charket__Handler__c = 'RealTimeVoteSkillHandler', Charket__ValidFor__c = 5.00);
        insert skill;

        Charket__CharketContext__c charketContext = new Charket__CharketContext__c(Charket__CurrentSkill__c = skill.Id);
        insert charketContext;

        Charket__SkillContext__c skillContext = new Charket__SkillContext__c(Charket__Skill__c = skill.Id,
                Charket__CharketContext__c = charketContext.Id, Charket__Status__c = 'In Progress', Charket__LastRunTime__c = datetime.now());
        insert skillContext;
        
        Charket.WeChatApiMessage.Text text = new Charket.WeChatApiMessage.Text('1');
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        context.WeChatFollowerId = follower.Id;
        context.WeChatEvent = new Charket.WeChatApiEvent.Scan();
        Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;

        context.WeChatMessage = text;

        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{}', Charket.SkillSession.class);
        session.IsNew = true;

        Map<String, String> attributes = new Map<String, String>();
        session.Attributes = attributes;

        Test.startTest();
        AnnualPartyAnswerHandler handler = new AnnualPartyAnswerHandler();
        Charket.SkillResponse response = handler.execute(context, session);

        System.assertEquals(response == null, false);

        session.IsNew = false;
        AnnualPartyAnswerHandler handler1 = new AnnualPartyAnswerHandler();
        Charket.SkillResponse response1 = handler1.execute(context, session);

        Charket.SkillContext context2 = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        context2.WeChatFollowerId = follower.Id;
        context2.WeChatEvent = new Charket.WeChatApiEvent.Scan();
        Charket.WeChatApiEvent.Scan scanEvent2 = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
        Charket.WeChatApiMessage.Text text2 = new Charket.WeChatApiMessage.Text('2');
        context2.WeChatMessage = text2;
        AnnualPartyAnswerHandler handler2 = new AnnualPartyAnswerHandler();
        Charket.SkillResponse response2 = handler1.execute(context2, session);
        Test.stopTest();
    }

    @isTest
    static void testContext2()
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
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test', Charket__Type__c = 'Single Choice', Charket__Survey__c = survey.Id,
                ShowStatus__c = 'showing', CorrectAnswer__c = '1'));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test1', Charket__Type__c = 'Single Choice', Charket__Survey__c = survey.Id));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test2', Charket__Type__c = 'Multiple Choice', Charket__Survey__c = survey.Id));
        surveyQuestions.add(new Charket__SurveyQuestion__c(Charket__Question__c = 'test3', Charket__Type__c = 'Multiple Choice', Charket__Survey__c = survey.Id));
        insert surveyQuestions;

        List<Charket__SurveyAnswer__c> surveyAnswers = new List<Charket__SurveyAnswer__c>();
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test', Charket__SurveyQuestion__c = surveyQuestions[0].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test1', Charket__SurveyQuestion__c = surveyQuestions[0].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test2', Charket__SurveyQuestion__c = surveyQuestions[0].Id));
        surveyAnswers.add(new Charket__SurveyAnswer__c(Charket__Choice__c = 'test3', Charket__SurveyQuestion__c = surveyQuestions[3].Id));
        insert surveyAnswers;

        List<Charket__SurveyTaken__c> surveyTakens = new List<Charket__SurveyTaken__c>();
        surveyTakens.add(new Charket__SurveyTaken__c(Charket__WeChatFollower__c = follower1.Id, Charket__Survey__c = survey.Id));
        insert surveyTakens;

        List<CharKet__SurveyResponse__c> surveyResponses = new List<CharKet__SurveyResponse__c>();
        surveyResponses.add(new CharKet__SurveyResponse__c(Charket__SurveyQuestion__c = surveyQuestions[0].Id,
                Charket__SurveyAnswer__c = surveyAnswers[0].Id, Charket__SurveyTaken__c = surveyTakens[0].Id));
        insert surveyResponses;

        Charket__Skill__c skill = new Charket__Skill__c(Charket__Handler__c = 'RealTimeVoteSkillHandler', Charket__ValidFor__c = 5.00);
        insert skill;

        Charket__CharketContext__c charketContext = new Charket__CharketContext__c(Charket__CurrentSkill__c = skill.Id);
        insert charketContext;

        Charket__SkillContext__c skillContext = new Charket__SkillContext__c(Charket__Skill__c = skill.Id,
                Charket__CharketContext__c = charketContext.Id, Charket__Status__c = 'In Progress', Charket__LastRunTime__c = datetime.now());
        insert skillContext;

        Charket.WeChatApiMessage.Text text = new Charket.WeChatApiMessage.Text('2');
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        context.WeChatFollowerId = follower.Id;
        context.WeChatEvent = new Charket.WeChatApiEvent.Scan();
        Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;

        context.WeChatMessage = text;

        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{}', Charket.SkillSession.class);
        session.IsNew = true;

        Map<String, String> attributes = new Map<String, String>();
        session.Attributes = attributes;

        Test.startTest();
        AnnualPartyAnswerHandler handler = new AnnualPartyAnswerHandler();
        Charket.SkillResponse response = handler.execute(context, session);

        System.assertEquals(response == null, false);

        session.IsNew = false;
        AnnualPartyAnswerHandler handler1 = new AnnualPartyAnswerHandler();
        Charket.SkillResponse response1 = handler1.execute(context, session);

        AnnualPartyAnswerHandler handler2 = new AnnualPartyAnswerHandler();
        Charket.SkillResponse response2 = handler2.execute(context, session);

        context.WeChatMessage = new Charket.WeChatApiMessage.Text('a');
        AnnualPartyAnswerHandler handler3 = new AnnualPartyAnswerHandler();
        Charket.SkillResponse response3 = handler3.execute(context, session);

        context.WeChatMessage = new Charket.WeChatApiMessage.Text('9');
        AnnualPartyAnswerHandler handler4 = new AnnualPartyAnswerHandler();
        Charket.SkillResponse response4 = handler4.execute(context, session);

        Test.stopTest();
    }
}