@isTest
public class UserUtilTest 
{   
    @testSetup
    public static void testSetup()
    {
        String ret = 'user' + Math.rint(Math.random() * 100000);

        UserRole r = [select Id from UserRole limit 1];

        Profile p = [select Id from Profile where Name = 'Standard User'];
        User u = new User();
        //u.UserRoleId = r.Id;
        u.Email = ret + '@qwer1.com';
        u.Username = ret + '@qwer1.com';
        u.LastName = 'qwer1';
        u.Alias = 'qwer1';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Chicago';
        u.EmailEncodingKey = 'UTF-8';
        u.ManagerId = UserInfo.getUserId();
        u.IsActive = true;
        u.IsPayrollUser__c = false;
        u.IsSuperUser__c = false;
        u.ProfileId = p.Id;
        u.EnrollmentDate__c = Date.today() + 30;
        u.GraduateDate__c = Date.today() - 389;
        u.BirthdayType__c = 'Lunar';
        insert u;

		Group grp1;

        List<Group> grps = [select Id from Group where DeveloperName = 'HRs' limit 1];

        if(grps.size() > 0)
        {
            grp1 = grps[0];
        }
        else
        {
            grp1 = new Group();
            grp1.DeveloperName = 'HRs';
            grp1.Name = 'grp1';
            grp1.Type = 'Regular';

            insert grp1;
        }

        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = u.Id;
        grpMem1.GroupId = grp1.Id;

        Insert grpMem1;
        
        Group grp2;

        List<Group> grps2 = [select Id from Group where DeveloperName = 'SystemAdmin' limit 1];

        if(grps2.size() > 0)
        {
            grp2 = grps2[0];
        }
        else
        {
            grp2 = new Group();
            grp2.DeveloperName = 'SystemAdmin';
            grp2.Name = 'grp2';
            grp2.Type = 'Regular';

            insert grp2;
        }

        //Create Group Member
        GroupMember grpMem2 = new GroupMember();
        grpMem2.UserOrGroupId = u.Id;
        grpMem2.GroupId = grp2.Id;

        Insert grpMem2;
    }

    @isTest
    public static void testGetHREmails()
    {
        UserUtil.getHREmails();
    }

    @isTest
    public static void testGetSystemAdminEmails()
    {
        UserUtil.getSystemAdminEmails();
    }
}