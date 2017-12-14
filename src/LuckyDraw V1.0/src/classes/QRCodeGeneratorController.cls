/**
 * An apex page controller that generate QRCode functionality
 */
public with sharing class QRCodeGeneratorController 
{
    public ApexPages.StandardSetController setCon;
    private String batchJobId;

    public QRCodeGeneratorController(ApexPages.StandardSetController stdSetCon)
    {
        setCon = stdSetCon;
        QRCodeExpirationHours = 720;
        IsBatchJobCompleted = true;
    }

    public Boolean IsBatchJobCompleted { get; set; }
    public Id WeChatAccountId { get; set; }
    public Id WeChatMessageId { get; set; }
    public Integer QRCodeExpirationHours { get; set; }

    public List<SelectOption> getWeChatAccountNames()
    {
        List<SelectOption> options = new List<SelectOption>();

        for(Charket__WeChatAccount__c wechatAccount : [select Name from Charket__WeChatAccount__c 
                where Charket__WeChatOriginId__c != null])
        {
            options.add(new SelectOption(wechatAccount.Id, wechatAccount.Name));
        }

        return options;
    }

    public void generateQRCode()
    {
        QRCodeGenerateJob batchGenerator = new QRCodeGenerateJob(setCon, WeChatAccountId, WeChatMessageId, QRCodeExpirationHours);
        batchJobId = Database.executeBatch(batchGenerator, 50);
        checkBatchStatus();
    }
    
    public void checkBatchStatus()
    {
        AsyncApexJob job = [select Status from AsyncApexJob where Id = :batchJobId]; 
        IsBatchJobCompleted = (job.Status == 'Completed');
    }
}