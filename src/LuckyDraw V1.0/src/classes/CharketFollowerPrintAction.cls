/**
 * Update follower fields to print for meeting
 */
global without sharing class CharketFollowerPrintAction
{
    global class UpdateFollowerPrintRequest
    {
        @InvocableVariable(label='Current Object ID' required=true)
        global Id objectId;

        @InvocableVariable(label='WeChat Account ID' required=true)
        global Id accountId;

        @InvocableVariable(label='Contact/Lead ID' required=true)
        global Id whoId;
    }

    /**
     * Sends the wechat template message
     */
    @InvocableMethod(label = 'Follower Print Update')
    global static void updateFollowerPrint(List<UpdateFollowerPrintRequest> requests)
    {
        UpdateFollowerPrintRequest request = requests[0];
        
        String wechatAccountId = request.accountId;
        String whoId = request.whoId;

        if(String.isNotBlank(whoId) && String.isNotBlank(wechatAccountId))
        {
            List<Charket__WeChatFollower__c> followers = [select Id,Charket__Contact__c,Charket__Lead__c
                    from Charket__WeChatFollower__c
                    where (Charket__Contact__c = :whoId OR Charket__Lead__c = :whoId)
                    and Charket__WeChatAccount__c = :wechatAccountId limit 1];
            if(followers.size() == 0)
            { 
                throw new WeChatTemplateAsyncJobException('The follower doesn\'t exist.'); 
            }
            String badgeName = '';
            String badgeCompany = '';
            if(String.isNotBlank(followers[0].Charket__Contact__c))
            {
                List<Contact> contacts = [select Id, Name, Account.Name from Contact where Id = :whoId limit 1];
                if(contacts.size() > 0)
                {
                    badgeName = contacts[0].Name;
                    badgeCompany = contacts[0].Account.Name;
                }
            }
            else if(String.isNotBlank(followers[0].Charket__Lead__c))
            {
                List<Lead> leads = [select Id, Name, Company from Lead where Id = :whoId limit 1];
                if(leads.size() > 0)
                {
                    badgeName = leads[0].Name;
                    badgeCompany = leads[0].Company;
                }
            }
            if(String.isNotBlank(badgeName) && String.isNotBlank(badgeCompany))
            {
                followers[0].BadgeName__c = badgeName;
                followers[0].BadgeCompany__c = badgeCompany;
                followers[0].BadgePrintDate__c = Datetime.now();
                update followers[0];
            }
        }
    }

    public class WeChatTemplateAsyncJobException extends Exception {}
}