global class CustomLogoutSkillSessionHandler implements Charket.CharketSkillHandler
{
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        session.ShouldEndSession = true;
        session.ShouldLogout = true;
        Charket.WeChatApiMessage returnMsg;
        returnMsg = new Charket.WeChatApiMessage.Text('Logout Success.');
        return new Charket.SkillResponse(returnMsg);
    }
}