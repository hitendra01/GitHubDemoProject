/**
 * Riptide Software
 *
 * This trigger wil create a new Listing objects when the Proposal Status is 'Listed'
 * and populate it.
 *
 *@author: Ravel Antunes
 *@author: Trey Dickson
 */ 
trigger Proposal_Trigger on Proposal__c (after insert,before insert, before update ) {
    Set<String> proposalIds = new Set<String>();
    List<Commission__c> commissionList = new List<Commission__c>();
    if(Trigger.isInsert && Trigger.isAfter){
        for(Proposal__c p :  trigger.new){
            Commission__c comm = new Commission__c();
            comm.broker__c = p.OwnerId;
            comm.proposal__c = p.id;
            commissionList.add(comm);
        }   
        upsert commissionList;
    }else if(Trigger.isBefore){ 
        Map<Id,List<Proposal__c>> contactMap = new Map<Id,List<Proposal__c>>();
        if(Trigger.isInsert){
            for(Proposal__c p : Trigger.new){       
                if(contactMap.containskey(p.Client__c)){
                    contactMap.get(p.Client__c).add(p);
                }else{
                    contactMap.put(p.Client__c,new List<Proposal__c>{p});
                }   
                    
            }
        }else if(Trigger.isUpdate){
            for(Proposal__c p : Trigger.new){       
                if(p.Client__c != Trigger.OldMap.get(p.id).Client__c){
                    if(contactMap.containskey(p.Client__c)){
                        contactMap.get(p.Client__c).add(p);
                    }else{
                        contactMap.put(p.Client__c,new List<Proposal__c>{p});
                    }   
                }   
            }
        }
        if(contactMap.size()> 0){
            for(Contact c : [Select id,AccountId from Contact where id in: contactMap.keyset()]){
                for(Proposal__c p : contactMap.get(c.id)){       
                    p.Client_Company__c = c.AccountId;
                }
            }
        }
    }
    
    /*
    
    
    // Creates a Set list with all the Listing Id's
    for(Proposal__c p : Trigger.new){       
        proposalIds.add(p.Id);  
    }
    
    // Gets all Project_Leasing objects with the Id's in the proposalIds set list
    List<Listing__c> currentListings = [SELECT Id, Proposal__c
                                        FROM Listing__c WHERE Proposal__c
                                        IN :proposalIds];
                                        

    // Gets all Commission__c objects with the Id's in the proposalIds set list
    List<Commission__c> commissionList = [SELECT Id, Proposal__c
                                        FROM Commission__c WHERE Proposal__c
                                        IN :proposalIds];                                       
    
    List<Listing__c> listingList = new List<Listing__c>();
    
    Boolean alreadyExists;
    for(Proposal__c p : trigger.new){
        alreadyExists = false;
        
        // If finds a listing for the Proposal, set alreadyExists to true
        for(Listing__c l : currentListings){
            if(p.Id == l.Proposal__c){
                alreadyExists = true;
            }   
        }
                    
        
        if(p.Status__c.equalsIgnoreCase('Listed') && !alreadyExists){
                        
            Listing__c listing = new Listing__c();          
            listing.Proposal__c = p.Id;
            listing.Name = p.Name;
            
            if(p.Property__c != null){
                listing.Property__c = p.Property__c;                
            }
            
            if(p.Client__c != null){
                listing.Owner_Contact__c = p.Client__c;
            }   
            
            //Set Record type of Assignment
            if(ProposalTriggerHelper.getAssignmentRecordType(p.recordTypeId) != null){
                listing.recordtypeid = ProposalTriggerHelper.getAssignmentRecordType(p.recordTypeId);
            }           

            listingList.add(listing);                                   
        }
    }
    
    upsert listingList;

    
    //
    //  Searches for a Commission__c with the same
    //  Proposal__c. If found, add the new listing Id
    //  to the Commission
    //
    for(Listing__c l : listingList){                
        for(Commission__c c: commissionList){
            if(l.Proposal__c == c.Proposal__c){
                c.Listing__c = l.Id;
                c.Proposal__c = null;
            }       
        }
    }   
    upsert commissionList;
    */
}