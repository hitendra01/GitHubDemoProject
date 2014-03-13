/*
This class contains all installation scripts that need to run.
*/
global class PostInstallClass implements InstallHandler {
  global void onInstall(InstallContext context) {
    loadAssignmentSetting();
    loadProjectRecordTypeMapping();
    loadProposalSetting();
    if(context.isUpgrade()){
    	if(context.previousVersion().compareTo(new Version(2,150))<0){
	    	// Update the Sale Price
	    	Database.executeBatch(new BatchSalePriceUpdate(),400);
    	}
    	if(context.previousVersion().compareTo(new Version(2,147))<0){
	    	// Update the contacts based on Property Addresses
	    	Database.executeBatch(new BatchContactPropertyAddressUpdate(), 200);
    	}
	    if(context.previousVersion().compareTo(new Version(2,148))<0){
	    	// Update the Property image field with the first image attachment
	    	Database.executeBatch(new BatchPropertyImage(), 200);
    	}
    }
  }
  
  global void loadProposalSetting(){
    List<ProposalRecordtypeMapping__c> settings  = new List<ProposalRecordtypeMapping__c>();  
    if(ProposalRecordtypeMapping__c.getInstance('Tenant Representation') == null){
      settings.add(new ProposalRecordtypeMapping__c(Name = 'Tenant Representation', AssignmentRecordType__c = 'Tenant Representation'));
    }
    if(ProposalRecordtypeMapping__c.getInstance('Seller Representation') == null){
      settings.add(new ProposalRecordtypeMapping__c(Name = 'Seller Representation', AssignmentRecordType__c = 'Seller Representation'));
    }
    
    if(ProposalRecordtypeMapping__c.getInstance('Landlord Representation') == null){
      settings.add(new ProposalRecordtypeMapping__c(Name = 'Landlord Representation', AssignmentRecordType__c = 'Landlord Representation'));
    }
    
    if(ProposalRecordtypeMapping__c.getInstance('Buyer Representation') == null){
      settings.add(new ProposalRecordtypeMapping__c(Name = 'Buyer Representation', AssignmentRecordType__c = 'Buyer Representation'));
    }
    
    insert settings;
    
  }
  
  
  global void loadProjectRecordTypeMapping(){
    List<ProjectRecordTypeMapping__c> settings  = new List<ProjectRecordTypeMapping__c>();  
    if(ProjectRecordTypeMapping__c.getInstance('Pending Lease') == null){
      settings.add(new ProjectRecordTypeMapping__c(Name = 'Pending Lease', CompRecordType__c = 'Lease'));
    }
    if(ProjectRecordTypeMapping__c.getInstance('Pending Sale') == null){
      settings.add(new ProjectRecordTypeMapping__c(Name = 'Pending Sale', CompRecordType__c = 'Sale'));
    }
    insert settings;
    
  }
  
  global void loadAssignmentSetting(){
    List<AssignmentRecordTypeMapping__c> settings  = new List<AssignmentRecordTypeMapping__c>();  
    if(AssignmentRecordTypeMapping__c.getInstance('Buyer Representation') == null){
      settings.add(new AssignmentRecordTypeMapping__c(Name = 'Buyer Representation', ProjectRecordType__c = 'Pending Sale'));
    }
    if(AssignmentRecordTypeMapping__c.getInstance('Seller Representation') == null){
      settings.add(new AssignmentRecordTypeMapping__c(Name = 'Seller Representation', ProjectRecordType__c = 'Pending Sale'));
    }
    
    if(AssignmentRecordTypeMapping__c.getInstance('Tenant Representation') == null){
      settings.add(new AssignmentRecordTypeMapping__c(Name = 'Tenant Representation', ProjectRecordType__c = 'Pending Lease'));
    }
    
    insert settings;
    
  }
  
  @istest
  private static void testRecordType(){
    PostInstallClass p = new PostInstallClass();
    
    // Test initial install
    Test.TestInstall(p,null);
    
    // Validate that the settings were created
    List<AssignmentRecordTypeMapping__c> settings = AssignmentRecordTypeMapping__c.getAll().Values();
    System.AssertEquals(3,settings.size(),'Assignment Settings were not set correctly');
    
    List<ProjectRecordTypeMapping__c> projectsettings = ProjectRecordTypeMapping__c.getAll().Values();
    System.AssertEquals(2,projectsettings.size(),'Project settings were not created correctly.');
    
    // Test an upgrade
    Test.TestInstall(p, new Version(1,0),true); // Test upgrade from version 1.0
    
    // To-do: Test upgrade scripts (May not be needed since everyone will be upgraded in November '13)
  }

}