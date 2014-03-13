/**
 * Shrew Designs
 * converts the Assignment to a Project and updates Assignment Status to [In Contract]
 *@author: Chetan Garg
 */ 
public  class AssignmentProjectController {
    public string listingId {get;set;}
    public AssignmentProjectController(ApexPages.StandardController stdCon){
        listingId = stdCon.getId();
    }
    
    public Pagereference createProject(){
        Pagereference pg = null;
        RecordType projectRecordType = null;
        try{
            Listing__c listing = [Select id,RecordTypeId, Property__c, Proposal__c, Owner_Contact__c,Client_Company__c, Name,OwnerId,Commission_input__c,probability__c
                                    , (Select Id, Listing__c, Seller__c,Landlord__c From Escrows__r), (Select Id, Listing__c From Commissions__r)
                                    ,RecordType.Name 
                                  From Listing__c
                                  Where id=:listingid];
            List<Escrow__c> escrowList = new List<Escrow__c>();
            if(listing.Escrows__r.size() == 0){
                Escrow__c escrow = new Escrow__c();
                escrow.Listing__c = listing.Id;     
                escrow.Name = listing.Name;// + ' - ' +  System.now().format('MM/dd/yy  hh:mm a');
                
                if(listing.Property__c != null){
                    escrow.Property__c = listing.Property__c;
                }       
                
                escrow.escrow__c = listing.Commission_input__c;
                //escrow.probability__c = listing.probability__c;
                escrow.System_Commis__c = true;
                
                if(listing.Proposal__c != null){
                    escrow.Proposal__c = listing.Proposal__c;
                }                   
                
                //if(listing.Owner_Contact__c != null){
                    
                //}
                
                
                //Populate Project's Record TypeId based on listing record Type Id
                if(AssignmentTriggerHelper.getProjectRecordTypeId(listing.recordTypeId) != null){
                	escrow.recordTypeId = AssignmentTriggerHelper.getProjectRecordTypeId(listing.recordTypeId);
                }
                
                for(RecordType rt :[Select id ,Name from RecordType where id=:escrow.recordTypeId]){
                	projectRecordType = rt;
                }
                
                if(listing.recordType.Name == 'Tenant Representation'){
                	escrow.Tenant_Company__c = listing.Client_Company__c;
                	escrow.Tenant__c = listing.Owner_Contact__c;
                }else if(listing.recordType.Name == 'Landlord Representation'){
                	escrow.Landlord_Company__c = listing.Client_Company__c;
                	escrow.Landlord__c = listing.Owner_Contact__c;
                }else if(listing.recordType.Name == 'Seller Representation'){	
                	escrow.Seller_Company__c = listing.Client_Company__c;
                	escrow.Seller__c = listing.Owner_Contact__c;	
                }else{
                	escrow.Buyer__c = listing.Owner_Contact__c;
                	escrow.Buyer_Company__c = listing.Client_Company__c;
                }
                
                
                escrowList.add(escrow);
                upsert escrow;
            }else{
                escrowList = listing.Escrows__r;
            }
            
            for(Escrow__c e : escrowList){              
                for(Commission__c c: listing.Commissions__r){
                    if(e.Listing__c == c.Listing__c){
                        c.Escrow__c = e.Id;
                        c.Listing__c = null;
                    }       
                }
                
                if(listing.Commissions__r.size() == 0 ){
					Commission__c comm = new Commission__c();
					comm.broker__c = listing.OwnerId;
					comm.Escrow__c = e.id;
					//comm.Listing__c = listing.id;
					insert comm;
				}
            }   
            upsert listing.Commissions__r;
            
            Transaction__c[] sellers = new Transaction__c[]{};
    
            for(Escrow__c escrow : escrowList) {
            	Transaction__c party = new Transaction__c();
            	party.Escrow__c = escrow.Id;
            	party.Transcation_Company__c = listing.Client_Company__c;
                party.Contact__c = listing.Owner_Contact__c;
            	if(listing.recordType.Name == 'Tenant Representation'){
                	party.Role__c = 'Tenant';
                }else if(listing.recordType.Name == 'Buyer Representation'){
                	party.Role__c = 'Buyer';
                }else if(listing.recordType.Name == 'Seller Representation'){	
                	party.Role__c = 'Seller';
                }else{
                	party.Role__c = 'Landlord';
                }
                sellers.add(party);
            }
            
            insert(sellers);
            
            listing.Status__c = 'In Contract';
            update listing;
        
            return new Pagereference('/' + (listing.Escrows__r.size() > 0 ? listing.Escrows__r[0].id : escrowList[0].id) );
        }catch(Exception ex){
            Apexpages.addMessages(ex);
        }
        return pg;
    }

}