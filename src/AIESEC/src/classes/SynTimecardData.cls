/*
 *Sync time card data from other org, such as Tack, Moblor.
 */
global class SynTimecardData implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts
{
    private static OAuth2 oauth;
    private static Datetime now = Datetime.now();
    private static String nowStr = (now + '').replace(' ', 'T') + 'Z';
    private static String yesterdayNow = (now.addDays(-1) + '').replace(' ', 'T') + 'Z';
    private static string queryStr = 'select Id, Moblor_Tack__Description__c, Moblor_Tack__Hours__c, Moblor_Tack__TeamMember__c,'
            + ' Moblor_Tack__Date__c, Moblor_Tack__TeamMember__r.name, Moblor_Tack__TeamMember__r.Moblor_Tack__User__r.FirstName,'
            + ' Moblor_Tack__TeamMember__r.Moblor_Tack__User__r.LastName,'
            + ' Moblor_Tack__Task__r.Name,Moblor_Tack__Task__r.Moblor_Tack__Project__r.Name from Moblor_Tack__TimeCard__c'
            + ' where CreatedDate <= ' + nowStr + ' and CreatedDate > ' + yesterdayNow;

    public static String responseShow { get; set; }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([select Id, Name, LastName from User where IsActive = true]);
    }

    global void execute(Database.BatchableContext BC, List<User> users)
    {
        String userNamestr = '(';
        for(User u : users)
        {
            userNamestr += '\'' + u.Name + '\',';
        }
        userNamestr = userNamestr.removeEnd(',');
        userNamestr += ')';
        queryStr += ' and Moblor_Tack__TeamMember__r.Moblor_Tack__User__r.Name in ' + userNamestr;

        query();
    }

    global void execute(SchedulableContext sc)
    {
        SynTimecardData batch = new SynTimecardData();
        Database.executeBatch(batch, 100);
    }

    global void finish(Database.BatchableContext BC)
    {
        if(!Test.isRunningTest())
        {
            SendDailyTimeCardReportSchedule batch = new SendDailyTimeCardReportSchedule();
            Database.executeBatch(batch, 1);
        }
    }

    public static void query()
    {
        List<SynTimeCardSettings__mdt> settings = TimeCardMetadata;

        if(settings.size() > 0)
        {
            for(SynTimeCardSettings__mdt setting : settings)
            {
                try
                {
                    login(setting.ClientId__c, setting.ClientSecret__c, setting.Username__c, setting.Password__c, setting.EndPoint__c);
                }
                catch(Exception e)
                {
                    system.debug('exmessage:::' + e.getMessage());
                }
            }
        }
    }

    @testVisible
    static List<SynTimeCardSettings__mdt> TimeCardMetadata
    {
        get
        {
            if (TimeCardMetadata == null)
            {
                TimeCardMetadata = [select ClientId__c, ClientSecret__c, Username__c, EndPoint__c, Password__c
                        from SynTimeCardSettings__mdt];
            }
            return TimeCardMetadata;
        }
        set;
    }

    public static void login(String clientId, String clientSecret, String userName, String passWord, String endPoint)
    {
        //Here write a sample query or fetch from custom settings the consumer,
        //  client secret and username and password of destination org
        String requestBody = 'grant_type=password&client_id=' + clientId +
            '&client_secret=' + clientSecret +
            '&username=' + userName +
            '&password=' + passWord;

        HttpRequest request = new HttpRequest();
        request.setBody(requestBody);
        request.setMethod('POST');
        request.setEndpoint(endPoint + '/services/oauth2/token');
        //Note if my domain is set up use the proper domain name else use login.salesforce.com for prod
        //  or developer or test.salesforce.com for sandbox instance

        HttpResponse response = (new Http()).send(request);
        OAuth2 objAuth = (OAuth2)JSON.deserialize(response.getbody(), OAuth2.class);

        if(String.isBlank(objAuth.Access_Token) || String.isBlank(objAuth.Instance_Url))
        {
            oauth = null;
        }
        else
        {
            oauth = objAuth;
        }
        
        try
        {
            handleResponses();
        }
        catch(Exception e)
        {
            system.debug('exception : ' + e.getMessage() + '====line number : ' + e.getLineNumber());
        }
    }

    private static void handleResponses()
    {
        try
        {
            HttpResponse response;
            HttpRequest request = new HttpRequest();
            PageReference theUrl = new PageReference(oauth.Instance_Url + '/services/data/v22.0/query/');
            theUrl.getParameters().put('q', queryStr);
            request.setEndpoint(theUrl.getUrl());
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + oauth.Access_Token);

            response = (new Http()).send(request);
            system.debug('response:::' + response.getBody());
            responseShow = response.getBody();
            system.debug('responseShow response : ' + responseShow);
            synchronizeTheDate(parseJson(response));
        }
        catch(Exception e)
        {
            system.debug('exMessage::' + e.getMessage() + '---' + e.getLineNumber());
        }
    }

    private static JSONParser parseJson(HttpResponse response)
    {
        String body = replaceRelationFieldSuffix(replaceCustomFieldSuffix(response.getBody()));
        JSONParser parser = JSON.createParser(body);

        do
        {
            parser.nextToken();
        }
        while(parser.hasCurrentToken() && !'records'.equals(parser.getCurrentName()));

        parser.nextToken();

        return parser;
    }

    private static void synchronizeTheDate(JSONParser parser)
    {
        List<NewTimecard> NewTimecards = (List<NewTimecard>)parser.readValueAs(List<NewTimecard>.class);

        if(NewTimecards.size() > 0)
        {
            List<TimeCard__c> timecards = new List<TimeCard__c>();
            Map<TimeCard__c, String> timeCardToName = new Map<TimeCard__c, String>();
            List<String> firstNames = new List<String>();
            List<String> lastNames = new List<String>();

            for(NewTimecard newTimecard : NewTimecards)
            {
                TimeCard__c timecard = new TimeCard__c();
                timecard.Description__c = newTimecard.Moblor_Tack_Description_c;
                timecard.Date__c = newTimecard.Moblor_Tack_Date_c;
                timecard.Hours__c = newTimecard.Moblor_Tack_Hours_c;
                
                timecard.Task__c = newTimecard.Moblor_Tack_Task_r == null ? '' :
                    (newTimecard.Moblor_Tack_Task_r.Name == null ? '' : newTimecard.Moblor_Tack_Task_r.Name);
                timecard.Project__c = newTimecard.Moblor_Tack_Task_r == null ? '' :
                    (newTimecard.Moblor_Tack_Task_r.Moblor_Tack_Project_r == null ? '' :
                    (newTimecard.Moblor_Tack_Task_r.Moblor_Tack_Project_r.Name == null ? '' :
                    newTimecard.Moblor_Tack_Task_r.Moblor_Tack_Project_r.Name));

                timeCardToName.put(timecard, newTimecard.Moblor_Tack_TeamMember_r.Moblor_Tack_User_r.FirstName
                    + newTimecard.Moblor_Tack_TeamMember_r.Moblor_Tack_User_r.LastName);
                firstNames.add(newTimecard.Moblor_Tack_TeamMember_r.Moblor_Tack_User_r.FirstName);
                system.debug('firstNames : ' + firstNames);
                lastNames.add(newTimecard.Moblor_Tack_TeamMember_r.Moblor_Tack_User_r.LastName);
                system.debug('lastNames : ' + lastNames);
            }
			
            system.debug('timeCardToName : ' + timeCardToName);

            List<User> users = [select Id, FirstName, LastName from User where FirstName in :firstNames
                    and LastName in :lastNames and IsActive = true];
			
            system.debug('users : ' + users);
            
            Map<String, User> nameToUser = new Map<String, User>();

            for(User u : users)
            {
                String key = (u.FirstName + u.LastName).toLowerCase();
                nameToUser.put(key, u);
            }
			system.debug('nameToUser : ' + nameToUser);
            for(TimeCard__c timecard : timeCardToName.keySet())
            {
                if(timeCardToName.get(timecard) != null && nameToUser.get((timeCardToName.get(timecard)).toLowerCase()) != null)
                {
                    timecard.User__c = nameToUser.get((timeCardToName.get(timecard)).toLowerCase()).Id;
                    timecards.add(timecard);
                }
            }
            system.debug('timecards1 : ' + timecards);
            if(timecards.size() > 0)
            {
                system.debug('timecards2 : ' + timecards);
                insert timecards;
            }
        }
    }

    private static String replaceCustomFieldSuffix(String body)
    {
        body = body.replaceAll('Tack__', 'Tack_');
        return body.replaceAll('_c"\\s*:', 'c" :');
    }

    private static String replaceRelationFieldSuffix(String body)
    {
        return body.replaceAll('_r"\\s*:', 'r" :');
    }

    public class OAuth2
    {
        public String Id { get; set; }
        public String Issued_At { get; set; }
        public String Instance_Url { get; set; }
        public String Signature { get; set; }
        public String Access_Token { get; set; }
    }

    public class NewTimecard
    {
        public String Moblor_Tack_Description_c { get; set; }
        public Decimal Moblor_Tack_Hours_c { get; set; }
        public Date Moblor_Tack_Date_c { get; set; }
        public Task Moblor_Tack_Task_r { get; set; }
        public TeamMember Moblor_Tack_TeamMember_r { get; set; }
    }

    public class TeamMember
    {
        public String Name { get; set; }
        public Userc Moblor_Tack_User_r { get; set; }
    }

    public class Userc
    {
        public String LastName { get; set; }
        public String FirstName { get; set; }
    }

    public class Task
    {
        public String Name { get; set; }
        public Project Moblor_Tack_Project_r { get; set; }
    }

    public class Project
    {
        public String Name { get; set; }
    }
}