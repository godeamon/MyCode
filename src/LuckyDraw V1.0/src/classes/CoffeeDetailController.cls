public with sharing class CoffeeDetailController 
{
    public String taskId;
    public Task Task { get; set; }
    
    public CoffeeDetailController(ApexPages.StandardController stdSetCon)
    {
        taskId = ApexPages.currentPage().getParameters().get('id');
   
        if(String.isNotBlank(taskId))
        {
            Task = [Select Description from Task where Id = :taskId];
        }
    }
}