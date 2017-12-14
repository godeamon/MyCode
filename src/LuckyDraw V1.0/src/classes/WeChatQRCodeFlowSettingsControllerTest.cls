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

        charket__WeChatQRCode__c QRCode = new charket__WeChatQRCode__c(name = 'test', Charket__WhatId__c = campaign.Id, MoreInfo__c = '{"FormBanner":"fb","FormTitle":"title","SuccessTemplateId":"template","SuccessMessageId":"message","CampaignMemberStatus":"Sent"}');
        insert QRCode;

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
        pageRef.getParameters().put('id', QRCode.Id);

        WeChatQRCodeFlowSettingsController weChatQRCodeFlowSettingsController = new WeChatQRCodeFlowSettingsController();

        weChatQRCodeFlowSettingsController.NotificationTemplateWrapper = notificationTemplateWrapper;
        weChatQRCodeFlowSettingsController.MessageWrapper = messageWrapper;
        weChatQRCodeFlowSettingsController.RegisterOrCheckIn = 'Register';
        weChatQRCodeFlowSettingsController.FormBanner = 'test';
        weChatQRCodeFlowSettingsController.FormTitle = 'test';
        weChatQRCodeFlowSettingsController.CampaignMemberStatus = 'test';

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

        charket__WeChatQRCode__c QRCode = new charket__WeChatQRCode__c(name = 'test', Charket__WhatId__c = campaign.Id, MoreInfo__c = '{"IsAttended":true,"IsPrint":false,"CampaignMemberStatus":"Sent","SuccessTemplateId":"template","SuccessMessageId":"message","FormBanner":"fb","FormTitle":"title","HasSuccessLabel":"您已签到成功"}');
        insert QRCode;

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
        pageRef.getParameters().put('id', QRCode.Id);

        WeChatQRCodeFlowSettingsController weChatQRCodeFlowSettingsController = new WeChatQRCodeFlowSettingsController();

        weChatQRCodeFlowSettingsController.NotificationTemplateWrapper = notificationTemplateWrapper;
        weChatQRCodeFlowSettingsController.MessageWrapper = messageWrapper;
        weChatQRCodeFlowSettingsController.RegisterOrCheckIn = 'true';
        weChatQRCodeFlowSettingsController.FormBanner = 'test';
        weChatQRCodeFlowSettingsController.FormTitle = 'test';
        weChatQRCodeFlowSettingsController.CampaignMemberStatus = 'test';

        weChatQRCodeFlowSettingsController.save();
        weChatQRCodeFlowSettingsController.cancel();
        system.assert(String.isNotEmpty(weChatQRCodeFlowSettingsController.JSONResult));
    }
}