public class UpdateFollowerInfoTest {

    public static void updateFollower()
    {
        Charket__WeChatFollower__c follower = new Charket__WeChatFollower__c(
            Id = 'a0O0l00000139uu',
            BadgeId__c = 'a0y0l000000AO1lAAG',
            BadgeName__c = 'Vicky',
            BadgeCompany__c = 'Charket6',
            BadgePrintDate__c = Datetime.now()
        );
        update follower;
    }
}