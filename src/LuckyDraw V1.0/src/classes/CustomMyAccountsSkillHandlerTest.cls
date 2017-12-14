@isTest
private class CustomMyAccountsSkillHandlerTest
{
    @isTest
    static void testExecute()
    {
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
            
        CustomMyAccountsSkillHandler createAccount = new CustomMyAccountsSkillHandler();
        Charket.SkillResponse response = createAccount.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('未找到数据。', textMessage.Content);
        
        Account acc = new Account(Name = 'Charket');
        insert acc;
        
        /**
        *1. Charket
        *
        *请回复数字查看客户详情
        *回复 0 结束
        *回复 logout 退出登录
        **/
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('1. Charket'));
        
        /**
        *1. 名称: Charket
        *2. 类型: 
        *3. 行业: 
        *
        *请回复数字修改对应的信息
        *回复 A 开始创建销售活动
        *回复 C 添加联系人
        *回复 0 结束
        *回复 logout 退出登录
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('1. 名称: Charket'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('请输入修改后的名字', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('新修改的名字');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('1. 名称：新修改的名字'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('请回复数字选择'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('6');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('2. 类型：Partner'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('3');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('请回复数字选择'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('23');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('3. 行业：Media'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('incorrect message');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('您回复的不在列表, 请重新选择\n', textMessage.Content);
    }
}