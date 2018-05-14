/*
 * this controller used to correlate to custom component "DailyTimeCardReport".
 */
public class DailyTimeCardReportController
{
    private String userName;
    private Map<Id, String> userMap = new Map<Id, String>();
    private Map<String, Id> finUNToUserId = new Map<String, Id>();
    private List<User> teamUsers = new List<User>();

    public String UserId { get; set; }

    public String UrlStr
    {
        get
        {
            return URL.getSalesforceBaseUrl().toExternalForm();
        }
    }

    public String UserFullName
    {
        get
        {
            return userName;
        }
    }

    // Gets the total hour of today
    public Decimal TotalHours
    {
        get
        {
            List<AggregateResult> results = [select sum(Hours__c) hour from TimeCard__c where User__c=:UserId and Date__c = :Date.today() and Hours__c != null];
            if(results.size() > 0)
            {
                Decimal result = (Decimal)results[0].get('hour');
                return (result != null) ? result : 0;
            }
            else
            {
                return 0;
            }
        }
    }

    public ChartTable MyMembers
    {
        get
        {
            initUserData();

            if(String.isEmpty(UserId)) return new ChartTable();

            ChartTable table = generateBlankTable(userMap, UserId, teamUsers);

            // Gets user logged time cards in one week
            Map<Id, Map<Date, Decimal>> userIdToDaysHours = getUserIdToDaysHours(userMap.keySet());

            // Gets user leave info in Fin system in one week
            Map<Id, Map<Date, DailyTimeCardReportController.HalfDay>> userIdToDaysHalfDays = getUserIdToDaysHalfDays(userIdToDaysHours);

            for(Id userId : userMap.keySet())
            {
                for(Integer i = 0; i > -7; i--)
                {
                    Date d = Date.today().addDays(i);

                    Decimal hours = (userIdToDaysHours.containsKey(userId) && userIdToDaysHours.get(userId).containsKey(Date.today().addDays(i))) ?
                                    userIdToDaysHours.get(userId).get(d) : 0;

                    DailyTimeCardReportController.HalfDay halfDay = (userIdToDaysHalfDays.containsKey(userId) && userIdToDaysHalfDays.get(userId).containsKey(d)) ?
                                    userIdToDaysHalfDays.get(userId).get(d) : DailyTimeCardReportController.HalfDay.NONE;

                    String imageName = getImageName(halfDay, hours);

                    table.addValue(userMap.get(userId), getDayOfWeek(d), new ChartTable.CellInfo(hours, halfDay.name(), imageName));
                }
            }
            return table;
        }
    }

    private void initUserData()
    {
        teamUsers = getTeamUsers(UserId);

        if(teamUsers.size() > 0)
        {
            for(User user : teamUsers)
            {
                userMap.put(user.Id, user.Name);
                finUNToUserId.put(user.Name, user.Id);
            }

            userName = userMap.get(UserId);
        }
        
    }

    // Get a table with a date header(7 days) and user name as first column of each row
    private static ChartTable generateBlankTable(Map<Id, String> userMap, String userId, List<User> teamUsers)
    {
        ChartTable table = new ChartTable(true); // Cumulative table

        for(Integer i = 0; i > -7; i--)
        {
            table.Columns.add(getDayOfWeek(Date.today().addDays(i)));
        }

        // Put current use as a first row
        table.addValue(userMap.get(userId), table.Columns[0], new ChartTable.CellInfo(0));

        for(User user : teamUsers)
        {
            if(user.Id != userId)
            {
                table.addValue(user.Name, table.Columns[0], new ChartTable.CellInfo(0));
            }
        }

        return table;
    }

    //returns the day of week of specified date, e.g. Tue 30
    private static String getDayOfWeek(Date d)
    {
        return DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('EEE d');
    }

