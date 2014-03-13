/**
 * This class contains unit tests for validating the behavior of
 * Escrow_Trigger class.
 *
 *@author: Ravel Antunes
 */
@isTest(SeeAllData = true)
private class Escrow_TriggerTest {

    static testMethod void createNewClosedEscrow() {
        // Setup aux objects
        Property__c property = new Property__c(Property_Address__c = 'alafaya 1');
        insert property;
        Proposal__c proposal = new Proposal__c();
        insert proposal;
        Listing__c listing = new Listing__c();
        insert listing;
        
        
        Escrow__c escrow = new Escrow__c();                        
        //escrow.Status__c = 'Closed';
        escrow.Property__c = property.Id;
        escrow.Proposal__c = proposal.Id;
        escrow.Listing__c = listing.Id;
        escrow.Close_of_Escrow__c = Date.today();
        escrow.Contract_Price__c = 1000;        
        upsert escrow;
        
        
        
        
        
       ProjectCompController obj = new ProjectCompController(new ApexPages.Standardcontroller(escrow));
       	obj.createComp();
        
                                        
    }
}