/**
 * Shrew Designs
 * creates a Project with the Lease record type.
 * copy the Property, Project Leasing, and Update the Record Name with “Suite/Floor [Suite_Floor] 
 * Pending Lease” and update the Status to [Pending].
 *
 *@author: Chetan Garg
 */ 
public  class SpaceProjectController {
	// Properties (Default get/set)
    public boolean hasSaved {get;set;}
    public string spaceId {get;set;}
    
    // Construcgor
    public SpaceProjectController(ApexPages.StandardController stdCon){
        spaceId = stdCon.getId();
    }
    
    // Methods
    public Pagereference initPage(){
    	if(apexPAges.currentPage().getParameters().get('p') == 'comp'){
    		return createComp();
    	}else if(apexPAges.currentPage().getParameters().get('p') == 'escrow'){
    		return createProject();
    	}
    	return null;
    }
    
     public Pagereference createComp(){
        Pagereference pg = null;
        Savepoint sp = Database.setSavepoint();
        try{
            RecordType leaseRecordtype = [Select id from RecordType where DeveloperName = 'Lease' and sobjectType='Sale__c'];
             
            Spaces__c space = [Select Project_Leasing__r.Name, Id,Landlord_Representation_Assignment__r.Owner_Contact__c, Suite_Floor__c,Landlord_Representation_Assignment__c, 
                                Property__c,Property__r.Name, Project_Leasing__c,Property__r.Square_Footage__c
                                ,Landlord_Representation_Assignment__r.Owner_Contact__r.AccountID,Square_Footage__c
                                ,Project_Leasing__r.Property__r.Square_Footage__c, Property__r.OwnerId From Spaces__c where id=:spaceId];
                                
            // Create and insert a comp                    
            Sale__c sale = new Sale__c();
                sale.Name = space.Property__r.Name + '- Suite/Floor #'+ space.Suite_Floor__c;
                sale.System_Commis__c = true;
                sale.Listing__c = space.Landlord_Representation_Assignment__c;
                sale.Space__c = space.id;
                sale.RecordTypeId = leaseRecordType.Id;
               //sale.Property__c = space.Property__c;
                sale.Property_Leases__c = space.Property__c;
                sale.Suite_Floor__c = space.Suite_Floor__c;
                sale.Square_Footage__c = space.Square_Footage__c;
                
                sale.Landlord__c = space.Landlord_Representation_Assignment__r.Owner_Contact__r.AccountId;
                sale.Landlord_Contact__c = space.Landlord_Representation_Assignment__r.Owner_Contact__c;
                
        	upsert sale;
            space.Status__c = 'Leased';
            update space;
            
            //List of parties to the transaction to be update in the database
            Transaction__c[] partiesToUpdate = new Transaction__c[]{};
            if(sale.Landlord_Contact__c != null){
                Transaction__c party = new Transaction__c();
                party.Contact__c = sale.Landlord_Contact__c;
                party.Sale__c = sale.Id;
                party.Role__c = 'Lessor';
                party.Transcation_Company__c = sale.Landlord__c;
                partiesToUpdate.add(party); 
            }else if (sale.Landlord__c != null){
                Transaction__c party = new Transaction__c();
                party.Contact__c = sale.Landlord_Contact__c;
                party.Sale__c = sale.Id;
                party.Role__c = 'Lessor';
                party.Transcation_Company__c = sale.Landlord__c;
                partiesToUpdate.add(party); 
            }
            insert partiesToUpdate;
            
            // Create and Insert a commission  
	        Commission__c comm = new Commission__c();
		        comm.broker__c = space.Property__r.OwnerId;
		        comm.Sale__c = sale.id;
	        insert comm;
	        
            pg = new Pagereference('/'+sale.id);
            
        }catch(Exception ex){
            Database.rollback(sp);
            Apexpages.addMessages(ex);
        }
        return pg;
    }
    