    public static List<User> getTeamUsers(Id userId)
    {
        List<User> users = [select Id, UserRoleId, UserRole.ParentRoleId from User where Id=:userId limit 1];
        if(users.size() > 0)
        {
            Set<Id> teamRoles = new Set<Id>();
            teamRoles.addAll(getSubordinateRoles(users[0].UserRoleId));
            teamRoles.add(users[0].UserRole.ParentRoleId);
            //return [select Id, Name, FinUserName__c from User where IsActive=true and IsEmployee__c=1 and UserRoleId in :teamRoles order by Name];
            
            //return [select Id, Name from User where IsActive=true and IsEmployee__c=1 and UserRoleId in :teamRoles order by Name];
            return [select Id, Name from User where IsActive=true and UserRoleId in :teamRoles order by Name];
        }
        return new List<User>();
    }

    private static Set<Id> getSubordinateRoles(Id roleId)
    {
        return getSubordinateRoles(new Set<Id> {roleId});
    }

    private static Set<Id> getSubordinateRoles(Set<Id> roleIds)
    {
        List<UserRole> subRoles = [select Id from UserRole where Id in :roleIds or ParentRoleId in :roleIds];
        if(subroles.size() > roleIds.size())
        {
            for(UserRole role : subRoles)
            {
                roleIds.add(role.Id);
            }
            return getSubordinateRoles(roleIds);
        }
        return roleIds;
    }

    // Gets user day hours in this week.  key: user Id, value: key:Date , value : hours
    public Map<Id, Map<Date, Decimal>> getUserIdToDaysHours(Set<Id> userIds)
    {
        Map<Id, Map<Date, Decimal>> userIdToDaysHours = new Map<Id, Map<Date, Decimal>>();
        for(AggregateResult aggResult : [select User__c u, sum(Hours__c) h, Date__c d from TimeCard__c
                                 where User__c in :userIds and Date__c <= :Date.today() and Date__c >= :Date.today().addDays(-6)
                                  group by User__c, Date__c])
        {
            if(userIdToDaysHours.containsKey((Id)aggResult.get('u')))
            {
                Map<Date, Decimal> dayToHours = userIdToDaysHours.get((Id)aggResult.get('u'));
                dayToHours.put((Date)aggResult.get('d'), (Decimal)aggResult.get('h'));
            }
            else
            {
                Map<Date, Decimal> dayToHours = new Map<Date, Decimal>();
                dayToHours.put((Date)aggResult.get('d'), (Decimal)aggResult.get('h'));
                userIdToDaysHours.put((Id)aggResult.get('u'), dayToHours);
            }
        }
        return userIdToDaysHours;
    }

    // Gets user leave info this week , key : userid  value : key: leave date  value : halfday
    public Map<Id, Map<Date, DailyTimeCardReportController.HalfDay>> getUserIdToDaysHalfDays(Map<Id, Map<Date, Decimal>> userIdToDaysHours)
    {
        //Map<EmployeeLeave.Leave, Map<Date, String>> leaveToDaysHalfDays, List<User> leaveUsers
        Map<Id, Map<Date, DailyTimeCardReportController.HalfDay>> userIdToDaysHalfDays = new Map<Id, Map<Date, DailyTimeCardReportController.HalfDay>>();

        Set<Id> userIds = getUserMayLeaveIds(userIdToDaysHours, userMap);
        Set<String> leaveUserNames = new Set<String>();

        for(Id uId : userIds)
        {
            leaveUserNames.add(userMap.get(uId));
        }
        List<Leave__c> leaves = getLeavesInFin(leaveUserNames);

        for(Leave__c leave : leaves)
        {
            Id userId = finUNToUserId.get(leave.Employee__r.Name);

            for(Integer i=0; i <= leave.StartDate__c.daysBetween(leave.EndDate__c); i++)
            {
                DailyTimeCardReportController.HalfDay halfDay = getHalfDay(leave.HalfDay__c);

                if(userIdToDaysHalfDays.containsKey(userId))
                {
                    userIdToDaysHalfDays.get(userId).put(leave.StartDate__c.addDays(i), halfDay);
                }
                else
                {
                    Map<Date, DailyTimeCardReportController.HalfDay> dayToHalfDay = new Map<Date, DailyTimeCardReportController.HalfDay>();
                    dayToHalfDay.put(leave.StartDate__c.addDays(i), halfDay);
                    userIdToDaysHalfDays.put(userId, dayToHalfDay);
                }
            }
        }

        return userIdToDaysHalfDays;
    }

