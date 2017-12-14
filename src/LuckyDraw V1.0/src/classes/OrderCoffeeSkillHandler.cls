global class OrderCoffeeSkillHandler implements Charket.CharketSkillHandler
{
    private String textMessage = '';
    private final String ERROR_MESSAGE = '您的选择不在列表中，请重新选择\nInvalid option selected, please reply with a valid bullet item number';

    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {  
        if(!session.ShouldEndSession && (repeatScan(context, session)) && ((session.Attributes.get('isWinning') != null && Boolean.valueOf(session.Attributes.get('isWinning'))) || checkUser(context.WeChatFollowerId, session, context)))
        {
            if(context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text)
            {
                String content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content.trim();

                if(!session.IsNew)
                {
                    if(session.Sequences.size() > 0)
                    {
                        String lastSession = session.Sequences.get(session.Sequences.size() - 1);

                        try
                        {
                            if(lastSession == 'ChooseCoffeeType')
                            {
                                String coffeeType = getCoffeeType(content);
                                if(coffeeType == null)
                                {
                                    throw new OrderCoffeeSkillHandlerException(ERROR_MESSAGE);
                                }
                                session.Attributes.put('CoffeeType', coffeeType.split(' / ')[0]);
                                session.Attributes.put('CoffeeTypeEng', coffeeType.split(' / ')[1]);

                                session.Sequences.add('IcedOrHot');
                                textMessage = '请选择冷饮或者热饮(有些饮品类型不适用)\nPlease choose either hot or cold beverage (may not applicable to certain drinks)\n\n1. 热饮 / Hot\n2. 冷饮 / Cold';
                            }
                            else if(lastSession == 'IcedOrHot')
                            {
                                if(content != '1' && content != '2')
                                {
                                    throw new OrderCoffeeSkillHandlerException(ERROR_MESSAGE);
                                }
                                session.Attributes.put('IcedOrHot', content == '1' ? '热饮' : '冷饮');
                                session.Attributes.put('IcedOrHotEng', content == '1' ? 'Hot' : 'Cold');

                                session.Sequences.add('ChooseCupSize');
                                textMessage = '请选择杯型\nPlease choose the size of your drink\n';
                                for(Integer i = 1; i < 4; i++)
                                {
                                    textMessage += '\n' + i + '. ' + getCupSize(String.valueOf(i));
                                }
                            }
                            else if(lastSession == 'ChooseCupSize')
                            {
                                String cupSize = getCupSize(content);
                                if(cupSize == null)
                                {
                                    throw new OrderCoffeeSkillHandlerException(ERROR_MESSAGE);
                                }
                                session.Attributes.put('CupSize', cupSize.split(' / ')[0]);
                                session.Attributes.put('CupSizeEng', cupSize.split(' / ')[1]);
                                session.Sequences.add('ChooseMilk');
                                textMessage = '请选择牛奶或豆奶\nPlease choose either regular milk or soy milk\n\n1. 牛奶 / Regular Milk\n2. 豆奶 / Soy Milk';
                            }
                            else if (lastSession == 'ChooseMilk')
                            {
                                if(content != '1' && content != '2')
                                {
                                    throw new OrderCoffeeSkillHandlerException(ERROR_MESSAGE);
                                }

                                session.Attributes.put('MilkType', content == '1' ? '牛奶' : '豆奶');
                                session.Attributes.put('MilkTypeEng', content == '1' ? 'Regular Milk' : 'Soy Milk');

                                textMessage = '收到，我们会发送给您一张饮品兑换券，并在饮品准备好的时候通过微信提醒您。\nAll done! We will send you a coupon to redeem the free drink. We will also send you a notification once your drink is ready.';
                                String stickerInfo = session.Attributes.get('FollowerName') + '\n'
                                    + session.Attributes.get('CupSize') + ' / ' + session.Attributes.get('IcedOrHot')
                                    + ' / ' + session.Attributes.get('CoffeeType') + ' / ' + session.Attributes.get('MilkType') + '\n'
                                    + session.Attributes.get('CupSizeEng') + ' / ' + session.Attributes.get('IcedOrHotEng')
                                    + ' / ' + session.Attributes.get('CoffeeTypeEng') + ' / ' + session.Attributes.get('MilkTypeEng');

                                Task newTask = new Task(
                                    WhoId = session.Attributes.get('FollowerLeadOrContactId'),
                                    Subject = 'Lucky Draw - Free Drink',
                                    ActivityDate = Date.today(),
                                    Status = 'Not Started',
                                    Description = stickerInfo,
                                    OwnerId = session.Attributes.get('AssignToId')
                                );

                                try
                                {
                                    insert newTask;
                                    session.ShouldEndSession = true;
                                }
                                catch(Exception e)
                                {
                                    Charket__Log__c log = new Charket__Log__c(
                                        Charket__ApexCodeName__c = 'OrderCoffeeSkillHandler',
                                        Charket__Message__c = e.getMessage() + '\n\nLine Number:' + e.getLineNumber() + '\n\nTaskInfo:' + newTask
                                    );
                                    insert log;
                                }
                            }
                        }
                        catch(Exception e)
                        {
                            textMessage = e.getMessage();
                        }
                    }
                }
            }
            else
            {
                session.Sequences.add('ChooseCoffeeType');
                textMessage += String.isNotBlank(textMessage) ? '\n\n您喜欢尝试那种类型的饮品？\nWhich type of drink would you like?\n' : '您喜欢尝试那种类型的饮品？\nWhich type of drink would you like?\n';
                for(Integer i = 1; i < 10; i++)
                {
                    textMessage += '\n' + i + '. ' + getCoffeeType(String.valueOf(i));
                }
            }
        }
        
        return new Charket.SkillResponse(new Charket.WeChatApiMessage.Text(textMessage));
    }
    
    private Boolean checkUser(String followerId, Charket.SkillSession session, Charket.SkillContext context)
    {
        Charket__WeChatFollower__c follower = [select Id, Name, Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c where Id = :followerId limit 1];

        Charket.WeChatApiEvent.Scan event = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
        List<Charket__WeChatQRCode__c> qrCodes = [select OwnerId, Charket__WhatId__c from Charket__WeChatQRCode__c where Charket__Ticket__c = :event.Ticket];
        session.Attributes.put('AssignToId', qrCodes[0].OwnerId);

        List<CampaignMember> member = [select Id, Status from CampaignMember where Status = 'Lucky Draw - Coffee' and CampaignId = :qrCodes[0].Charket__WhatId__c and ((LeadId = :follower.Charket__Lead__c and LeadId != null) or (ContactId = :follower.Charket__Contact__c and ContactId != null))];
        if(member.size() > 0)
        {
            session.Attributes.put('isWinning', 'true');
            session.Attributes.put('FollowerName', follower.Name);
            session.Attributes.put('FollowerLeadOrContactId', String.isNotBlank(follower.Charket__Lead__c) ? follower.Charket__Lead__c : follower.Charket__Contact__c);
            textMessage += 'Lucky you! It\'s our pleasure to offer you a free drink.';
        }
        else
        {
            textMessage += 'Sorry, this QR code is invalid for your WeChat account [难过]';
            session.ShouldEndSession = true;
        }
        return member.size() > 0;
    }
    
    private String getCoffeeType(String typeNum)
    {
        Map<String, String> coffeeType = new Map<String, String>{
            '1' => '美式 / Americano',
            '2' => '拿铁 / Latte',
            '3' => '香草拿铁 / Vanilla Latte',
            '4' => '榛果拿铁 / Hazelnut Latte',
            '5' => '焦糖玛奇朵 / Caramel Macchiato',
            '6' => '咖啡星冰乐 / Caffe Frappuccino',
            '7' => '抹茶星冰乐 / Green Tea Frappuccino',
            '8' => '香草星冰乐 / Vanila Frappuccino',
            '9' => '芒果豆奶星冰乐 / Mango Soy Milk Frappuccino'
        };
        return coffeeType.get(typeNum);
    }

    private String getCupSize(String sizeNum)
    {
        Map<String, String> cupSize = new Map<String, String>{
            '1' => '中杯 / Tall',
            '2' => '大杯 / Grande',
            '3' => '超大杯 / Venti'
        };
        return cupSize.get(sizeNum);
    }

    private Boolean repeatScan(Charket.SkillContext context, Charket.SkillSession session)
    {
        if(context.WeChatEvent != null)
        {
            Charket__WeChatFollower__c follower = [select Id, Name, Charket__OpenId__c, Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c where Id = :context.WeChatFollowerId limit 1];

            Charket.WeChatApiEvent.Scan event = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
            List<Charket__WeChatQRCode__c> qrCodes = [select OwnerId, Charket__WhatId__c from Charket__WeChatQRCode__c where Charket__Ticket__c = :event.Ticket];
            if([select Id, Charket__Type__c, Charket__WeChatFollower__r.Name from Charket__WeChatEvent__c where Charket__WeChatQRCode__c = :qrCodes[0].Id and Charket__WeChatFollower__r.Charket__OpenId__c = :follower.Charket__OpenId__c].size() > 0)
            {
                session.ShouldEndSession = true;
                return false;
            }
        }

        return true;
    }

    public class OrderCoffeeSkillHandlerException extends Exception {}
}