/*** Update Property Address to Contact record
   *
   *  Version 1.0  -- Shrew Design  -- 
   *
  ***/
  
/*** To Run this Class From the Console:
     
id batchId = Database.executeBatch(new BatchContactPropertyAddressUpdate(), 200);
System.debug('\n\n==> batchId = ' + batchId); 

***/
global class BatchContactPropertyAddressUpdate implements Database.Batchable<SObject> {

  global Database.QueryLocator start(Database.BatchableContext context) {

    Database.QueryLocator ans = 
	   Database.getQueryLocator('Select id, Contact_Role__c,Property__c,Contact__c from  Ownership__c where Contact_Role__c != \'Former Owner\' ');
    return ans;
  }
  
  global void execute(Database.BatchableContext context, List<SOBject> objects) {  	
  	Set<Id> contactIds = new Set<Id>();
  	Map<Id,List<Id>> mapPropertiesToContactIds = new Map<Id,List<Id>>();
  	for(Ownership__c owner : (List<Ownership__c>)objects){
  		contactIds.add(owner.Contact__c);
  		if(mapPropertiesToContactIds.containskey(owner.Property__c)){
            mapPropertiesToContactIds.get(owner.Property__c).add(owner.Contact__c);
        }else{
            mapPropertiesToContactIds.put(owner.Property__c , new List<Id>{owner.Contact__c});
        }  
  	}
  	
  	 Map<Id,RecordType> mapPropertyRecordTypes = new Map<Id,RecordType>([Select id, Name from RecordType 
                                    where sobjecttype = 'Property__c']);
   
     Map<Id,Contact> contacts= new Map<Id,Contact> ([Select id, c.Property_Zips__c, c.Property_Submarkets4__c
                            , c.Property_States__c, c.Property_Markets__c, c.Property_Cities__c
                            ,Property_Types__c From Contact c where id in :contactIds]);
                            
     for(Property__c p : [Select m.Zip_Code__c, m.Submarket__c, m.State__c, m.Market__c, m.City__c ,RecordType.Name
                            From Property__c m
                             where id in:mapPropertiesToContactIds.keyset()]){
	    for(Id cId : mapPropertiesToContactIds.get(p.id)){
	        Contact c = contacts.get(cId);
	        if(c.Property_Cities__c != null){
	            if(p.City__c != null && c.Property_Cities__c.indexOf(p.City__c) == -1){
	                c.Property_Cities__c += ';' +  p.City__c; 
	            }
	        }else{
	            c.Property_Cities__c = p.City__c;
	        }
	        
	        if(c.Property_Types__c != null){
	            if(p.RecordType.Name!= null && c.Property_Types__c.indexOf(p.RecordType.Name) == -1){
	                c.Property_Types__c += ';' +  p.RecordType.Name; 
	            }
	        }else{
	            c.Property_Types__c = p.RecordType.Name;
	        }
	        
	        
	        
	        if(c.Property_Submarkets4__c != null){
	            if(p.Submarket__c != null && c.Property_Submarkets4__c.indexOf(p.Submarket__c) == -1){
	                c.Property_Submarkets4__c += ';' +  p.Submarket__c;   
	            }
	        }else{
	            c.Property_Submarkets4__c = p.Submarket__c;
	        }
	        
	        if(c.Property_States__c != null){
	            if(p.State__c != null && c.Property_States__c.indexOf(p.State__c) == -1){
	                c.Property_States__c += ';' +  p.State__c;    
	            }
	        }else{
	            c.Property_States__c = p.State__c;
	        }
	        
	        if(c.Property_Markets__c != null){
	            if(p.Market__c != null && c.Property_Markets__c.indexOf(p.Market__c) == -1){
	                c.Property_Markets__c += ';' +  p.Market__c;  
	            }
	        }else{
	            c.Property_Markets__c = p.Market__c;
	        }
	        
	        if(c.Property_Zips__c != null){
	            if(p.Zip_Code__c != null && c.Property_Zips__c.indexOf(p.Zip_Code__c) == -1){
	                c.Property_Zips__c += ';' +  p.Zip_Code__c; 
	            }
	        }else{
	            c.Property_Zips__c = p.Zip_Code__c;
	        }
	    
	    }
	}    
    
    update contacts.values();                       
  }

  global void finish(Database.BatchableContext context) {
  	
  
  }
  
  
}