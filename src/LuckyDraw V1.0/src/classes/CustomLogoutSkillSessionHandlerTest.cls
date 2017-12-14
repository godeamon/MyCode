@isTest
private class CustomLogoutSkillSessionHandlerTest
{
	@isTest
    static void testExecute()
    {
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
            
        CustomLogoutSkillSessionHandler logout = new CustomLogoutSkillSessionHandler();
        Charket.SkillResponse response = logout.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('Logout Success.', textMessage.Content);
    }
}