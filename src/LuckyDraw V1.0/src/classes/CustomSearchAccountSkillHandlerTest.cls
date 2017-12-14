@isTest
private class CustomSearchAccountSkillHandlerTest
{
	@isTest
    static void testExecute()
    {
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
            
        CustomSearchAccountSkillHandler searchAccount = new CustomSearchAccountSkillHandler();
        Charket.SkillResponse response = searchAccount.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('请输入你想搜索的客户名字:', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Charket');
        session.IsNew = false;
        response = searchAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assert(textMessage.Content.contains('未找到数据。'));
        
        List<Account> accounts = new List<Account>();
        
        for(Integer i = 0; i < 10; i++)
        {
            Account acc = new Account(Name = 'Charket' + i, Type = 'Other', Industry = 'Other');
            accounts.add(acc);
        }

        insert accounts;
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Charket');
        session.IsNew = false;
        response = searchAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assert(textMessage.Content.contains('1. Charket9\n2. Charket8\n3. Charket7\n4. Charket6\n5. Charket5\n6. Charket4\n7. Charket3\n8. Charket2\n9. Charket1\n\n回复对应数字查看客户详情\n回复名称搜索其他客户\n回复 N 下一页'));   
    }
}