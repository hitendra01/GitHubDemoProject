@isTest
private class Milestone1_Test_Clone {
			      
    static testMethod void testProjectManyMilestonesManyTasksClone() {
        final Integer NUMBER_OF_MILESTONES = 200;
        final Integer NUMBER_OF_TASKS = 200;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Escrow__c proj = Milestone1_Test_Utility.sampleProject('proj');
        insert proj;
        
        //create a couple of top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        topMilestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create a many sub-milestones underneath ms2
        Map<String,Milestone1_Milestone__c> subMilestones = Milestone1_Test_Utility.manyMilestones(null, ms2,NUMBER_OF_MILESTONES);
        
        //collect all milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        milestones.addAll(topMilestones);
        milestones.addAll(subMilestones.values());
        Map<Id, Milestone1_Milestone__c> milestonesById = new Map<Id, Milestone1_Milestone__c>();
        for(Milestone1_Milestone__c ms : milestones){
            milestonesById.put(ms.Id, ms);
        }
        
        //create tasks linked to milestones
        Map<String,Escrow_Task__c> tasks = new Map<String,Escrow_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_TASKS; i++){
            Id parentMilestoneId = milestones[(Math.random() * milestones.size()).intValue()].Id;
            Escrow_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            tasks.put(taskRec.Name,taskRec);
        }
        insert tasks.values();
        
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(proj);
        Milestone1_Clone_Project_Controller cont = new Milestone1_Clone_Project_Controller(stc);
        cont.createClone();
        
        Escrow__c proj2 = [SELECT Id,
                                              Name,
                                              Close_of_Escrow__c,
                                              Description__c,
                                              Status__c
                                       FROM Escrow__c
                                       WHERE ImportID__c = :proj.Id
                                      ];
        System.assertEquals('Copy of ' + proj.Name, proj2.Name);
        System.assertEquals(proj.Close_of_Escrow__c, proj2.Close_of_Escrow__c);
        System.assertEquals(proj.Description__c, proj2.Description__c);
        //System.assertEquals(proj.Status__c, proj2.Status__c);
        
        List<Milestone1_Milestone__c> milestones2 = [SELECT 
        												Id,ImportID__c,Name,Escrow__c,Complete__c,Kickoff__c,Deadline__c,
        												Description__c,Expense_Budget__c,Hours_Budget__c
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Escrow__c = :proj2.Id
                                                    ];
        System.assertEquals(NUMBER_OF_MILESTONES + 2, milestones2.size());
        
