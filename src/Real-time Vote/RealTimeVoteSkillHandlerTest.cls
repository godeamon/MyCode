@isTest
public class RealTimeVoteSkillHandlerTest
{
    @isTest
    static void testContext1()
    {
    Charket.WeChatApiMessage.Text text = new Charket.WeChatApiMessage.Text('1');
    Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
    context.WeChatEvent = new Charket.WeChatApiEvent.Scan();
    Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;

    Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(Name = 'test', Charket__Ticket__c = scanEvent.Ticket);
    insert qrcode;
    context.WeChatMessage = text;

    Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{}', Charket.SkillSession.class);
    session.IsNew = true;

    Map<String, String> attributes = new Map<String, String>();
    session.Attributes = attributes;

    Test.startTest();
    RealTimeVoteSkillHandler handler = new RealTimeVoteSkillHandler();
    Charket.SkillResponse response = handler.execute(context, session);

    session.IsNew = false;
    RealTimeVoteSkillHandler handler1 = new RealTimeVoteSkillHandler();    Charket.SkillResponse response1 = handler1.execute(context, session);
    Test.stopTest();
    System.assertEquals(response == null, false);
    System.assertEquals(response1 == null, false);
    }

    @isTest
    static void testContext0()
    {
    Charket.WeChatApiMessage.Text text = new Charket.WeChatApiMessage.Text('0');
    Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
    context.WeChatEvent = new Charket.WeChatApiEvent.Scan();
    Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;

    Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(Name = 'test', Charket__Ticket__c = scanEvent.Ticket);
    insert qrcode;
    context.WeChatMessage = text;

    Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{}', Charket.SkillSession.class);
    session.IsNew = false;

    Map<String, String> attributes = new Map<String, String>();
    session.Attributes = attributes;

    Test.startTest();
    RealTimeVoteSkillHandler handler = new RealTimeVoteSkillHandler();
    Charket.SkillResponse response = handler.execute(context, session);
    Test.stopTest();
    System.assertEquals(response == null, false);
    }

    @isTest
    static void testContextNo()
    {
    Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
    context.WeChatEvent = new Charket.WeChatApiEvent.Scan();
    Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;

    Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(Name = 'test', Charket__Ticket__c = scanEvent.Ticket);
    insert qrcode;

    Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{}', Charket.SkillSession.class);
    session.IsNew = false;

    Map<String, String> attributes = new Map<String, String>();
    session.Attributes = attributes;

    Test.startTest();
    RealTimeVoteSkillHandler handler = new RealTimeVoteSkillHandler();
    Charket.SkillResponse response = handler.execute(context, session);
    Test.stopTest();
    System.assertEquals(response == null, false);
    }

    @isTest
    static void testContextNotScan()
    {
    Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
    context.WeChatEvent = new Charket.WeChatApiEvent.SendLocationMenu();

    Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{}', Charket.SkillSession.class);
    session.IsNew = false;

    Map<String, String> attributes = new Map<String, String>();
    session.Attributes = attributes;

    Test.startTest();
    RealTimeVoteSkillHandler handler = new RealTimeVoteSkillHandler();
    Charket.SkillResponse response = handler.execute(context, session);
    Test.stopTest();
    System.assertEquals(response == null, false);
    }
}