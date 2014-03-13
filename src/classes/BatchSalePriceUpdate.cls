/*** Update Property Address to Contact record
   *
   *  Version 1.0  -- Shrew Design  -- 
   *
  ***/
  
/*** To Run this Class From the Console:
     
id batchId = Database.executeBatch(new BatchSalePriceUpdate(), 200);
System.debug('\n\n==> batchId = ' + batchId); 

***/
global class BatchSalePriceUpdate implements Database.Batchable<SObject> {

  global Database.QueryLocator start(Database.BatchableContext context) {

    Database.QueryLocator ans = 
       Database.getQueryLocator('Select id, Last_Sale_Price__c, Last_Sale_Date__c, ' 
                        + ' (Select Sale_Price__c, Sale_Date__c From Sales__r ' 
                        + ' where recordTypeId = \'' + RecordTypeManager.saleCompRecordTypeId + '\' order by Sale_Date__c desc NULLS Last limit 1)' 
                        + ' From Property__c m');
        return ans;
  }
  
  global void execute(Database.BatchableContext context, List<SOBject> objects) {   
    for(Property__c p : (List<Property__c>) objects){
        if(p.Sales__r.size() > 0){
            if(p.Last_Sale_Date__C == null || (p.Last_Sale_Date__C <= p.Sales__r[0].Sale_Date__c)){
                 p.Last_Sale_Price__c = p.Sales__r[0].Sale_Price__c;
                 p.Last_Sale_Date__C = p.Sales__r[0].Sale_Date__c;
            }
        }
    }    
    
    update objects;                       
  }

  global void finish(Database.BatchableContext context) {
    
  
  }
  
  @isTest
  private static void testBatch(){
      BatchSalePriceUpdate  con = new BatchSalePriceUpdate();
      con.start(null);
      con.finish(null);
      Property__c property = new Property__c(Property_Address__c = 'alafaya 1');
        insert property;
      con.execute(null,new List<Sobject>{property });
  }
  
  
}