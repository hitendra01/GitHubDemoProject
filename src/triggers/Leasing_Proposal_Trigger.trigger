/**
 * Riptide Software
 *
 * This trigger will create a new Project Leasing when
 * a Leasing Proposal status is marked as "Won". 
 *
 *@author: Ravel Antunes
 *@author: Trey Dickson
 */	
trigger Leasing_Proposal_Trigger on Lease_Proposal__c (after insert, after update) {
/*		
	Set<String> proposalIds = new Set<String>();
	
	// Creates a Set list with all the Proposal Id's
	for(Lease_Proposal__c lp : Trigger.new){		
		proposalIds.add(lp.Id);	
	}
	
	// Gets all Project_Leasing objects with the Id's in the proposalIds set list
	List<Project_Leasing__c> currentProjectLeasing = [SELECT Id, Leasing_Proposal__c
										FROM Project_Leasing__c WHERE Leasing_Proposal__c
										IN :proposalIds];
	
	
	
	List<Project_Leasing__c> projectLeasingList = new List<Project_Leasing__c>();
	
	Boolean alreadyExists;
	
	// Iterates through all the proposals being changed
	for(Lease_Proposal__c lp : Trigger.new){
		alreadyExists = false;		
		
		// If finds a project for the Proposal, set alreadyExists to true
		for(Project_Leasing__c pl : currentProjectLeasing){			
			if(lp.Id == pl.Leasing_Proposal__c){
				alreadyExists = true;	
			}
		}
		
		// Creates a new Project_Leasing if Lease_Proposal_status is 'Won'
		if(lp.Status__c == 'Won' && !alreadyExists){					
			Project_Leasing__c project = new Project_Leasing__c(
				Leasing_Proposal__c = lp.Id,
				Client__c = lp.Client__c,
				Property__c = lp.Property__c,
				Name = lp.Name
			);			
			projectLeasingList.add(project);		
		}		
	}
	
	upsert projectLeasingList;
	*/
}