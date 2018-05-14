/*
 * this Schedule used to send daily timecard report.
 */
global class SendDailyTimeCardReportSchedule implements Database.Batchable<SObject>, Database.Stateful
{
    private static final String EmailTemplateName = 'DailyTimeCardReport';
    private Id EmailTemplateId;
    private OrgWideEmailAddress OrgWideEmail;

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Integer dayofweekToday = DateUtil.getDayOfWeek(Date.today());
        if((DateUtil.isWeekend(dayofweekToday) && DateUtil.isWorkday(Date.today())) || (!DateUtil.isWeekend(dayofweekToday) && !DateUtil.isHoliday(Date.today())))
        {
            List<EmailTemplate> templates = [select Id from EmailTemplate where DeveloperName = :EmailTemplateName
                    and IsActive = true limit 1];
            List<OrgWideEmailAddress> orgWideEmails = [select Id, DisplayName from OrgWideEmailAddress where Address='fin@meginfo.com' limit 1];
            OrgWideEmail = (orgWideEmails.size() > 0) ? orgWideEmails[0] : null;

            if(templates.size() > 0)
            {
                EmailTemplateId = templates[0].Id;
                List<String> names = new List<String>();
                names.add('Felix');
                names.add('Ray');

                return Database.getQueryLocator([select Id, Name, Email from User where IsActive = true and IsEmployee__c = true and FirstName in :names]);
            }
        }
        return Database.getQueryLocator([SELECT Id, Name, Email FROM User where id in ('')]);
    }

    global void execute(Database.BatchableContext BC, List<User> users)
    {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        system.System.debug('users::' + users);
        for(User user : users)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setReplyTo('noreply@meginfo.com');
            if(OrgWideEmail != null)
            {
                mail.setOrgWideEmailAddressId(OrgWideEmail.Id);
            }
            else
            {
                mail.setSenderDisplayName('Meginfo System Administrator');
            }
            mail.setTargetObjectId(user.Id);
            mail.setTemplateId(EmailTemplateId);
            mail.setWhatId(user.Id);

            emails.add(mail);
        }
        if(emails.size() > 0)
        {
            try
            {
                Messaging.sendEmail(emails);
            }
            catch(Exception ex)
            {
                String error = ex.getMessage() + '\r\n' + ex.getStackTraceString();
                EmailUtil.sendException('Meginfo DailyTimeCard | Error in SendDailyTimeCardReportSchedule class', error);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {}
}