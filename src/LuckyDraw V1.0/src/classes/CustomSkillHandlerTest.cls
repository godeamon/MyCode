@isTest
private class CustomSkillHandlerTest 
{   
    @isTest
    static void testCreateLeadWithChineseName()
    {
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
        
        CustomSkillHandler createLead = new CustomSkillHandler();
        Charket.SkillResponse response = createLead.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('1. What\'s his/her name?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('张三');
        session.IsNew = false;
        response = createLead.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('2. Which company does he/she work for?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Charket');
        session.IsNew = false;
        response = createLead.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('3. What\'s his/her email address? Reply 0 if you don\'t know.', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme.charket@charket.com');
        session.IsNew = false;
        response = createLead.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('4. What\'s his/her mobile number? Reply 0 if you don\'t know.', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1234567890');
        session.IsNew = false;
        response = createLead.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('The lead was created with the following details:\n\nName: 三 张\nCompany: Charket\nEmail: acme.charket@charket.com\nMobile: 1234567890', textMessage.Content);
    }
    
    @isTest
    static void testCreateLeadWithEnglishName()
    {
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize('{"Attributes":{}, "Sequences":[], "IsNew":true, "ShouldEndSession":false, "ShouldLogout":false}', Charket.SkillSession.class);
        
        CustomSkillHandler createLead = new CustomSkillHandler();
        Charket.SkillResponse response = createLead.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('1. What\'s his/her name?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Acme Charket');
        session.IsNew = false;
        response = createLead.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('2. Which company does he/she work for?', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('Charket');
        session.IsNew = false;
        response = createLead.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('3. What\'s his/her email address? Reply 0 if you don\'t know.', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('acme.charket@charket.com');
        session.IsNew = false;
        response = createLead.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('4. What\'s his/her mobile number? Reply 0 if you don\'t know.', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1234567890');
        session.IsNew = false;
        response = createLead.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('The lead was created with the following details:\n\nName: Acme Charket\nCompany: Charket\nEmail: acme.charket@charket.com\nMobile: 1234567890', textMessage.Content);
    }
}