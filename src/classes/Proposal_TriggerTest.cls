/**
 * This class contains unit tests for validating the behavior of
 * Proposal_Trigger class.
 *
 *@author: Ravel Antunes
 */
@isTest
private class Proposal_TriggerTest {

    static testMethod void createNewProposal() {

        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Person';        
        upsert contact;
        
        Property__c property  = new Property__c();
        property.Property_Address__c = '123 alafaya';
        upsert property;
        
        Proposal__c proposal = new Proposal__c();        
        //proposal.Status__c = 'Listed';
        proposal.Client__c = contact.Id;
        proposal.Property__c = property.Id;        
        upsert proposal;
        
        Commission__c commission = new Commission__c();        
        commission.Proposal__c = proposal.Id;
        commission.Gross_Commission__c = 1;
        //insert commission;
        
        proposal.Status__c = 'Listed';
        update proposal;
               
        // Run another update to test if it's not going to create a duplicated Listing
        update proposal;
        
                                           
    }
}