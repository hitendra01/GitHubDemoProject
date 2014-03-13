/**
 * Shrew Designs
 * onverts the Project to a Comp and updates Assignment and Project Status’ to [Closed] for all record types except for those converted 
 * from a Space Lease Record Type. For those update Project status to [Closed] and the Space status to [Leased]
 *@author: Chetan Garg
 * revision : - 02/11/2013, Copy space from Project to Comp(Sale)
 */ 
public  class ProjectCompController {
    public Escrow__c  project {get;set;}
    public Apexpages.StandardController stdCon;
    public ProjectCompController(ApexPages.StandardController stdCon){
        project = [select OwnerId, space__c,id,RecordTypeId,Name,Property__c,Listing__c,Proposal__c,Close_of_Escrow__c,Escrow__c,probability__c,
                    seller__c,seller_Company__c, buyer__c,buyer_Company__c,Landlord_Company__c,tenant__C, tenant_Company__c,
                    space__r.Suite_Floor__c, space__r.Square_Footage__c,
                  Contract_Price__c , landlord__c, Listing__r.Owner_Contact__c,RecordType.Name
                  from Escrow__c where id =:stdCon.getId()];
        this.stdCon = stdCon;
    }
    
    public Pagereference createComp(){
        Pagereference pg = null;
        try{
            
            List<Sale__c> saleList = new List<Sale__c>();
            Set<String> escrows = new Set<String>();
            
            //Query out a list of all the parties to the transaction for the escrows
            Transaction__c[] parties = [SELECT ID, Escrow__c, Sale__c, Contact__c, Role__c FROM Transaction__c WHERE Escrow__c = :project.id];                      
            
            // Gets all Commission__c objects with the Id's in the proposalIds set list
            List<Commission__c> commissionList = [SELECT Id, Escrow__c
                                        FROM Commission__c WHERE Escrow__c = :project.id];
            
            //Pull a list of the current sales
            Sale__c[] sales = [SELECT ID, Escrow__c FROM Sale__c WHERE Escrow__c = :project.id];
            
            // Creates a new Sale when there's a Escrow with status 'closed'
            Boolean alreadyExists = sales.size() >0 ;
                
            if(!alreadyExists){             
                Sale__c sale = new Sale__c();
                sale.Escrow__c = project.Id;
                sale.Name = project.Name;
                sale.System_Commis__c = true;
                //sale.probability__c = project.probability__c;
                sale.Commission__c = project.Escrow__c;
                if(EscrowTriggerHelper.getCompRecordTypeId(project.RecordTypeId) != null){
                    sale.recordTypeId = EscrowTriggerHelper.getCompRecordTypeId(project.RecordTypeId);
                }
                sale.Suite_Floor__c = project.space__r.Suite_Floor__c;
                sale.Square_Footage__c = project.space__r.Square_Footage__c;
                sale.seller__c = project.seller__c;
                sale.seller_Company__c = project.seller_Company__c;
                sale.Buyer__c = project.Buyer__c;
                sale.Buyer_Company__c = project.Buyer_Company__c;
                sale.Landlord__c = project.landlord_Company__c;
                sale.Landlord_Contact__c = project.landlord__c;
                sale.Tenant__c = project.Tenant_Company__c;
                sale.Tenant_Contact__c = project.Tenant__c;
                if(project.recordtype.Name == 'Pending Sale'){
	               sale.Property__c = project.Property__c;
                }else{
                	sale.Property_Leases__c = project.Property__c;
                }
                                   
                                   
                if(project.Proposal__c != null){
                    sale.Proposal__c = project.Proposal__c;
                }
                if(project.Listing__c != null){
                    sale.Listing__c = project.Listing__c;
                }
                if(project.Close_of_Escrow__c != null){
                    sale.Sale_Date__c = project.Close_of_Escrow__c;
                }           
                if(project.Contract_Price__c != null){
                    sale.Sale_Price__c = project.Contract_Price__c;
                }
                sale.Space__c = project.Space__c;
                saleList.add(sale);
            }else{
                saleList.addAll(sales);
            }
                
            //upsert sales;
            upsert saleList;
            
            if(project.RecordType.Name == 'Pending Sale' && project.listing__c != null){
            	Listing__c listing = new Listing__c(id = project.listing__c);
            	listing.Status__c = 'Closed';
            	update listing;
            }
            
            /*
                Searches for a Commission__c with the same
                Proposal__c. If found, add the new sale Id
                to the Commission
            */
            for(Sale__c s : saleList){      
                for(Commission__c c: commissionList){
                    if(s.Escrow__c == c.Escrow__c){
                        c.Sale__c = s.Id;
                        c.Escrow__c = null;
                    }       
                }
                
                if(commissionList.size() == 0){
                    Commission__c comm = new Commission__c();
                    comm.broker__c = project.OwnerId;
                    comm.Sale__c = s.id;
                    //comm.Listing__c = listing.id;
                    insert comm;
                }
            }   
            upsert commissionList;
            
                
            
            //List of parties to the transaction to be update in the database
            Transaction__c[] partiesToUpdate = new Transaction__c[]{};
            set<String> roleExists = new Set<String>();
            for(Sale__c sale : saleList) {
                                    
                if(parties.size() > 0) {
                    for(Transaction__c party : parties) {
                    	if(party.Role__c != 'Seller'){
                        	party.Sale__c = sale.Id;
                    	}
                        roleExists.add(party.Role__c);
                    }
                    partiesToUpdate.addAll(parties);
                    
                    
                }
                if(project.RecordType.Name == 'Pending Sale'){
                    if(project.seller__c != null && roleExists.contains('Seller') == false){
                        Transaction__c party = new Transaction__c();
                        party.Contact__c = project.seller__c;
                        party.Sale__c = sale.Id;
                        party.Role__c = 'Seller';
                        //party.Transcation_Company__c = project.client_Company__c;
                        //partiesToUpdate.add(party); 
                    }
                    
                    if(project.Buyer__c != null && roleExists.contains('Buyer')== false){
                        Transaction__c party = new Transaction__c();
                        party.Contact__c = project.Buyer__c;
                        party.Sale__c = sale.Id;
                        party.Role__c = 'Buyer';
                        //party.Transcation_Company__c = project.client_Company__c;
                        //partiesToUpdate.add(party); 
                    }
                    
                  }else{  
                    if(project.landlord__c != null && roleExists.contains('Lessee')== false){
                        Transaction__c party = new Transaction__c();
                        party.Contact__c = project.landlord__c;
                        party.Sale__c = sale.Id;
                        party.Role__c = 'Lessee';
                        party.Transcation_Company__c = project.landlord_Company__c;
                        partiesToUpdate.add(party); 
                    }else if (project.landlord_Company__c != null && roleExists.contains('Lessee')== false){
                        Transaction__c party = new Transaction__c();
                        party.Contact__c = project.landlord__c;
                        party.Sale__c = sale.Id;
                        party.Role__c = 'Lessee';
                        party.Transcation_Company__c = project.landlord_Company__c;
                        partiesToUpdate.add(party); 
                    }
                }
            }
            
            
            
            
            //insert parties;
            
            //update the parties to the database
            upsert (partiesToUpdate);
            
            Escrow__c es = new Escrow__c(id = project.id, Status__c = 'Closed');
            //project.Status__c = 'Closed';
            update  es;
            pg = new Pagereference('/'+saleList[0].id);
        }catch(Exception ex){
            Apexpages.addMessages(ex);
        }
        return pg;
    }

}