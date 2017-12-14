@isTest
public class OrderiPhoneFlowSkillTest
{
    @isTest
    static void testOrderiPhone()
    {
        Lead lead = new Lead(LastName = 'acme', Company = 'Charket');
        insert lead;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Charket__OpenId__c = 'openId',
            Charket__Lead__c = lead.Id,
            Name = 'acme'
        );
        insert follower;
        
        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        context.WeChatFollowerId = follower.Id;
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize(
            '{"ShouldLogout":false,"ShouldEndSession":false,"Sequences":[],' 
            + '"IsNew":true,"Attributes":{}}', Charket.SkillSession.class);
        
        OrderiPhoneFlowSkill orderiPhone = new OrderiPhoneFlowSkill();
        Charket.SkillResponse response = orderiPhone.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('请选择需要购买的手机类型?\n\n1. iPhone 8\n2. iPhone 8 Plus', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = orderiPhone.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('请选择 iPhone 的颜色?\n\n1. 银色\n2. 金色\n3. 深空灰', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = orderiPhone.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('请选择存储容量\n\n1. 64GB\n2. 256GB', textMessage.Content);
    }
}