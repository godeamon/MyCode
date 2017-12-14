@isTest
public class NewCaseSkillHandlerTest
{
    @isTest
    static void testLogCase()
    {
        Lead lead = new Lead(LastName = 'acme', Company = 'Charket');
        insert lead;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Charket__OpenId__c = 'openId',
            Charket__Lead__c = lead.Id,
            Name = 'acme'
        );
        insert follower;
        
        Charket.SkillContext context = new Charket.SkillContext();
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('case');
        context.WeChatFollowerId = follower.Id;
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
        
        NewCaseSkillHandler logCase = new NewCaseSkillHandler();
        Charket.SkillResponse response = logCase.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('What is this case about?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('CAD data issue');
        session.IsNew = false;
        response = logCase.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Could you please provide more information about this issue?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('The machine could not recognize the input data and reported an invalid data format error.');
        session.IsNew = false;
        response = logCase.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assert(textMessage.Content.contains('Please choose the Type of the issue:'));

        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = logCase.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assert(textMessage.Content.contains('Please choose the Priority of this case:'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = logCase.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Do you have image(s) to upload?\n1. Yes\n2. No', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = logCase.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Please upload all images through this chat window and reply "0" after you finish uploading them', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('0');
        session.IsNew = false;
        response = logCase.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Your case was logged. Here are the details of the case:\nSubject: CAD data issue\nAccount Name: Auto Converted\nPriority: Medium\nType: Problem\nDescription: The machine could not recognize the input data and reported an invalid data format error.\n\nYou will be updated through WeChat when progress is made.', textMessage.Content);
    }
}