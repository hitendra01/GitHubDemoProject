/**
 * This class contains unit tests for validating the behavior of
 * Listing_Trigger class.
 *
 *@author: Ravel Antunes
 */ 
@isTest
private class Listing_TriggerTest {

    static testMethod void createNewListing() {
        //Setup aux objects
        Property__c property = new Property__c(Property_Address__c = 'alafaya 1');
        insert property;
        Proposal__c proposal = new Proposal__c();
        insert proposal;
        Contact owner = new Contact(LastName = 'lastname');
        insert owner;
                
        
        Listing__c listing = new Listing__c();      
        listing.Property__c = property.Id;
        listing.Proposal__c = proposal.Id;
        listing.Owner_Contact__c = owner.Id;    
        insert listing;
        

        Commission__c commission = new Commission__c();
        commission.Proposal__c = proposal.Id;
        commission.Listing__c = listing.Id;
        commission.Gross_Commission__c = 1000;      
        //insert commission;
                            
        
        // Update listing, so it adds the escrow Id to comission.
        listing.Status__c = 'In Escrow'; 
        update listing;
        
        // Updates again to test if no duplicate Escrow is created
        update listing;                                         
        
                                                                                            
    }
}