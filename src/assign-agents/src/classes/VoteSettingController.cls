public class VoteSettingController
{
    private String surveyId;
    private List<Charket__Survey__c> surveyList = new List<Charket__Survey__c>();
    private List<Charket__SurveyQuestion__c> surveyQuestions = new List<Charket__SurveyQuestion__c>();

    public VoteSettingController()
    {
        QrCodes = new List<SelectOption>();
        Campaigns = new List<SelectOption>();
        Surveys = new List<SelectOption>();
        Statuses = new List<Status>();
        IsShowPersonNum = false;
        IsSetting = false;

        surveyId = ApexPages.currentPage().getParameters().get('Id');
        if(String.isNotBlank(surveyId))
        {
            surveyList = [select Id, Name, PollingSettings__c, CurrentPollingQuestion__c from Charket__Survey__c where Id = :surveyId limit 1];
            surveyQuestions = [select Id, Charket__Order__c, Charket__Question__c from Charket__SurveyQuestion__c 
                where Charket__Survey__c = :surveyId order by Charket__Order__c, CreatedDate limit 1];

            if(surveyList.size() > 0)
            {
                SurveyName = surveyList[0].Name;
            }
        }
        
        getQrcodes();
        getCampaigns();
        //getSurveys();
        getCampaignMemberStatuses();
    }

    public String QrCodeId { get; set; }
    public String CampaignId { get; set; }
    public String SurveyName { get; set; }
    
    public Boolean IsShowPersonNum { get; set; }
    public List<SelectOption> QrCodes { get; set; }
    public List<SelectOption> Campaigns { get; set; }
    public List<SelectOption> Surveys { get; set; }
    public List<Status> Statuses { get; set; }
    public String QrCodeName { get; set; }
    public String CampaignName { get; set; }
    public String StatusesStr { get; set; }

    public Boolean IsSetting { get; set; }

    public void edit()
    {
        IsSetting = false;
    }

    public void cancel()
    {
        IsSetting = true;
    }

    public void validateSettings()
    {
        if(surveyList.size() > 0 && String.isNotBlank(surveyList[0].PollingSettings__c))
        {
            try
            {
                VoteSettingController.JSONResult parser = (VoteSettingController.JSONResult)JSON.deserialize(surveyList[0].PollingSettings__c, VoteSettingController.JSONResult.class);
                IsSetting = true;
                IsShowPersonNum = parser.IsShowPersonNum;

                List<Charket__WeChatQRCode__c> qrCodeList = [select Id, Charket__WeChatAccount__c, Name from Charket__WeChatQRCode__c where Id = :parser.QRCodeId limit 1];
                QrCodeName = qrCodeList[0].Name;
                QrCodeId = qrCodeList[0].Id;

                List<Campaign> campaignList = [select Id, Name from Campaign where Id = :parser.CampaignId];
                CampaignName = campaignList[0].Name;
                CampaignId = campaignList[0].Id;

                StatusesStr = '';
                getCampaignMemberStatuses();
                for(String s : parser.Status)
                {
                    StatusesStr += s + '; ';
                    for(Status status : Statuses)
                    {
                        if(status.Status.equals(s))
                        {
                            status.IsChecked = true;
                        }
                    }
                }
                StatusesStr = StatusesStr.substring(0, StatusesStr.length() - 2);
                

            }
            catch(Exception e)
            {
                System.debug(e.getMessage());
                IsSetting = false;
            }
        }
        else
        {
            IsSetting = false;
        }
    }

    public void getCampaignMemberStatuses()
    {
        Statuses.clear();
        if(String.isNotBlank(CampaignId))
        {
            List<CampaignMemberStatus> statusList = [select Id, Label from CampaignMemberStatus where CampaignId = :CampaignId and Label != null];
            if(statusList.size() > 0)
            {
                for(CampaignMemberStatus s : statusList)
                {
                    Statuses.add(new VoteSettingController.Status(s.Label, false));
                }
            }
        }
    }

    public PageReference beganToVote()
    {
        PageReference pageRef = Page.RealTimeVote;
        if(String.isNotBlank(CampaignId))
        {
            //List<CampaignMember> campaignMembers = [select Id, LeadOrContactId from CampaignMember where CampaignId = :CampaignId];
            ////sendWeChatQrCode(QrCodeId, campaignMembers);

            pageRef.getParameters().put('qrCodeId', QrCodeId);
            pageRef.getParameters().put('campaignId', CampaignId);
            pageRef.getParameters().put('surveyId', surveyId);
            if(IsShowPersonNum)
            {
                pageRef.getParameters().put('isShowPersonNum', '1');
            }
            else
            {
                pageRef.getParameters().put('isShowPersonNum', '0');
            }
        }

        //record the first quest Id. 
        recordQuestionNumber();
        
        return pageRef;
    }

    public void sendQRCode()
    {
        List<String> statusCkeckedList = new List<String>();
        for(Status s : Statuses)
        {
            if(s.IsChecked)
            {
                statusCkeckedList.add(s.Status);
            }
        }
        if(String.isNotBlank(CampaignId) && statusCkeckedList.size() > 0)
        {
            List<CampaignMember> campaignMembers = [select Id, LeadOrContactId from CampaignMember where CampaignId = :CampaignId and Status in :statusCkeckedList];
            System.debug('campaignMembers:::' + campaignMembers);
            sendWeChatQrCode(QrCodeId, campaignMembers);
        }
    }

    public void insertWeChatMessage()
    {
        IsSetting = true;
        VoteSettingController.JSONResult jsonResult = new VoteSettingController.JSONResult();
        jsonResult.QrCodeId = QrCodeId;
        jsonResult.CampaignId = CampaignId;
        jsonResult.surveyId = surveyId;
        jsonResult.IsShowPersonNum = IsShowPersonNum;
        List<String> checkedStatus = new List<String>();
        String statusStr = '';

        for(Status s : Statuses)
        {
            if(s.IsChecked)
            {
                statusStr += s.Status + ',';
                checkedStatus.add(s.Status);
            }
        }

        jsonResult.Status = checkedStatus;
        String jsonStr = JSON.serialize(jsonResult);
        
        if(surveyList.size() > 0)
        {
            surveyList[0].PollingSettings__c = jsonStr;
            update surveyList;
        }

        validateSettings();

        List<Attachment> qrCodeAtts = [select Id, ParentId, Body, Name from Attachment where ParentId = :QRCodeId limit 1];
        List<Charket__WeChatQRCode__c> qrCodeList = [select Id, Charket__WeChatAccount__c from Charket__WeChatQRCode__c where Id = :QRCodeId];
        

        if(qrCodeAtts.size() > 0 && qrCodeList.size() > 0)
        {
            List<Charket__WeChatMessage__c> wechatMessages = [select Charket__TextBody__c, Id
                                                                from Charket__WeChatMessage__c
                                                                where Name = :(qrCodeAtts[0].Name + '-' + qrCodeAtts[0].Id)
                                                                and Charket__WeChatMediaId__c != null
                                                                order by CreatedDate desc limit 1];
            if(wechatMessages.size() == 0)
            {
                try
                {
                    Charket__WeChatMessage__c wechatMessage = new Charket__WeChatMessage__c();
                    wechatMessage.Name = qrCodeAtts[0].Name + '-' + qrCodeAtts[0].Id;
                    wechatMessage.Charket__Type__c = 'Image';
                    wechatMessage.Charket__WeChatAccount__c = qrCodeList[0].Charket__WeChatAccount__c;
                    wechatMessage.Charket__WeChatMediaId__c = null;
                    insert wechatMessage;

                    Charket__WechatMessageAttachment__c wechatMessageAttachment = new Charket__WechatMessageAttachment__c();
                    wechatMessageAttachment.Charket__WeChatMessage__c = wechatMessage.Id;
                    wechatMessageAttachment.Charket__AttachmentId__c = null;
                    insert wechatMessageAttachment;

                    Attachment att = new Attachment();
                    att.ParentId = wechatMessageAttachment.Id;
                    att.Body = qrCodeAtts[0].Body;
                    att.Name = qrCodeAtts[0].Name;
                    att.ContentType = 'image/jpg';
                    insert att;

                    //wechatMessageAttachment.Charket__AttachmentId__c = att.Id;
                    att.Name = qrCodeAtts[0].Name + '1';
                    update wechatMessageAttachment;

                }
                catch(Exception e)
                {
                    System.debug(e.getMessage() + '---' + e.getLineNumber());
                }
            }
        }
    }

    private void recordQuestionNumber()
    {
        if(surveyList.size() > 0)
        {
            if(surveyQuestions.size() > 0)
            {
                surveyList[0].CurrentPollingQuestion__c = surveyQuestions[0].Id;

                update surveyList;
            }
        }
    }

    private void sendWeChatQrCode(String QRCodeId, List<CampaignMember> campaignMembers)
    {
        List<Attachment> qrCodeAtts = [select Id, ParentId, Body, Name from Attachment where ParentId = :QRCodeId limit 1];
        List<Charket__WeChatMessage__c> wechatMessages = [select Charket__TextBody__c, Id
                                                            from Charket__WeChatMessage__c
                                                            where Name = :(qrCodeAtts[0].Name + '-' + qrCodeAtts[0].Id)
                                                            and Charket__WeChatMediaId__c != null
                                                            order by CreatedDate desc limit 1];
        if(wechatMessages.size() > 0)
        {
            try
            {
                for(CampaignMember member : campaignMembers)
                {
                    Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest messageRequest = new Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest();
                    messageRequest.objectId = member.Id;
                    messageRequest.messageId = wechatMessages[0].Id;
                    messageRequest.whoId = member.LeadOrContactId;
                    System.debug('member.Id:::' + member.Id);
                    System.debug('wechatMessageId:::' + wechatMessages[0].Id);
                    System.debug('member.LeadOrContactId:::' + member.LeadOrContactId);
                    List<Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest> messageRequests = new List<Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest>();
                    messageRequests.add(messageRequest);
                    Charket.CharketSendWeChatMessageAction.sendWeChatMessage(messageRequests);
                }
            }
            catch(Exception e)
            {
                System.debug(e.getMessage() + '---' + e.getLineNumber() + e.getCause() + '@@' + e.getStackTraceString());
            }
        }
    }

    private void getQrcodes()
    {
        List<Charket__WeChatQRCode__c> qrCodeList = [select Id, Name from Charket__WeChatQRCode__c];
        if(qrCodeList.size() > 0)
        {
            for(Charket__WeChatQRCode__c qrCode : qrCodeList)
            {
                QrCodes.add(new SelectOption(qrCode.Id, qrCode.Name));
            }
        }
    }

    private void getCampaigns()
    {
        List<Campaign> campaignList = [select Id, Name from Campaign];
        if(campaignList.size() > 0)
        {
            CampaignId = campaignList[0].Id;
            for(Campaign c : CampaignList)
            {
                Campaigns.add(new SelectOption(c.Id, c.Name));
            }
        }
    }

    //private void getSurveys()
    //{
    //  List<Charket__Survey__c> surveyList = [select Id, Name from Charket__Survey__c order by CreatedDate];
    //  if(surveyList.size() > 0)
    //  {
    //      for(Charket__Survey__c s : surveyList)
    //      {
    //          Surveys.add(new SelectOption(s.Id, s.Name));
    //      }
    //  }
    //}

    public class JSONResult
    {
        public JSONResult()
        {
            Status = new List<String>();
        }

        public String QrCodeId { get; set; }
        public String CampaignId { get; set; }
        public String SurveyId { get; set; }
        public Boolean IsShowPersonNum { get; set; }
        public List<String> Status { get; set; }
    }

    public class Status
    {
        public Status(String status, Boolean isChecked)
        {
            this.Status = status;
            this.IsChecked = isChecked;
        }

        public String Status { get; set; }
        public Boolean IsChecked { get; set; }
    }
}