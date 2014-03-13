/************************************************************************************************
@ name          :  PropertyMapcontroller
page            :  PropertyMap
@ author        :  iBirds Services
@ date          :  14 May, 2011
@ description   :  This is the class to provide the address and functionality to the page.
************************************************************************************************/

public with sharing class PropertyMapcontroller{
    public AddressModel addressmodel {get;set;}
    String propertyid;
    Property__c property;
    public boolean showMap {get;set;}
    public PropertyMapcontroller(ApexPages.StandardController sc){
    	
    	
    	//String s = rcm1Api.getProjects().getBody();
    	//ProjectAdapter pa = new ProjectAdapter(s); 
    	
    	
        property = (Property__c)sc.getRecord();
        addressmodel = new AddressModel();

        if(property.Id != null){
            for(Property__c property: [Select id, Name, Property_Address__c, City__c, state__c, County__c, Zip_Code__c from Property__c where id =:property.Id]){
            showMap = true;
            if(property.Property_Address__c == null || property.Property_Address__c == '' ||
               property.City__c == null || property.City__c == '' ||
               property.state__c == null || property.state__c == '' ||
               property.Zip_Code__c == null || property.Zip_Code__c == ''){
                showMap = false;
            }
            
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
            
            addressmodel.add(address,
                             '',
                             '',
                             '<h3><a href=/' + property.id + ' target=_blank>' + property.name + '</a></h3>' +
                             '<br>' + address);
            }
    
        }
    }    
    
    private static testMethod void test(){
    	Property__c p = new Property__c();
    	p.Property_Address__c = 'test';
    	insert p;
    	PropertyMapcontroller controller = new PropertyMapcontroller(new ApexPages.Standardcontroller(p));
    }
}