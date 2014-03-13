/**
 * Riptide Software
 *
 * This trigger will use the Owner that is marked primary contact
 * to populate the Primary Pontact field in the Property object 
 *
 *@author: Ravel Antunes
 *@author: Trey Dickson
 */  
trigger Ownership_Trigger on Ownership__c(after insert, after update, before delete, after delete) {
    //Scope2:- Item 3
    Map<Id,List<Id>> mapPropertiesToContactIds = new Map<Id,List<Id>>();
    Set<Id> contactIds = new Set<Id>();       
            
    if(Trigger.isDelete){   
    	if(Trigger.isbefore){    
	        // Gets all the properties that are associated with the Trigger.old ownerships
	        List<Property__c> properties = Ownership_Trigger_Helper.getAllPropertiesFromOwnership(Trigger.old);                                                                                     
	
	        // Set the properties of                                            
	        for(Property__c p : properties){                    
	            p.Primary_Contact__c = null;
	        }    
	        
	        update properties;  
	        
    	}else{
    		Set<Id> contactIdsForPInfo = new Set<Id>();
	        for(Ownership__c owner : Trigger.Old){     
	            //Scope2:- Item 3
	            if(owner.Contact_Role__c != 'Former Owner' ){
	               contactIdsForPInfo.add(owner.contact__c);
	            }    
	        } 
	        
	        if(contactIdsForPInfo.size() > 0){
              	ContactPropertyInfoUtil.SetPropertyInfoContact(contactIdsForPInfo);
            }
        
    	}                                   
                                        
          
                                                        
    }else{
                     
        if(!Ownership_Trigger_Helper.getIsRunningTrigger()){
            // Set static variable to true, to prevent recursive trigger calls          
            Ownership_Trigger_Helper.setIsRunningTrigger(true);         
                    
            // All ownerships       
            List<Ownership__c> ownershipOfProperties = Ownership_Trigger_Helper.getAllOwnershipProperties(Trigger.new);
            List<Property__c> properties = Ownership_Trigger_Helper.getAllPropertiesFromOwnership(Trigger.new);                                 
            Map<ID, Property__c> propertyMap = new Map<ID, Property__c>();
            
            for(Property__c property : properties) {
                propertyMap.put(property.Id, property);
            }
                     
            if(Trigger.isUpdate){                       
                set<Id> contactIdsForPInfo = new Set<Id>();    
                for(Ownership__c owner : Trigger.new){     
                    //Scope2:- Item 3
                    if(owner.Contact_Role__c == 'Former Owner' && Trigger.OldMap.get(owner.id).Contact_Role__c != 'Former Owner'){
                        contactIdsForPInfo.add(owner.Contact__c);
                    }
                
                    
                    if(propertyMap.containsKey(owner.Property__c)) {  
                        Property__c p = propertyMap.get(owner.Property__c);                             
                    
                        if(owner.Primary_Contact__c){
                            // Sets all the other ownerships to null
                            for(Ownership__c ow : ownershipOfProperties){
                                if(ow.id != owner.id){
                                    ow.Primary_Contact__c = false;  
                                }                           
                            }       
                            
                            // If it's marked as Primary Contact, sets Primary_Contact to the ownership contact
                            p.Primary_Contact__c = owner.Contact__c;
                        }else{
                            // If it's not marked as Primary Contact, sets Primary_Contact to null
                            // Property_trigger will then run and add another Primary_contact, if any
                            p.Primary_Contact__c = null;
                        }

                    }                                        
                }
                
                if(contactIdsForPInfo.size() > 0){
	              	ContactPropertyInfoUtil.SetPropertyInfoContact(contactIdsForPInfo);
	            }
            }else{
                // if (Trigger.isInsert)     
                Map<Id,Id> mapPropertiesToOwner = new Map<Id,Id>();           
                for(Ownership__c owner : Trigger.new){
                    //Scope2:- Item 3
                    if(owner.Contact_Role__c != 'Former Owner'){
                        if(mapPropertiesToContactIds.containskey(owner.Property__c)){
                            mapPropertiesToContactIds.get(owner.Property__c).add(owner.Contact__c);
                        }else{
                            mapPropertiesToContactIds.put(owner.Property__c , new List<Id>{owner.Contact__c});
                        }                                 
                       contactIds.add(owner.Contact__c);
                    }
                    
                    
                                        
                    // Checks if new Ownership is marked as Primary Contact
                    if(owner.Primary_Contact__c == true && owner.Property__c != null){
                        integer i = 0;                       
                        for(Ownership__c o : ownershipOfProperties){
                            if(o.Property__c == owner.Property__c && o.id != owner.id){
                                o.Primary_Contact__c = false;
                            }
                        }   
                        
                        if(propertyMap.containsKey(owner.Property__c)) {  
                            Property__c p = propertyMap.get(owner.Property__c);  

                            p.Primary_Contact__c = owner.Contact__c;    
                        }                                                                 
                    }               
                }
                
                //Find Property and update
                         
            }                           
                
        update ownershipOfProperties;
        update properties;
        if(mapPropertiesToContactIds.size() > 0){
            Map<Id,RecordType> mapPropertyRecordTypes = new Map<Id,RecordType>([Select id, Name from RecordType 
                                    where sobjecttype = 'Property__c']);
       
            Map<Id,Contact> contacts= new Map<Id,Contact> ([Select id, c.Property_Zips__c, c.Property_Submarkets4__c
                                , c.Property_States__c, c.Property_Markets__c, c.Property_Cities__c
                                ,Property_Types__c From Contact c where id in :contactIds]);
            for(Property__c p : [Select m.Zip_Code__c, m.Submarket__c, m.State__c
            							, m.Market__c, m.City__c ,RecordType.Name
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
        
        
        Ownership_Trigger_Helper.setIsRunningTrigger(false);
        }
    } 
    
}