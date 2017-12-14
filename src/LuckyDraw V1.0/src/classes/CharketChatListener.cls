@RestResource(urlMapping='/livechat/*')
global with sharing class CharketChatListener
{
    @HttpPost
    global static void doPost()
    {
        try
        {
            if(RestContext.request.requestBody != null)
            { 
                String accountId = RestContext.request.params.get('accountId');
                String openId = RestContext.request.params.get('openId');
                String requestBody = RestContext.request.requestBody.toString();
                String transcriptId = RestContext.request.params.get('transcriptId');
                String responseBody;
                if(String.isNotBlank(accountId) && String.isNotBlank(openId) && String.isNotBlank(requestBody))
                {
                    List<Charket__WeChatTranscript__c> transcripts = [select Id, Charket__StartTime__c, 
                        Charket__AgentMessageCount__c, Charket__WeChatAgent__r.Charket__IsActive__c,
                        Charket__WeChatAgent__c, Charket__WeChatAgent__r.Charket__WeChatUsername__c 
                        from Charket__WeChatTranscript__c
                        where Id = :transcriptId and Charket__WeChatAgent__c != null limit 1];
                    if(transcripts.size() > 0)
                    {
                        if(!transcripts[0].Charket__WeChatAgent__r.Charket__IsActive__c)
                        {
                            responseBody = 'Please contact your system administrator for setting you up as a WeChat agent.';
                        }
                        else
                        {
                            Charket.WeChatApiMessage.Text message = new Charket.WeChatApiMessage.Text(requestBody);
                            message.ToUserId = openId;
                            message.CreateTime = Datetime.now();
                            Charket.WeChatClient client = new Charket.WeChatClient(accountId);
                            if(client != null)
                            {
                                Charket.WeChatApiAgent agent = client.getAgent();
                                String agentUserName = (transcripts[0].Charket__WeChatAgent__c != null) ? transcripts[0].Charket__WeChatAgent__r.Charket__WeChatUsername__c : null;
                                agent.sendMessage(message, agentUserName);
                            }
                            
                            updateTranscriptForAgent(transcripts[0], requestBody);
                            responseBody = 'success';
                        }
                    }
                }
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }
        }
        catch(Exception e)
        {
            String data = RestContext.request.requestBody != null ? RestContext.request.requestBody.toString() : 'No Request Body';
            insert (new Charket__Log__c(Charket__ApexCodeName__c = 'CharketChatListener', Charket__Message__c = e.getMessage(), Charket__Data__c = data));
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
        }
    }

    public static void updateTranscriptForAgent(Charket__WeChatTranscript__c transcript, String content)
    {
        Charket__WeChatTranscriptItem__c item = new Charket__WeChatTranscriptItem__c(
            Charket__WeChatCreatedTime__c = Datetime.now().getTime(),
            Charket__WeChatAgentId__c = transcript.Charket__WeChatAgent__c,
            Charket__SenderId__c = UserInfo.getUserId(),
            Charket__SendBy__c = 'Agent',
            Charket__Type__c = 'TEXT',
            Charket__MessageId__c = UserInfo.getUserId() + Datetime.now().getTime(),
            Charket__Body__c = content,
            Charket__ShortBody__c = (content != null) ? content.left(255): content,
            Charket__IsActive__c = true
        );

        if(transcript.Charket__StartTime__c == null)
        {
            transcript.Charket__StartTime__c = Datetime.now();
            transcript.Charket__Status__c = 'In Progress';
        }
        transcript.Charket__AgentMessageCount__c += 1;
        update transcript;

        item.Charket__WeChatTranscript__c = transcript.Id;
        insert item;
    }
}