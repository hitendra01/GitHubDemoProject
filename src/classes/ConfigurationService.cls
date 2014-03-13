/**
 * This class is responsible for managing anything to do with
 * the configurations needed for the app as well as providing
 * that information to other classes.
 *
 * @auther Josh Russell (Riptide Software, Inc.)
 * @auther Alex Acosta  (Riptide Software, Inc.)
 */
public with sharing class ConfigurationService {
    
    private static RCM1_Settings__c config;
    
    // This flag will be used to let us know if we were able
    // to query an existing configuration and can update this
    // existing record or if we had to create a new record and
    // we need to insert the new record.
    private static Boolean configFound;
    
    // Make sure we have an initialized Schoology_Org_Wide_Config__c
    // object available for use throughout the object. If one has
    // not been created yet, as could potentially be the case,
    // we create the config.
    static{
        
        // A query for a List is used here because if no records exist and
        // we query for a single record, a List has no rows for assignment to SObject
        // exception is thrown. If we query for a list of records, even if no
        // records are returned, we avoid the exception and can continue on to
        // create the new record.
        RCM1_Settings__c[] configs = [SELECT s.Name, s.Id, s.isTest__c, s.Api_Key__c, scheduler_id__c, Activities_Import_Date__c FROM RCM1_Settings__c s];
                                                  
        if(null == configs || configs.size() == 0){
            config = new RCM1_Settings__c();
            config.Name = McLabsConstants.CONFIGURATION_NAME;
            config.isTest__c = true;
            configFound = false;
        }
        else{
            configFound = true;
            config = configs.get(0);
        }
    }
    
    public static Boolean isTest(){
        return config.isTest__c;
    }
    
    public static void setIsTest(final boolean x){
        config.isTest__c = x;
    }
    
    public static String getHost(){
        if (isTest()){
            return  McLabsConstants.RCM1_API_TEST_URL;      
        } else {
            return McLabsConstants.RCM1_API_URL;
        }
    }
    
    public static String getApiKey(){
        system.debug(config);
        if (null != config && null != config.Api_Key__c){
            return config.Api_Key__c;
        } else {
            system.debug('An api key was not found. Please provide one...');
            return '';
        }
    }
    
    public static void setApiKey(final String x){
        config.Api_Key__c = x;
    }
    
    public static String getSchedulerId(){
        return config.scheduler_id__c;
    }
    
    public static void setSchedulerId(final String x){
        config.scheduler_id__c = x;
    }
    
    public static Date getActivitiesImportDate() {
        return config.activities_import_date__c;
    }
    
    public static void setActivitiesImportDate(Date activitiesImportDate) {
        config.activities_import_date__c = activitiesImportDate;
    }
    
    /**
     * Because there is a limit on the number of DML operations that can
     * be performed, this method is a compromise that limits the number of
     * DML operations that must be perfomed when setting configurations. The
     * trade off is that any code updating configurations needs to call this
     * method after updating any configurations. This limits the DML statements
     * for configuration updates to exactly 1, regardless of the number of
     * configuration options that are added.
     */
    public static void updateConfig(){
        if(configFound){
            update config;
        }
        else{
            insert config;
        }
    }
}