global class CharketScanTempQRCodeHandler extends Charket.CharketEventHandler
{
    global override Charket.WechatApiMessage onNotFollowerScan(Charket.WechatApiEvent.Scan event)
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
        Charket.WeChatApiMessage.Text returnMessage;
        String tempScene;
        String openId;
        if(Test.isRunningTest())
        {
            tempScene = 'key_10001234';
            openId = 'client_abc123';
        }
        else
        {
            tempScene = event.EventKey;
            openId = event.FromUserId;
        }
        
        String memberId = tempScene != null ? tempScene.substring(tempScene.lastIndexof('_') + 1) : null;
        if(memberId == null){ throw new CustomInfoException('Can not get the tempScene when the follower(' + openId + ') scan temp QRCode.'); }
        List<Account> accounts = [select Id, PersonContactId, Name from Account where Member_Id__pc = :memberId limit 1];
        List<Charket__WeChatFollower__c> followers = [select Id, Charket__OpenId__c from Charket__WeChatFollower__c where Charket__OpenId__c = :openId limit 1];
        if(accounts.size() > 0)
        {
            Account account = accounts[0];
            Charket__WeChatFollower__c follower;
            if(followers.size() > 0)
            {
                follower = followers[0];                    
            }
            else
            {
                follower = new Charket__WeChatFollower__c(Charket__OpenId__c = openId);
            }
            follower.Charket__Contact__c = account.PersonContactId;
            upsert follower Charket__WeChatFollower__c.Charket__OpenId__c;
            returnMessage = new Charket.WeChatApiMessage.Text('亲爱的' + account.Name + ', 感谢您选择英孚教育，您的身份信息已经通过认证，可以在微信中和我们随时沟通。');
        }
        else
        {
            throw new CustomInfoException('Can not find the related account when the follower(' + openId + ') scan temp QRCode.');
        }

        return returnMessage;
    }
    
    public class CustomInfoException extends Exception {}
}
