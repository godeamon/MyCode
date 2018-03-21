public class WeChatLeadController
{
    public WeChatLeadController()
    {
        ErrorMessage = '';
        IsSaved = false;
    }

    public String LastName { get; set; }
    public String MobilePhone { get; set; }
    public String Company { get; set; }
    public String Email { get; set; }
    public String ErrorMessage { get; set; }
    public Boolean IsSaved { get; set; }
    

    public PageReference save()
    {
        errorMessage = '';
        String openId; 
        String leadId;
        String contactId;

        try
        {
            if(String.isBlank(leadId))
            {
                openId = (String.isBlank(openId)) ? getOpenId() : openId;

                List<WeChatFollower__c> followers = [select Lead__c, Contact__c 
                        from WeChatFollower__c where OpenId__c = :openId and OpenId__c != null];
                
                if(followers.size() > 0)
                {
                    leadId = followers[0].Lead__c;
                    contactId = followers[0].Contact__c;
                }
            }

            if(String.isNotBlank(contactId))
            {
                contactId = saveContact(contactId);
            }
            else 
            {
                leadId = saveLead(leadId);
            }

            updateCampaignMemberStatus(leadId, contactId);
            
            IsSaved = true;
        }
        catch(Exception ex)
        {
            errorMessage = ex.getMessage();
        }
        
        return null;
    }
    
    private String getOpenId()
    {
        String result;

        String wechatCode = ApexPages.currentPage().getParameters().get('code');
        String wechatAccountId = ApexPages.currentPage().getParameters().get('accId');
        
        WeChatClient client = new WeChatClient(wechatAccountId);
        WeChatApiOAuth oauth = client.getOAuth();
        
        if(wechatCode != null)
        {
            WeChatApiOAuth.AuthTokenResponse response = oauth.handleCallback(wechatCode, '');
            result = response.OpenId;
        }
        
        return result;
    }

    private String saveLead(Id leadId)
    {
        Lead lead = new Lead(Id=leadId);
        lead.LastName = LastName;
        lead.Email = Email;
        lead.Company = Company;
        lead.LeadSource = 'WeChat';
        lead.Description = 'From WeChat lead page.';
        
        upsert lead;
        
        return lead.Id;
    }

    private String saveContact(Id contactId)
    {
        Contact contact = new Contact(Id=contactId);
        contact.Email = Email;
        contact.LastName = LastName;
        contact.LeadSource = 'WeChat';
        contact.Description = 'From WeChat lead page.';
        
        upsert contact;
        
        return contact.Id;
    }

    private void updateCampaignMemberStatus(String leadId, String contactId)
    {
        String campaignId = ApexPages.currentPage().getParameters().get('cId');
        String status = ApexPages.currentPage().getParameters().get('cstatus');
        
        if(String.isBlank(campaignId)) { return; }
            
        List<CampaignMember> members = [select Id from CampaignMember 
                where CampaignId = :campaignId and
                 (LeadId = :leadId or ContactId = :contactId)];
        
        if(members.size() > 0)
        {
            CampaignMember member = members[0];
            member.Status = (String.isNotBlank(status)) ? status : 'Responded';
            update member;
        }
    }
}