public class AnnualPartyAnswerController
{
    private List<Charket__SurveyQuestion__c> SurveyQuestions = new List<Charket__SurveyQuestion__c>();
    private static final String mchId = '1441852502';// 商户号
    private static final String sendName = 'Charket';// 商户名称
    private static final String wxAppid = 'wxca02c88b2a50abd3';// 公众账号appid
    private static final String key = 'MtNkJHchHuaYUZZXfVDZVXtJnnaFPzgb';
    private static final String activeName = 'Meginfo十周年';
    private static final String clientIp = '10.1.3.50';
    private static final String remark = '恭喜发财'; 
    private static final String sceneId = 'PRODUCT_4';// 场景Id

    public AnnualPartyAnswerController()
    {
        SendAll = false;
        QRCodeId = ApexPages.currentPage().getParameters().get('qrCodeId');
        if(String.isNotBlank(QRCodeId))
        {
            List<Charket__WeChatQRCode__c> weChatQRCodes = [select Id, Charket__WhatId__c, MoreInfo__c, Charket__WeChatAccount__c
                    from Charket__WeChatQRCode__c where Id = :QRCodeId];

            if(weChatQRCodes.size() > 0 && String.isNotBlank(weChatQRCodes[0].MoreInfo__c))
            {
                if(String.isNotBlank(weChatQRCodes[0].Charket__WeChatAccount__c))
                {
                    AccountId = weChatQRCodes[0].Charket__WeChatAccount__c;
                }

                SurveyId = weChatQRCodes[0].MoreInfo__c;

                CurrentNum = 0;
                if(getSurveyQuestions().size() > 0)
                {
                    QuestionsCount = getSurveyQuestions().size();
                    system.debug('firstQuestionsCount:::'+QuestionsCount);
                    IsLastQuestion = false;
                    IsFirstQuestion = true;
                    if(CurrentNum == getSurveyQuestions().size() - 1)
                    {
                        IsLastQuestion = true;
                    }

                    SurveyQuestions = getSurveyQuestions();
                    CurrentQuestion = SurveyQuestions[CurrentNum];
                    FirstQuestionId = SurveyQuestions[CurrentNum].Id;
                    CurrentQuestionText = CurrentQuestion.Charket__Question__c;
                    CurrentCorrectNum = CurrentQuestion.CorrectAnswer__c;

                    if(String.isNotBlank(weChatQRCodes[0].Charket__WhatId__c))
                    {
                        if(((Id)weChatQRCodes[0].Charket__WhatId__c).getSobjectType() == Schema.Campaign.SObjectType)
                        {
                            CampaignId = weChatQRCodes[0].Charket__WhatId__c;
                        }
                        else if(((Id)weChatQRCodes[0].Charket__WhatId__c).getSobjectType() == Schema.Charket__WeChatCampaignFlowStep__c.SObjectType)
                        {
                            List<Charket__WeChatCampaignFlowStep__c> wechatCampaigns = [select Id, Charket__WeChatCampaignFlow__r.Charket__Campaign__c
                                    from Charket__WeChatCampaignFlowStep__c where Id = :weChatQRCodes[0].Charket__WhatId__c];

                            if(wechatCampaigns.size() > 0 && String.isNotBlank(wechatCampaigns[0].Charket__WeChatCampaignFlow__r.Charket__Campaign__c)
                                    && ((Id)wechatCampaigns[0].Charket__WeChatCampaignFlow__r.Charket__Campaign__c).getSobjectType() == Schema.Campaign.SObjectType)
                            {
                                CampaignId = wechatCampaigns[0].Charket__WeChatCampaignFlow__r.Charket__Campaign__c;
                            }
                        }
                    }
                }
            }
        }
    }

    public Integer CurrentNum { get; set; }
    public Integer QuestionsCount { get; set; }

    public Boolean IsLastQuestion { get; set; }
    public Boolean IsFirstQuestion { get; set; }

    public String AccountId { get; set; }
    public String QRCodeId { get; set; }
    public String SurveyId { get; set; }
    public String CurrentQuestionText { get; set; }
    public String FirstQuestionId { get; set; }
    public String CampaignId { get; set; }
    public String CurrentCorrectNum { get; set; }

