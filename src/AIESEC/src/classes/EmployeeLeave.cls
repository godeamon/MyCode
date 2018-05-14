public class EmployeeLeave
{
    //public static List<Leave> getLeaves(String q)
    //{
    //    HttpResponse response;
    //    try
    //    {
    //        response = SFRestAPI.query(q);
    //        JSONParser parser = JsonUtil.parseJson(response);
    //        return (List<Leave>)parser.readValueAs(List<Leave>.class);
    //    }
    //    catch(Exception ex)
    //    {
    //        System.debug(ex);
    //        return new List<Leave>();
    //    }
    //}

    //public static ProcessInstance getProcesses(String q)
    //{
    //    HttpResponse response;
    //    ProcessInstance process;
    //    try
    //    {
    //        response = SFRestAPI.query(q);
    //        process = (ProcessInstance)JSON.deserialize(response.getBody(), EmployeeLeave.ProcessInstance.class);
    //    }
    //    catch(Exception ex)
    //    {
    //        System.debug(ex);
    //    }
    //    return process;
    //}

    //public static void createLeaveWithObject(Leave leave)
    //{
    //    String obj = 'Leave__c';
    //    String jsonBody = generateJson(leave);
    //    SFRestAPI.create(obj, jsonBody);
    //}

    //public static void updateLeave(String field, String filedValue, String leaveId)
    //{
    //    SFRestAPI.updateLeave('Leave__c', '{ "' + field + '" : "' + filedValue + '"}', leaveId);
    //}

    //public static void deleteLeave(String leaveId)
    //{
    //    String obj = 'Leave__c';
    //    SFRestAPI.del(obj, leaveId);
    //}

    private static String generateJson(Leave leave)
    {
        Map<String, String> fieldToValueMap = new Map<String, String>();
        fieldToValueMap.put('Description__c', leave.Description_c);
        fieldToValueMap.put('LeaveType__c', leave.LeaveType_c);
        fieldToValueMap.put('StartDate__c', String.valueOf(leave.StartDate_c));
        fieldToValueMap.put('EndDate__c', String.valueOf(leave.EndDate_c));
        fieldToValueMap.put('HalfDay__c', leave.HalfDay_c);
        fieldToValueMap.put('Employee__c', leave.Employee_r.Id);
        return JSON.serialize(fieldToValueMap);
    }

    //public static Response submitLeaves(String leaveId)
    //{
    //    Submit submit = new Submit();
    //    Request request = new Request();
    //    request.skipEntryCriteria = true;
    //    request.processDefinitionNameOrId = '';
    //    request.contextActorId = '';
    //    request.comments = '';
    //    request.contextId = leaveId;
    //    request.actionType = 'Submit';
    //    submit.requests.add(request);
    //    String jsonBody = JSON.serialize(submit);
    //    String responseBody = SFRestAPI.submitLeaves(jsonBody);
    //    Response response = ((List<Response>)JSON.deserialize(responseBody, List<Response>.class))[0];
    //    return response;
    //}

    //public static Response approveOrRejectLeaves(String contextId, String actionType)
    //{
        
    //    Request request = new Request();
    //    if('Approve'.equals(actionType))
    //    {
    //        request.comments = 'this record is approved';
    //        request.actionType = 'Approve';
    //    }
    //    else
    //    {
    //        request.comments = 'this record is rejected';
    //        request.actionType = 'Reject';
    //    }
    //    request.contextId = contextId;
    //    approve.requests.add(request);
    //    String jsonBody = JSON.serialize(approve);
    //    String responseBody = SFRestAPI.submitLeaves(jsonBody);
    //    Response response = ((List<Response>)JSON.deserialize(responseBody, List<Response>.class))[0];
    //    return response;
    //}

    public class Leave
    {
        public Leave(Date startDate, Date endDate, String halfDay, Employee employee, String description, String leaveType)
        {
            this.StartDate_c = startDate;
            this.EndDate_c = endDate;
            this.HalfDay_c = halfDay;
            this.Employee_r = employee;
            this.Description_c = description;
            this.LeaveType_c = leaveType;
        }
        public String Id { get; set; }
        public Date StartDate_c { get; set; }
        public Date EndDate_c { get; set; }
        public String HalfDay_c { get; set; }
        public Employee Employee_r { get; set; }
        public String Description_c { get; set; }
        public String LeaveType_c { get; set; }
        public String OwnerId { get; set; }
        public String Approved_c { get; set; }
        public String Name { get; set; }
        public String ApprovalStatus_c { get; set; }
    }

    public class Employee
    {
        public Employee(String id)
        {
            this.Id = id;
        }
        public String Id { get; set; }
        public String Name { get; set; }
        public String Email { get; set; }
        public String UserName { get; set; }
    }

    public class Submit
    {
        public Submit()
        {
            this.requests = new List<Request>();
        }
        public List<Request> requests { get; set; }
    }

    public class Approve
    {
        public Approve()
        {
            this.requests = new List<Request>();
        }
        public List<Request> requests { get; set; }
    }

    public class Request
    {
        public Request()
        {
            this.nextApproverIds = new List<String>();
        }
        public String actionType { get; set; }
        public String contextId { get; set; }
        public List<String> nextApproverIds { get; set; }
        public String comments { get; set; }
        public String contextActorId { get; set; }
        public String processDefinitionNameOrId { get; set; }
        public Boolean skipEntryCriteria { get; set; }
    }

    public class Response
    {   
        public Response()
        {
            this.actorIds = new List<String>();
            this.newWorkitemIds = new List<String>();
        }
        public List<String> actorIds { get; set; }
        public String entityId { get; set; }
        public String errors { get; set; }
        public String instanceId { get; set; }
        public String instanceStatus { get; set; }
        public List<String> newWorkitemIds { get; set; }
        public Boolean success { get; set; }
    }

    public class ProcessInstance
    {
        public String totalSize { get; set; }
        public String done { get; set; }
        public List<Records> records { get; set; }
    }

    public class Records
    {
        public Attributes attributes { get; set; }
        public String Id { get; set; }
        public Boolean IsDeleted { get; set; }
        public String Status { get; set; }
        public String TargetObjectId { get; set; }
        public String ActorId { get; set; }
        public String ProcessInstanceId { get; set; }
        public String OriginalActorId { get; set; }
    }

    public class Attributes
    {
        public String type { get; set; }
        public String url { get; set; }
    }

    public enum HalfDay { NONE, MORNING, AFTERNOON, WHOLEDAY }

    public enum LeaveType { PERSONALAFFAIR, SICK, ANNUAL, OTHER, COMPENSATED }
}