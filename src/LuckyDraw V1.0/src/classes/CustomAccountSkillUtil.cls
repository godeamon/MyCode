public class CustomAccountSkillUtil
{
    public static final Integer PAGESIZE = 9;
    
    public static String getSkillReturnMessage(Charket.SkillSession session, String content)
    {
        String returnText;

        if(content == 'R' && session.Attributes.containsKey('CurrentAccountId'))
        {
            returnText = returnToAccount(session, content);
        }
        else
        {
            String lastSession = session.Sequences.get(session.Sequences.size() - 1);
            if(lastSession == 'createAccount')
            {
                returnText = createAccount(session, content);
            }
            else if(lastSession == 'getUpdateField')
            {
                if(session.Attributes.containsKey('UpdateField'))
                {
                    updateFieldValue(session, content);
                    session.Sequences.add('getAccountDetail');
                    returnText = '客户修改成功，详情如下：\n';
                    returnText += '1. 名称：' + session.Attributes.get('Name') + '\n2. 类型：' + session.Attributes.get('Type') + '\n3. 行业：' + session.Attributes.get('Industry');
                    returnText += '\n\n回复数字修改对应信息\n回复 A 创建销售活动\n回复 C 添加联系人';
                }
            }
            else if(lastSession == 'getAccountList' || lastSession == 'searchAccounts')
            {
                if(session.Attributes.containsKey('Account-' + content))
                {
                    returnText = getAccountDetail(session, content);
                }
            }
            else if(lastSession == 'getAccountDetail')
            {
                if(session.Attributes.containsKey('Field-' + content))
                {
                    String fieldName = session.Attributes.get('Field-' + content);
                    returnText = getUpdateFieldValue(session, fieldName);
                }
                else if(content == 'A')
                {
                    returnText = '请回复数字选择销售活动类型' + '\n1. 记录销售活动' + '\n2. 创建任务';
                    session.Sequences.add('createActivity');
                }
                else if(content == 'C')
                {
                    returnText = '请回复联系人的姓名，邮箱和手机号码（比如：张 学友 jacky.chueng@charket.com 18610026227）';
                    session.Sequences.add('createContact');
                }
            }
            else if(lastSession == 'createActivity')
            {
                returnText = createActivity(session, content);
            }
            else if(lastSession == 'createTask')
            {
                returnText = createTask(session, content);
            }
            else if(lastSession == 'createContact')
            {
                returnText = createContact(session, content);
            }

            if(String.isBlank(returnText))
            {
                returnText = '您回复的不在列表, 请重新选择\n';
            }
        }

        return returnText;
    }

    public static String getAccountDetail(Charket.SkillSession session, String content)
    {
        String returnText = '';
        String lastSession = session.Sequences.get(session.Sequences.size() - 1);
        String id = session.Attributes.get('Account-' + content);
        for(Account acc : [select Name, Type, Industry
                from Account where OwnerId = :UserInfo.getUserId()
                and Id = :id
                order by LastModifiedDate desc limit 9])
        {
            acc.Name = acc.Name == null ? '' : acc.Name;
            acc.Type = acc.Type == null ? '' : acc.Type;
            acc.Industry = acc.Industry == null ? '' : acc.Industry;
            returnText += '1. 名称: ' + acc.Name + '\n' + '2. 类型: ' + acc.Type + '\n' + '3. 行业: ' + acc.Industry;
            session.Attributes.put('Field-1', 'Name');
            session.Attributes.put('Field-2', 'Type');
            session.Attributes.put('Field-3', 'Industry');
            session.Attributes.put('Name', acc.Name);
            session.Attributes.put('Type', acc.Type);
            session.Attributes.put('Industry', acc.Industry);

            session.Attributes.put('CurrentAccountId', id);
            session.Attributes.put('CurrentAccountName', acc.Name);
            session.Attributes.put('CurrentAccountNumber', content);
            session.Sequences.add('getAccountDetail');
            break;
        }
        if(returnText != '')
        {
            returnText += '\n\n请回复数字修改对应的信息';
            returnText = lastSession == 'searchAccounts' ? returnText + '\n回复名称搜索其他客户' : returnText;
            returnText += '\n回复 A 创建销售活动' + '\n回复 C 添加联系人';
        }
        return returnText;
    }

    public static String createAccount(Charket.SkillSession session, String content)
    {
        String returnText;
        try
        {
            if(session.Attributes.get('Name') == null)
            {
                session.Attributes.put('Name', content); 
                returnText = '请输入数字选择公司类型：\n';
                returnText = getFieldValues(returnText, 'Type');
            }
            else if(session.Attributes.get('Type') == null)
            {
                session.Attributes.put('Type', getFieldValue('Type', Integer.valueOf(content))); 
                returnText = '请输入数字选择行业：\n';
                returnText = getFieldValues(returnText, 'Industry');
            }
            else
            {
                Account account = new Account();
                account.Name = session.Attributes.get('Name');
                account.Type = session.Attributes.get('Type');
                account.Industry = getFieldValue('Industry', Integer.valueOf(content));
                insert account;
                
                returnText = '成功创建客户，详情如下：\n';
                returnText += '1. 名称：' + account.Name + '\n2. 类型：' + account.Type + '\n3. 行业：' + account.Industry;
                returnText += '\n\n回复数字修改对应信息\n回复 A 创建销售活动\n回复 C 添加联系人';
                session.Attributes.put('Field-1', 'Name');
                session.Attributes.put('Field-2', 'Type');
                session.Attributes.put('Field-3', 'Industry');
    
                session.Sequences.add('getAccountDetail');
                session.Attributes.put('Industry', account.Industry);
                session.Attributes.put('CurrentAccountId', account.Id);
                session.Attributes.put('CurrentAccountName', account.Name);
                session.Attributes.put('CurrentAccountNumber', '1');
                session.Attributes.put('Account-1', account.Id);
            }
        }
        catch(Exception ex)
        {
            returnText = ex.getMessage() + '\n\n请重新回复';
        }

        return returnText;
    }

    public static String returnToAccount(Charket.SkillSession session, String content)
    {
        if(session.Attributes.get('CurrentAccountNumber') != null)
        {
            return getAccountDetail(session, session.Attributes.get('CurrentAccountNumber'));
        }
        
        return null;
    }

    public static String getUpdateFieldValue(Charket.SkillSession session, String fieldName)
    {
        String returnText = '';
        if(fieldName == 'Name')
        {
            returnText += '请输入修改后的名字';
            session.Attributes.put('UpdateField', 'Name');
            session.Attributes.put('FieldIsPicklist', '1');
        }
        else if(fieldName == 'Type' || fieldName == 'Industry')
        {
            Map<String, String> picklistMap = new Map<String, String>();
            Schema.DescribeFieldResult descriptionResult = SObjectType.Account.fields.getMap().get(fieldName).getDescribe();
            Integer i = 0;
            for(Schema.PicklistEntry entry : descriptionResult.getPicklistValues())
            {
                i = i + 1;
                returnText += i + '. ' + entry.getValue() + '\n';
                session.Attributes.put('FieldPicklist-' + String.valueOf(i), entry.getValue());
            }
            if(String.isNotBlank(returnText))
            {
                returnText += '请回复数字选择';
            }

            session.Attributes.put('UpdateField', fieldName);
            session.Attributes.put('FieldIsPicklist', '0');
        }
        session.Sequences.add('getUpdateField');
        return returnText;
    }

    public static String createActivity(Charket.SkillSession session, String content)
    {
        String returnText;
        if(content == '1')
        {
            returnText = '请问记录的内容是什么？';
            session.Attributes.put('ActivityType', 'CompletedTask');
            session.Attributes.put('TaskFieldName', 'Subject');
            session.Sequences.add('createTask');
        }
        else if(content == '2')
        {
            returnText = '需要安排什么任务？';
            session.Attributes.put('ActivityType', 'NewTask');
            session.Attributes.put('TaskFieldName', 'Subject');
            session.Sequences.add('createTask');
        }

        return returnText;
    }

    public static String createTask(Charket.SkillSession session, String content)
    {
        String returnText;
        if(session.Attributes.get('ActivityType') == 'CompletedTask')
        {
            Task task = new Task();
            task.WhatId = session.Attributes.get('CurrentAccountId');
            task.Subject = content.length() > 25 ? content.substring(0, 25) + '...' : content;
            task.ActivityDate = Date.today();
            task.Description = content;
            task.Status = 'Completed';
            try
            {
                insert task;
                returnText = '记录成功，详情如下：\n\n' + '活动标题：' + task.Subject + '\n日期：' + String.valueOf(Date.today()).subStringBefore(' ')  + '\n记录人：' + UserInfo.getName() + '\n记录内容：' + content;
                returnText += '\n\n回复 R 返回到客户';
                session.Sequences.add('createSuccess');
            }
            catch(Exception ex)
            {
                returnText = ex.getMessage();
                returnText += '\n回复 A 重新创建销售活动\n回复 R 返回到客户';
            }
            session.Attributes.put('ActivityType', '');
        }
        else if(session.Attributes.get('ActivityType') == 'NewTask')
        {
            returnText = createNewTask(session, content);
        }
        return returnText;
    }

    public static String createNewTask(Charket.SkillSession session, String content)
    {
        String returnText;
        String taskFieldName = session.Attributes.get('TaskFieldName');
        if(taskFieldName == 'Subject' || taskFieldName == 'ActivityDate')
        {
            Date activityDate = getActivityDate(content);
            
            if(activityDate != null)
            {
                returnText = '这个任务是分配给您本人吗？（是，回复1；否则回复同事的名字）';
                session.Attributes.put('TaskFieldName', 'OwnerId');
                session.Attributes.put('NewTaskActivityDate', String.valueOf(activityDate));
            }
            else
            {
                returnText = '该任务需要在哪天之前完成？';
                session.Attributes.put('TaskFieldName', 'ActivityDate');
            }
            if(taskFieldName == 'Subject')
            {
                String subject = content.length() > 25 ? content.substring(0, 25) + '...' : content;
                session.Attributes.put('NewTaskSubject', subject);
                session.Attributes.put('NewTaskDescription', content);
            }
        }
        else if(taskFieldName == 'OwnerId')
        {
            if(content == '1')
            {
                session.Attributes.put('NewTaskOwnerName', UserInfo.getName());
                session.Attributes.put('NewTaskOwnerId', UserInfo.getUserId());
                returnText = createNewTask(true, session);
            }
            else
            {
                List<User> users = [select Name from User where Name = :content];
                if(users.size() == 0)
                {
                    returnText = '没有找到您的同事，请回复您同事的 Frist Name';
                    session.Attributes.put('TaskFieldName', 'FirstName');
                }
                else
                {
                    session.Attributes.put('NewTaskOwnerName', users[0].Name);
                    session.Attributes.put('NewTaskOwnerId', users[0].Id);
                    returnText = createNewTask(true, session);
                }
            }
        }
        else if(taskFieldName == 'FirstName')
        {
            List<User> users = [select Id, Name from User where FirstName = :content limit 10];
            if(users.size() == 0)
            {
                session.Attributes.put('NewTaskOwnerName', UserInfo.getName());
                session.Attributes.put('NewTaskOwnerId', UserInfo.getUserId());
                returnText = createNewTask(false, session);
            }
            else if(users.size() > 1)
            {
                returnText = '找到了如下多个同事\n回复 1 分配给自己\n回复其它数字分配给对应同事\n';
                Integer i = 2;
                Map<String, String> ownerMap = new Map<String, String>();
                
                for(User user : users)
                {
                    returnText += i + user.Name;
                    session.Attributes.put('TaskOwner-' + String.valueOf(i), user.Id + ';' + user.Name);
                    i++;
                }
                session.Attributes.put('TaskFieldName', 'SelectOwner');
            }
            else if(users.size() == 1)
            {
                session.Attributes.put('NewTaskOwnerName', users[0].Name);
                session.Attributes.put('NewTaskOwnerId', users[0].Id);
                returnText = createNewTask(true, session);
            }
        }
        else if(taskFieldName == 'SelectOwner')
        {
            if(session.Attributes.containsKey('TaskOwner-' + content))
            {
                String selectedOwner = session.Attributes.get('TaskOwner-' + content);
                String userId = selectedOwner.split(';')[0];
                String userName = selectedOwner.split(';')[1];
                session.Attributes.put('NewTaskOwnerName', userName);
                session.Attributes.put('NewTaskOwnerId', userId);
                returnText = createNewTask(true, session);
            }
            else
            {
                returnText = createNewTask(false, session);
            }
        }
        return returnText;
    }

    public static String createContact(Charket.SkillSession session, String content)
    {
        String returnText = '';
        Contact contact = new Contact();
        try
        {
            List<String> contentFields = content.split(' ');
            if(contentFields.size() == 4)
            {
                contact.FirstName = contentFields[0];
                contact.LastName = contentFields[1];
                contact.Email = contentFields[2];
                contact.Phone = contentFields[3];
            }
            else if(contentFields.size() == 3 && contentFields[1].contains('@'))
            {
                //contact.LastName = contentFields[0];
                contact.LastName = contentFields[0].left(1);

                //contact.FirstName = '';
                contact.FirstName = contentFields[0].right(contentFields[0].length() - 1);
                contact.Email = contentFields[1];
                contact.Phone = contentFields[2];
            }
            returnText += '姓名：' + contact.FirstName + ' ' + contact.LastName + '\n';
            returnText += '邮箱：' + contact.Email + '\n';
            returnText += '电话：' + contact.Phone + '\n';

            contact.AccountId = session.Attributes.get('CurrentAccountId');
            insert contact;
            returnText += '\n回复 R 返回到客户';
            session.Sequences.add('createSuccess');
        }
        catch(Exception ex)
        {
            returnText = ex.getMessage() + '\n\n回复 C 重新添加联系人\n回复 R 返回到客户';
        }

        return returnText;
    }

    private static Date getActivityDate(String content)
    {
        Date activityDate;
        Map<String, Integer> dayToInteger = new Map<String, Integer>{
                    '一' => 1, '二' => 2, '三' => 3, '四' => 4, '五' => 5, '六' => 6, '日' => 7
                };
        if(content.contains('这周') && String.isNotBlank(content.substringAfter('这周')))
        {
            String day = content.substringAfter('这周').left(1);
            if(dayToInteger.get(day) != null)
            {
                activityDate = Date.today().toStartofWeek().addDays(dayToInteger.get(day));
            }
        }
        else if(content.contains('下周') && String.isNotBlank(content.substringAfter('下周')))
        {
            String day = content.substringAfter('下周').left(1);
            if(dayToInteger.get(day) != null)
            {
                activityDate = Date.today().toStartofWeek().addDays(dayToInteger.get(day) + 7);
            }
        }
        else if(content.contains('周') && String.isNotBlank(content.substringAfter('周')))
        {
            String day = content.substringAfter('周').left(1);
            if(dayToInteger.get(day) != null)
            {
                activityDate = Date.today().toStartofWeek().addDays(dayToInteger.get(day));
                if(activityDate < Date.today())
                {
                    activityDate = activityDate.addDays(7);
                }
            }
        }
        return activityDate;
    }

    public static String createNewTask(Boolean isOwner, Charket.SkillSession session)
    {
        String result;
        String text;
        String label = isOwner ? '任务创建成功，详情如下：\n\n' : '很抱歉，还是没有找到您的同事。系统已经自动将任务分配给了您本人，详情如下\n\n';
        String subject = session.Attributes.get('NewTaskSubject');
        Date activityDate = Date.valueOf(session.Attributes.get('NewTaskActivityDate'));
        String ownerName = session.Attributes.get('NewTaskOwnerName');
        String description = session.Attributes.get('NewTaskDescription');
        String ownerId = session.Attributes.get('NewTaskOwnerId');
        Task task = new Task(Subject = subject, ActivityDate = activityDate, OwnerId = ownerId, Description = description);
        task.WhatId = session.Attributes.get('CurrentAccountId');
        text = '任务标题: ' + subject + '\n';
        text += '完成日期: ' + String.valueOf(activityDate).subStringBefore(' ') + '\n';
        text += '被分配人: ' + ownerName + '\n';
        text += '任务内容: ' + description + '\n';
        try
        {
            insert task;
            text += '\n回复 R 返回到客户';
            result = label + text;
            session.Sequences.add('createSuccess');
        }
        catch(Exception ex)
        {
            text = ex.getMessage();
            text += '\n回复 A 重新创建销售活动\n回复 R 返回到客户';
            result = text;
        }
        return result;
    }

    public static String getFieldValues(String returnText, String fieldName)
    {
        Schema.DescribeFieldResult descriptionResult = SObjectType.Account.fields.getMap().get(fieldName).getDescribe();
        Integer i = 0;
        for(Schema.PicklistEntry entry : descriptionResult.getPicklistValues())
        {
            i = i + 1;
            returnText += i + '. ' + entry.getValue() + '\n';
        }

        return returnText;
    }

    public static String getFieldValue(String fieldName, Integer orderNumber)
    {
        Map<Integer, String> orderNumberToFieldValue = new Map<Integer, String>();
        Schema.DescribeFieldResult descriptionResult = SObjectType.Account.fields.getMap().get(fieldName).getDescribe();
        Integer i = 0;
        for(Schema.PicklistEntry entry : descriptionResult.getPicklistValues())
        {
            i = i + 1;
            orderNumberToFieldValue.put(i, entry.getValue());
        }

        return orderNumberToFieldValue.get(orderNumber);
    }

    public static void updateFieldValue(Charket.SkillSession session, String fieldValue)
    {
        String fieldName = session.attributes.get('UpdateField');
        fieldValue = fieldName == 'Name' ? fieldValue : getFieldValue(fieldName, Integer.valueOf(fieldValue));
        session.attributes.put(fieldName, fieldValue);
        Account account = new Account(
            Id = session.attributes.get('CurrentAccountId'),
            Name = session.attributes.get('Name'),
            Industry = session.attributes.get('Industry'),
            Type = session.attributes.get('Type')
        );

        update account;
    }
    
    public static String getTargetAccounts(String returnText, Integer newOffset, Charket.SkillSession session, Boolean isPrevious, Boolean isSearching)
    {
        String queryStr = 'select Name, Type, Industry from Account'
            + ' where OwnerId = \'' + UserInfo.getUserId() + '\'';
        queryStr = isSearching && String.isNotBlank(session.Attributes.get('SearchKey')) ? queryStr + ' and Name like \'%' + session.Attributes.get('SearchKey') + '%\' ' : queryStr;
        queryStr += ' order by LastModifiedDate desc limit ' + PAGESIZE + ' offset ' + newOffset;
        String lastSession = session.Sequences.get(session.Sequences.size() - 1);
        
        List<Account> accounts = Database.query(queryStr);
        Integer i = 0;
        
        for(Account acc : accounts)
        {
            i++;
            returnText += i + '. ' + acc.Name + '\n';
            session.Attributes.put('Account-' + String.valueOf(i), acc.Id);
        }
        
        if(accounts.size() > 0 && accounts.size() != PAGESIZE)
        {
            i = PAGESIZE;
            for(Integer j = 0; j < PAGESIZE-accounts.size(); j++)
            {
                session.Attributes.remove('Account-' + i);
                i--;
            }
        }
        
        if(returnText != '')
        {
            returnText += '\n回复对应数字查看客户详情';
            returnText = lastSession == 'getAccountList' ? returnText : returnText + '\n回复名称搜索其他客户';
            returnText = newOffset != 0 ? returnText + '\n回复 P 上一页' : returnText;
            returnText = accounts.size() >= PAGESIZE ? returnText + '\n回复 N 下一页' : returnText;
            session.Sequences.add(lastSession);
            session.Attributes.put('Offset', String.valueOf(newOffset));
        }
        else if(isPrevious)
        {
            returnText = 'You are already at the first page.';
        }
        else if(!isPrevious)
        {
            returnText = 'You already reached the last page.';
        }
        
        return returnText;
    }
    
    public static String getReturnText(String returnText, Charket.SkillSession session, String content, Boolean isSearching)
    {
        String lastSession = session.Sequences.get(session.Sequences.size() - 1);
        
        if(content == 'N')
        {
            Integer newOffset = Integer.valueOf(session.Attributes.get('Offset')) + PAGESIZE;

            returnText = getTargetAccounts(returnText, newOffset, session, false, isSearching);
        }
        else if(content == 'P')
        {
            if(Integer.valueOf(session.Attributes.get('Offset')) == 0)
            {
                returnText = 'You are already at the first page.';
            }
            else
            {
                Integer newOffset = Integer.valueOf(session.Attributes.get('Offset')) - PAGESIZE;
                
                returnText = getTargetAccounts(returnText, newOffset, session, true, isSearching);
            }
        }
        else if(lastSession == 'searchAccounts' && content.length() > 1)
        {
            session.Attributes.put('SearchKey', content);
            returnText = getTargetAccounts(returnText, 0, session, true, isSearching);
        }
        else if(lastSession == 'getAccountDetail' && session.Sequences.size() > 2 && session.Sequences.get(session.Sequences.size() - 2) == 'searchAccounts'
                 && content.length() > 1)
        {
            session.Attributes.put('SearchKey', content);
            session.Sequences.add('searchAccounts');
            returnText = getTargetAccounts(returnText, 0, session, true, isSearching);
        }
        else
        {
            returnText = getSkillReturnMessage(session, content);
        }
        
        return returnText;
    }
}