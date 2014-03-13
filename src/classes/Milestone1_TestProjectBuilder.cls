public with sharing class Milestone1_TestProjectBuilder {

	public Integer numberMilestones { get; set; }
	public Integer numberTasks {get; set; }
	
	public void buildProject() {
		
		Escrow__c newProject = Milestone1_Test_Utility.sampleProjectActive('Sample ' + Datetime.now());
		insert newProject;
		
		for (Integer i=0; i < numberMilestones; i++) {
			Milestone1_Milestone__c ms = Milestone1_Test_Utility.sampleMilestone(newProject);
			insert ms;
			for (Integer j=0; j < numberTasks; j++) {
				Escrow_Task__c task = Milestone1_Test_Utility.sampleTask(ms);
				insert task;
				
			}
		}
		
	}
}