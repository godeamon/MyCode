public with sharing class WeChatQRCodeUtil 
{
    static final String DEVELOPER_NAME = 'Charket_QR_Code';

    static Map<SObject, Document> objToDocument = new Map<SObject, Document>();
    static Map<String, Charket.WeChatApiQRCode> objIdToWeChatApiQRCode = new Map<String, Charket.WeChatApiQRCode>();
    static Map<Blob, Charket__WeChatQRCode__c> blobBodytoWeChatQRCode = new Map<Blob, Charket__WeChatQRCode__c>();
    static Map<Charket__WeChatQRCode__c, Attachment> attachmentIdtoWeChatQRCode = new Map<Charket__WeChatQRCode__c, Attachment>();

    public static List<String> createQRCodeByNumberId(List<sObject> objs, Id wechatAccountId, Id wechatMessageId, Integer qrcodeExpirationHours)
    {
        List<Charket__WeChatAccount__c> charketAccount = [select Id from Charket__WeChatAccount__c where Id = :wechatAccountId];
        List<String> codeURLs = new List<String>();
        
        upsertDocument(objs, qrcodeExpirationHours, charketAccount);
        codeURLs = insertWeChatQRCode(qrcodeExpirationHours, charketAccount, wechatMessageId);
        insertAttachment();
        updateWeChatQRcode();

        return codeURLs;
    }
    
    private static void upsertDocument(List<sObject> objs, Integer qrcodeExpirationHours, List<Charket__WeChatAccount__c> charketAccount)
    {
        List<Folder> folder = [select Id from Folder where DeveloperName = :DEVELOPER_NAME limit 1];

        for(sObject obj : objs)
        {
            Charket.WeChatApiQRCode qrCode = generateQRCode(charketAccount[0].Id, Integer.valueOf(obj.get('NumberId__c')), qrcodeExpirationHours * 3600);

            if(qrCode != null || Test.isRunningTest())
            {
                objIdToWeChatApiQRCode.put(obj.Id, qrCode);
                String contentType;
                Blob qrCodeBody;
                
                if(Test.isRunningTest())
                {
                    contentType = 'jpg';
                    qrCodeBody = Blob.valueOf('test');
                }
                else
                {
                    contentType = qrCode.ContentType;
                    qrCodeBody = qrCode.BlobBody;
                }
                
                String developerName = 'Charket_QRCode_' + obj.Id;
                Document qrCodeDocument;
                List<Document> docs = [select Id from Document where DeveloperName = :developerName limit 1];
                
                if(docs.size() > 0)
                {
                    qrCodeDocument = docs[0];
                    qrCodeDocument.body = qrCodeBody;
                }
                else 
                {
                    qrCodeDocument = new Document(
                        Name = 'Charket_QRCode_' + obj.Id,
                        ContentType = contentType,
                        DeveloperName = developerName,
                        IsPublic = true,
                        Type = 'jpg',
                        FolderId = folder[0].Id,
                        body = qrCodeBody);
                }

                objToDocument.put(obj, qrCodeDocument);
            }
            else
            {
                throw new CustomInfoException('Generate the QRCode failure.');
            }
        }
        
        upsert objToDocument.values();
    }
    
    private static List<String> insertWeChatQRCode(Integer qrcodeExpirationHours, List<Charket__WeChatAccount__c> charketAccount, Id wechatMessageId)
    {
        List<Charket__WeChatResponseItem__c> charketResponseItem = [SELECT Charket__WeChatResponse__c FROM 
                Charket__WeChatResponseItem__c where Charket__WeChatMessage__c = :wechatMessageId];
        List<String> codeURLs = new List<String>();

        for(SObject obj : objToDocument.keySet())
        {
            Charket.WeChatApiQRCode qrCode = objIdToWeChatApiQRCode.get(obj.Id);
            String code_url = System.URL.getSalesforceBaseUrl().toExternalForm() 
                    + '/servlet/servlet.ImageServer?id=' + objToDocument.get(obj).Id
                    + '&oid=' + UserInfo.getOrganizationId();
            codeURLs.add(code_url);
            
            if(Test.isRunningTest())
            {
                Charket__WeChatQRCode__c wechatQRCode = new Charket__WeChatQRCode__c(
                    Charket__WhatId__c = obj.Id, 
                    Charket__WeChatAccount__c = charketAccount[0].Id,
                    Charket__Url__c = 'qrCode.Ticket.Url',
                    Charket__WeChatCreatedDate__c = Datetime.now(),
                    Charket__ExpirationSeconds__c = qrcodeExpirationHours * 3600,
                    Charket__Ticket__c = '000000000000000',
                    Charket__WeChatResponse__c = charketResponseItem.size() > 0 ? charketResponseItem[0].Charket__WeChatResponse__c : null,
                    Name = obj.getSObjectType().getDescribe().getName() + ': QR code for ' 
                            + obj.get('Name') + ' ' + obj.get('NumberId__c')
                );
                
                blobBodytoWeChatQRCode.put(Blob.valueOf('test'), wechatQRCode);
            }
            else
            {
                Charket__WeChatQRCode__c wechatQRCode = new Charket__WeChatQRCode__c(
                    Charket__WhatId__c = obj.Id, 
                    Charket__IsActive__c = true,
                    Charket__WeChatAccount__c = charketAccount[0].Id,
                    Charket__Url__c = qrCode.Ticket.Url,
                    Charket__WeChatCreatedDate__c = Datetime.now(),
                    Charket__ExpirationSeconds__c = qrcodeExpirationHours * 3600,
                    Charket__Ticket__c = String.valueOf(qrCode.Ticket.Ticket),
                    Charket__WeChatResponse__c = charketResponseItem.size() > 0 ? charketResponseItem[0].Charket__WeChatResponse__c : null,
                    Name = obj.getSObjectType().getDescribe().getName() + ': QR code for ' 
                            + obj.get('Name') + ' ' + obj.get('NumberId__c')
                );
                
                blobBodytoWeChatQRCode.put(qrCode.BlobBody, wechatQRCode);
            }            
        }

        insert blobBodytoWeChatQRCode.values();
        return codeURLs;
    }

    private static void insertAttachment()
    {
        for(Blob blobBody : blobBodytoWeChatQRCode.keySet())
        {
            Attachment attachment = new Attachment(
                ParentId = blobBodytoWeChatQRCode.get(blobBody).Id,
                Body = blobBody,
                Name = blobBodytoWeChatQRCode.get(blobBody).Name + '.jpg'
                );
            attachmentIdtoWeChatQRCode.put(blobBodytoWeChatQRCode.get(blobBody), attachment);
            
        }
        insert attachmentIdtoWeChatQRCode.values();
    }

    private static void updateWeChatQRcode()
    {
        for(Charket__WeChatQRCode__c qrCode : attachmentIdtoWeChatQRCode.keySet())
        {
            qrCode.Charket__AttachmentId__c = attachmentIdtoWeChatQRCode.get(qrCode).Id;
        }

        update new List<Charket__WeChatQRCode__c>(attachmentIdtoWeChatQRCode.keySet());
    } 

    private static Charket.WeChatApiQRCode generateQRCode(String accountId, Integer tempScene, Integer expirationSeconds)
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