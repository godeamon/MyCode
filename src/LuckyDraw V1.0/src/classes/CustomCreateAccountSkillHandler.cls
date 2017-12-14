global class CustomCreateAccountSkillHandler implements Charket.CharketSkillHandler
{
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        String returnText;
        Charket.WeChatApiMessage.Text returnMsg;

        if(session.IsNew)
        {
            returnText = '请问客户公司叫什么名字？（比如：微软中国）';
            session.Sequences.add('createAccount');
        }
        else if(context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text )
        {
            if(session.Sequences.size() > 0)
            {
                String content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content;
                returnText = CustomAccountSkillUtil.getSkillReturnMessage(session, content);
            }
        }

        if(String.isNotBlank(returnText))
        {
            returnMsg = new Charket.WeChatApiMessage.Text(returnText);
        }
        return new Charket.SkillResponse(returnMsg);
    }
}