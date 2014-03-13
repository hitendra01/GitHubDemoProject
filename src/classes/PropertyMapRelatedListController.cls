/**
 * Riptide Software
 *
 * This controller manages the PropertyMapRelatedList visual force page. It pulls a list of properties based on the 
 * contact selected and pushes the data to a Google Maps visual force component to be rendered. 
 *
 *@author: Trey Dickson
 */	

public with sharing class PropertyMapRelatedListController {

	public boolean showMap {get;set;}
	public boolean notFound {get;set;}
	public AddressModel addressmodel {get;set;}

	public ApexPages.StandardSetController setCon {
		get {
			if(setCon == null)	{
				//Get the list of ownership records for the contact
				List<Ownership__c> ownership = [SELECT Property__c FROM Ownership__c WHERE Contact__c = :ApexPages.currentPage().getParameters().get('id')];
				System.Debug('&&&&&&&&&&&&&&&&&&&&& ' + ownership.size());
				Set<String> properties = new Set<String>();
				
				//Build a list of properties ids
				for(Ownership__c owner : ownership) {
					properties.add(owner.Property__c);
				}
				System.Debug('&&&&&&&&&&&&&&&&&&&&& ' + properties.size());
				
				//pull the properties for the contact and set them to the StandardSetController
				setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT id, Name, Property_Address__c, City__c, state__c, County__c, Zip_Code__c from Property__c WHERE ID IN :properties]));
				
			}
			return setCon;
		}
		set;
	}
	
	public PropertyMapRelatedListController() {
		//Create an address model to place the 
		addressmodel = new AddressModel();
		
		//Get the list of properties
		List<Property__c> properties = getProperties();
		
		for(Property__c property : properties) {
            showMap = true;
            //Check to see if the property has all the address fields filled out
            if(property.Property_Address__c == null || property.Property_Address__c == '' ||
               property.City__c == null || property.City__c == '' ||
               property.state__c == null || property.state__c == '' ||
               property.Zip_Code__c == null || property.Zip_Code__c == '')
               {
                notFound = true;
            } else {
            
	            string address = property.Property_Address__c != null ? property.Property_Address__c.replaceall('\n','') :  '';
	            
	            if(address.trim().length() > 0 )
	                address += ',';
	            address += property.City__c != null ? property.City__c.replaceall('\n','') :  '';
	            
	            if(address.trim().length() > 0 )
	                address += ',';       
	            address += property.state__c != null ? property.state__c : '';
	
	            if(address.trim().length() > 0 )
	                address += ',';       
	            address += property.Zip_Code__c != null ? property.Zip_Code__c : '';
	            
	            //Add the address tot he list of address models
	            addressmodel.add(address,
	                             '',
	                             '',
	                             '<h3><a href=/' + property.id + ' target=_blank>' + property.name + '</a></h3>' +
	                             '<br>' + address);
            
            }
		}
	}
	
	public List<Property__c> getProperties() {
		return (List<Property__c>) setCon.getRecords();
	}
	
	private static testMethod void testController() {
		//Test the controller
		Property__c prop1 = new Property__c();
		prop1.Name = 'hi';
		prop1.Property_Address__c = '123 N Alafaya Trl';
		prop1.City__c = 'Orlando';
		prop1.State__c = 'FL';
		prop1.Zip_Code__c = '55555';
		
		insert prop1;
		
		Property__c prop2 = new Property__c();
		prop2.Name = 'Hi';
		prop2.Property_Address__c = '123 N Alafaya trl';
		
		insert prop2;
		
		Contact contact = new Contact();
		contact.LastName = 'James';
		
		insert contact;
		
		Ownership__c ownership = new Ownership__c();
		ownership.Contact__c = contact.Id;
		ownership.Property__c = prop1.Id;
		
		insert ownership;
		
		ownership = new Ownership__c();
		ownership.Contact__c = contact.Id;
		ownership.Property__c = prop2.Id;
		
		insert ownership;
		
		PageReference pageRef = new Pagereference('/apex/PropertyMapRelatedList?id=' + contact.Id);
		Test.setCurrentPage(pageref);
		
		PropertyMapRelatedListController controller = new PropertyMapRelatedListController();
	}
}