    // Get user does not log time card or logged hours less than 4 hours
    // These users who need post to Fin system to check leave info
    private static Set<Id> getUserMayLeaveIds(Map<Id, Map<Date, Decimal>> userIdToDaysHours, Map<Id, String> userMap)
    {
        Set<Id> userMayLeaveIds = new Set<Id>();

        for(Id userId : userMap.keySet())
        {
            // User doesn't log any time cards in one week
            if(!userIdToDaysHours.containsKey(userId))
            {
                userMayLeaveIds.add(userId);
                continue;
            }

            Map<Date, Decimal> dateToHours = userIdToDaysHours.get(userId);
            for(Integer i = 0; i > -7; i--)
            {
                Date d = Date.today().addDays(i);
                Decimal oneDayhours = dateToHours.get(d);

                // User does not log time card for one day or logged hours less than 4 hours
                if(oneDayhours == null || oneDayhours < 4)
                {
                    userMayLeaveIds.add(userId);
                    break;
                }
            }
        }
        return userMayLeaveIds;
    }

    private static List<Leave__c> getLeavesInFin(Set<String> leaveUserNames)
    {
        String todayStr = String.valueOf(Date.today());
        String sevenDaysAgo = String.valueOf(Date.today().addDays(-6));

        String soql = 'select Id, StartDate__c, EndDate__c, HalfDay__c, Employee__c, Employee__r.Name from Leave__c' +
                    ' where (StartDate__c <= ' + todayStr + ' and EndDate__c >= ' + sevenDaysAgo + ') and Employee__r.Name in (';

        for(String userName : leaveUserNames)
        {
            if(String.isNotBlank(userName))
            {
                soql += '\'' + userName + '\',';
            }
        }

        soql = soql.removeEnd(',');

        soql += ')';

        return Database.Query(soql);
        //return EmployeeLeave.getLeaves(soql);
    }

    public DailyTimeCardReportController.HalfDay getHalfDay(String halfDay)
    {
        DailyTimeCardReportController.HalfDay newHalfDay = DailyTimeCardReportController.HalfDay.NONE;
        if(halfDay == null)
        {
            newHalfDay = DailyTimeCardReportController.HalfDay.WHOLEDAY;
        }
        if(halfDay == DailyTimeCardReportController.HalfDay.MORNING.name())
        {
            newHalfDay = DailyTimeCardReportController.HalfDay.MORNING;
        }
        if(halfDay == DailyTimeCardReportController.HalfDay.AFTERNOON.name())
        {
            newHalfDay = DailyTimeCardReportController.HalfDay.AFTERNOON;
        }
        return newHalfDay;
    }

    public String getImageName(DailyTimeCardReportController.HalfDay halfDay, Decimal hours)
    {
        String imageName = '';

        if(halfDay == DailyTimeCardReportController.HalfDay.WHOLEDAY)
        {
            imageName = 'grayCircle.png';
        }
        else if(halfDay == DailyTimeCardReportController.HalfDay.MORNING)
        {
            imageName = 'greenCircle-left-gray.png';
        }
        else if(halfDay == DailyTimeCardReportController.HalfDay.AFTERNOON)
        {
            imageName = 'greenCircle-right-gray.png';
        }
        else
        {
            if(hours >= 6)
            {
                imageName = 'greenCircle.png';
            }
            else if(hours >= 4)
            {
                imageName = 'yellowCircle.png';
            }
            else
            {
                imageName = 'redCircle.png';
            }
        }
        return imageName;
    }

    public enum HalfDay { NONE, MORNING, AFTERNOON, WHOLEDAY }
 }