        Map<String,Escrow_Task__c> tasks2 = new Map<String,Escrow_Task__c>([SELECT 
											Name,Complete__c,Description__c,Start_Date__c,Due_Date__c,
									        Estimated_Expense__c,Estimated_Hours__c,Priority__c,
									        Task_Stage__c,Class__c,Assigned_To__c,
									        Last_Email_Received__c
                                            FROM Escrow_Task__c
                                            WHERE Project_Milestone__r.Escrow__c = :proj2.Id
                                           ]);
        areEqualsTasks(tasks2,tasks);
    }
 
    static testMethod void testProjectManyTasksClone() {
        final Integer NUMBER_OF_TASKS = 200;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Escrow__c proj = Milestone1_Test_Utility.sampleProject('proj');
        insert proj;
        
        //create a couple of top-level milestones
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        topMilestones.add(ms1);
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        topMilestones.add(ms2);
        insert topMilestones;
        
       //collect all milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        milestones.addAll(topMilestones);
        Map<Id, Milestone1_Milestone__c> milestonesById = new Map<Id, Milestone1_Milestone__c>();
        for(Milestone1_Milestone__c ms : milestones){
            milestonesById.put(ms.Id, ms);
        }
        
        //create tasks linked to milestones
        Map<String,Escrow_Task__c> tasks = new Map<String,Escrow_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_TASKS; i++){
            Id parentMilestoneId = milestones[(Math.random() * milestones.size()).intValue()].Id;
            Escrow_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            tasks.put(taskRec.Name,taskRec);
        }
        insert tasks.values();
        
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(proj);
        Milestone1_Clone_Project_Controller cont = new Milestone1_Clone_Project_Controller(stc);
        cont.createClone();
        
        Map<String,Escrow_Task__c> tasks2 = new Map<String,Escrow_Task__c>([SELECT 
												Name,Complete__c,Description__c,Start_Date__c,Due_Date__c,
									        	Estimated_Expense__c,Estimated_Hours__c,Priority__c,
									        	Task_Stage__c,Class__c,Blocked__c,Blocked_Reason__c,
									        	Last_Email_Received__c,Assigned_To__c
                                            FROM Escrow_Task__c
                                            WHERE Project_Milestone__r.Escrow__c = :proj.Id
                                           ]);
        areEqualsTasks(tasks2,tasks);
    }
    
    static testMethod void testMilestoneWithManyTasksManySubMilestonesClone() {
        final Integer NUMBER_OF_MILESTONES = 200;
        final Integer NUMBER_OF_TASKS = 200;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Escrow__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a top-level milestone
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms');
        ms2.Alias__c = 'DCMTEST927';
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create a few sub-milestones underneath ms2
        Map<String,Milestone1_Milestone__c> subMilestones = Milestone1_Test_Utility.manyMilestones(proj,ms2,NUMBER_OF_MILESTONES);
        
        //collect all milestones
        List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
        milestones.addAll(topMilestones);
        milestones.addAll(subMilestones.values());
        
        //create tasks linked to milestones
        Map<String,Escrow_Task__c> tasks = new Map<String,Escrow_Task__c>();
        for(Integer i = 0; i < NUMBER_OF_TASKS; i++){
            Id parentMilestoneId = milestones[(Math.random() * milestones.size()).intValue()].Id;
            Escrow_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            tasks.put(taskRec.Name,taskRec);
        }
        insert tasks.values();
        
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
        Milestone1_Clone_Milestone_Controller cont = new Milestone1_Clone_Milestone_Controller(stc);
        cont.createClone();
        
        Milestone1_Milestone__c ms2Clone = [SELECT Id,
                                                   Name,
                                                   Alias__c
                                            FROM Milestone1_Milestone__c
                                            WHERE ImportID__c = :ms2.Id
                                           ];
        System.assertNotEquals(null, ms2Clone);
        System.assertEquals(null, ms2Clone.Alias__c);
        
        Map<String,Milestone1_Milestone__c> milestones2 = new Map<String,Milestone1_Milestone__c>([SELECT
        												Id,ImportID__c,Name,Escrow__c,Complete__c,Kickoff__c,Deadline__c,
        												Description__c,Expense_Budget__c,Hours_Budget__c
                                                     FROM Milestone1_Milestone__c
                                                     WHERE Parent_Milestone__c = :ms2Clone.Id
                                                    ]);
        System.assertEquals(NUMBER_OF_MILESTONES, milestones2.size());

        areEqualsMilestones(milestones2,subMilestones);        
        Map<String,Escrow_Task__c> tasks2 = new Map<String,Escrow_Task__c>([SELECT 
												Name,Complete__c,Description__c,Start_Date__c,Due_Date__c,
									        	Estimated_Expense__c,Estimated_Hours__c,Priority__c,
									        	Task_Stage__c,Class__c,Blocked__c,Blocked_Reason__c,
									        	Last_Email_Received__c,Assigned_To__c
                                            FROM Escrow_Task__c
                                            WHERE Project_Milestone__c = :ms2Clone.Id
                                            OR Project_Milestone__r.Parent_Milestone__c = :ms2Clone.Id
                                           ]);
        areEqualsTasks(tasks2,tasks);
        
    }
    


    static testMethod void testMilestoneWithManyTasksClone(){
        final Integer NUMBER_OF_TASKS = 200;
        
        Milestone1_Test_Utility.createDefaultCustomChatterSettings(false);
        
        //create a project
        Escrow__c proj = Milestone1_Test_Utility.sampleProject('Project');
        insert proj;
        
        //create a top-level milestone
        List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
        Milestone1_Milestone__c ms2 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms2');
        ms2.Alias__c = 'DCMTEST927';
        topMilestones.add(ms2);
        insert topMilestones;
        
        //create tasks linked to the first milestone 
        Map<String,Escrow_Task__c> tasks = manyTasks(ms2,NUMBER_OF_TASKS);
        
        //create clone page controller and call clone action
        ApexPages.StandardController stc = new ApexPages.StandardController(ms2);
        Milestone1_Clone_Milestone_Controller cont = new Milestone1_Clone_Milestone_Controller(stc);
        cont.createClone();
        
        Milestone1_Milestone__c ms2Clone = [SELECT 
        										Id,ImportID__c,Name,Escrow__c,Complete__c,Kickoff__c,Deadline__c,
        										Description__c,Expense_Budget__c,Hours_Budget__c,Alias__c
                                            FROM Milestone1_Milestone__c
                                            WHERE ImportID__c = :ms2.Id
                                           ];
        System.assertNotEquals(null, ms2Clone);
        System.assertEquals(null, ms2Clone.Alias__c);
              
        Map<String,Escrow_Task__c> tasks2 = new Map<String,Escrow_Task__c>([SELECT 
												Name,Complete__c,Description__c,Start_Date__c,Due_Date__c,
									        	Estimated_Expense__c,Estimated_Hours__c,Priority__c,
									        	Task_Stage__c,Class__c,Blocked__c,Blocked_Reason__c,
									        	Last_Email_Received__c,Assigned_To__c
                                            FROM Escrow_Task__c
                                            WHERE Project_Milestone__c = :ms2Clone.Id
                                            OR Project_Milestone__c = :ms2Clone.Id 
                                           ]);
                                  
        areEqualsTasks(tasks2, tasks);
    }
    

    
    /**
    *	Create a batch of tasks
    */
    public static Map<String,Escrow_Task__c> manyTasks(Milestone1_Milestone__c parentMilestone, Integer size){
    	
    	Map<String,Escrow_Task__c> tasksMap = new Map<String,Escrow_Task__c>();
    	Escrow_Task__c task;
    	List<Escrow_Task__c> tasks = new List<Escrow_Task__c>();
    	for(Integer i = 0; i < size; i++){
        	task = Milestone1_Test_Utility.sampleTask(parentMilestone.Id);
        	task.Name =  'ts'+i;
        	tasksMap.put(task.Name,task);
        }
        insert tasksMap.values();
        return tasksMap;		
    }
    
    public static void areEqualsMilestones (Map<String,Milestone1_Milestone__c> milestonesOriginal,
    											Map<String,Milestone1_Milestone__c> milestones){
   	
	   	Milestone1_Milestone__c milestone;
	   	for(Milestone1_Milestone__c milestoneOriginal : milestonesOriginal.values()){
   			milestone = milestones.get(milestoneOriginal.Name);
   			System.assert(milestone != null,milestoneOriginal.Name);
   			System.assert(milestoneOriginal.Name == milestone.Name);
   			System.assert(milestoneOriginal.Kickoff__c == milestone.Kickoff__c);
   			System.assert(milestoneOriginal.Deadline__c == milestone.Deadline__c);
   			System.assert(milestoneOriginal.Description__c == milestone.Description__c);
   			System.assert(milestoneOriginal.Expense_Budget__c == milestone.Expense_Budget__c);
			System.assert(milestoneOriginal.Hours_Budget__c == milestone.Hours_Budget__c);   			
   		}
	}
    
    public static void areEqualsTasks (Map<String,Escrow_Task__c> tasksOriginal,
    											Map<String,Escrow_Task__c> tasks){
   	
	   	Escrow_Task__c task;
	   	for(Escrow_Task__c taskOriginal : tasksOriginal.values()){
   			task = tasks.get(taskOriginal.Name);
   			System.assert(task != null,taskOriginal.Name);
   			System.assert(taskOriginal.Name == task.Name);
   			System.assert(taskOriginal.Due_Date__c == task.Due_Date__c);
   			System.assert(taskOriginal.Start_Date__c == task.Start_Date__c);
   			System.assert(taskOriginal.Description__c == task.Description__c);
   			System.assert(taskOriginal.Estimated_Expense__c == task.Estimated_Expense__c);
			System.assert(taskOriginal.Estimated_Hours__c == task.Estimated_Hours__c);
			System.assert(taskOriginal.Last_Email_Received__c == task.Last_Email_Received__c);
   			System.assert(taskOriginal.Assigned_To__c == task.Assigned_To__c);
   			System.assert(taskOriginal.Priority__c == task.Priority__c);
			System.assert(taskOriginal.Class__c == task.Class__c);   			
   		}
	}
}