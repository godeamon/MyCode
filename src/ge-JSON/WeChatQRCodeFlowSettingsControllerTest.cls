@IsTest
public class WeChatQRCodeFlowSettingsControllerTest
{
    @IsTest
    static void testRegisterOrCheckInFalse()
    {
        Campaign campaign = new Campaign(Name = 'test');
        insert campaign;
        
        CampaignMemberStatus campaignMemberStatus = new CampaignMemberStatus(Label = 'test', CampaignId = campaign.Id);
        insert campaignMemberStatus;
        
        charket__WeChatQRCode__c qrCode = new charket__WeChatQRCode__c(name = 'test', Charket__WhatId__c = campaign.Id, MoreInfo__c = '{"FormBanner":"fb","FormTitle":"title","SuccessTemplateId":"template","SuccessMessageId":"message","CampaignMemberStatus":"Sent"}');
        insert qrCode;
        
        Charket__WeChatNotificationTemplate__c wechatNotificationTemplate = new Charket__WeChatNotificationTemplate__c(Name = 'test');
        insert wechatNotificationTemplate;
        
        Charket__WeChatMessage__c weChatMessage = new Charket__WeChatMessage__c(Name = 'test', Charket__TextBody__c = 'test');
        insert weChatMessage;
        
        WeChatQRCodeFlowSettingsController.WeChatNotificationTemplateWrapper notificationTemplateWrapper = new WeChatQRCodeFlowSettingsController.WeChatNotificationTemplateWrapper();
        notificationTemplateWrapper.TempId = wechatNotificationTemplate.Id;
        notificationTemplateWrapper.Name = 'test';
        
        WeChatQRCodeFlowSettingsController.WeChatMessageWrapper messageWrapper = new WeChatQRCodeFlowSettingsController.WeChatMessageWrapper();
        messageWrapper.MessageId = weChatMessage.Id;
        messageWrapper.Name = 'test';
        
        PageReference pageRef = ApexPages.currentPage();
        pageRef.getParameters().put('id', qrCode.Id);
        
        WeChatQRCodeFlowSettingsController weChatQRCodeFlowSettingsController = new WeChatQRCodeFlowSettingsController();
        
        weChatQRCodeFlowSettingsController.NotificationTemplateWrapper = notificationTemplateWrapper;
        weChatQRCodeFlowSettingsController.MessageWrapper = messageWrapper;
        weChatQRCodeFlowSettingsController.RegisterOrCheckIn = 'Register';
        weChatQRCodeFlowSettingsController.FormBanner = 'test';
        weChatQRCodeFlowSettingsController.FormTitle = 'test';
        weChatQRCodeFlowSettingsController.CampaignMemberStatus = 'test';
        weChatQRCodeFlowSettingsController.getCampaignMemberStatusSelectOptions();
        
        weChatQRCodeFlowSettingsController.save();
        weChatQRCodeFlowSettingsController.cancel();
        system.assert(String.isNotEmpty(weChatQRCodeFlowSettingsController.JSONResult));
    }
    
