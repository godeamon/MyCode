/*
 * A util class for User/Group/Queue
 */
public class UserUtil
{
    public static List<String> getHREmails()
    {
        return getUserEmailsByGroupName('HRs');
    }

    public static List<String> getSystemAdminEmails()
    {
        return getUserEmailsByGroupName('SystemAdmin');
    }

    public static List<String> getUserEmailsByGroupName(String groupDeveloperName)
    {	
        List<String> emailAddresses = new List<String>();

        List<Group> groups = [select Id from Group where DeveloperName = :groupDeveloperName limit 1];
		
        if(groups.size() > 0)
        {
            Set<Id> groupMemberIds = getUserIdsFromGroup(new Set<Id>{ groups[0].Id });

            for(User user : [select Email from User where Id in :groupMemberIds])
            {
                emailAddresses.add(user.Email);
            }
        }

        return emailAddresses;
    }

    public static Set<id> getUserIdsFromGroup(Set<Id> groupIds)
    {
        // store the results in a set so we don't get duplicates
        Set<Id> result = new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix(); //005
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<Id> groupIdProxys = new Set<Id>();

        // Loop through all group members in a group
        for(GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId in :groupIds])
        {
            // If the user or group id is a user
            if(((String)m.UserOrGroupId).startsWith(userType))
            {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                groupIdProxys.add(m.UserOrGroupId);
            }
        }
        if(groupIdProxys.size() > 0)
        {
            result.addAll(getUserIdsFromGroup(groupIdProxys));
        }
        return result;
    }
}