@isTest
public class Rcm1ApiTest {

    private static Rcm1Api rcm1ApiObj = new Rcm1Api();

    static testMethod void testGetListings() {
        HttpResponse response = rcm1ApiObj.getListings();
        
        System.assertNotEquals(null, response);
    }
    
    static testMethod void testGetListing() {
        HttpResponse response = rcm1ApiObj.getListing('1');
        
        System.assertNotEquals(null, response);
    }
    
    static testMethod void testGetBuyers() {
        HttpResponse response = rcm1ApiObj.getBuyers('1');
        
        System.assertNotEquals(null, response);
    }

    static testMethod void testGetUsers() {
        HttpResponse response = rcm1ApiObj.getUsers();
        
        System.assertNotEquals(null, response);
    }
    
    static testMethod void testSendBuyer() {
        Contact contact = new Contact(
            FirstName = 'Test Contact',
            LastName = 'Test Contact'
        );
        
        insert contact;
        
        Listing__c listing = new Listing__c(
            Name = 'Test Listing'
        );
        
        insert listing;
        
        Buyer__c buyer = new Buyer__c(
            Contact__c = contact.id,
            Listing__c = listing.id
        );
        
        insert buyer;
        
        try {
            Rcm1Api.sendBuyer(contact.id, listing.id);
        } catch(Exception e) {
            System.assert(false);
        }
    }

    static testMethod void testSendProperty() {
        Property__c property = new Property__c(
            Name = 'Test Property'
            ,Property_Address__c = 'test'
        );
        
        insert property;

        Listing__c listing = new Listing__c(
            Name = 'Test Listing',
            Property__c = property.id
        );
        
        insert listing;

        try {    
            Rcm1Api.sendProperty(property.id);
        } catch(Exception e) {
            System.assert(false);
        }
    }

    static testMethod void testSendListing() {
        Property__c property = new Property__c(
            Name = 'Test Property'
            ,Property_Address__c = 'test'
        );
        
        insert property;

        Listing__c listing = new Listing__c(
            Name = 'Test Listing',
            Property__c = property.id
        );
        
        insert listing;

        try {
            Rcm1Api.sendListing(listing.id);
        } catch(Exception e) {
            System.assert(false);
        }
    }

}