    @IsTest
    static void testRegisterOrCheckInTrue()
    {
        Campaign campaign = new Campaign(name = 'test');
        insert campaign;
        
        CampaignMemberStatus campaignMemberStatus = new CampaignMemberStatus(Label = 'test', CampaignId = campaign.Id);
        insert campaignMemberStatus;
        
        charket__WeChatQRCode__c qrCode = new charket__WeChatQRCode__c(name = 'test', Charket__WhatId__c = campaign.Id, MoreInfo__c = '{"IsAttended":true,"OnlyMemberStatuses":"Accepted;","OnlyMemberResponse":"test","IsOnlyMember":true,"IsPrint":false,"CampaignMemberStatus":"Sent","SuccessTemplateId":"template","SuccessMessageId":"message","FormBanner":"fb","FormTitle":"title","StepSequence":"InputForm;","Step":{"EnterPhone":{"Label":"请输入您的手机号码","ErrorLabel":"请输入正确格式的手机号码"},"EnterLastName":{"Label":"请输入您的姓氏"},"Confirm":{"Label":"若信息正确，请回复数字“1”；\\n若信息有误，请回复数字“0”","Yes":"1","No":"0"},"InputForm":{"Label":"请您点击此处完善个人信息完成签到"}},"HasSuccessLabel":"您已签到成功","Form":{"FirstName":"","LastName":"","Province":"","Phone":"","Email":"","Company":"","PSICodeDescription":"","Department":"","Title":"","ThankYouMessage":"","ButtonRedirectURL":"","ButtonLabel":""}}');
        insert qrCode;
        
        Charket__WeChatNotificationTemplate__c weChatNotificationTemplate = new Charket__WeChatNotificationTemplate__c(Name = 'test');
        insert weChatNotificationTemplate;
        
        Charket__WeChatMessage__c weChatMessage = new Charket__WeChatMessage__c(Name = 'test', Charket__TextBody__c = 'test');
        insert weChatMessage;
        
        WeChatQRCodeFlowSettingsController.WeChatNotificationTemplateWrapper notificationTemplateWrapper = new WeChatQRCodeFlowSettingsController.WeChatNotificationTemplateWrapper();
        notificationTemplateWrapper.TempId = weChatNotificationTemplate.Id;
        notificationTemplateWrapper.Name = 'test';
        
        WeChatQRCodeFlowSettingsController.WeChatMessageWrapper messageWrapper = new WeChatQRCodeFlowSettingsController.WeChatMessageWrapper();
        messageWrapper.MessageId = weChatMessage.Id;
        messageWrapper.Name = 'test';
        
        PageReference pageRef = ApexPages.currentPage();
        pageRef.getParameters().put('id', qrCode.Id);
        
        WeChatQRCodeFlowSettingsController weChatQRCodeFlowSettingsController = new WeChatQRCodeFlowSettingsController();
        
        weChatQRCodeFlowSettingsController.NotificationTemplateWrapper = notificationTemplateWrapper;
        weChatQRCodeFlowSettingsController.MessageWrapper = messageWrapper;
        weChatQRCodeFlowSettingsController.RegisterOrCheckIn = 'CheckIn';
        weChatQRCodeFlowSettingsController.FormBanner = 'test';
        weChatQRCodeFlowSettingsController.FormTitle = 'test';
        weChatQRCodeFlowSettingsController.CampaignMemberStatus = 'test';
        weChatQRCodeFlowSettingsController.FirstName = 'test';
        weChatQRCodeFlowSettingsController.LastName = 'test';
        weChatQRCodeFlowSettingsController.Province = 'test';
        weChatQRCodeFlowSettingsController.Phone = 'test';
        weChatQRCodeFlowSettingsController.Email = 'test';
        weChatQRCodeFlowSettingsController.Company = 'test';
        weChatQRCodeFlowSettingsController.PSICodeDescription = 'test';
        weChatQRCodeFlowSettingsController.Department = 'test';
        weChatQRCodeFlowSettingsController.Title = 'test';
        weChatQRCodeFlowSettingsController.ThankYouMessage = 'test';
        weChatQRCodeFlowSettingsController.ButtonRedirectURL = 'test';
        weChatQRCodeFlowSettingsController.ButtonLabel = 'test';
        weChatQRCodeFlowSettingsController.IsConfirm = true;
        weChatQRCodeFlowSettingsController.IsEnterLastName = true;
        weChatQRCodeFlowSettingsController.IsEnterPhone = true;
        weChatQRCodeFlowSettingsController.IsInputForm = true;
        weChatQRCodeFlowSettingsController.IsAllowSelectStatus = true;
        weChatQRCodeFlowSettingsController.getCampaignMemberStatusSelectOptions();
        
        weChatQRCodeFlowSettingsController.save();
        weChatQRCodeFlowSettingsController.cancel();
        system.assert(String.isNotEmpty(weChatQRCodeFlowSettingsController.JSONResult));
    }
}