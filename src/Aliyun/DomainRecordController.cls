/**
 * Add domain record to aliyun,CNAME or A type record.
 */
public class DomainRecordController
{
    private static String licenseId = ApexPages.currentPage().getParameters().get('id');
    private static final String API_VERSION = '2015-01-09';
    private static final String SIGNATURE_METHOD = 'HMAC-SHA1';
    private static final String SIGNATURE_VERSION = '1.0';
    private static final String RETURN_VALUE_FORMAT = 'JSON';
    private static final String DNS_API_URL = 'https://alidns.aliyuncs.com/?';

    private String orgId;
    private String hostValue;
    
    private List<String> domainNames = new List<String>();
    private List<String> domainValues = new List<String>();
    private Map<String, String> nameToValue = new Map<String, String>(); 
    private List<sfLma__License__c> licenses = new List<sfLma__License__c>();
    
    private Map<String, DoaminRecordSettings__c> keys = DoaminRecordSettings__c.getAll();
    private DoaminRecordSettings__c addDomainRecord = keys.get('DoaminRecordSettings');
    
    public DomainRecordController()
    {
        TimeToLive = '600';
        licenses = [select Id, Name, sfLma__Subscriber_Org_ID__c, sfLma__Account__r.Alias__c from sfLma__License__c where Id = :licenseId];
        
        if(licenses.size() > 0)
        {
            orgId = ((String) Id.valueOf(licenses[0].sfLma__Subscriber_Org_ID__c)).toLowerCase();
            LicenseName = licenses[0].Name;
        }
        
        if(String.isNotEmpty(addDomainRecord.DomainName__c) && String.isNotEmpty(addDomainRecord.Value__c))
        {
            domainNames = addDomainRecord.DomainName__c.split(';');
            domainValues = addDomainRecord.Value__c.split(';');
            SelectedDomainName = domainNames[0];
            hostValue = domainValues[0];
        }
        confirmHostAndValue();
    }
    
    public String LicenseName { get; set; }
    public String SelectedDomainName { get; set; }
    public String HostRecord { get; set; }
    public String RecordValue { get; set; }
    public String SelectedRecordType { get; set; }
    public String TimeToLive { get; set; }
    
    public List<SelectOption> getType()
    {
        List<SelectOption> listNameSelected = new List<SelectOption>();
        listNameSelected.add(new SelectOption('CNAME', 'CNAME'));
        listNameSelected.add(new SelectOption('A', 'A'));
        return listNameSelected;
    }

    public List<SelectOption> getDomainNames()
    {
        List<SelectOption> listDomainNames = new List<SelectOption>();
        
        for(Integer i = 0; i < domainNames.size(); i++)
        {
            if(i < domainValues.size())
            {
                nameToValue.put(domainNames[i], domainValues[i]);
            }
            else
            {
                nameToValue.put(domainNames[i], '');
            }
            listDomainNames.add(new selectOption(domainNames[i], domainNames[i]));
        }
        return listDomainNames;
    }
    
    public void confirmHostAndValue() 
    {
        if(nameToValue.get(SelectedDomainName) != null)
        {
            hostValue = nameToValue.get(SelectedDomainName);
        }
        
        HostRecord = licenses[0].sfLma__Account__r.Alias__c + '.' + hostValue;
        
        if(String.isEmpty(SelectedRecordType) || SelectedRecordType.equals('CNAME'))
        {
            SelectedRecordType = 'CNAME';
            RecordValue = licenses[0].sfLma__Account__r.Alias__c + '.' + hostValue + '.' + SelectedDomainName + '.'  + orgId + '.live.siteforce.com';
        }
        else
        {
            RecordValue = addDomainRecord.IPAddress__c;
        }
    }
    
    public void save()
    {
        if(String.isEmpty(HostRecord))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Host is required !'));
        }
        else if(String.isEmpty(RecordValue))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Value is required !'));
        }
        else
        {
            addDomainRecord();
        }
    }
    
    public PageReference cancel()
    {
        PageReference pageReference = new PageReference('/'+ licenseId);
        pageReference.setRedirect(true);
        return pageReference;
    }
    
    private void addDomainRecord()
    {
        HttpResponse response = sendToAliYun();
        
        if(response.getStatus() == 'OK')
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'You have added a domain record !'));
        }
        else
        {
            DomainRecordController.ResponseMessage ResponseMessage = (DomainRecordController.ResponseMessage)JSON.deserialize(response.getBody(), DomainRecordController.ResponseMessage.class);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ResponseMessage.message));
        }
    }
    
    /**
     * Compute signature method and various parameters according to aliyun API
     * Please reference https://help.aliyun.com/document_detail/29772.html?spm=5176.doc29806.6.609.M8hwHd 
     */
    private HttpResponse sendToAliYun()
    {
        String timeStamp = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'', 'GMT');
        Blob binary = Crypto.GenerateAESKey(128);
        String blobToString = EncodingUtil.ConvertTohex(binary);
        String signatureNonce = blobToString.SubString(0, 8) + '-' + blobToString.SubString(8, 12) + '-' + blobToString.SubString(12, 16) + '-' + blobToString.SubString(16, 20) + '-' + blobToString.substring(20);
        
        Map<String, String> httpParameters = new Map<String, String>();
        httpParameters.put('Action', 'AddDomainRecord');
        httpParameters.put('Version', API_VERSION);
        httpParameters.put('AccessKeyId', addDomainRecord.AccessKeyId__c);
        httpParameters.put('Timestamp', timeStamp);
        httpParameters.put('SignatureMethod', SIGNATURE_METHOD);
        httpParameters.put('SignatureVersion', SIGNATURE_VERSION);
        httpParameters.put('SignatureNonce', signatureNonce);
        httpParameters.put('Value', RecordValue);
        httpParameters.put('TTL', TimeToLive);
        httpParameters.put('RR', HostRecord);
        httpParameters.put('Type', SelectedRecordType);
        httpParameters.put('Format', RETURN_VALUE_FORMAT);
        
        if(String.isNotEmpty(SelectedDomainName))
        {
            httpParameters.put('DomainName', SelectedDomainName);
        }
        
        List<String> sortedKeys = new List<String>(httpParameters.keySet());
        sortedKeys.sort();
        String stringToSign = 'GET' + '&' + percentEncode('/') + '&';
        String canonicalizedQueryString = '';
        
        for(String key : sortedKeys)
        {
            canonicalizedQueryString = canonicalizedQueryString + '&' + percentEncode(key) + '=' + percentEncode(httpParameters.get(key));
        }
        
        stringToSign = stringToSign + percentEncode(canonicalizedQueryString.substring(1));
        String secretKey = addDomainRecord.SecretKey__c + '&';
        Blob data = crypto.generateMac('HmacSHA1', Blob.valueOf(stringToSign), Blob.valueOf(secretKey));
        String signature = EncodingUtil.base64Encode(data);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(DNS_API_URL + canonicalizedQueryString + '&Signature=' + signature);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }
    
    private static String percentEncode(String value)
    {
        return value != null ? EncodingUtil.urlEncode(value, 'UTF-8').replace('+', '%20').replace('*', '%2A').replace('%7E', '~') : null;
    }
    
    public class ResponseMessage
    {
        public String message;
    }
}