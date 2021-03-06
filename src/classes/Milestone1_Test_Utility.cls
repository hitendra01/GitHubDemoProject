public with sharing class Milestone1_Test_Utility {
    
    public static Escrow__c sampleProject(String name) {
        Escrow__c rec = new Escrow__c();
        rec.Name = name + ''+ Datetime.now().getTime();
        return rec;
    }

    public static Escrow__c sampleProjectActive(String name) {
        Escrow__c rec = Milestone1_Test_Utility.sampleProject(name);
        rec.Status__c   =   'In Escrow';
        rec.Effective_Date__c  =   Date.today().addDays(-14);
        rec.Close_of_Escrow__c =   Date.today().addDays(14);
        return rec;
    }
    public static Milestone1_Milestone__c sampleMilestone(Escrow__c project) {
        Milestone1_Milestone__c rec = new Milestone1_Milestone__c();
        rec.Name = project.Name + '' + Datetime.now().getTime();
        rec.Escrow__c = project.id;
        rec.Complete__c = false; //getRandomBool(.25);
        rec.Kickoff__c = project.Effective_Date__c;
        rec.Deadline__c = project.Close_of_Escrow__c;
        rec.Description__c = 'Description for ' + rec.Name;
        rec.Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100;
        rec.Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100;
        return rec;
    }
    public static Milestone1_Milestone__c sampleMilestone(Id projectId, Id parentMSId, String name) {
        Milestone1_Milestone__c rec = new Milestone1_Milestone__c();
        rec.Name = name;
        rec.Parent_Milestone__c = parentMSId;
        rec.Escrow__c = projectId;
        rec.Complete__c = false; //getRandomBool(.25);
        rec.Deadline__c = Date.today().addDays(1);
        rec.Description__c = 'Description for ' + name;
        rec.Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100;
        rec.Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100;
        return rec;
    }

	public static Escrow_Task__c sampleTask(Id milestoneId, Date kickoff, Date deadline, Boolean isComplete, Boolean isBlocked) {
        Escrow_Task__c rec = new Escrow_Task__c();
        rec.Project_Milestone__c = milestoneId;
        rec.Assigned_To__c = UserInfo.getUserId();
        rec.Name = 'MS ' + milestoneId + ' task ' + Datetime.now().getTime();
        rec.Complete__c = isComplete; //getRandomBool(.25);
        rec.Description__c   = 'test description ' + rec.Name;
        rec.Start_Date__c   = kickoff;
        rec.Due_Date__c   = deadline;
        rec.Estimated_Expense__c = 100.00;
        rec.Estimated_Hours__c = 110.00;
        rec.Priority__c = '0';
        rec.Task_Stage__c = 'None';
        rec.Class__c = 'Ad Hoc';
        rec.Blocked__c = isBlocked;
        if (!isBlocked) {
        	rec.Blocked_Reason__c = null;
        } else {
        	rec.Blocked_Reason__c = 'Blocked Task Test';
        }
        rec.Last_Email_Received__c = Date.today();
        return rec;		
	}

    public static Escrow_Task__c sampleTask(Milestone1_Milestone__c milestone) {
		return Milestone1_Test_Utility.sampleTask(milestone.Id, milestone.Kickoff__c.addDays(-1), milestone.Deadline__c.addDays(-1), false, false);
    }
    
    public static Escrow_Task__c sampleTask(Id milestoneId) {
		return Milestone1_Test_Utility.sampleTask(milestoneId, Date.today().addDays(1), Date.today().addDays(1), false, false);
    }

    public static Escrow_Task__c sampleTaskComplete(Id milestoneId) {
		return Milestone1_Test_Utility.sampleTask(milestoneId, Date.today().addDays(1), Date.today().addDays(1), true, false);
    }

    public static Escrow_Task__c sampleTaskBlocked(Id milestoneId) {
		return Milestone1_Test_Utility.sampleTask(milestoneId, Date.today().addDays(1), Date.today().addDays(1), false, true);
    }
    
    /*public static Milestone1_Time__c sampleTime(Id taskId) {
        Milestone1_Time__c rec = new Milestone1_Time__c();
        rec.Project_Task__c = taskId;
        rec.Hours__c = Math.floor(Math.random() * 10 * 100) / 100;
        return rec;
    }*/
    
    public static Milestone1_Expense__c sampleExpense(Id taskId) {
        Milestone1_Expense__c rec = new Milestone1_Expense__c();
        rec.Project_Task__c = taskId;
        rec.Amount__c = Math.floor(Math.random() * 1000 * 100) / 100;
        return rec;
    }
    
    public static Boolean getRandomBool(Decimal oddsOfTrue){
        if(Math.random() <= oddsOfTrue){
            return true;
        }
        return false;
    }
    
    public static Date getRandomDate(Integer rangeFromToday){
        return Date.today().addDays((Math.random() * rangeFromToday * 2 - rangeFromToday).intValue());
    }
    
    public static Milestone1_Settings__c createDefaultCustomChatterSettings(Boolean autoFollowTasks)
    {
        
        Milestone1_Settings__c testRule = Milestone1_Settings__c.getOrgDefaults();
        if(testRule == null)
        {
            testRule = new Milestone1_Settings__c();
            testRule.SetupOwnerId = UserInfo.getUserId();
            insert testRule;
        } 
            testRule.Auto_Follow_Task__c = autoFollowTasks;
            testRule.Auto_Follow_Complete_Task__c = autoFollowTasks;
            testRule.Auto_Unfollow_Reassignment__c = autoFollowTasks;
            update testRule;
            System.debug(testRule);
        
        
        return testRule;
    }
    
   	/**
	* Extract the ids from a milestone list
	*
	* @param src Milestone list
	* @return Set of milestone ids
	*/    
    public static Set<Id> extractMilestoneIds(List<Milestone1_Milestone__c> src){
    	Set<Id> res = new Set<Id>();
    	
    	for(Milestone1_Milestone__c m : src){ 
    		res.add( m.Id ); 
    	}
    	
    	return res;
    }
    
        /**
    * 	Create a batch of milestones
    */
    public static Map<String,Milestone1_Milestone__c> manyMilestones(Escrow__c project,
    															Milestone1_Milestone__c parentMilestone, Integer size){
    	Map<String,Milestone1_Milestone__c> milestonesMap = new Map<String,Milestone1_Milestone__c>();
    	Milestone1_Milestone__c milestone;
    	List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
    	Id projectId;
    	if(project != null){
    		projectId = project.Id;	
    	}
    	for(Integer i = 0; i < size; i++){
        	milestone = Milestone1_Test_Utility.sampleMilestone(projectId, parentMilestone.Id, 'ms'+i);
        	milestonesMap.put(milestone.Name,milestone);
        }
        insert milestonesMap.values();
        return milestonesMap;	
    }    
    
}