trigger Property_After_Trigger on Property__c (after update) {
	Set<Id> propertyIdAddressUpdated = new Set<Id>();
    
    // Creates a Set list with all the Property Id's
    for(Property__c p : Trigger.New){
    	 Property__c oldP = Trigger.oldMap.get(p.id);
    	 if(p.Market__c != oldp.market__c || p.City__c != oldp.City__c  || p.State__c != oldp.state__c 
    	 			|| p.Submarket__c != oldp.Submarket__c || p.Zip_Code__c != oldp.zip_code__c
    	 			|| p.RecordTypeId != oldp.RecordTypeId){
    	 	propertyIdAddressUpdated.add(p.id);
    	 }
    }
    
    ContactPropertyInfoUtil.SetPropertyInfo(propertyIdAddressUpdated);
    
}