@isTest
private class CustomLoginSkillSessionHandlerTest
{
	@isTest
    static void testExecute()
    {
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
            
        CustomLoginSkillSessionHandler login = new CustomLoginSkillSessionHandler();
        Charket.SkillResponse response = login.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('You\'ve already logged into Salesforce.', textMessage.Content);
    }
}