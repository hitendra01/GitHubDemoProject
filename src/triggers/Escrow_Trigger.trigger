/**
 * Riptide Software
 *
 * This trigger will create a new Sale object when
 * a Escrow status is changed to "Closed". 
 * revision : - 02/11/2013, Copy space from Project to Comp(Sale)
 *
 *@author: Ravel Antunes
 *@author: Trey Dickson
 */ 
trigger Escrow_Trigger on Escrow__c (before delete, before insert, before update,  after insert, after update) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        List<Commission__c> commissionList = new List<Commission__c>();
        
        for(Escrow__c p :  trigger.new){
            if(p.System_Commis__c != true){
                Commission__c comm = new Commission__c();
                comm.broker__c = p.OwnerId;
                comm.escrow__c = p.id;
                commissionList.add(comm);
            }
        }   
        upsert commissionList;
    }
    
    if(Trigger.isAfter){
        /*
        if(Trigger.isUpdate || Trigger.isInsert){
            List<Sale__c> saleList = new List<Sale__c>();
            Set<String> escrows = new Set<String>();
            
            //Create a set of the escrow ids
            for(Escrow__c e : trigger.new) {
                escrows.add(e.Id);
            }
            
            //Query out a list of all the parties to the transaction for the escrows
            Transaction__c[] parties = [SELECT ID, Escrow__c, Sale__c, Contact__c, Role__c FROM Transaction__c WHERE Escrow__c IN :escrows];                        
            
            //Map of escrows to their parties to the transaction
            Map<String, Transaction__c[]> transactions = new Map<String, Transaction__c[]>();
            
            //Build the map of escrows and their parties
            for(String escrow : escrows) {
                List<Transaction__c> partiesList = new List<Transaction__c>();
                for(Transaction__c party : parties) {
                    if(escrow == party.Escrow__c) {
                        partiesList.add(party);
                    }
                }
                transactions.put(escrow, partiesList);
            }
            
            // Gets all Commission__c objects with the Id's in the proposalIds set list
            List<Commission__c> commissionList = [SELECT Id, Escrow__c
                                        FROM Commission__c WHERE Escrow__c
                                        IN :escrows];
            
            //Pull a list of the current sales
            Sale__c[] sales = [SELECT ID, Escrow__c FROM Sale__c WHERE Escrow__c IN :escrows];
            
            // Creates a new Sale when there's a Escrow with status 'closed'
            Boolean alreadyExists;
            for(Escrow__c e : Trigger.new){
                alreadyExists =false;
        
                // If finds a escrow for the Proposal, set alreadyExists to true
                for(Sale__c sale : sales){          
                    if(e.Id == sale.Escrow__c){
                        alreadyExists = true;
                        
                        
                        
                         //This next line of code would update the Sales of the Escrow to have the
                         //Sale_Price updated to the new Contract_Price
                        
                        // sale.Sale_Price__c = e.Contract_Price__c;
                    }
                }
                
                
                
                if(e.Status__c == 'Closed' && !alreadyExists){
                    
                    Sale__c sale = new Sale__c();
                    sale.Escrow__c = e.Id;
                    sale.Name = e.Name;
                    if(EscrowTriggerHelper.getCompRecordTypeId(e.RecordTypeId) != null){
                        sale.recordTypeId = EscrowTriggerHelper.getCompRecordTypeId(e.RecordTypeId);
                    }

                    if(e.Property__c != null){
                        sale.Property__c = e.Property__c;
                    }                   
                    if(e.Proposal__c != null){
                        sale.Proposal__c = e.Proposal__c;
                    }
                    if(e.Listing__c != null){
                        sale.Listing__c = e.Listing__c;
                    }
                    if(e.Close_of_Escrow__c != null){
                        sale.Sale_Date__c = e.Close_of_Escrow__c;
                    }           
                    if(e.Contract_Price__c != null){
                        sale.Sale_Price__c = e.Contract_Price__c;
                    }
                    if(e.Space__c != null){
                        sale.Space__c = e.Space__c;
                    }

                    
                    
                    saleList.add(sale);
                }
            }   
            upsert sales;
            upsert saleList;
            
            
            
            
                //Searches for a Commission__c with the same
                //Proposal__c. If found, add the new sale Id
                //to the Commission
            
            for(Sale__c s : saleList){      
                for(Commission__c c: commissionList){
                    if(s.Escrow__c == c.Escrow__c){
                        c.Sale__c = s.Id;
                        c.Escrow__c = null;
                    }       
                }
            }   
            upsert commissionList;
            
                
            
            //List of parties to the transaction to be update in the database
            Transaction__c[] partiesToUpdate = new Transaction__c[]{};
            
            for(Sale__c sale : saleList) {
                                    
                //Pull the list of parties to the transaction for this sale based on the escrow ID
                parties = transactions.get(sale.Escrow__c);
                
                //If there are parties to the transaction, then edit their record and add the sale ID
                if(parties.size() > 0) {
                    for(Transaction__c party : parties) {
                        party.Sale__c = sale.Id;
                    }
                    partiesToUpdate.addAll(parties);
                }
            }
            
            //update the parties to the database
            update(partiesToUpdate);
            
        }   
        */      
    }else{
        // This are all the Trigger.isBefore
            
        if( Trigger.isUpdate ){
            //TODO can we delete this?
            Milestone1_Project_Trigger_Utility.handleProjectUpdateTrigger(trigger.new);
        } 
        else if( Trigger.isDelete ) {
            //cascades through milestones
            Milestone1_Project_Trigger_Utility.handleProjectDeleteTrigger(trigger.old);
        }
        else if( Trigger.isInsert ) {
            //checks for duplicate names
            Milestone1_Project_Trigger_Utility.handleProjectInsertTrigger( trigger.new );
        }
    }
    
    
    if(Trigger.isBefore){
		Map<Id,List<Escrow__c>> contactMapBuyer = new Map<Id,List<Escrow__c>>();
		Map<Id,List<Escrow__c>> contactMapLandlord = new Map<Id,List<Escrow__c>>();
		Map<Id,List<Escrow__c>> contactMapSeller = new Map<Id,List<Escrow__c>>();
		Map<Id,List<Escrow__c>> contactMapTenant = new Map<Id,List<Escrow__c>>();
        if(Trigger.isInsert){
            for(Escrow__c p : Trigger.new){       
                if(contactMapBuyer.containskey(p.Buyer__c) && p.Buyer__c != null){
                    contactMapBuyer.get(p.Buyer__c).add(p);
                }else if(p.Buyer__c != null){
                    contactMapBuyer.put(p.Buyer__c,new List<Escrow__c>{p});
                }  
                
                if(contactMapLandlord.containskey(p.Landlord__c) && p.Landlord__c != null){
                    contactMapLandlord.get(p.Landlord__c).add(p);
                }else if(p.Landlord__c != null){
                    contactMapLandlord.put(p.Landlord__c,new List<Escrow__c>{p});
                }  
                
                if(contactMapSeller.containskey(p.Seller__c) && p.Seller__c != null){
                    contactMapSeller.get(p.Seller__c).add(p);
                }else if(p.Seller__c != null){
                    contactMapSeller.put(p.Seller__c,new List<Escrow__c>{p});
                } 
                
                if(contactMapTenant.containskey(p.Tenant__c) && p.Tenant__c != null){
                    contactMapTenant.get(p.Tenant__c).add(p);
                }else if(p.Tenant__c != null){
                    contactMapTenant.put(p.Tenant__c,new List<Escrow__c>{p});
                }    
                    
            }
        }else if(Trigger.isUpdate){
            for(Escrow__c p : Trigger.new){       
                if(p.Landlord__c != Trigger.OldMap.get(p.id).Landlord__c && p.Landlord__c != null){
                    if(contactMapLandlord.containskey(p.Landlord__c)){
                        contactMapLandlord.get(p.Landlord__c).add(p);
                    }else{
                        contactMapLandlord.put(p.Landlord__c,new List<Escrow__c>{p});
                    }   
                }
                
                if(p.Buyer__c != Trigger.OldMap.get(p.id).Buyer__c && p.Buyer__c != null){
                    if(contactMapBuyer.containskey(p.Buyer__c)){
                        contactMapBuyer.get(p.Buyer__c).add(p);
                    }else{
                        contactMapBuyer.put(p.Buyer__c,new List<Escrow__c>{p});
                    }   
                }
                
                
                if(p.Seller__c != Trigger.OldMap.get(p.id).Seller__c && p.Seller__c != null){
                    if(contactMapSeller.containskey(p.Seller__c)){
                        contactMapSeller.get(p.Seller__c).add(p);
                    }else{
                        contactMapSeller.put(p.Seller__c,new List<Escrow__c>{p});
                    }   
                }
                
                
                if(p.Tenant__c != Trigger.OldMap.get(p.id).Tenant__c && p.Tenant__c != null){
                    if(contactMapTenant.containskey(p.Tenant__c)){
                        contactMapTenant.get(p.Tenant__c).add(p);
                    }else{
                        contactMapTenant.put(p.Tenant__c,new List<Escrow__c>{p});
                    }   
                }   
            }
        }
        for(Contact c : [Select id,AccountId from Contact 
        		where id in: contactMapBuyer.keyset() OR id in: contactMapLandlord.keyset() OR id in: contactMapSeller.keyset() 
        			OR id in:  contactMapTenant.keyset()]){
            
            if(contactMapBuyer.containskey(c.id)){
                for(Escrow__c p : contactMapBuyer.get(c.id)){       
                    p.Buyer_Company__c = c.AccountId;
                }
            }
            
            if(contactMapLandlord.containskey(c.id)){
                for(Escrow__c p : contactMapLandlord.get(c.id)){       
                    p.Landlord_Company__c = c.AccountId;
                }
            }
            
            if(contactMapSeller.containskey(c.id)){
                for(Escrow__c p : contactMapSeller.get(c.id)){       
                    p.Seller_Company__c = c.AccountId;
                }
            }
            
            if(contactMapTenant.containskey(c.id)){
                for(Escrow__c p : contactMapTenant.get(c.id)){       
                    p.Tenant_Company__c = c.AccountId;
                }
            }
        }
        
        
	}
    
    
    
    
}