    public Charket__SurveyQuestion__c CurrentQuestion { get; set; }

    public Integer TotalAmount { get; set; }// 付款金额 单位分
    public Integer TotalNum { get; set; }// 红包发放总人数
    public String Wishing { get; set; }// 红包祝福语
    public Boolean SendAll { get; set; }

    @RemoteAction
    public static String updateCurrentQuestionStatus(String firstQuestionId)
    {
        Charket__SurveyQuestion__c questionToUpdate = [select ShowStatus__c from Charket__SurveyQuestion__c where Id = :firstQuestionId];
        questionToUpdate.ShowStatus__c = 'showing';
        update questionToUpdate;

        return questionToUpdate.ShowStatus__c;
    }

    @RemoteAction
    public static void sendTimeoutAndWinMessage(String wechatFollowerId, String isWin, List<String> winFollowerIds)
    {
        try
        {
            List<Charket__WeChatFollower__c> wechatFollowers = new List<Charket__WeChatFollower__c>();
            String wechatMessageId = '';

            if(String.isBlank(isWin))
            {
                List<String> charketContextIds = getCharketContexts(wechatFollowerId, 0, true);
                wechatFollowers = [select Id, Charket__WeChatAccount__c, Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c where Id = :wechatFollowerId];
                List<Charket__WeChatMessage__c> wechatMessagesExist = [select Charket__TextBody__c, Id from Charket__WeChatMessage__c
                        where Charket__WeChatAccount__c = :wechatFollowers[0].Charket__WeChatAccount__c and Name = 'Answer timeout'
                        order by CreatedDate desc];
                if(wechatMessagesExist.size() > 0)
                {
                    wechatMessageId = wechatMessagesExist[0].Id;
                }
                else
                {
                    Charket__WeChatMessage__c wechatMessage = new Charket__WeChatMessage__c(Name = 'Answer timeout',
                            Charket__WeChatAccount__c = wechatFollowers[0].Charket__WeChatAccount__c, Charket__TextBody__c = '对不起，手速太慢，答题超时了！');
                    wechatMessage.Charket__Type__c = 'Text Message';
                    insert wechatMessage;
                    wechatMessageId = wechatMessage.Id;
                }

                Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest messageRequest = new Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest();
                messageRequest.objectId = wechatFollowerId;
                messageRequest.messageId = wechatMessageId;
                messageRequest.whoId = String.isNotEmpty(wechatFollowers[0].Charket__Lead__c) ?
                        wechatFollowers[0].Charket__Lead__c : wechatFollowers[0].Charket__Contact__c;

                List<Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest> messageRequests = new List<Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest>();
                messageRequests.add(messageRequest);
                Charket.CharketSendWeChatMessageAction.sendWeChatMessage(messageRequests);
            }
            else
            {
                emptyCurrentSkill();

                wechatFollowers = [select Id, Charket__WeChatAccount__c, Charket__Lead__c, Charket__Contact__c from Charket__WeChatFollower__c where Id in :winFollowerIds];
                List<Charket__WeChatMessage__c> wechatMessagesExist = [select Charket__TextBody__c, Id from Charket__WeChatMessage__c
                        where Charket__WeChatAccount__c = :wechatFollowers[0].Charket__WeChatAccount__c and Name = 'Answer winner'
                        order by CreatedDate desc];
                
                if(wechatMessagesExist.size() > 0)
                {
                    wechatMessageId = wechatMessagesExist[0].Id;
                }
                else
                {
                    Charket__WeChatMessage__c wechatMessage = new Charket__WeChatMessage__c(Name = 'Answer winner',
                            Charket__WeChatAccount__c = wechatFollowers[0].Charket__WeChatAccount__c, Charket__TextBody__c = '从一开始就觉得你不平凡！果然，你全对了！稍等片刻，红包正在路上！');
                    wechatMessage.Charket__Type__c = 'Text Message';
                    insert wechatMessage;
                    wechatMessageId = wechatMessage.Id;
                }
                if(wechatFollowers.size() > 0)
                {
                    for(Charket__WeChatFollower__c follower : wechatFollowers)
                    {
                        Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest messageRequest = new Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest();
                        messageRequest.objectId = follower.Id;
                        messageRequest.messageId = wechatMessageId;
                        messageRequest.whoId = String.isNotEmpty(follower.Charket__Lead__c) ?
                                follower.Charket__Lead__c : follower.Charket__Contact__c;

                        List<Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest> messageRequests = new List<Charket.CharketSendWeChatMessageAction.SendWeChatMessageRequest>();
                        messageRequests.add(messageRequest);
                        Charket.CharketSendWeChatMessageAction.sendWeChatMessage(messageRequests);
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    }

    //form Red pack method
    @RemoteAction
    public static void sendWeChatRedPack(List<String> followIds, String totalAmount, String wishing, Boolean sendAll, String compainId, String accountId)
    {
        String totalNum = '';

        List<String> openIds = new List<String>();

        if(!sendAll)
        {
            if(followIds.size() > 0)
            {
                try
                {
                    List<Charket__WeChatFollower__c> weChatFollowers = [select Charket__OpenId__c from Charket__WeChatFollower__c where id in :followIds];
                    
                    if(weChatFollowers.size() > 0)
                    {
                        for(Charket__WeChatFollower__c weChatFollower : weChatFollowers)
                        {
                            openIds.add(weChatFollower.Charket__OpenId__c);
                            system.debug('Charket__OpenId__c:::' + weChatFollower.Charket__OpenId__c);
                        }
                    }
                }
                catch(Exception e)
                {
                    system.debug(e.getMessage());
                }
            }
        }
        else
        {
            try
            {
                List<Charket__WeChatFollower__c> charketWeChatFollowers = [select Charket__Lead__c, Charket__Contact__c, Charket__OpenId__c
                        from Charket__WeChatFollower__c where Charket__WeChatAccount__c = :accountId];

                List<CampaignMember> CampaignMembers = [select LeadOrContactId from CampaignMember where CampaignId = :compainId and status = 'Answered'];

                Set<String> leadOrContactIds = new Set<String>();

                for(CampaignMember campaignMember : CampaignMembers)
                {
                    leadOrContactIds.add(campaignMember.LeadOrContactId);
                }

                for(Charket__WeChatFollower__c follower : charketWeChatFollowers)
                {
                    if(leadOrContactIds.contains(String.valueOf(follower.Charket__Lead__c)) ||
                            leadOrContactIds.contains(String.valueOf(follower.Charket__Contact__c)))
                    {
                        openIds.add(follower.Charket__OpenId__c);
                        system.debug('Charket__OpenId__c:::' + follower.Charket__OpenId__c);
                    }
                }
            }
            catch(Exception e)
            {
                system.debug(e.getMessage());
            }
        }
        
        totalNum = String.valueOf(openIds.size());
        Integer aveMoney = (Integer.valueOf(totalAmount)/Integer.valueOf(totalNum))*100;

        if(openIds.size() > 0)
        {
            for(String openId : openIds)
            {
                String mchBillnoNumber = generateRandomString(28);//商户订单编号（必须唯一）
                //random number
                String nonceString = generateRandomString(28);

                List<SortedMap> sortedMaps = new List<SortedMap>();
                sortedMaps.add(new SortedMap('act_name', activeName));
                sortedMaps.add(new SortedMap('client_ip', clientIp));
                sortedMaps.add(new SortedMap('mch_billno', mchBillnoNumber));
                sortedMaps.add(new SortedMap('mch_id', mchId));
                sortedMaps.add(new SortedMap('nonce_str', nonceString));
                sortedMaps.add(new SortedMap('re_openid', openId));
                sortedMaps.add(new SortedMap('remark', remark));
                sortedMaps.add(new SortedMap('total_amount', String.valueOf(aveMoney)));
                sortedMaps.add(new SortedMap('total_num', '1'));
                sortedMaps.add(new SortedMap('scene_id', sceneId));

                if(String.isNotBlank(wishing))
                {
                    sortedMaps.add(new SortedMap('wishing', wishing));
                }
                else
                {
                    sortedMaps.add(new SortedMap('wishing', '恭喜发财大吉大利'));
                }

                sortedMaps.add(new SortedMap('send_name', sendName));
                sortedMaps.add(new SortedMap('wxappid', wxAppid));
                sortedMaps.sort();

                String generateRedPackString = '';
                for(SortedMap sortedMap : sortedMaps)
                {
                    generateRedPackString += sortedMap.Label + '=' + sortedMap.Content + '&';
                }

                generateRedPackString += 'key=' + key;

                Blob targetBlob = Crypto.generateDigest('MD5', Blob.valueOf(generateRedPackString));
                String sendRedPack = EncodingUtil.convertToHex(targetBlob).toUpperCase();

                DOM.Document document = new DOM.Document();
                dom.XmlNode xml = document.createRootElement('xml', null, null);

                dom.XmlNode body = xml.addChildElement('act_name', null, null);
                body.addTextNode(activeName);

                dom.XmlNode body2 = xml.addChildElement('client_ip', null, null);
                body2.addTextNode(clientIp);

                dom.XmlNode body3 = xml.addChildElement('mch_billno', null, null);
                body3.addTextNode(mchBillnoNumber);

                dom.XmlNode body4 = xml.addChildElement('mch_id', null, null);
                body4.addTextNode(mchId);

                dom.XmlNode body5 = xml.addChildElement('nonce_str', null, null);
                body5.addTextNode(nonceString);

                dom.XmlNode body6 = xml.addChildElement('re_openid', null, null);
                body6.addTextNode(openId);

                dom.XmlNode body7 = xml.addChildElement('remark', null, null);
                body7.addTextNode(remark);

                dom.XmlNode body8 = xml.addChildElement('scene_id', null, null);
                body8.addTextNode(sceneId);

                dom.XmlNode body9 = xml.addChildElement('send_name', null, null);
                body9.addTextNode(sendName);

                dom.XmlNode body10 = xml.addChildElement('total_amount', null, null);
                body10.addTextNode(String.valueOf(aveMoney));

                dom.XmlNode body11 = xml.addChildElement('total_num', null, null);
                body11.addTextNode('1');

                dom.XmlNode body12 = xml.addChildElement('wishing', null, null);
                body12.addTextNode(Wishing);

                dom.XmlNode body13 = xml.addChildElement('wxappid', null, null);
                body13.addTextNode(wxAppid);

                dom.XmlNode body14 = xml.addChildElement('sign', null, null);
                body14.addTextNode(sendRedPack);

                try
                {
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('callout:WeChatRedPack/mmpaymkttransfers/' + 'sendredpack');
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'text/xml');
                    request.setBodyDocument(document);
                    HttpResponse response = http.send(request);
                    system.debug('response : ' + response.getBody());
                    String responseStatus = response.getStatus();
                }
                catch(Exception e)
                {
                    system.debug(e.getMessage());
                }
            }
        }
    }

    public void next()
    {
        List<Charket__SurveyQuestion__c> questionList = new List<Charket__SurveyQuestion__c>();
        if(SurveyQuestions.size() > 0)
        {
            try
            {
                questionList.add(SurveyQuestions[CurrentNum]);

                if(CurrentNum < SurveyQuestions.size() - 1 && CurrentNum >= 0)
                {
                    CurrentNum += 1;
                }
                CurrentQuestion = SurveyQuestions[CurrentNum];
                CurrentQuestionText = CurrentQuestion.Charket__Question__c;
                CurrentCorrectNum = CurrentQuestion.CorrectAnswer__c;

                questionList.add(SurveyQuestions[CurrentNum]);

                if(questionList.size() == 2)
                {
                    questionList[0].ShowStatus__c = 'end';
                    questionList[1].ShowStatus__c = 'showing';
                }
                update questionList;
            }
            catch(Exception e)
            {
                System.debug(e.getMessage());
            }

            if(CurrentNum == SurveyQuestions.size() - 1)
            {
                IsLastQuestion = true;
            }
        }

        List<String> charketContextIds = getCharketContexts('', CurrentNum, false);
    }

    //form Red pack method
    private static String generateRandomString(Integer len)
    {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len)
        {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    private static void emptyCurrentSkill()
    {
        try
        {
            List<Charket__Skill__c> skills = [select Id, (select Id, Charket__CharketContext__c from Charket__SkillContexts__r
                    where Charket__IsValid__c = true) from Charket__Skill__c where Charket__Handler__c = 'AnnualPartyAnswerHandler' limit 1];
            List<Charket__CharketContext__c> charketContexts = [select Id, Charket__WeChatFollower__c, Charket__CurrentSkill__c,
                    (select charket__Status__c from Charket__SkillContexts__r where Charket__IsValid__c = true)
                    from Charket__CharketContext__c where Charket__CurrentSkill__c = :skills[0].Id];

            if(charketContexts.size() > 0)
            {
                for(Charket__CharketContext__c context : charketContexts)
                {
                    context.Charket__PreviousSkill__c = context.Charket__CurrentSkill__c;
                    context.Charket__CurrentSkill__c = null;
                    if(context.Charket__SkillContexts__r.size() > 0)
                    {
                        context.Charket__SkillContexts__r[0].charket__Status__c = 'Completed';
                    }
                }

                update charketContexts;
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    }

    private static List<String> getCharketContexts(String wechatFollowerId, Integer CurrentNum, Boolean notNext)
    {
        List<Charket__Skill__c> skillsOne = [select Id, (select Id, Charket__CharketContext__c, Charket__Body__c
                from Charket__SkillContexts__r where Charket__IsValid__c = true) from Charket__Skill__c
                where Charket__Handler__c = 'AnnualPartyAnswerHandler' limit 1];

        List<Charket__Skill__c> skills = new List<Charket__Skill__c>();
        if(String.isNotBlank(wechatFollowerId))
        {
            List<Charket__CharketContext__c> charketContexts = [select Id, Charket__CurrentSkill__c from Charket__CharketContext__c
                    where Charket__WeChatFollower__c = :wechatFollowerId and Charket__CurrentSkill__c = :skillsOne[0].id];
            if(charketContexts.size() > 0)
            {
                skills = [select Id, (select Id, Charket__CharketContext__c, Charket__Body__c
                from Charket__SkillContexts__r where Charket__IsValid__c = true and Charket__CharketContext__c = :charketContexts[0].Id) from Charket__Skill__c
                where Charket__Handler__c = 'AnnualPartyAnswerHandler' limit 1];
            }
            
        }
        else
        {
            skills = [select Id, (select Id, Charket__CharketContext__c, Charket__Body__c
                    from Charket__SkillContexts__r where Charket__IsValid__c = true) from Charket__Skill__c
                    where Charket__Handler__c = 'AnnualPartyAnswerHandler' limit 1];
        }

        List<String> charketContextIds = new List<String>();

        if(skills.size() > 0)
        {
            for(Charket__SkillContext__c skillContext : skills[0].Charket__SkillContexts__r)
            {
                charketContextIds.add(skillContext.Charket__CharketContext__c);

                try
                {
                   Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(skillContext.Charket__Body__c);
                   Map<String, Object> m2=(Map<String, Object>)m.get('Attributes');

                   if(!notNext)
                   {
                        m2.put('currentQuestionNum', CurrentNum);
                        skillContext.Charket__Body__c = JSON.serialize(m);
                   }
                   else
                   {
                        m2.put('status', 'outtime');
                        skillContext.Charket__Body__c = JSON.serialize(m);
                   }
                }
                catch(Exception e)
                {
                    System.debug(e.getMessage() + ':::' + e.getLineNumber());
                }
            }
            update skills[0].Charket__SkillContexts__r;
            system.debug('skillbody:::');
        }

        return charketContextIds;
    }

    private List<Charket__SurveyQuestion__c> getSurveyQuestions()
    {
        return [select Id, Charket__Question__c, Charket__Type__c, CorrectAnswer__c, ShowStatus__c, (select Id, Charket__Choice__c
                from CharKet__SurveyAnswers__r order by Charket__Order__c, CreatedDate)
                from Charket__SurveyQuestion__c where Charket__Survey__c = :SurveyId order by Charket__Order__c, CreatedDate];
    }

    //form Red pack method
    public class SortedMap implements Comparable
    {
        public String Label { get; set; }
        public String Content { get; set; }
        
        public Integer compareTo(Object instance)
        {
            SortedMap sortedMap = (SortedMap)instance;
            if(this.Label > sortedMap.Label)
            {
                return 1;
            }
            else
            {
                return -1;
            }
        }

        public SortedMap(String label, String content)
        {
            this.Label = label;
            this.Content = content;
        }
    }
}