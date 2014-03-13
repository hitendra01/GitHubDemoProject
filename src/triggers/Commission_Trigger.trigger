/*
*	Validate, Commision can not be greater than 100% 
*/
trigger Commission_Trigger on Commission__c (after insert, after update, before insert, before update){
	Map<Id,List<Commission__c>> proposalIdCommissions = new Map<Id,List<Commission__c>>();
	Map<Id,List<Commission__c>> listingIdCommissions = new Map<Id,List<Commission__c>>();
	Map<Id,List<Commission__c>> projectIdCommissions = new Map<Id,List<Commission__c>>();
	Map<Id,List<Commission__c>> compIdCommissions = new Map<Id,List<Commission__c>>();
	
	if(Trigger.isBefore){//Update Commission.OwnerId = Commission.Internal_Agent__c
		for(Commission__c c : Trigger.New){
			if(c.broker__c != null){
				c.OwnerId = c.Broker__c;
			}
		}
		
	}else if(Trigger.isAfter){//Validate Commission can not be greater than 100%
		for(Commission__c c : Trigger.New){
			if(Trigger.isInsert){//Insert
				populateRelatedIds(c);
			}else if(c.Agent_Percentage__c != Trigger.OldMap.get(c.id).Agent_Percentage__c//Update: if percentage is changed or relation is changed
					|| c.Proposal__c != Trigger.OldMap.get(c.id).Proposal__c
					|| c.Listing__c != Trigger.OldMap.get(c.id).Listing__c
					|| c.Sale__c != Trigger.OldMap.get(c.id).Sale__c
					|| c.Escrow__c != Trigger.OldMap.get(c.id).Escrow__c
				){
				populateRelatedIds(c);
			}
		}
		
		
		//Validate
		if(proposalIdCommissions.size() > 0){
			for(Proposal__c p : [Select id, 
									(Select Agent_Percentage__c From Commissions__r where Agent_Percentage__c <> null) 
								From Proposal__c where id IN: proposalIdCommissions.keyset()]){
				decimal percentCommission = 0;					
				for(Commission__c c : p.Commissions__r){
					percentCommission+= c.Agent_Percentage__c;
				}
				
				if(percentCommission > 100){
					for(Commission__c c : proposalIdCommissions.get(p.id)){
						c.Agent_Percentage__c.addError(Label.Commission_Error_Message);
					}
				}
			}
		}
		
		if(listingIdCommissions.size() > 0){
			for(Listing__c l : [Select id, 
									(Select Agent_Percentage__c From Commissions__r where Agent_Percentage__c <> null) 
								From Listing__c where id IN: listingIdCommissions.keyset()]){
				decimal percentCommission = 0;					
				for(Commission__c c : l.Commissions__r){
					percentCommission+= c.Agent_Percentage__c;
				}
				
				if(percentCommission > 100){
					for(Commission__c c : listingIdCommissions.get(l.id)){
						c.Agent_Percentage__c.addError(Label.Commission_Error_Message);
					}
				}
			}
		}
		
		if(compIdCommissions.size() > 0){
			for(Sale__c s : [Select id, 
									(Select Agent_Percentage__c From Commissions__r where Agent_Percentage__c <> null) 
								From Sale__c where id IN: compIdCommissions.keyset()]){
				decimal percentCommission = 0;					
				for(Commission__c c : s.Commissions__r){
					percentCommission+= c.Agent_Percentage__c;
				}
				
				if(percentCommission > 100){
					for(Commission__c c : compIdCommissions.get(s.id)){
						c.Agent_Percentage__c.addError(Label.Commission_Error_Message);
					}
				}
			}
		}
		
		
		if(projectIdCommissions.size() > 0){
			for(Escrow__c e : [Select id, 
									(Select Agent_Percentage__c From Commissions__r where Agent_Percentage__c <> null) 
								From Escrow__c where id IN: projectIdCommissions.keyset()]){
				decimal percentCommission = 0;					
				for(Commission__c c : e.Commissions__r){
					percentCommission+= c.Agent_Percentage__c;
				}
				
				if(percentCommission > 100){
					for(Commission__c c : projectIdCommissions.get(e.id)){
						c.Agent_Percentage__c.addError(Label.Commission_Error_Message);
					}
				}
			}
		}
	}
	
	//Copy Related fields ids
	void populateRelatedIds(Commission__c c){
		if(c.Proposal__c != null){
			if(proposalIdCommissions.containskey(c.Proposal__c)){
				proposalIdCommissions.get(c.Proposal__c).add(c);
			}else{
				proposalIdCommissions.put(c.Proposal__c , new List<Commission__c>{c});
			}
		}
		if(c.Listing__c != null){
			if(listingIdCommissions.containskey(c.Listing__c)){
				listingIdCommissions.get(c.Listing__c).add(c);
			}else{
				listingIdCommissions.put(c.Listing__c , new List<Commission__c>{c});
			}
		}
		if(c.Sale__c != null){
			if(compIdCommissions.containskey(c.Sale__c)){
				compIdCommissions.get(c.Sale__c).add(c);
			}else{
				compIdCommissions.put(c.Sale__c , new List<Commission__c>{c});
			}
		}
		if(c.Escrow__c != null){
			if(projectIdCommissions.containskey(c.Escrow__c)){
				projectIdCommissions.get(c.Escrow__c).add(c);
			}else{
				projectIdCommissions.put(c.Escrow__c , new List<Commission__c>{c});
			}
		}
			//Agent_Percentage__c			
	}
}