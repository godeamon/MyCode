public class TestRESTAPI2
{
    private static OAuth2 oauth;
    private static String clientId = '3MVG9d8..z.hDcPItJUmtNQSnKNyRj3sZ1qG4lpSgPLht3PW8dm9zgUb1HAI7wol._D56vIek2DN2YvF2D5Ic';
    private static String clientSecret = '1138485987942597865';
    private static String userName = 'felixdeveloper@meginfo.com';
    private static String passWord = '123mutouRenmeginfoMpBDvZ1Ld8MWkABdu55kMutNl';
    
    public static String QueryStr { get; set; }
    public static String ResponseBody { get; set;}
    public static String ExceptionMessage { get;set; }
    
    public static void query()
    {
        try
        {
            if(oauth == null)
            {
                oauth = login();
            }

            HttpResponse response;
            HttpRequest request = new HttpRequest();
            PageReference theUrl = new PageReference(oauth.Instance_Url + '/services/data/v22.0/query/');
            theUrl.getParameters().put('q', 'select Moblor_Tack__Account__c, Moblor_Tack__Description__c, Moblor_Tack__HoursEstimated__c, Moblor_Tack__HoursLeft__c, Moblor_Tack__HoursSpent__c, Moblor_Tack__Priority__c, Moblor_Tack__Status__c from Moblor_Tack__Project__c');
            request.setEndpoint(theUrl.getUrl());
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + oauth.Access_Token);
            
            response = (new Http()).send(request);
            ResponseBody = response.getBody();
        }
        catch(Exception e)
        {
            ExceptionMessage = e.getMessage() + '---' + e.getLineNumber();
            system.debug('exmessage:::' + ExceptionMessage);
        }
        
    }
    
    public static OAuth2 login()
    {
        //FinanceServer__c financeServer = FinanceServer__c.getInstance();
        //Here write a sample query or fetch from custom settings the consumer ,client secret and username and password of destination org
        String requestBody = 'grant_type=password&client_id=' + clientId +
            '&client_secret=' + clientSecret +
            '&username=' + userName +
            '&password=' + passWord;
        HttpRequest request = new HttpRequest();
        request.setBody(requestBody);
        system.debug('22:::' + requestBody);
        request.setMethod('POST');
        request.setEndpoint('https://felixdeveloper-dev-ed.my.salesforce.com/services/oauth2/token');//Note if my domain is set up use the proper domain name else use login.salesforce.com for prod or developer or test.salesforce.com for sandbox instance
        HttpResponse response = (new Http()).send(request);
        
        system.debug('33:::' + response.getBody());
        system.debug('44:::' + response.getStatusCode());
        
        OAuth2 objAuth = (OAuth2)JSON.deserialize(response.getbody(), OAuth2.class);
        if(String.isBlank(objAuth.Access_Token) || String.isBlank(objAuth.Instance_Url))
        {
            oauth = null;
        }
        else
        {
            oauth = objAuth;
            system.debug('44:::' + oauth.Access_Token);
        }
        return oauth;
    }
    
    public class OAuth2
    {
        public String Id { get; set; }
        public String Issued_At { get; set; }
        public String Instance_Url { get; set; }
        public String Signature { get; set; }
        public String Access_Token { get; set; }
    }
}