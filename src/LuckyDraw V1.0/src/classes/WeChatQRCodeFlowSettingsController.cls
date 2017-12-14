public class WeChatQRCodeFlowSettingsController
{
    private static String qrCodeId = ApexPages.currentPage().getParameters().get('id');
    private Charket__WeChatQRCode__c qrCode;
    private String moreInfo;
    private String templateId;
    private String messageId;

    public WeChatQRCodeFlowSettingsController()
    {
        qrCode = [select Name, Charket__WhatId__c, MoreInfo__c from Charket__WeChatQRCode__c where Id = :qrCodeId limit 1];
        if(String.isNotBlank(qrCode.MoreInfo__c))
        {
            moreInfo = qrCode.MoreInfo__c.replace('\\n', '@@');
        }
        Boolean whetherAttended = VerifyJSONFormat();

        CampaignMemberStatus = 'Responded';
        CampaignMemberStatusSelectOptions = new List<SelectOption>();
        CampaignMemberStatusSelectOptions.add(new SelectOption('Responded','Responded'));

        if(String.isNotBlank(qrCode.Charket__WhatId__c))
        {
            Schema.SObjectType sObjectType = ((Id)qrCode.Charket__WhatId__c).getSobjectType();

            if(sObjectType == Schema.Campaign.SObjectType)
            {
                List<CampaignMemberStatus> CampaignMemberStatuss = [select Id, Label from CampaignMemberStatus where CampaignId = :qrCode.Charket__WhatId__c and Label != null];

                if(CampaignMemberStatuss.size() > 0)
                {
                    CampaignMemberStatusSelectOptions.clear();

                    for(CampaignMemberStatus campaignMemberStatus : CampaignMemberStatuss)
                    {
                        CampaignMemberStatusSelectOptions.add(new SelectOption(campaignMemberStatus.Label,campaignMemberStatus.Label));
                    }
                }
            }
        }

        QRCodeName = qrCode.Name;
        RegisterOrCheckIn = 'Register';

        IsPrint = false;
        HasSuccess = '您已签到成功';
        NotificationTemplateWrapper = new WeChatNotificationTemplateWrapper();
        MessageWrapper = new WeChatMessageWrapper();

        if(String.isNotBlank(moreInfo))
        {
            parseJSONGeneral();
            if(whetherAttended)
            {
                RegisterOrCheckIn = 'true';
                parseJSONForCheckIn();
            }
        }

        getNotificationTemplateAndMessageName();
        getNotificationTemplateAndMessageId();
    }

    public String WeChatMessageId { get; set; }
    public String NotificationTemplateId { get; set; }
    public WeChatMessageWrapper MessageWrapper { get; set; }
    public WeChatNotificationTemplateWrapper NotificationTemplateWrapper { get; set;}
    public String QRCodeName { get; set; }
    public String JSONResult { get; set; }
    public String RegisterOrCheckIn { get; set; }

    public String FormBanner { get; set; }
    public String FormTitle { get; set; }
    public String CampaignMemberStatus { get; set; }
    public List<SelectOption> CampaignMemberStatusSelectOptions { get; set; }

    public Boolean IsPrint { get; set; }
    public String HasSuccess { get; set; }

    public PageReference save()
    {
        if(RegisterOrCheckIn.equals('Register'))
        {
            generateJSONForRegister();
        }
        else
        {
            generateJSONForCheckIn();
        }

        qrCode.MoreInfo__c = JSONResult;
        update qrCode;

        PageReference pageReference = new PageReference('/'+ qrCodeId);
        pageReference.setRedirect(true);
        return pageReference;
    }

    public PageReference cancel()
    {
        PageReference pageReference = new PageReference('/'+ qrCodeId);
        pageReference.setRedirect(true);
        return pageReference;
    }

    private void getNotificationTemplateAndMessageName()
    {
        if(String.isNotBlank(NotificationTemplateWrapper.TempId))
        {
            List<Charket__WeChatNotificationTemplate__c> weChatNotificationTemplates = [select Id, Name from Charket__WeChatNotificationTemplate__c where Id = :NotificationTemplateWrapper.TempId];
            if(weChatNotificationTemplates.size() > 0)
            {
                NotificationTemplateWrapper.Name = weChatNotificationTemplates[0].Name;
            }
        }
        
        if(String.isNotBlank(MessageWrapper.MessageId))
        {
            List<Charket__WeChatMessage__c> weChatMessages = [select Id, Name from Charket__WeChatMessage__c where Id = :MessageWrapper.MessageId];
            if(weChatMessages.size() > 0)
            {
                MessageWrapper.Name = weChatMessages[0].Name;
            }
        }
    }

    private void getNotificationTemplateAndMessageId()
    {
        List<Charket__WeChatMessage__c> wechatMessages = [select id from Charket__WeChatMessage__c];
        if(wechatMessages.size() > 0)
        {
            WeChatMessageId = ((String)wechatMessages[0].Id).subString(0, 3);
        }

        List<Charket__WeChatNotificationTemplate__c> notificationTemplates = [select id from Charket__WeChatNotificationTemplate__c];
        if(notificationTemplates.size() > 0)
        {
            NotificationTemplateId = ((String)notificationTemplates[0].Id).subString(0, 3);
        }
    }

    //JSON Validation.
    private Boolean VerifyJSONFormat()
    {
        try
        {
            JSONParser jsonParser = JSON.createParser(moreInfo);
            while (jsonparser.nextToken() != null)
            {
                if ((jsonparser.getCurrentToken() == JSONToken.FIELD_NAME) && (jsonparser.getText() == 'IsAttended'))
                {
                    return true;
                }
            }
            return false;
        }
        catch(Exception e)
        {
            return false;
        }
    }

    //Parse JSON
    private void parseJSONGeneral()
    {
        try
        {
            WeChatQRCodeFlowSettingsController.JsonParserWrapper jsonParserWrapper = (WeChatQRCodeFlowSettingsController.JsonParserWrapper)JSON.deserialize(moreInfo, WeChatQRCodeFlowSettingsController.JsonParserWrapper.class);
            FormBanner = jsonParserWrapper.formBanner;
            FormTitle = jsonParserWrapper.formTitle;
            NotificationTemplateWrapper.TempId = jsonParserWrapper.templateId;
            MessageWrapper.MessageId = jsonParserWrapper.messageId;
            CampaignMemberStatus = jsonParserWrapper.campaignMemberStatus;
        }
        catch(Exception e)
        {
            insert (new Charket__Log__c(Charket__ApexCodeName__c = 'WeChatQRCodeFlowSettingsController', Charket__Message__c = e.getMessage()));
        }
    }

    private void parseJSONForCheckIn()
    {
        WeChatQRCodeFlowSettingsController.JsonParserWrapper jsonParserWrapper = (WeChatQRCodeFlowSettingsController.JsonParserWrapper)JSON.deserialize(moreInfo, WeChatQRCodeFlowSettingsController.JsonParserWrapper.class);
        IsPrint = jsonParserWrapper.isPrint;
        HasSuccess = jsonParserWrapper.hasSuccessLabel;
    }

    //Generate JSON
    private void generateJSONForRegister()
    {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();

        generator.writeStringField('FormBanner', FormBanner);
        generator.writeStringField('FormTitle', FormTitle);
        generator.writeStringField('TemplateId', NotificationTemplateWrapper.TempId);
        generator.writeStringField('MessageId', MessageWrapper.MessageId);
        generator.writeStringField('CampaignMemberStatus', CampaignMemberStatus);

        generator.writeEndObject();
        JSONResult = generator.getAsString().replaceAll( '\\s+', '');
    }

    private void generateJSONForCheckIn()
    {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();

        generator.writeBooleanField('IsAttended', true);
        generator.writeBooleanField('IsPrint', IsPrint);
        generator.writeStringField('CampaignMemberStatus', CampaignMemberStatus);
        generator.writeStringField('TemplateId', NotificationTemplateWrapper.TempId);
        generator.writeStringField('MessageId', MessageWrapper.MessageId);
        generator.writeStringField('FormBanner', FormBanner);
        generator.writeStringField('FormTitle', FormTitle);
        generator.writeStringField('HasSuccessLabel', HasSuccess);

        generator.writeEndObject();
        JSONResult = generator.getAsString().replace('\\\\', '\\').replaceAll( '\\s+', '');
    }

    public class WeChatNotificationTemplateWrapper
    {
        public String TempId { get; set; }
        public String Name { get; set; }

    }

    public class WeChatMessageWrapper
    {
        public String MessageId { get; set; }
        public String Name { get; set; }
    }

    //JSON inner calss
    public class JsonParserWrapper
    {
        public String formBanner;
        public String formTitle;
        public String templateId;
        public String messageId;
        public String campaignMemberStatus;
        public Boolean isPrint;
        public String hasSuccessLabel;
    }
}