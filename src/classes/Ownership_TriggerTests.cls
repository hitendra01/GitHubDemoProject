/**
 * This class contains unit tests for validating the behavior of
 * Ownership_Trigger class.
 *
 *@author: Ravel Antunes
 */
@isTest
private class Ownership_TriggerTests {

    static testMethod void createsNewOwnership() {
        Contact c1 = new Contact(
        	LastName = 'lastName'
        );
        insert c1;
        
        
        Map <String,Schema.RecordTypeInfo> recordTypes =        Property__c.sObjectType.getDescribe().getRecordTypeInfosByName();
	        string rectype = 'Portfolio';
	        string rectypeid =  recordTypes.get(rectype).getRecordTypeId();
	        
	        
        Property__c p = new Property__c(
        	Property_Address__c = 'Alafaya 123'
        	,recordtypeId = rectypeid
        );
        insert p;
        
        Property__c p1 = new Property__c(
        	Property_Address__c = 'Alafaya 123',
        	Square_Footage__c =12,
        	units__c =12
        );
        insert p1;
        
       	Portfolio__c  pt = new Portfolio__c();
       	pt.Portfolio__c = p.id;
       	pt.property__C = p1.id;
       	insert pt;
        
        
        Ownership__c o1 = new Ownership__c(
        	Contact__c = c1.Id,
        	Property__c = p.Id,
        	Primary_Contact__c = true
        );
        insert o1;
        
        o1.Primary_Contact__c = false;
        update o1;
        
        Ownership__c o2 = new Ownership__c(
        	Contact__c = c1.Id,
        	Property__c = p.Id,
        	Primary_Contact__c = true
        );
        insert o2;
        
        o1.Primary_Contact__c = true;
        update o1;
        
        // Checks if Primary_Contact was set to null on Property object
        System.assert(p.Primary_Contact__c == null);
        
        delete o1;
        
        Contact con = new Contact();
        con.FirstName = 'firstContact';
        con.LastName = 'lastContact';
        insert con;
        
        Map<string,Id> PropertyRecordTypes = RecordTypeManager.GetRecordTypeIdsByDeveloperName(Property__c.SObjectType);
        
        Property__c pro = new Property__c();
        pro.City__c = 'testCity';
        pro.Property_Address__c = 'test Alafaya 123';
        pro.Name = 'testProperty';
        pro.RecordTypeId = PropertyRecordTypes.get('Healthcare');
        pro.State__c = 'AK';
        pro.Market__c = 'AK-Anchorage';
        pro.Zip_Code__c = '48965';
        insert pro;
        
        Ownership__c onw = new Ownership__c();
        onw.Contact_Role__c = 'Former Owner1';
        onw.Contact__c = c1.Id;
        onw.Property__c = pro.Id;
        insert onw;
        
        pro.Property_Address__c = 'test Alafaya 12455';
        update pro;
        
        delete onw;
        delete pro;
        
        
    }
}