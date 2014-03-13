/*** Update Property Address to Contact record
   *
   *  Version 1.0  -- Shrew Design  -- 
   *
  ***/
  
/*** To Run this Class From the Console:
     
id batchId = Database.executeBatch(new BatchPropertyImage(), 200);
System.debug('\n\n==> batchId = ' + batchId); 

***/
global class BatchPropertyImage implements Database.Batchable<SObject> {

  global Database.QueryLocator start(Database.BatchableContext context) {

    Database.QueryLocator ans = 
       Database.getQueryLocator('Select m.Id, (Select Id, ContentType From Attachments where contentType like \'%image%\' order by createdDate desc limit 1) From Property__c m ');
        return ans;
  }
  
  global void execute(Database.BatchableContext context, List<SOBject> objects) {   
    List<Property__c> properties = new List<Property__c>();
    for(Property__c p : (List<Property__c>)objects){
        if(p.Attachments.size() > 0){
            p.Image_Attachment_Id__c = p.Attachments[0].id;
            properties.add(p);
        }   
    }
    
    update properties;
                           
  }

  global void finish(Database.BatchableContext context) {
    
  
  }
  
   @isTest
  private static void testBatch(){
      BatchPropertyImage con = new BatchPropertyImage();
      con.start(null);
      con.finish(null);
      Property__c property = new Property__c(Property_Address__c = 'alafaya 1');
      insert property;
      Attachment att = new Attachment();
      att.ParentId = property.id;
      att.body=blob.valueOf('test');
      att.name='test';
      insert att;
      List<Property__c> ps = [Select m.Id, (Select Id, ContentType From Attachments  order by createdDate desc limit 1) From Property__c m];
      con.execute(null,ps);
  }
  
  
}