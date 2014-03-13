public with sharing class InvoicePDFController {
    public string InvoiceId {get; set;}
    private Invoice__c invoice;
    public Commission_Item__c[] CommissionItems {get; private set;}
        
    public String companyLogoUrl {get; private set;}
    
    public String compRecordTypeId {get; private set;}
    public String compSaleRecordTypeId {get; private set;}
    public boolean isSaleRecordType {get; set;} 
    
    private static Map<string,Id> CompsRecordTypes = RecordTypeManager.GetRecordTypeIdsByDeveloperName(Sale__c.SObjectType);
    
  
        
    public InvoicePDFController(ApexPages.StandardController stdCon){
            invoice = (Invoice__c) stdCon.getRecord();
            invoiceid = invoice.id;
            getInvoice();
            
            /*
                Added by:  Hitendra 
                Date: 06-Mar-2014
                Issue #17 Invoice Settings 
             */
            compRecordTypeId = invoice.Comp__r.recordTypeId;
            compSaleRecordTypeId = CompsRecordTypes.get('Sale');
            isSaleRecordType = (compRecordTypeId == compSaleRecordTypeId);
            
            companyLogoUrl = getComponyLogoUrl();
    }
        
    public InvoicePDFController(){
        invoiceid = invoice.id;
        getInvoice();
    }

    public Invoice__c getInvoice(){
        if(InvoiceId!=null&&invoice==null){
            invoice = [Select i.Total_Due__c, i.Tax__c, i.SystemModstamp, i.Subtotal__c, 
                i.Recipient__c, i.Percent_Due__c, i.Paid__c, i.OwnerId, i.Name, i.LastViewedDate, i.LastReferencedDate, 
                i.LastModifiedDate, i.LastModifiedById, i.LastActivityDate, i.IsDeleted, i.Invoice_Date__c, i.Id, 
                i.Due_Date__c, i.CreatedDate, i.CreatedById, i.Comp__r.Property_Zip_Postal_Code__c, i.Comp__r.Property_State__c, 
                i.Comp__r.Property_City__c, i.Comp__r.Property_Address__c, i.Comp__r.Buyer__c, i.Comp__r.Buyer_Company__c, 
                i.Comp__r.RecordType.DeveloperName, i.Comp__r.Rental_Rate_Type__c, i.Comp__c, i.Total_Commissions__c, i.Comp__r.RecordTypeId  
                From Invoice__c i
                where i.Id = :InvoiceId];
                
        }
        if(InvoiceId!=null&&commissionitems==null){
            CommissionItems = [Select c.Type__c, c.Total__c, c.Rent_Sq_Ft__c, c.Quantity__c, c.Order__c, c.Name, 
                        c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Comp__c, 
                        c.Commission_Percent__c, c.Commission_Amount__c, c.Area_Sq_Ft__c, c.Amount__c 
                                From Commission_Item__c c
                                where c.Comp__c = :invoice.Comp__c
                                order by c.Order__c asc];
        }
        return invoice;
    }
    
    public string getCompRecordType(){
        return invoice.Comp__r.RecordType.DeveloperName;
    }
    
     /*
        Added by:  Roshan 
        Date: 06-Mar-2014
        Issue #16 Invoice Settings 
     */
    private String getComponyLogoUrl() {
        list<Document> documentList = [select Id from Document where DeveloperName='Company_Logo'];
        Document companyLogoDoc = (documentList != null && documentList.size()>0)? documentList[0] : null;
        
        return (companyLogoDoc != null)? '/servlet/servlet.FileDownload?file=' + companyLogoDoc.Id : '';
    } 

}