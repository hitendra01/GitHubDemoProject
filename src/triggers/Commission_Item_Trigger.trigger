trigger Commission_Item_Trigger on Commission_Item__c (after delete, after insert, after undelete, 
after update) {
	Set<Id> CompIds = new set<Id>();
	if(Trigger.isDelete||Trigger.isUpdate){
		for(Commission_Item__c item : Trigger.Old){
			CompIds.add(item.Comp__c);
		}
	}
	if(Trigger.isInsert||Trigger.isUndelete||Trigger.isUpdate){
		for(Commission_Item__c item : Trigger.New){
			CompIds.add(item.Comp__c);
		}
	}
	if(CompIds.size()>0){
		Sale__c[] comps = [Select s.Lease_Total__c, s.Commission__c, (Select Total__c, Commission_Amount__c From Commission_Items__r) From Sale__c s where s.Id in :CompIds];
		for(Sale__c comp : comps){
			comp.Lease_Total__c = 0;
			comp.Commission__c = 0;
			for(Commission_Item__c item : comp.Commission_Items__r){
				comp.Lease_Total__c += item.Total__c;
				comp.Commission__c += item.Commission_Amount__c;
			}
		}
		update comps;
	}
}