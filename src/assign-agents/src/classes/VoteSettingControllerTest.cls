@isTest
public class VoteSettingControllerTest
{
	@isTest
	static void test()
	{
		Charket__Survey__c survey = new Charket__Survey__c(Name = 'test');
		insert survey;

		Charket__WeChatQRCode__c qrcode = new Charket__WeChatQRCode__c(Name = 'test', Charket__WhatId__c = survey.Id);
		insert qrcode;

		List<Attachment> qrCodeAtts = new List<Attachment>();
		Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
		qrCodeAtts.add(new Attachment(ParentId = qrcode.Id, Name = 'test', Body = bodyBlob));
		insert qrCodeAtts;

		List<Campaign> campaignList = new List<Campaign>();
		campaignList.add(new Campaign(Name = 'test'));
		insert campaignList;

		List<CampaignMemberStatus> statusList = new List<CampaignMemberStatus>();
		statusList.add(new CampaignMemberStatus(CampaignId = campaignList[0].Id, Label = 'test'));
		insert statusList;
		Test.setCurrentPageReference(new PageReference('Page.myPage')); 
		System.currentPageReference().getParameters().put('id', survey.Id);
        
		Test.startTest();
		VoteSettingController voteSettingController = new VoteSettingController();

		voteSettingController.QrCodeId = qrcode.Id;
		voteSettingController.CampaignId = campaignList[0].Id;
		voteSettingController.IsShowPersonNum = true;

		voteSettingController.beganToVote();
		voteSettingController.sendQRCode();
		voteSettingController.insertWeChatMessage();
		Test.stopTest();
	}
}