@isTest
public class OrderCoffeeSkillHandlerTest
{
    @isTest
    static void orderCoffeeTest()
    {
        Lead lead = new Lead(LastName = 'acme', Company = 'Charket');
        insert lead;
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Charket__OpenId__c = 'openId',
            Charket__Lead__c = lead.Id,
            Name = 'acme'
        );
        insert follower;
        
        Profile p = [select Id from Profile where Name = 'Standard User'];
        User testUser = new User();
        testUser.Email = 'test@test.com';
        testUser.Username = 'acme@testuser.com';
        testUser.LastName = 'test';
        testUser.Alias = 'test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ManagerId = UserInfo.getUserId();
        testUser.ProfileId = p.Id;
        insert testUser;

        Charket.SkillContext context = (Charket.SkillContext)JSON.deserialize('{}', Charket.SkillContext.class);
        Charket.SkillSession session = (Charket.SkillSession)JSON.deserialize(
            '{"ShouldLogout":false,"ShouldEndSession":false,"Sequences":["ChooseCoffeeType"],' 
            + '"IsNew":true,"Attributes":{"FollowerLeadOrContactId":"' + lead.Id + '", ' 
            + ' "FollowerName":"acme","isWinning":"true","AssignToId":"' + testUser.Id + '"}}', Charket.SkillSession.class);
        
        OrderCoffeeSkillHandler orderCoffee = new OrderCoffeeSkillHandler();
        Charket.SkillResponse response = orderCoffee.execute(context, session);
        Charket.WeChatApiMessage.Text textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('您喜欢尝试那种类型的饮品？\nWhich type of drink would you like?\n\n1. 美式 / Americano\n2. 拿铁 / Latte\n3. 香草拿铁 / Vanilla Latte\n4. 榛果拿铁 / Hazelnut Latte\n5. 焦糖玛奇朵 / Caramel Macchiato\n6. 咖啡星冰乐 / Caffe Frappuccino\n7. 抹茶星冰乐 / Green Tea Frappuccino\n8. 香草星冰乐 / Vanila Frappuccino\n9. 芒果豆奶星冰乐 / Mango Soy Milk Frappuccino', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = orderCoffee.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('请选择冷饮或者热饮(有些饮品类型不适用)\nPlease choose either hot or cold beverage (may not applicable to certain drinks)\n\n1. 热饮 / Hot\n2. 冷饮 / Cold', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('1');
        session.IsNew = false;
        response = orderCoffee.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('请选择杯型\nPlease choose the size of your drink\n\n1. 中杯 / Tall\n2. 大杯 / Grande\n3. 超大杯 / Venti', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('3');
        session.IsNew = false;
        response = orderCoffee.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('请选择牛奶或豆奶\nPlease choose either regular milk or soy milk\n\n1. 牛奶 / Regular Milk\n2. 豆奶 / Soy Milk', textMessage.Content);
        
        context.WeChatMessage = new Charket.WeChatApiMessage.Text('2');
        session.IsNew = false;
        response = orderCoffee.execute(context, session);
        textMessage = (Charket.WeChatApiMessage.Text)response.WeChatMessage;
        System.assertEquals('收到，我们会发送给您一张饮品兑换券，并在饮品准备好的时候通过微信提醒您。\nAll done! We will send you a coupon to redeem the free drink. We will also send you a notification once your drink is ready.', textMessage.Content);
    }

}