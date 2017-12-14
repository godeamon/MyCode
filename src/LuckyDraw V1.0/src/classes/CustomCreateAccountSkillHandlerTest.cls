@isTest
private class CustomCreateAccountSkillHandlerTest
{
    @isTest
    static void testExecute()
    {   
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
            
        CustomCreateAccountSkillHandler createAccount = new CustomCreateAccountSkillHandler();
        Charket.SkillResponse response = createAccount.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('请问客户公司叫什么名字？（比如：微软中国）', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Charket');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('请输入数字选择公司类型'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('10');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('请输入数字选择行业'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('25');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('成功创建客户，详情如下：\n1. 名称：Charket\n2. 类型：Other\n3. 行业：Other'));
    }
}