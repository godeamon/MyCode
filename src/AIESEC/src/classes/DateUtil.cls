public with sharing class DateUtil
{
    //recurring holiday is not supported
    public static Boolean isWorkday(Date d)
    {
        List<Holiday> holidays = [select Id, Name from Holiday where ActivityDate=:d order by LastModifiedDate desc limit 1];
        if(holidays.size() > 0)
        {
            return holidays[0].Name.toLowerCase() == 'workday';
        }
        else
        {
            return false;
        }
    }

    //recurring holiday is not supported
    public static Boolean isHoliday(Date d)
    {
        List<Holiday> holidays = [select Id, Name from Holiday where ActivityDate=:d order by LastModifiedDate desc limit 1];
        if(holidays.size() > 0)
        {
            return holidays[0].Name.toLowerCase() != 'workday';
        }
        else
        {
            return false;
        }
    }

    public static Boolean isWeekend(Integer dayOfWeek)
    {
        return dayOfWeek == 6 || dayOfWeek == 0;
    }

    public static Integer getDayOfWeek(Date d)
    {
        Date previousDate = Date.newInstance(2012, 1, 1); //it is sunday
        return Math.mod(previousDate.daysBetween(d), 7);
    }
}