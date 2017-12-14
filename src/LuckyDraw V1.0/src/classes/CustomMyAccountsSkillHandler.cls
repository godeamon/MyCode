global class CustomMyAccountsSkillHandler implements Charket.CharketSkillHandler
{
    String returnText = '';
    final Integer PAGESIZE = CustomAccountSkillUtil.PAGESIZE;
    
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage.Text returnMsg;

        if(session.IsNew)
        {
            String queryStr = 'select Name, Type, Industry from Account'
                + ' where OwnerId = \'' + UserInfo.getUserId() + '\''
                + ' order by LastModifiedDate desc limit ' + PAGESIZE + ' offset 0';
            List<Account> accounts = Database.query(queryStr);
            Integer i = 0;
            for(Account acc : accounts)
            {
                i++;
                returnText += i + '. ' + acc.Name + '\n';
                session.Attributes.put('Account-' + String.valueOf(i), acc.Id);
            }
            if(returnText != '')
            {
                returnText += '\n回复对应数字查看客户详情';
                returnText = accounts.size() >= PAGESIZE ? returnText + '\n回复 N 下一页' : returnText;
                session.Sequences.add('getAccountList');
                session.Attributes.put('Offset', '0');
            }
            else
            {
                returnText = '未找到数据。';
                session.ShouldEndSession = true;
            }
        }
        else if(context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text)
        {
            if(session.Sequences.size() > 0)
            {
                String content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content.trim();
                returnText = CustomAccountSkillUtil.getReturnText(returnText, session, content, false);
            }
        }

        if(String.isNotBlank(returnText))
        {
            returnMsg = new Charket.WeChatApiMessage.Text(returnText);
        }
        
        return new Charket.SkillResponse(returnMsg);
    }
}