global class CharketScanEmailQRCodeHandler extends Charket.CharketEventHandler 
{   
    global override Charket.WeChatApiMessage onNotFollowerScan(Charket.WeChatApiEvent.Scan event)
    {
        return handleQRCode(event);
    }

    global override Charket.WeChatApiMessage onFollowerScan(Charket.WeChatApiEvent.Scan event)
    {
        return handleQRCode(event);
    }
    
    @TestVisible
    private Charket.WeChatApiMessage.Text handleQRCode(Charket.WechatApiEvent.Scan event)
    {
        String openId;
        String ticket;

        if(Test.isRunningTest())
        {
            openId = 'client_abc123';
            ticket = '00000000000000000';
        }
        else
        {
            openId = event.FromUserId;
            ticket = event.Ticket;
        }
        
        List<Charket__WeChatQRCode__c> qrCodes = [select Charket__WhatId__c, Charket__Ticket__c, Charket__IsActive__c  
                from Charket__WeChatQRCode__c where Charket__Ticket__c = :ticket limit 1];

        if(qrCodes.size() > 0 && String.isNotBlank(qrCodes[0].Charket__WhatId__c))
        {
            String oldLeadOrContactId = qrCodes[0].Charket__WhatId__c;
            
            if(Id.valueOf(oldLeadOrContactId).getSObjectType() != Lead.sObjectType 
                    && Id.valueOf(oldLeadOrContactId).getSObjectType() != Contact.sObjectType)
            {
                return null;
            }
            
            if(qrCodes[0].Charket__IsActive__c == false)
            {
                String tips = '当前二维码已经被使用，如果需要报名参加会议，可直接回复"报名"。';
                return new Charket.WeChatApiMessage.Text(tips);
            }
            
            List<Charket__WeChatFollower__c> followers = [select Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c 
                    where Charket__OpenId__c = :openId limit 1]; 
                    
            qrCodes[0].Charket__IsActive__c = false;
            
            update qrCodes[0];

            try
            {
                if(followers.size() > 0 && (followers[0].Charket__Lead__c != null || followers[0].Charket__Contact__c != null))
                {              
                    String newLeadOrContactId = followers[0].Charket__Lead__c != null ? followers[0].Charket__Lead__c : followers[0].Charket__Contact__c;

                    if(followers[0].Charket__Lead__c == oldLeadOrContactId 
                            || followers[0].Charket__Contact__c == oldLeadOrContactId)
                    {
                        return null;
                    }
                    else
                    {
                        if(Id.valueOf(newLeadOrContactId).getSObjectType() == Lead.sObjectType 
                                && Id.valueOf(oldLeadOrContactId).getSObjectType() == Lead.sObjectType)
                        {
                            merge new Lead(Id = oldLeadOrContactId) new Lead(Id = newLeadOrContactId);
                        }
                        else if(Id.valueOf(newLeadOrContactId).getSObjectType() == Contact.sObjectType 
                                && Id.valueOf(oldLeadOrContactId).getSObjectType() == Contact.sObjectType)
                        {
                            merge new Contact(Id = oldLeadOrContactId) new Contact(Id = newLeadOrContactId);
                        }
                    }
                }
                else
                {
                    Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(Charket__OpenId__c = openId);

                    if(Id.valueOf(oldLeadOrContactId).getSObjectType() == Lead.sObjectType)
                    {
                        follower.Charket__Lead__c = oldLeadOrContactId;
                    }
                    else if(Id.valueOf(oldLeadOrContactId).getSObjectType() == Contact.sObjectType)
                    {
                        follower.Charket__Contact__c = oldLeadOrContactId;
                    }

                    upsert follower Charket__WeChatFollower__c.Charket__OpenId__c;
                }
            }
            catch(Exception ex)
            {
                insert (new Charket__Log__c(Charket__ApexCodeName__c = 'CharketScanEmailQRCodeHandler', 
                        Charket__Message__c = openId, Charket__Data__c = String.valueOf(followers)));
                return null;
            }
        }
        
        return null;
    }
}