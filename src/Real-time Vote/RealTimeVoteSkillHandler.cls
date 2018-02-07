global class RealTimeVoteSkillHandler implements Charket.CharketSkillHandler
{
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage.Text returnMsg;
        String content;
        list<RealTimeVote__e> eventList = new list<RealTimeVote__e>();

        try
        {
            RealTimeVote__e event = new RealTimeVote__e();
            if(session.IsNew && context.WeChatEvent != null && context.WeChatEvent instanceOf Charket.WeChatApiEvent.Scan)
            {
                Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
                List<Charket__WeChatQRCode__c> qrcodes = [select Id, Name from Charket__WeChatQRCode__c where Charket__Ticket__c = :scanEvent.Ticket limit 1];
                if(qrcodes.size() > 0)
                {
                    session.Attributes.put('qrCodId', qrcodes[0].Id);
                    event.UserSentMessage__c = 'NoAnswer';
                    event.WeChatFollowerId__c = context.WeChatFollowerId;
                    event.WeChatQRCodeId__c = qrcodes[0].Id;
                    eventList.add(event);
                    EventBus.publish(eventList);

                    returnMsg = new Charket.WeChatApiMessage.Text('欢迎参加本次投票！');
                    return new Charket.SkillResponse(returnMsg);
                }
                else
                {
                    returnMsg = new Charket.WeChatApiMessage.Text('欢迎参加本次投票！');
                    return new Charket.SkillResponse(returnMsg);
                }
            }
            else if(!session.IsNew && context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text )
            {
                content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content;
                if(content.equals('0'))
                {
                    session.ShouldEndSession = true;
                    returnMsg = new Charket.WeChatApiMessage.Text('您已退出本次投票，如想继续投票请扫描投票二维码。');
                    return new Charket.SkillResponse(returnMsg);
                }

                event.UserSentMessage__c = content;
                event.WeChatFollowerId__c = context.WeChatFollowerId;
                event.WeChatQRCodeId__c = session.Attributes.get('qrCodId');
                eventList.add(event);
                EventBus.publish(eventList);
            }
            else if(context.WeChatEvent != null && context.WeChatEvent instanceOf Charket.WeChatApiEvent.Scan)
            {
                Charket.WeChatApiEvent.Scan scanEvent = (Charket.WeChatApiEvent.Scan)context.WeChatEvent;
                List<Charket__WeChatQRCode__c> qrcodes = [select Id, Name from Charket__WeChatQRCode__c where Charket__Ticket__c = :scanEvent.Ticket limit 1];
                session.Attributes.clear();
                session.Attributes.put('qrCodId', qrcodes[0].Id);
                event.UserSentMessage__c = 'NoAnswer';
                event.WeChatFollowerId__c = context.WeChatFollowerId;
                event.WeChatQRCodeId__c = session.Attributes.get('qrCodId');
                eventList.add(event);
                Database.SaveResult sr = EventBus.publish(eventList[0]);

                returnMsg = new Charket.WeChatApiMessage.Text('');
                return new Charket.SkillResponse(returnMsg);
            }
            else
            {
                event.UserSentMessage__c = 'NoAnswer';
                event.WeChatFollowerId__c = context.WeChatFollowerId;
                event.WeChatQRCodeId__c = session.Attributes.get('qrCodId');
                eventList.add(event);
                Database.SaveResult sr = EventBus.publish(eventList[0]);

                returnMsg = new Charket.WeChatApiMessage.Text('');
                return new Charket.SkillResponse(returnMsg);
            }
        }
        catch(Exception e)
        {
            return new Charket.SkillResponse(new Charket.WeChatApiMessage.Text(''));
        }

        return new Charket.SkillResponse(new Charket.WeChatApiMessage.Text(''));
    }
}