/**
 * This class contains unit tests for validating the behavior of
 * Leasing_Proposal_Trigger class.
 *
 *@author: Ravel Antunes
 */
@isTest
private class Leasing_Proposal_TriggerTest {

    static testMethod void createNewLeaseProposal() {
        Lease_Proposal__c lp = new Lease_Proposal__c(Status__c = 'Won');
        insert lp;  
        
        update lp;
    }
}