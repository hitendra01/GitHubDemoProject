/**
 * This class contains unit tests for validating the behavior of
 * ProjectCompControllerTest  class.
 *
 *@author: Ravel Antunes
 */
@isTest
private class ProjectCompControllerTest  {

    static testMethod void createNewProposal() {

        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Person';        
        upsert contact;
        
        Property__c property  = new Property__c();
        property.Property_Address__c = '123 alafaya';
        upsert property;
        
        Spaces__c space= new Spaces__c();
        space.property__c = property.id;
        space.Square_Footage__c = 120;
        space.Asking_Rate_PSF__c = 120;
        space.Lease_Type__c = 'NNN';
        space.Rental_Rate_Type__c = 'Amount/Month';
        insert space;
        
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
        proposal.recordTypeId = [Select id from RecordType where Name = 'Buyer Representation' and Sobjecttype  = 'Proposal__c'].id;
        update proposal;
               
        // Run another update to test if it's not going to create a duplicated Listing
        update proposal;
        //delete space;
        
        ProposalAssignmentController  pcon = new ProposalAssignmentController (new ApexPages.StandardController(proposal));
        pcon.createAssignment();
        Listing__c listing = [Select id from Listing__c order by createdDate desc limit 1];
        AssignmentProjectController  acon = new AssignmentProjectController (new ApexPages.StandardController(listing));
        acon.createProject();       
        Escrow__c project = [Select id from Escrow__c order by createdDate desc limit 1];
        ProjectCompController  pcomp = new ProjectCompController (new ApexPages.StandardController(project));
        pcomp.createComp();
        
        
        Attachment att = new Attachment(parentId = property.id, name = 'test.jpg',body=blob.valueOf('test'));
        insert att;
        att = new Attachment(parentId = property.id, name = 'test.jpg',body=blob.valueOf('test'));
        insert att;
        
        delete att;
        
        
                              
        
    }
}