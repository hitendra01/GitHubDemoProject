trigger Escrow_Task_Trigger on Escrow_Task__c (after insert, after update, before insert, 
before update) {
	if(trigger.isBefore) {
		Milestone1_Task_Trigger_Utility.handleTaskBeforeTrigger(trigger.new);  
	} 
	
	if(trigger.isAfter) {
		Milestone1_Task_Trigger_Utility.handleTaskAfterTrigger(trigger.new,trigger.old);
	} 
}