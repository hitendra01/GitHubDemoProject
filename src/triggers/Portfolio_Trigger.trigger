/*
*	Rollup Square footage, units from portfolio to Property(Shrew Designs)
*/
trigger Portfolio_Trigger on Portfolio__c (after insert, after update, after delete) {
	Set<Id> propertyIds = new Set<Id>();
	
		
	if(Trigger.isInsert || Trigger.isUpdate){
		for(Portfolio__c a : Trigger.New){
			if(a.Property__c != null 
						&& (Trigger.isInsert ||
								(Trigger.isUpdate && Trigger.oldMap.get(a.id).Property__c != a.Property__c) 
							)){			
				propertyIds.add(a.Portfolio__c);
			}
		}
	}else{
		for(Portfolio__c a : Trigger.Old){
			if(a.Property__c != null){			
				propertyIds.add(a.Portfolio__c);
			}
		}
	}
	
	if(propertyIds.size() > 0){
		List<Property__c> listParentObject = new List<Property__c>();
		for(Property__c po: [Select Square_Footage__c, Units__c,
							(Select Property__r.Units__c, Property__r.Square_Footage__c From Portfolios__r) 
							From Property__c where id in :propertyIds ]){
							
			listParentObject.add(po);
			po.Square_Footage__c  = 0;
			po.Units__c  = 0;
			for	(Portfolio__c co : po.Portfolios__r){
				po.Square_Footage__c  += ( co.Property__r.Square_Footage__c == null ? 0 : co.Property__r.Square_Footage__c);
				po.Units__c  += ( co.Property__r.Units__c == null ? 0 : co.Property__r.Units__c);
			}
		}
		update listParentObject;
	}
}