public class PropertyImageController{
     public string propertyid{get;set;}
     public Property__c property;
     
    public PropertyImageController(ApexPages.StandardSetController controller) {
                property   = (Property__c)controller.getRecord();
                string pageref=ApexPages.currentPage().getParameters().get('id');
                propertyid = pageref;
    }
    
    private static testMethod void PropertyImageControllerTest() {
        Property__c p = new Property__c();
    	p.Property_Address__c = 'test';
    	insert p;
    	Property__c[] props = new Property__c[]{};
    	props.add(p);
    	//PageReference page = new PageReference('/apex/PropertyImage');
    	ApexPages.StandardSetController con = new ApexPages.StandardSetController(props);
    	PropertyImageController controller = new PropertyImageController(con);
    }
}