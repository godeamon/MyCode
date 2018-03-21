public class QRCodeComponentController 
{
    private Id documentId;
    private Id orgId;
    
    public QRCodeComponentController()
    {
        orgId = UserInfo.getOrganizationId();
    }
    
    public Id ContactId { get; set; }
    
    public String QRCodeUrl 
    {
        get 
        {
            List<Account> personAccs = [select Id, Member_Id__pc, PersonEmail from Account where PersonContactId = :ContactId limit 1];
            if(personAccs.size() > 0)
            {
                Account personAcc = personAccs[0];
                if(personAcc.PersonEmail == null)
                {
                   throw new CustomInfoException('The Email is required.');
                }
                documentId = createQRCodeDocForAccount(personAcc.Id);
            }
            return System.URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentId  + '&oid=' + orgId;
        }
    }
    
    private Id createQRCodeDocForAccount(Id personAccId)
    {
        Charket__WeChatAccount__c weChatAccount = [select Id, Name from Charket__WeChatAccount__c where Name = 'Charket'];
        Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Charket_QRCode' LIMIT 1];
        Account personAcc = [select Id, PersonContactId, Member_Id__pc from Account where Id = :personAccId];
        
        try
        {
            if(personAcc.Member_Id__pc == null)
            {
                throw new CustomInfoException('The Member Id is required.');
            }
            if(personAcc.Member_Id__pc != String.valueOf(Integer.valueOf(personAcc.Member_Id__pc)))
            {
                throw new CustomInfoException('The Member Id is an invalid integer.');
            }
        }
        catch(TypeException ex)
        {
            throw new CustomInfoException('The Member Id is an invalid integer.');
        }
        
        Charket.WeChatApiQRCode qrCode = getQRCode(weChatAccount.Id, Integer.valueOf(personAcc.Member_Id__pc), 2592000);
        User siteUser = [select Id, Name from User where Profile.Name = 'eftscn Profile' limit 1];
        if(qrCode != null || Test.isRunningTest())
        {
            String contentType;
            Blob blobBody;
            if(Test.isRunningTest())
            {
                contentType = 'jpg';
                blobBody = Blob.valueOf('test');
            }
            else
            {
                contentType = qrCode.ContentType;
                blobBody = qrCode.BlobBody;
            }
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = personAcc.Id;
            accountShare.UserOrGroupId = siteUser.Id;
            accountShare.AccountAccessLevel = 'Read';
            accountShare.OpportunityAccessLevel = 'Read';
            accountShare.RowCause = Schema.AccountShare.RowCause.Manual;
            insert accountShare;
        
            String developerName = 'Charket_QRCode_' + personAcc.Member_Id__pc;
            Document docForQRCode;
            List<Document> oldDocs = [select Id from Document where DeveloperName = :developerName limit 1];
            if(oldDocs.size() > 0)
            {
                docForQRCode = oldDocs[0];
                docForQRCode.body = blobBody;
            }
            else 
            {
                docForQRCode = new Document(
                                        Name = 'Charket-QRCode-' + personAcc.Member_Id__pc,
                                        ContentType = contentType,
                                        DeveloperName = developerName,
                                        IsPublic = true,
                                        Type = 'jpg',
                                        FolderId = folder.Id,
                                        body = blobBody
                                    );
            }
            
            upsert docForQRCode;
            return docForQRCode.Id;
        }
        else
        {
            throw new CustomInfoException('Generate the QRCode failure.');
        }
        return null;
    }
    
    private Charket.WeChatApiQRCode getQRCode(String accountId, Integer tempScene, Integer expirationSeconds)
    {
        if(Test.isRunningTest())
        {
            return null;
        }
        Charket.WeChatClient client = new Charket.WeChatClient(accountId);
        Charket.WeChatApiQRCode qrCode = client.getQRCode().generateQRCode(tempScene, expirationSeconds);
        
        return qrCode;
    }
    
    public class CustomInfoException extends Exception {}
}