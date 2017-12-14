@isTest
private class CustomAccountSkillUtilTest
{
    @isTest
    static void testCreateAccountAndCreaetContact()
    {
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
            
        CustomCreateAccountSkillHandler createAccount = new CustomCreateAccountSkillHandler();
        Charket.SkillResponse response = createAccount.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('请问客户公司叫什么名字？（比如：微软中国）', textMessage.Content);
        
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
        
        /**
         * 成功创建客户，详情如下：
         *1. 名称: Charket
         *2. 类型: Other
         *3. 行业: Other
         *
         *请回复数字修改对应的信息
         *回复 A 创建销售活动
         *回复 C 添加联系人
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('25');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assert(textMessage.Content.contains('成功创建客户，详情如下：\n1. 名称：Charket\n2. 类型：Other\n3. 行业：Other'));
        
        // update field value
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
        
        // Create contact
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('C');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('请回复联系人的姓名，邮箱和手机号码（比如：张 学友 jacky.chueng@charket.com 18610026227）', textMessage.Content);
        
        /**
         *姓名：Acme Charket
         *邮箱：acme.charket@charket.com
         *电话：1234567890
         *
         *回复 R 返回到客户
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Acme Charket acme.charket@charket.com 1234567890');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('姓名：Acme Charket\n邮箱：acme.charket@charket.com\n电话：1234567890\n\n回复 R 返回到客户', textMessage.Content);
        
        /**
         *1. 名称: 新修改的名字
         *2. 类型: Partner
         *3. 行业: Media
         *
         *请回复数字修改对应的信息
         *回复 A 创建销售活动
         *回复 C 添加联系人
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('R');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('1. 名称: 新修改的名字\n2. 类型: Partner\n3. 行业: Media\n\n请回复数字修改对应的信息\n回复 A 创建销售活动\n回复 C 添加联系人', textMessage.Content);
        
        // Create contact with Chinese name
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('C');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('请回复联系人的姓名，邮箱和手机号码（比如：张 学友 jacky.chueng@charket.com 18610026227）', textMessage.Content);
        
        /**
         *姓名：张三
         *邮箱：acme.charket@charket.com
         *电话：1234567890
         *
         *回复 R 返回到客户
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('张三 acme.charket@charket.com 1234567890');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('姓名：三 张\n邮箱：acme.charket@charket.com\n电话：1234567890\n\n回复 R 返回到客户', textMessage.Content);
        
        /**
         *1. 名称: 新修改的名字
         *2. 类型: Partner
         *3. 行业: Media
         *
         *请回复数字修改对应的信息
         *回复 A 创建销售活动
         *回复 C 添加联系人
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('R');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('1. 名称: 新修改的名字\n2. 类型: Partner\n3. 行业: Media\n\n请回复数字修改对应的信息\n回复 A 创建销售活动\n回复 C 添加联系人', textMessage.Content);
        
        // reply incorrect message
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('incorrect message');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('您回复的不在列表, 请重新选择\n', textMessage.Content);
        
        // logout session
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('logout');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('您回复的不在列表, 请重新选择\n', textMessage.Content);
        
        // end session
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('0');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('您回复的不在列表, 请重新选择\n', textMessage.Content);
    }
    
    @isTest
    static void testCreateTaskFromMyAccount()
    {
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
            
        CustomMyAccountsSkillHandler createAccount = new CustomMyAccountsSkillHandler();
        Charket.SkillResponse response = createAccount.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('未找到数据。', textMessage.Content);
        
        Account acc = new Account(Name = 'Charket', Type = 'Other', Industry = 'Other');
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
        *2. 类型: Other
        *3. 行业: Other
        *
        *请回复数字修改对应的信息
        *回复 A 创建销售活动
        *回复 C 添加联系人
        *回复 0 结束
        *回复 logout 退出登录
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('1. 名称: Charket\n2. 类型: Other\n3. 行业: Other\n\n请回复数字修改对应的信息\n回复 A 创建销售活动\n回复 C 添加联系人', textMessage.Content);
        
        /**
        *请回复数字选择销售活动类型
        *1. 记录销售活动
        *2. 创建任务
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('A');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('请回复数字选择销售活动类型\n1. 记录销售活动\n2. 创建任务', textMessage.Content);
        
        // create markting activity
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('请问记录的内容是什么？', textMessage.Content);
        
        /**
        *记录成功，详情如下：
        *
        *活动标题：meeting content
        *日期：2017-07-25
        *记录人：Jair Zheng
        *记录内容：meeting content
        *
        *回复 R 返回到客户
        *回复 0 结束
        *回复 logout 退出登录
        **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('meeting content');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('记录成功，详情如下：\n\n活动标题：meeting content\n日期：2017-07-25\n记录人：Jair Zheng\n记录内容：meeting content\n\n回复 R 返回到客户', textMessage.Content);
        //System.assert(textMessage.Content.contains('记录成功，详情如下：\n\n活动标题：meeting content'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('R');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('A');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        // create task
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('需要安排什么任务？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Task content');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('该任务需要在哪天之前完成？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('周一');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('这个任务是分配给您本人吗？（是，回复1；否则回复同事的名字）', textMessage.Content);
        
        /**
         *任务创建成功，详情如下：
         *
         *任务标题: Task content
         *完成日期: 2017-07-28
         *被分配人: Jair Zheng
         *任务内容: Task content
         *
         *回复 R 返回到客户
         **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('任务创建成功，详情如下：\n\n任务标题: Task content\n完成日期: 2017-07-31\n被分配人: Jair Zheng\n任务内容: Task content\n\n回复 R 返回到客户', textMessage.Content);
        //System.assert(textMessage.Content.contains('任务创建成功，详情如下：\n\n任务标题: Task content'));
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('R');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('A');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        // create task with wrong user name
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('需要安排什么任务？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Task content');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('该任务需要在哪天之前完成？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('周一');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('这个任务是分配给您本人吗？（是，回复1；否则回复同事的名字）', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme charket');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //System.assertEquals('没有找到您的同事，请回复您同事的 Frist Name', textMessage.Content);
        
        /**
         *任务标题: Task content
         *完成日期: 2017-07-31
         *被分配人: Jair Zheng
         *任务内容: Task content
         *
         *回复 R 返回到客户
         **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('很抱歉，还是没有找到您的同事。系统已经自动将任务分配给了您本人，详情如下\n\n任务标题: Task content\n完成日期: 2017-07-31\n被分配人: Jair Zheng\n任务内容: Task content\n\n回复 R 返回到客户', textMessage.Content);
        //System.assert(textMessage.Content.contains('很抱歉，还是没有找到您的同事。系统已经自动将任务分配给了您本人，详情如下\n\n任务标题: Task content'));
        
        // back to account
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('R');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('A');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        // create task this Friday
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('需要安排什么任务？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Task content');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('该任务需要在哪天之前完成？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('这周五');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('这个任务是分配给您本人吗？（是，回复1；否则回复同事的名字）', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('没有找到您的同事，请回复您同事的 Frist Name', textMessage.Content);
        
        List<Profile> profiles = [select Id from Profile];
        User user = new User(
            FirstName = 'acme', 
            LastName = 'charket',
            Username = 'acme.charket@charket.com',
            Email = 'acme.charket@charket.com',
            Alias = 'acmec',
            CommunityNickname = 'acme',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profiles[0].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert user;
        
        /**
         *任务创建成功，详情如下：
         *
         *任务标题: Task content
         *完成日期: 2017-07-28
         *被分配人: acme charket
         *任务内容: Task content
         *
         *回复 R 返回到客户
         **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //////System.assertEquals('任务创建成功，详情如下：\n\n任务标题: Task content\n完成日期: 2017-07-28\n被分配人: acme charket\n任务内容: Task content\n\n回复 R 返回到客户', textMessage.Content);
        //System.assert(textMessage.Content.contains('任务创建成功，详情如下：\n\n任务标题: Task content'));
        
        // back to account
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('R');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('A');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        // create task in next Friday
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('需要安排什么任务？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Task content1');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('该任务需要在哪天之前完成？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('下周五');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('这个任务是分配给您本人吗？（是，回复1；否则回复同事的名字）', textMessage.Content);
        
        User newUser = new User(
            FirstName = 'acme', 
            LastName = 'charket1',
            Username = 'acme.charket1@charket.com',
            Email = 'acme.charket1@charket.com',
            Alias = 'acmec',
            CommunityNickname = 'acme1',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profiles[0].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert newUser;
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('没有找到您的同事，请回复您同事的 Frist Name', textMessage.Content);
        
        /**
         *找到了如下多个同事
         *回复 1 分配给自己
         *回复其它数字分配给对应同事
         *2acme charket3acme charket1
         **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('找到了如下多个同事\n回复 1 分配给自己\n回复其它数字分配给对应同事\n2acme charket3acme charket1', textMessage.Content);
        
        /**
         *任务创建成功，详情如下：
         *
         *任务标题: Task content1
         *完成日期: 2017-08-04
         *被分配人: acme charket1
         *任务内容: Task content1
         *
         *回复 R 返回到客户
         **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('3');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //////System.assertEquals('任务创建成功，详情如下：\n\n任务标题: Task content1\n完成日期: 2017-08-04\n被分配人: acme charket1\n任务内容: Task content1\n\n回复 R 返回到客户', textMessage.Content);
        //System.assert(textMessage.Content.contains('任务创建成功，详情如下：\n\n任务标题: Task content'));
        
        // back to account
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('R');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('A');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        
        // create task assign to acme charket directly
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('需要安排什么任务？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Task content1');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('该任务需要在哪天之前完成？', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('下周五');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('这个任务是分配给您本人吗？（是，回复1；否则回复同事的名字）', textMessage.Content);
        
        /**
         *任务创建成功，详情如下：
         *
         *任务标题: Task content1
         *完成日期: 2017-08-04
         *被分配人: acme charket
         *任务内容: Task content1
         *
         *回复 R 返回到客户
         **/
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme charket');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        //////System.assertEquals('任务创建成功，详情如下：\n\n任务标题: Task content1\n完成日期: 2017-08-04\n被分配人: acme charket\n任务内容: Task content1\n\n回复 R 返回到客户', textMessage.Content);
        //System.assert(textMessage.Content.contains('任务创建成功，详情如下：\n\n任务标题: Task content1'));
    }
    
    @isTest
    static void testMyAccount()
    {
        List<Account> accounts = new List<Account>();
        
        for(Integer i = 0; i < 10; i++)
        {
            Account acc = new Account(Name = 'Charket' + i, Type = 'Other', Industry = 'Other');
            accounts.add(acc);
        }

        insert accounts;

        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
            
        CustomMyAccountsSkillHandler createAccount = new CustomMyAccountsSkillHandler();
        Charket.SkillResponse response = createAccount.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('1. Charket9\n2. Charket8\n3. Charket7\n4. Charket6\n5. Charket5\n6. Charket4\n7. Charket3\n8. Charket2\n9. Charket1\n\n回复对应数字查看客户详情\n回复 N 下一页', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('P');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('You are already at the first page.', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('N');
        session.IsNew = false;
        response = createAccount.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        ////System.assertEquals('You are already at the first page.1. Charket0\n\n回复对应数字查看客户详情\n回复 P 上一页', textMessage.Content);
    }
}