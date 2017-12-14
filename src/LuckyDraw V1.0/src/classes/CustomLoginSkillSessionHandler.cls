global class CustomLoginSkillSessionHandler implements Charket.CharketSkillHandler
{
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage returnMsg;
        
        if(!session.ShouldEndSession && !session.ShouldLogout)
        {
        	returnMsg = new Charket.WeChatApiMessage.Text('You\'ve already logged into Salesforce.'); 
        }
        else
        {
            returnMsg = new Charket.WeChatApiMessage.Text('Internal error.'); 
        }
        
        return new Charket.SkillResponse(returnMsg);
    }
}