/**
 * This class contains unit tests for validating the behavior of
 * AssignmentProjectController class.
 *
 *@author: Chetan Garg
 */ 
@isTest(SeeAllData = true)
private class AssignmentProjectControllerTest {

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
        

       
                            
        AssignmentProjectController con = new AssignmentProjectController(new Apexpages.Standardcontroller(listing));
        con.createProject();
        
        // Updates again to test if no duplicate Escrow is created
        update listing;                                         
        
        List<Escrow__c> escrowList = [SELECT Property__c, Proposal__c 
                                    FROM Escrow__c WHERE Listing__r.Id = :listing.Id];
                                    
        System.assert(escrowList.size() > 0);                                                                                           
    }
}