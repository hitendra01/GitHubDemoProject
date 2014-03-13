/**
 * Riptide Software 
 *
 * This trigger will populate the primary contact field with
 * the same contact as the contact in the Ownership relation
 * that is marked is primary contact.
 *
 *@author: Ravel Antunes
 *@author: Trey Dickson
 */
trigger Property_Trigger on Property__c (before update) {   
    
    if(FutureCallsSemaphore.futureCallAllowed) {
        for(Property__c property : trigger.new) {
            rcm1Api.sendProperty(property.id);
        }
    }
    
    
    
    
        
    List<Property__c> propertyList = trigger.new;   
    Set<String> propertyIds = new Set<String>();
    
    // Creates a Set list with all the Property Id's
    for(Property__c p : propertyList){
    	 if(p.Primary_Contact__c == null){
        	propertyIds.add(p.Id);  
    	 }
    }
    
    // Gets all ownerships objects with the Id's in the propertyIds set list
    List<Ownership__c> ownershipList = [SELECT Id, Contact__c, Primary_Contact__c, Property__c
                                        FROM Ownership__c WHERE Property__c IN :propertyIds
                                        AND Primary_Contact__c = TRUE ORDER BY LastModifiedDate Asc];
        
    Map<String, Ownership__c[]> ownershipMap = new Map<String, Ownership__c[]>();   
    
    // Maps the Ownership objects with it's property ID
    for(String p : propertyIds){        
        List<Ownership__c> oList = new List<Ownership__c>();
        for(Ownership__c o : ownershipList){
            if(o.Property__c == p){
                oList.add(o);
            }
        } 
        ownershipMap.put(p,oList);
    }   
    
    
    for(Property__c p : propertyList){              
        if(p.Primary_Contact__c == null){
            // Assigns the primary contact, if it was null
            List<Ownership__c> oList = ownershipMap.get(p.Id);
            
            // The most recent primary contact will be the one assigned.                                
            for(Ownership__c o : oList){                        
                p.Primary_Contact__c = o.Contact__c;                        
            }           
        }   
    }   
}