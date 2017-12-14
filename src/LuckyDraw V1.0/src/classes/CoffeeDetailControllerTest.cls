@isTest
private class CoffeeDetailControllerTest 
{
    @isTest
    static void testGetTaskDetail()
    {
        Task newTask = new Task(Description = 'Sticker Information陈小年榛果拿铁');
        insert newTask;
        
        Test.startTest();
        PageReference pageRef = Page.CoffeeDetail; // Add your VF page Name here
  		pageRef.getParameters().put('id', String.valueOf(newTask.Id));
  		Test.setCurrentPage(pageRef);
		CoffeeDetailController controller = new CoffeeDetailController(new ApexPages.StandardController(newTask));
        Test.stopTest();
        
        System.assertEquals(controller.Task.Description, 'Sticker Information陈小年榛果拿铁');
        System.assertEquals(controller.taskId, newTask.Id);
    }
}