public class Ownership_Trigger_Helper {
    private static Boolean isRunningTrigger = false;
    
    public static void setIsRunningTrigger(Boolean isRunning){
        isRunningTrigger = isRunning;
    }
    
    public static Boolean getIsRunningTrigger(){
        return isRunningTrigger;
    }
    
    
    /**
     * Get all the ownerships that are the properties child
     */
    public static List<Ownership__c> getAllOwnershipProperties(List<Ownership__c> triggerNew){
    
        Set<String> propertyIds = new Set<String>();
                
        for(Ownership__c o: triggerNew){        
            propertyIds.add(o.Property__c); 
        }
        
        List<Ownership__c> ownershipOfProperties = [SELECT Id, Property__c, Primary_Contact__c
                                            FROM Ownership__c WHERE Property__c
                                            IN :propertyIds];
        return ownershipOfProperties;       
        
    }
    
    
    /**
     * Get all the properties that are the ownerships child
     */
    public static List<Property__c> getAllPropertiesFromOwnership(List<Ownership__c> triggerOld){       
        Set<String> propertyIds = new Set<String>();
        for(Ownership__c o: triggerOld){    
            if(o.Primary_Contact__c == true && o.Property__c != null){
                propertyIds.add(o.Property__c);
            }               
        }               
        
        QueryUtils queryUtils = new QueryUtils();  
        string fields = 'Primary_Contact__c, ';
        List<Property__c> properties = Database.query('SELECT ID, Primary_Contact__c FROM Property__c WHERE ID in :propertyIds');                                           
        return properties;
    }
    
    public class QueryUtils {
    
        public String prepareFields(Schema.SObjectType objectType){
            return prepareFields(objectType.getDescribe(), null);
        }
        
        public String prepareFields(Schema.DescribeSObjectResult objectType){
            return prepareFields(objectType, null);
        }
        
        public String prepareFields(Schema.SObjectType objectType, String prefix){
            return prepareFields(objectType.getDescribe(), prefix);
        }
    
        public String prepareFields(Schema.DescribeSObjectResult objectType, String prefix){
            String sqlQueryFields = '';
            Map<String, Schema.SObjectField> fieldsMap = objectType.fields.getMap();
            for(Schema.SObjectField f : fieldsMap.values()){
                if('' != sqlQueryFields){
                    sqlQueryFields += ',';
                }
                if(prefix != '' && prefix != null)
                    sqlQueryFields += prefix + '.';
                sqlQueryFields += f.getDescribe().getName();
            }
            
            return sqlQueryFields + ' ';
        }
        
        public String prepareSelectQuery(Schema.SObjectType objectType, ID id){
            return prepareSelectQuery(objectType.getDescribe(), id);
        }
    
        public String prepareSelectQuery(Schema.DescribeSObjectResult objectType, ID id){
            return 'select ' + prepareFields(objectType) +
                   ' from ' + objectType.getName() +
                   ' where Id = \'' + id + '\'' +
                   ' limit 1';
        }
        
        public String prepareFields(Schema.DescribeSObjectResult objectType, String prefix, Set<String> ignoreFieldNames)
        {
            String sqlQueryFields = '';
            Map<String, Schema.SObjectField> fieldsMap = objectType.fields.getMap();
            for(Schema.SObjectField f : fieldsMap.values()){
                
                String name = f.getDescribe().getName();
                
                if(ignoreFieldNames.contains(name))
                {
                    continue;
                }
                
                if('' != sqlQueryFields){
                    sqlQueryFields += ',';
                }
                if(prefix != '' && prefix != null)
                    sqlQueryFields += prefix + '.';
                sqlQueryFields += f.getDescribe().getName();
            }
            
            return sqlQueryFields + ' ';
        }
         
    }
    
    static testMethod void testPrepareAccountFields()
        {
            Set<String> ignoredFields = new Set<String>();
            ignoredFields.add('SicDesc');
            ignoredFields.add('AccountSource');
            ignoredFields.add('RecordType');
            
            QueryUtils queryUtils = new QueryUtils();    
            String fields = QueryUtils.prepareFields(Schema.SObjectType.Account, null, ignoredFields);
            
            try
            {
                Database.query('Select '+fields+' from Account');
            }
            catch(Exception e)
            {
                system.debug(e);
                throw e;
            }
        }
}