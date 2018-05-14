@isTest
private class DailyTimeCardReportControllerTest
{
    @testSetup
    static void setup()
    {
        Profile p = [select Id from Profile limit 1];
        List<User> users = new List<User>();
        users.add(new User(FirstName = 'test', LastName = 'test', Email = 'example.test@test.com', Username = 'example.test@test.com', Alias = 'test',
            CommunityNickname = 'test', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'utf-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US'));
        insert users;
        List<TimeCard__c> timeCards = new List<TimeCard__c>();
        timeCards.add(new TimeCard__c(Name = 'test', Date__c = Date.toDay(), hours__c = 8));
        insert timeCards;

        List<Leave__c> leaves = new List<Leave__c>();
        leaves.add(new Leave__c(LeaveType__c = 'Sick', StartDate__c = Date.today(), EndDate__c = Date.today(), Description__c = 'test'));
        insert leaves;
    }
    
    @isTest
    static void test()
    {
        DailyTimeCardReportController controller = new DailyTimeCardReportController();
        User u = [select Id from User limit 1];
        controller.UserId = u.Id;
        Decimal hours = controller.TotalHours;
        ChartTable chartTable = controller.MyMembers;
    }
}