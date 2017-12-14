/**
 * An class to generate QR codes for sObject who has WeChatQRcodeURL__c field
 */
global class QRCodeGenerateJob implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    private ApexPages.StandardSetController stdSetController;
    private Id wechatAccountId;
    private Id wechatMessageId;
    private Integer qrcodeExpirationHours;
    private String exceptionMessage = '';

    public QRCodeGenerateJob(ApexPages.StandardSetController stdSetController, Id wechatAccountId, Id wechatMessageId, Integer qrcodeExpirationHours)
    {
        this.stdSetController = stdSetController;
        this.wechatAccountId = wechatAccountId;
        this.wechatMessageId = wechatMessageId;
        this.qrcodeExpirationHours = qrcodeExpirationHours;
    }

    global Iterable<sObject> start(Database.BatchableContext bc)
    {
        List<sObject> allRecords = new List<sObject>();

        do
        {
            allRecords.addAll(stdSetController.getRecords());
            stdSetController.setpageNumber(stdSetController.getPageNumber() + 1);
        }
        while(stdSetController.getHasNext());

        return allRecords;
    }

    global void execute(Database.BatchableContext bc, List<sObject> objList)
    {
        List<sObject> sObjs = new List<sObject>();
        List<String> codeURLs = new List<String>();

        try
        {
            codeURLs = WeChatQRCodeUtil.createQRCodeByNumberId(objList, wechatAccountId, wechatMessageId, qrcodeExpirationHours);

            for(Integer i = 0; i < objList.size(); i++)
            {
                objList[i].put('WeChatQRCodeURL__c', codeURLs[i]);
                sObjs.add(objList[i]);
            }
            
            update sObjs;
        }
        catch(Exception e)
        {
            exceptionMessage += e.getMessage();
        }        
    }

    global void finish(Database.BatchableContext bc)
    {
        AsyncApexJob job = [select CreatedBy.Email, Status, NumberOfErrors, JobItemsProcessed, 
                TotalJobItems, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
        
        if(job.Status == 'Completed')
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] Addresses = new String[]{job.CreatedBy.Email};
            mail.setToAddresses(Addresses);
            mail.setSenderDisplayName('Charket LMO');
            mail.setSubject('Generate QR codes job was completed');
            mail.setPlainTextBody('The batch Apex job processed ' + job.TotalJobItems + ' batches with ' 
                    + job.NumberOfErrors + ' failures. Extended Status: ' + job.ExtendedStatus 
                    + '. Exception Message: ' + exceptionMessage);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail});
        }
    }
}