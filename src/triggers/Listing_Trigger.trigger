/**
 * Riptide Software
 *
 * This field will create a new Escrow when a Listing
 * status is marked as "In Escrow". 
 *
 *@author: Ravel Antunes
 *@author: Trey Dickson
 */	
trigger Listing_Trigger on Listing__c (before insert, before update, after insert, after update) {
	if(Trigger.isAfter){
		if(AssignmentTriggerHelper.hasRun == false){
			AssignmentTriggerHelper.hasRun = true;
			/*Shrew Designs
			 * When a Property is added to the Property Lookup field on a Landlord Representation Assignment record type, 
			 * Query all spaces associated with the Property and update their Landlord Representation Assignment lookup to match
			 *@author: Chetan Garg
			 */ 
			AssignmentTriggerHelper.runListingTrigger(Trigger.OldMap, Trigger.New, Trigger.isInsert);
			
			/*	
			if(FutureCallsSemaphore.futureCallAllowed) {
			        for(Listing__c listing : trigger.new) {
			            rcm1Api.sendListing(listing.id);
			        }
			    }*/
			    
			    if(Trigger.isInsert){
				    List<Commission__c> commissionList = new List<Commission__c>();
					
					for(Listing__c p :  trigger.new){
						if(p.System_Commis__c != true){
							Commission__c comm = new Commission__c();
							comm.broker__c = p.OwnerId;
							comm.listing__c = p.id;
							commissionList.add(comm);
						}
					}	
					upsert commissionList;
			    }
	    	AssignmentTriggerHelper.hasRun = false;
		}
	}else if(Trigger.isBefore){
		Map<Id,List<Listing__c>> contactMap = new Map<Id,List<Listing__c>>();
        if(Trigger.isInsert){
            for(Listing__c p : Trigger.new){       
                if(contactMap.containskey(p.Owner_Contact__c)){
                    contactMap.get(p.Owner_Contact__c).add(p);
                }else{
                    contactMap.put(p.Owner_Contact__c,new List<Listing__c>{p});
                }   
                    
            }
        }else if(Trigger.isUpdate){
            for(Listing__c p : Trigger.new){       
                if(p.Owner_Contact__c != Trigger.OldMap.get(p.id).Owner_Contact__c){
                    if(contactMap.containskey(p.Owner_Contact__c)){
                        contactMap.get(p.Owner_Contact__c).add(p);
                    }else{
                        contactMap.put(p.Owner_Contact__c,new List<Listing__c>{p});
                    }   
                }   
            }
        }
        if(contactMap.size()> 0){
            for(Contact c : [Select id,AccountId from Contact where id in: contactMap.keyset()]){
                for(Listing__c p : contactMap.get(c.id)){       
                    p.Client_Company__c = c.AccountId;
                }
            }
        }
	}

/*
	Set<String> listingIds = new Set<String>();
	
	// Creates a Set list with all the listing Id's
	for(Listing__c l: Trigger.new){		
		listingIds.add(l.Id);	
	}
	
	// Gets all Escrow objects with the Id's in the listingIds set list
	List<Escrow__c> currentEscrows = [SELECT Id, Listing__c
										FROM Escrow__c WHERE Listing__c
										IN :listingIds AND Status__c != 'Dead'];


	// Gets all Commission__c objects with the Id's in the proposalIds set list
	List<Commission__c> commissionList = [SELECT Id, Listing__c
										FROM Commission__c WHERE Listing__c
										IN :listingIds];
	

	List<Escrow__c> escrowList = new List<Escrow__c>();
	
	Boolean alreadyExists;
	for(Listing__c l :trigger.new){
		alreadyExists =false;
		
		// If finds a escrow for the Proposal, set alreadyExists to true
		for(Escrow__c escrow : currentEscrows){			
			if(l.Id == escrow.Listing__c){
				alreadyExists = true;	
			}
		}
		
		
		if(l.Status__c == 'In Escrow' && !alreadyExists){
			System.debug('In Escrow is true');
			Escrow__c escrow = new Escrow__c();
			escrow.Listing__c = l.Id;		
			escrow.Name = l.Name + ' - ' +  System.now().format('MM/dd/yy  hh:mm a');
			
			if(l.Property__c != null){
				escrow.Property__c = l.Property__c;
			}		
			
			if(l.Proposal__c != null){
				escrow.Proposal__c = l.Proposal__c;
			}					
			
			if(l.Owner_Contact__c != null){
				escrow.Seller__c = l.Owner_Contact__c;
			}
			
			
			
			
			//Populate Project's Record TypeId based on listing record Type Id
			if(AssignmentTriggerHelper.getProjectRecordTypeId(l.recordTypeId) != null){
				escrow.recordTypeId = AssignmentTriggerHelper.getProjectRecordTypeId(l.recordTypeId);
			}
			
			escrowList.add(escrow);	
		}
	}
	
	upsert escrowList;
	
	
	///
	//	Searches for a Commission__c with the same
	//	Proposal__c. If found, add the new escrow Id
	//	to the Commission
	
	for(Escrow__c e : escrowList){				
		for(Commission__c c: commissionList){
			if(e.Listing__c == c.Listing__c){
				c.Escrow__c = e.Id;
                c.Listing__c = null;
			}		
		}
	}	
	upsert commissionList;
	
	
	
	Transaction__c[] sellers = new Transaction__c[]{};
	
	for(Escrow__c escrow : escrowList) {
		if(escrow.Seller__c != null) {
			Transaction__c party = new Transaction__c();
			party.Contact__c = escrow.Seller__c;
			party.Escrow__c = escrow.Id;
			party.Role__c = 'Seller';
			sellers.add(party);
		}
	}
	
	insert(sellers);
	*/
}