global class CustomSearchAccountSkillHandler implements Charket.CharketSkillHandler
{
    String returnText = '';
    
    global Charket.SkillResponse execute(Charket.SkillContext context, Charket.SkillSession session)
    {
        Charket.WeChatApiMessage returnMsg;
        
        if(session.IsNew)
        {
            returnMsg = new Charket.WeChatApiMessage.Text('请输入你想搜索的客户名字:');
            session.Sequences.add('SearchAccount');
        }
        else if(context.WeChatMessage != null && context.WeChatMessage instanceOf Charket.WeChatApiMessage.Text)
        {
            if(session.Sequences.size() > 0)
            {
                String lastSession = session.Sequences.get(session.Sequences.size() - 1);
                String content = ((Charket.WeChatApiMessage.Text)context.WeChatMessage).Content.trim();
                
                if(lastSession == 'SearchAccount')
                {
                    String queryStr = 'select Name, Type, Industry from Account'
                        + ' where OwnerId = \'' + UserInfo.getUserId() + '\' and Name like \'%' + content + '%\' '
                        + ' order by LastModifiedDate desc limit 9 offset 0';
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
                        returnText += '\n回复对应数字查看客户详情\n回复名称搜索其他客户';
                        returnText = accounts.size() >= 9 ? returnText + '\n回复 N 下一页' : returnText;
                        session.Sequences.add('searchAccounts');
                        session.Attributes.put('Offset', '0');
                        session.Attributes.put('SearchKey', content);
                    }
                    else
                    {
                        returnText = '未找到数据。';
                        session.ShouldEndSession = true;
                    }
                }
                else
                {
                    returnText = CustomAccountSkillUtil.getReturnText(returnText, session, content, true);
                }
            }
            
            returnMsg = new Charket.WeChatApiMessage.Text(returnText);
        }

        return new Charket.SkillResponse(returnMsg);
    }
}