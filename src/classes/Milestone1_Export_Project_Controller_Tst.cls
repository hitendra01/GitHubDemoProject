@isTest
private class Milestone1_Export_Project_Controller_Tst {

    static testMethod void testImportController() {
        Milestone1_XML_Export_Utility m1exportutility = new Milestone1_XML_Export_Utility();
        Escrow__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME CONTROLLER UNIQUE' + System.now());
        insert testProject;
        testProject = [select Id, Name from Escrow__c where Name = :testProject.Name limit 1];
        
       
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        insert testMilestone;
        testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
        
        Milestone1_Milestone__c testSubMilestone = Milestone1_Test_Utility.sampleMilestone(null,testMilestone.Id,'UNIT TEST SUB MILESTONE 1 NAME ACB123XYZ UNIQUE' + System.now());
        insert testSubMilestone;
        testSubMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testSubMilestone.Name limit 1];
        
        Escrow_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        insert task1;
        Escrow_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        insert task2;
        
        
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject));
        controller.createExportXML();
        System.assert(controller.doc != null);
        System.assert(controller.doc.Id != null);
        ApexPages.Pagereference docRef = controller.returnToDocument();
        system.assert(docRef != null);
        ApexPages.Pagereference projRef = controller.returnToProject();
        System.assert(projRef != null);
    }
    
    static testmethod void testExportFileTooLong(){
		// Set new size for project import
    	Integer old_max_file_size = Milestone1_Import_Project_Controller.MAX_FILE_SIZE;
    	Milestone1_Import_Project_Controller.MAX_FILE_SIZE = 1000;
    	
        try{
        	// Create a poject
        	Escrow__c proj = Milestone1_Test_Utility.sampleProject('TOO LONG TO EXPORT - PROJECT');
        	insert proj;
        	
        	// Create a milestone
        	Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
        	insert mstone;
        	
        	// Add 100 tasks to the milestone
        	Escrow_Task__c task;
        	List<Escrow_Task__c> lTask = new List<Escrow_Task__c>();
        	
        	for(Integer i = 0; i < 100; i++){
        		// Add 150 char description to the task
        		task = Milestone1_Test_Utility.sampleTask(mstone.Id);
        		task.Description__c = '012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
        		
        		lTask.add(task);
        	}
        	
			insert lTask;
			
			// Export project
			ApexPages.Standardcontroller         stc       = new ApexPages.Standardcontroller(proj);
			Milestone1_Export_Project_Controller projCntrl = new Milestone1_Export_Project_Controller(stc);
			projCntrl.createExportXML();
			
			system.assert(projCntrl.hasError());
        }
        catch(Exception e){
        	system.assert(false, e.getMessage());
        }
        finally{
        	Milestone1_Import_Project_Controller.MAX_FILE_SIZE = old_max_file_size;	
        }    	
    }
}