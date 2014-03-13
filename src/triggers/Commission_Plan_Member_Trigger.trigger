trigger Commission_Plan_Member_Trigger on Commission_Plan_Member__c (after insert, after update) {
	set<id> UserIds = new Set<id>();
	for(Commission_Plan_Member__c member : Trigger.New){
		UserIds.add(member.Agent__c);
	}
	
	Commission_Plan_Member__c[] MembersToDelete = [select Id from Commission_Plan_Member__c where Agent__c in :UserIds and Id not in :Trigger.NewMap.KeySet()];
	if(MembersToDelete.size()>0){
		try{
			delete MembersToDelete;
		}catch(exception ex){
			Trigger.New[0].addError('Error updating member - this Agent is on another plan and could not be removed. Technical details: '+ex.getMessage());
		}
	}
}