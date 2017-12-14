@RestResource(urlMapping='/UpdateFollower/*')
global class UpdateFollowerInfo
{
	@HttpPost
    global static void doPost()
    {
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Id = 'a0O0l00000139ulEAA',
            BadgeId__c = 'a0y0l000000AO1lAAG',
            BadgeName__c = 'Gary',
            BadgeCompany__c = 'Charket5',
            BadgePrintDate__c = Datetime.now()
        );
        update follower;
    }
    
    @HttpGet
    global static void doGet()
    {
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Id = 'a0O0l00000139ulEAA',
            BadgeId__c = 'a0y0l000000AO1lAAG',
            BadgeName__c = 'Gary',
            BadgeCompany__c = 'Charket5',
            BadgePrintDate__c = Datetime.now()
        );
        update follower;
    }
}