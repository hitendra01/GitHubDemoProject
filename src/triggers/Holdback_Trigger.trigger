trigger Holdback_Trigger on Holdback__c (after delete, after insert, after undelete, 
after update) {
	Set<Id> CompIds = new set<Id>();
	if(Trigger.isDelete||Trigger.isUpdate){
		for(Holdback__c item : Trigger.Old){
			CompIds.add(item.Comp__c);
		}
	}
	if(Trigger.isInsert||Trigger.isUndelete||Trigger.isUpdate){
		for(Holdback__c item : Trigger.New){
			CompIds.add(item.Comp__c);
		}
	}
	if(CompIds.size()>0){
		Sale__c[] comps = [Select s.Total_Holdbacks__c, (Select Amount__c From Holdbacks__r) From Sale__c s where s.Id in :CompIds];
		for(Sale__c comp : comps){
			comp.Total_Holdbacks__c = 0;
			for(Holdback__c item : comp.Holdbacks__r){
				comp.Total_Holdbacks__c += item.Amount__c;
			}
		}
		update comps;
	}
}