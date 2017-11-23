public class WeChatQRCodeFlowSettingsController
{
    private static String qrCodeId = ApexPages.currentPage().getParameters().get('id');
    private Charket__WeChatQRCode__c qrCode;
    private String moreInfo;
    private String successTemplateId;
    private String successMessageId;
    private static List<String> statusList = new List<String>();
    
    public WeChatQRCodeFlowSettingsController()
    {
        qrCode = [select Name, Charket__WhatId__c, MoreInfo__c, Charket__WeChatAccount__c from Charket__WeChatQRCode__c where Id = :qrCodeId limit 1];
        
        if(String.isNotBlank(qrCode.MoreInfo__c))
        {
            moreInfo = qrCode.MoreInfo__c;
        }
        CampaignMemberStatus = 'Responded';
        QRCodeName = qrCode.Name;
        
        RegisterOrCheckIn = 'Register';
        IsPrint = false;
        IsEnterPhone = false;
        IsEnterLastName = false;
        IsConfirm = false;
        IsInputForm = false;
        IsAllowSelectStatus = false;
        
        ResponseMessage = '';
        StepSequence = '';
        HasSuccess = '您已签到成功';
        EnterPhone = '请输入您的手机号码';
        PhoneError = '请输入正确格式的手机号码';
        EnterLastName = '请输入您的姓氏';
        Confirm = '若信息正确，请回复数字“1”；\n若信息有误，请回复数字“0”';
        ConfirmYes = '1';
        ConfirmNo = '0';
        InputForm = '请您点击此处完善个人信息完成签到';
        NotificationTemplateWrapper = new WeChatNotificationTemplateWrapper();
        MessageWrapper = new WeChatMessageWrapper();
        
        StatusMap = new Map<String, Boolean>();
        getCampaignmemberStatusMap();
        judgeMoreInfoFieldIsBlank();
        getNotificationTemplateAndMessageName();
        getNotificationTemplateAndMessageId();
        getCampaignMemberStatusSelectOptions();
    }
    
    public String NotificationTemplateId { get; set; }
    public String WeChatMessageId { get; set; }
    public WeChatMessageWrapper MessageWrapper { get; set; }
    public WeChatNotificationTemplateWrapper NotificationTemplateWrapper { get; set;}
    public String ResponseMessage { get; set; }
    public Boolean IsAllowSelectStatus { get; set; }
    public Boolean IsEnterPhone { get; set; }
    public Boolean IsEnterLastName { get; set; }
    public Boolean IsConfirm { get; set; }
    public Boolean IsInputForm { get; set; }
    public String QRCodeName { get; set; }
    public String JSONResult { get; set; }
    public String RegisterOrCheckIn { get; set; }
    
    public String FormBanner { get; set; }
    public String FormTitle { get; set; }
    public String CampaignMemberStatus { get; set; }
    
    public Boolean IsPrint { get; set; }
    public String StepSequence { get; set; }
    public String HasSuccess { get; set; }
    public String EnterPhone { get; set; }
    public String PhoneError { get; set; }
    public String EnterLastName { get; set; }
    public String Confirm { get; set; }
    public String ConfirmYes { get; set; }
    public String ConfirmNo { get; set; }
    public String InputForm { get; set; }
    
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Province { get; set; }
    public String Phone { get; set; }
    public String Email { get; set; }
    public String Company { get; set; }
    public String PSICodeDescription { get; set; }
    public String Department { get; set; }
    public String Title { get; set; }
    
    public String ThankYouMessage { get; set; }
    public String ButtonRedirectURL { get; set; }
    public String ButtonLabel { get; set; }
    public Map<String, Boolean> StatusMap { get; set; }
    
    public List<SelectOption> getCampaignMemberStatusSelectOptions()
    {
        List<SelectOption> CampaignMemberStatusSelectOptions = new List<SelectOption>();
        CampaignMemberStatusSelectOptions.add(new SelectOption('Responded','Responded'));
        
        if(String.isNotBlank(qrCode.Charket__WhatId__c))
        {
            Schema.SObjectType sObjectType = ((Id)qrCode.Charket__WhatId__c).getSobjectType();
            
            if(sObjectType == Schema.Campaign.SObjectType)
            {
                List<CampaignMemberStatus> CampaignMemberStatusList = [select Id, Label from CampaignMemberStatus where CampaignId = :QRCode.Charket__WhatId__c and Label != null];
                
                if(CampaignMemberStatusList.size() > 0)
                {
                    CampaignMemberStatusSelectOptions.clear();
                    
                    for(CampaignMemberStatus campaignMemberStatus : CampaignMemberStatusList)
                    {
                        CampaignMemberStatusSelectOptions.add(new SelectOption(campaignMemberStatus.Label,campaignMemberStatus.Label));
                    }
                    return CampaignMemberStatusSelectOptions;
                }
                return CampaignMemberStatusSelectOptions;
            }
            return CampaignMemberStatusSelectOptions;
        }
        return CampaignMemberStatusSelectOptions;
    }
    
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
    
    private void judgeMoreInfoFieldIsBlank()
    {
        if(String.isNotBlank(moreInfo))
        {
            if(!verifyJSONFormat().equals('Error'))
            {
                parseJSONGeneral();
                if(verifyJSONFormat().equals('Checkin'))
                {
                    RegisterOrCheckIn = 'Checkin';
                    parseJSONForCheckIn();
                }
            }
        }
        IsInputForm = true;
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
    private String verifyJSONFormat()
    {
        try
        {
            JSONParser jsonParser = JSON.createParser(moreInfo);
            while (jsonparser.nextToken() != null)
            {
                if ((jsonparser.getCurrentToken() == JSONToken.FIELD_NAME) && (jsonparser.getText() == 'IsAttended'))
                {
                    jsonparser.nextToken();
                    if(jsonparser.getBooleanValue())
                    {
                        return 'Checkin';
                    }
                }
            }
            return 'Register';
        }
        catch(Exception e)
        {
            return 'Error';
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
            NotificationTemplateWrapper.TempId = jsonParserWrapper.successTemplateId;
            MessageWrapper.MessageId = jsonParserWrapper.successMessageId;
            CampaignMemberStatus = jsonParserWrapper.campaignMemberStatus;
        }
        catch(Exception e){}
        
    }
    
    private void parseJSONForCheckIn()
    {
        try
        {
            WeChatQRCodeFlowSettingsController.JsonGenerateForCheckin jsonGenerateForCheckin = (WeChatQRCodeFlowSettingsController.JsonGenerateForCheckin)JSON.deserialize(moreInfo, WeChatQRCodeFlowSettingsController.JsonGenerateForCheckin.class);
            IsPrint = jsonGenerateForCheckin.IsPrint;
            IsAllowSelectStatus = jsonGenerateForCheckin.IsOnlyMember;
            ResponseMessage = jsonGenerateForCheckin.OnlyMemberResponse;
            
            if(String.isNotBlank(jsonGenerateForCheckin.OnlyMemberStatuses))
            {
                for(String status : jsonGenerateForCheckin.OnlyMemberStatuses.split(';'))
                {
                    if(string.isNotBlank(status))
                    {
                        StatusMap.remove(status);
                        StatusMap.put(status, true);
                    }
                }
            }
            HasSuccess = jsonGenerateForCheckin.HasSuccessLabel;
            CampaignMemberStatus = jsonGenerateForCheckin.CampaignMemberStatus;
            NotificationTemplateWrapper.tempId = jsonGenerateForCheckin.SuccessTemplateId;
            FormBanner = jsonGenerateForCheckin.FormBanner;
            FormTitle = jsonGenerateForCheckin.FormTitle;
            HasSuccess = jsonGenerateForCheckin.HasSuccessLabel;
            StepSequence = jsonGenerateForCheckin.StepSequence;
            EnterPhone = jsonGenerateForCheckin.Step.EnterPhone.Label;
            PhoneError = jsonGenerateForCheckin.Step.EnterPhone.ErrorLabel;
            EnterLastName = jsonGenerateForCheckin.Step.EnterLastName.Label;
            Confirm = jsonGenerateForCheckin.Step.Confirm.Label;
            ConfirmYes = jsonGenerateForCheckin.Step.Confirm.Yes;
            ConfirmNo = jsonGenerateForCheckin.Step.Confirm.No;
            InputForm = jsonGenerateForCheckin.Step.InputForm.Label;
            
            FirstName = jsonGenerateForCheckin.Form.FirstName;
            LastName = jsonGenerateForCheckin.Form.LastName;
            Province = jsonGenerateForCheckin.Form.Province;
            Phone = jsonGenerateForCheckin.Form.Phone;
            Email = jsonGenerateForCheckin.Form.Email;
            Company = jsonGenerateForCheckin.Form.Company;
            PSICodeDescription = jsonGenerateForCheckin.Form.PSICodeDescription;
            Department = jsonGenerateForCheckin.Form.Department;
            Title = jsonGenerateForCheckin.Form.Title;
            ThankYouMessage = jsonGenerateForCheckin.Form.ThankYouMessage;
            ButtonRedirectURL = jsonGenerateForCheckin.Form.ButtonRedirectURL;
            ButtonLabel = jsonGenerateForCheckin.Form.ButtonLabel;
            
            if(String.isNotBlank(StepSequence))
            {
                for(String sequence : StepSequence.split(';'))
                {
                    if(sequence.equals('EnterPhone'))
                    {
                        IsEnterPhone = true;
                    }
                    
                    if(sequence.equals('EnterLastName'))
                    {
                        IsEnterLastName = true;
                    }
                    
                    if(sequence.equals('Confirm'))
                    {
                        IsConfirm = true;
                    }
                    
                    if(sequence.equals('InputForm'))
                    {
                        IsInputForm = true;
                    }
                }
            }
        }
        catch(Exception e){}
    }
    
    //Generate JSON
    private void generateJSONForRegister()
    {
        WeChatQRCodeFlowSettingsController.JsonGenerateForRegister jsonGenerateForRegister = new WeChatQRCodeFlowSettingsController.JsonGenerateForRegister();
        jsonGenerateForRegister.FormBanner = FormBanner;
        jsonGenerateForRegister.FormTitle = FormTitle;
        jsonGenerateForRegister.SuccessTemplateId = NotificationTemplateWrapper.TempId;
        jsonGenerateForRegister.SuccessMessageId = MessageWrapper.MessageId;
        jsonGenerateForRegister.CampaignMemberStatus = CampaignMemberStatus;
        
        JSONResult = JSON.serialize(jsonGenerateForRegister).replace('\\r', '');
    }
    
    private void generateJSONForCheckIn()
    {
        StepSequence = '';
        if(IsEnterPhone)
        {
            StepSequence = StepSequence + 'EnterPhone;';
        }
        
        if(IsEnterLastName)
        {
            StepSequence = StepSequence + 'EnterLastName;';
        }
        
        if(IsConfirm)
        {
            StepSequence = StepSequence + 'Confirm;';
        }
        
        StepSequence = StepSequence + 'InputForm;';
        
        WeChatQRCodeFlowSettingsController.JsonGenerateForCheckin jsonGenerateForCheckin = new WeChatQRCodeFlowSettingsController.JsonGenerateForCheckin();
        jsonGenerateForCheckin.IsAttended = true;
        jsonGenerateForCheckin.IsPrint = IsPrint;
        
        String statuses = '';
        for(String key : StatusMap.keySet())
        {
            if(StatusMap.get(key))
            {
                statuses += key + ';';          
            }
        }
        
        if(!IsAllowSelectStatus)
        {
            statuses = '';
            ResponseMessage = '';
        }
        
        jsonGenerateForCheckin.IsOnlyMember = IsAllowSelectStatus;
        jsonGenerateForCheckin.OnlyMemberStatuses = statuses;
        jsonGenerateForCheckin.OnlyMemberResponse = ResponseMessage;
        jsonGenerateForCheckin.CampaignMemberStatus = CampaignMemberStatus;
        jsonGenerateForCheckin.SuccessTemplateId = NotificationTemplateWrapper.tempId;
        jsonGenerateForCheckin.SuccessMessageId = MessageWrapper.MessageId;
        jsonGenerateForCheckin.FormBanner = FormBanner;
        jsonGenerateForCheckin.FormTitle = FormTitle;
        jsonGenerateForCheckin.HasSuccessLabel = HasSuccess;
        jsonGenerateForCheckin.StepSequence = StepSequence;
        
        jsonGenerateForCheckin.Step.EnterPhone.Label = EnterPhone;
        jsonGenerateForCheckin.Step.EnterPhone.ErrorLabel = PhoneError;
        
        jsonGenerateForCheckin.Step.EnterLastName.Label = EnterLastName;
        
        jsonGenerateForCheckin.Step.Confirm.Label = Confirm;
        jsonGenerateForCheckin.Step.Confirm.Yes = ConfirmYes;
        jsonGenerateForCheckin.Step.Confirm.No = ConfirmNo;
        
        jsonGenerateForCheckin.Step.InputForm.Label = InputForm;
        
        jsonGenerateForCheckin.Form.FirstName = FirstName;
        jsonGenerateForCheckin.Form.LastName = LastName;
        jsonGenerateForCheckin.Form.Province = Province;
        jsonGenerateForCheckin.Form.Phone = Phone;
        jsonGenerateForCheckin.Form.Email = Email;
        jsonGenerateForCheckin.Form.Company = Company;
        jsonGenerateForCheckin.Form.PSICodeDescription = PSICodeDescription;
        jsonGenerateForCheckin.Form.Department = Department;
        jsonGenerateForCheckin.Form.Title = Title;
        jsonGenerateForCheckin.Form.ThankYouMessage = ThankYouMessage;
        jsonGenerateForCheckin.Form.ButtonRedirectURL = ButtonRedirectURL;
        jsonGenerateForCheckin.Form.ButtonLabel = ButtonLabel;
        
        JSONResult = JSON.serialize(jsonGenerateForCheckin).replace('\\r', '');
    }
    
    private void getCampaignmemberStatusMap()
    {
        if(String.isNotBlank(qrCode.Charket__WhatId__c))
        {
            Schema.SObjectType sObjectType = ((Id)qrCode.Charket__WhatId__c).getSobjectType();
            
            if(sObjectType == Schema.Campaign.SObjectType)
            {
                List<CampaignMemberStatus> CampaignMemberStatusList = [select Id, Label from CampaignMemberStatus where CampaignId = :QRCode.Charket__WhatId__c and Label != null];
                
                if(CampaignMemberStatusList.size() > 0)
                {
                    for(CampaignMemberStatus campaignMemberStatus : CampaignMemberStatusList)
                    {
                        statusList.add(campaignMemberStatus.Label);
                    }
                }
            }
        }
        for(String status : statusList)
        {
            StatusMap.put(status, false);
        }
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
        public String successTemplateId;
        public String successMessageId;
        public String campaignMemberStatus;
        public Boolean isPrint;
        public String stepSequence;
        public String hasSuccessLabel;
    }
    
    public class JsonGenerateForRegister
    {
        public String FormBanner;
        public String FormTitle;
        public String SuccessTemplateId;
        public String SuccessMessageId;
        public String CampaignMemberStatus;
    }
    
    public class JsonGenerateForCheckin
    {
        public Boolean IsAttended;
        public Boolean IsPrint;
        public Boolean IsOnlyMember;
        public String OnlyMemberStatuses;
        public String OnlyMemberResponse;
        public String CampaignMemberStatus;
        public String SuccessTemplateId;
        public String SuccessMessageId;
        public String FormBanner;
        public String FormTitle;
        public String HasSuccessLabel;
        public String StepSequence;
        public JsonGenerateForCheckinStep Step = new WeChatQRCodeFlowSettingsController.JsonGenerateForCheckinStep();
        public JsonGenerateForCheckinForm Form = new WeChatQRCodeFlowSettingsController.JsonGenerateForCheckinForm();
        
    }
    
    public class JsonGenerateForCheckinStep
    {
        public JsonGenerateForCheckinEnterPhone EnterPhone = new WeChatQRCodeFlowSettingsController.JsonGenerateForCheckinEnterPhone();
        public JsonGenerateForCheckinEnterLastName EnterLastName = new WeChatQRCodeFlowSettingsController.JsonGenerateForCheckinEnterLastName();
        public JsonGenerateForCheckinConfirm Confirm = new WeChatQRCodeFlowSettingsController.JsonGenerateForCheckinConfirm();
        public JsonGenerateForCheckinInputForm InputForm = new WeChatQRCodeFlowSettingsController.JsonGenerateForCheckinInputForm();
    }
    
    public class JsonGenerateForCheckinEnterPhone
    {
        public String Label;
        public String ErrorLabel;
    }
    
    public class JsonGenerateForCheckinEnterLastName
    {
        public String Label;
    }
    
    public class JsonGenerateForCheckinConfirm
    {
        public String Label;
        public String Yes;
        public String No;
    }
    
    public class JsonGenerateForCheckinInputForm
    {
        public String Label;
    }
    
    public class JsonGenerateForCheckinForm
    {
        public String FirstName;
        public String LastName;
        public String Province;
        public String Phone;
        public String Email;
        public String Company;
        public String PSICodeDescription;
        public String Department;
        public String Title;
        public String ThankYouMessage;
        public String ButtonRedirectURL;
        public String ButtonLabel;
    }
}