    public Pagereference createProject(){
        Pagereference pg = null;
        Savepoint sp = Database.setSavepoint();
        try{
            RecordType leaseRecordtype = [Select id from RecordType where developerName = 'Lease' and sobjectType='Escrow__c'];
            Spaces__c space = [Select Id,Landlord_Representation_Assignment__r.Owner_Contact__c, Suite_Floor__c,Landlord_Representation_Assignment__c, 
                                Property__c,Property__r.Name, Project_Leasing__c, Property__r.OwnerId From Spaces__c where id=:spaceId];
            // Create the project
            Escrow__c project = new Escrow__c();
            
            	project.Name =  space.Property__r.Name + '- Suite/Floor #'+ space.Suite_Floor__c + ' Lease (' +  datetime.now().format('MM/dd/yyyy') +')';
            	project.Space__C = space.id;
            	project.Property__c = space.Property__c;
            	project.landlord__c = space.Landlord_Representation_Assignment__r.Owner_Contact__c;
	            project.Status__c = 'Pending';
	            project.RecordTypeId = leaseRecordType.Id;
	            project.System_Commis__c = true;
	            project.Listing__c = space.Landlord_Representation_Assignment__c;
	            
            insert project;
            space.Status__c = 'Pending';
            update space;
            // Create and Insert the commission
            Commission__c comm = new Commission__c();
                comm.broker__c = space.Property__r.OwnerId;
                comm.Escrow__c = project.id;
            insert comm;
            
            //List of parties to the transaction to be update in the database
            Transaction__c[] partiesToUpdate = new Transaction__c[]{};
            if(project.landlord__c != null){
                Transaction__c party = new Transaction__c();
                party.Contact__c = project.landlord__c;
                party.Escrow__c = project.Id;
                party.Role__c = 'Lessor';
                party.Transcation_Company__c = project.landlord_Company__c;
                partiesToUpdate.add(party); 
            }else if (project.landlord_Company__c != null){
                Transaction__c party = new Transaction__c();
                party.Contact__c = project.landlord__c;
                party.Escrow__c = project.Id;
                party.Role__c = 'Lessor';
                party.Transcation_Company__c = project.landlord_Company__c;
                partiesToUpdate.add(party); 
            }
            insert partiesToUpdate;
            
            // Create redirect PageReference
            pg = new Pagereference('/'+project.id);
        }catch(Exception ex){
            Database.rollback(sp);
            Apexpages.addMessages(ex);
        }
        return pg;
    }
    
    /*
    Commented code:
    
                
            /*
            //List of parties to the transaction to be update in the database
            Transaction__c[] partiesToUpdate = new Transaction__c[]{};
            
            for(Sale__c sale : saleList) {
                                    
                if(parties.size() > 0) {
                    for(Transaction__c party : parties) {
                        party.Sale__c = sale.Id;
                    }
                    partiesToUpdate.addAll(parties);
                    
                    
                }
                if(project.RecordType.Name == 'Pending Sale'){
                    if(space.Landlord_Representation_Assignment__r.Owner_Contact__c != null ){
                        Transaction__c party = new Transaction__c();
                        party.Contact__c = project.Listing__r.Owner_Contact__c;
                        party.Sale__c = sale.Id;
                        party.Role__c = 'Lessor';
                        partiesToUpdate.add(party); 
                    }
                    
                    if(project.landlord__c != null){
                        Transaction__c party = new Transaction__c();
                        party.Contact__c = project.landlord__c;
                        party.Sale__c = sale.Id;
                        party.Role__c = 'Lessee';
                        partiesToUpdate.add(party); 
                    }
                }
            }
            
            
            
            //insert parties;
            
            //update the parties to the database
            //upsert (partiesToUpdate);
            
            //Escrow__c es = new Escrow__c(id = project.id, Status__c = 'Closed');
            //project.Status__c = 'Closed';
           // update  es;
           
            */
           

}