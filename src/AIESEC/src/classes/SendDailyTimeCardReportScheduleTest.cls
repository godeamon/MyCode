@isTest
public with sharing class SendDailyTimeCardReportScheduleTest
{
    @isTest
    static void testGetDayOfWeek()
    {
        System.assertEquals(0, DateUtil.getDayOfWeek(Date.newInstance(2013, 6, 9)));
        System.assertEquals(3, DateUtil.getDayOfWeek(Date.newInstance(2013, 2, 13)));
        System.assertEquals(1, DateUtil.getDayOfWeek(Date.newInstance(2012, 10, 29)));
    }

    @isTest
    static void testSendDailyTimeCardReportSchedule()
    {
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Daily TimeCard Report';
        validEmailTemplate.DeveloperName = 'DailyTimeCardReport';
        validEmailTemplate.TemplateType = 'visualforce';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        String html = '<messaging:emailTemplate subject="{!relatedTo.name}\'s Project Dashboard - {!TODAY()} " recipientType="User" relatedToType="User"> <messaging:htmlEmailBody > <c:DailyTimeCardReport userIdR="{!relatedTo.Id}"/> </messaging:htmlEmailBody> </messaging:emailTemplate>';
        validEmailTemplate.Markup = html;

        insert validEmailTemplate;
        Holiday workday = new Holiday(Name='Workday', ActivityDate=Date.today());
        insert workday;
        Test.startTest();
        SendDailyTimeCardReportSchedule batch = new SendDailyTimeCardReportSchedule();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testisWorkday()
    {
        Holiday workday = new Holiday(Name='Workday', ActivityDate=Date.today());
        insert workday;
        Test.startTest();
        Boolean isWorkDay = DateUtil.isWorkday(Date.today());
        system.assert(isWorkDay != null);
        Test.stopTest();
    }
}