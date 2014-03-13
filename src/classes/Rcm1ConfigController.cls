/**
 * This class is responsible for setting up, saving, editing, 
 * and controlling any actions dictated within the default 
 * Google Spreadsheet VisualForce Configuration Page.
 *
 * @author Adrian Jagnanan (Riptide Software, Inc.)
 */
public with sharing class Rcm1ConfigController {

    public RCM1_Settings__c config {get;set;}
    public Boolean editMode {get;set;}
    
    public Rcm1ConfigController(){
        // initate instance(s)
        config = new RCM1_Settings__c();
        editMode = false;   
    }
    
    /**
     * Saves all Google Spreadsheet Configurations. Will throw up and handle any errors
     * and display it to the user via the VisualForce Page neatly.
     */
    public PageReference save(){ 
        try{
            setConfig(); 
            ConfigurationService.updateConfig();
            editMode = false;
        }catch(Exception e){
            Apexpages.addMessages(e);
        }
        return null;
    }
    
    /**
     * Renders the edit portion of the VisualForce Page so a 
     * User may edit the Org Google Spreadsheet Configurations 
     */
    public PageReference edit(){
        editMode = true;
        return null;
    }
    
    /**
     * Will cancel any changes made within the edit page 
     * and rerender the details page
     */
    public PageReference cancel(){
        editMode = false;
        return null;
    }
    
    public void runImporter() {
//        Database.executeBatch(new Rcm1Importer(), 3);
        Rcm1ActivitiesImporter.process(0);
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The importing process has been started'));
    }
    
    public void startScheduler(){
        config.scheduler_id__c = ImportSchedulable.start();
        save();
        getConfig();

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The importing job was scheduled to run daily at 11pm'));
    }
    
    public void stopScheduler(){
        System.abortJob(config.scheduler_id__c);
        config.scheduler_id__c = null;
        save();
        getConfig();

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The importing job was stopped'));
    }
    
    /**
     * Getter for our Configurations
     */
    public PageReference getConfig(){
        config.Api_Key__c = ConfigurationService.getApiKey();
        config.isTest__c = ConfigurationService.isTest();
        config.scheduler_id__c = ConfigurationService.getSchedulerId();
        config.activities_import_date__c = ConfigurationService.getActivitiesImportDate();
        
        return null;
    }
    
    /**
     * Setter for our Configurations
     */
    private void setConfig(){
        ConfigurationService.setApiKey(config.Api_Key__c);
        ConfigurationService.setIsTest(config.isTest__c);
        ConfigurationService.setSchedulerId(config.scheduler_id__c);
        ConfigurationService.setActivitiesImportDate(config.activities_import_date__c);
    }
}