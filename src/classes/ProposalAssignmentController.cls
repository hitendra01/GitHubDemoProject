/*
*

*/
public class ProposalAssignmentController {
	public Id proposalId {get;set;}
	public ProposalAssignmentController(ApexPages.StandardController stdCon){
		proposalId = stdCon.getId();
	}
	
	public Pagereference createAssignment(){
		Proposal__c proposal = [Select Name, Status__c, Property__c, Client__c, recordTypeId,OwnerId,List_Probability__c,commission__c,Client_Company__c,
								(Select id, Proposal__c From Listings__r),
								(Select id, Proposal__c, Listing__c From Commissions__r) 
								From Proposal__c 
								where id=:proposalId limit 1];
		List<Listing__c> listingList = new List<Listing__c>();
		
		//If Listing do not exist for this proposal
		if(proposal.Listings__r.size() == 0){
			Listing__c listing = new Listing__c();			
			listing.Proposal__c = proposal.Id;
			listing.Name = proposal.Name;
			listing.Property__c = proposal.Property__c;
			listing.System_Commis__c = true;
			listing.Owner_Contact__c = proposal.Client__c;
			//listing.Client__c = proposal.Client__c;
			listing.Client_Company__c = proposal.Client_Company__c;
			//listing.probability__c = proposal.list_Probability__c;
			listing.commission_input__C = proposal.commission__c;
			listing.System_Commis__c = true;
			//Set Record type of Assignment
			listing.recordtypeid = ProposalTriggerHelper.getAssignmentRecordType(proposal.recordTypeId);
			listingList.add(listing);
		}
		insert listingList;
		/*
			Searches for a Commission__c with the same
			Proposal__c. If found, add the new listing Id
			to the Commission
		*/
		for(Commission__c c: proposal.Commissions__r){
		   c.Listing__c = (listingList.size() > 0) ? listingList[0].id : proposal.Listings__r[0].id;
	       c.Proposal__c = null;
		}	
		upsert proposal.Commissions__r;
		if(proposal.Commissions__r.size() == 0 && proposal.Listings__r.size() == 0){
			Commission__c comm = new Commission__c();
			comm.broker__c = proposal.OwnerId;
			//comm.Proposal__c = proposal.id;
			comm.Listing__c = (listingList.size() > 0) ? listingList[0].id : proposal.Listings__r[0].id;
			insert comm;
		}
		
		proposal.status__c = 'Won';
		update proposal;
		
		return new Pagereference('/' + (proposal.Listings__r.size() > 0 ? proposal.Listings__r[0].id : listingList[0].id) );
	}
}