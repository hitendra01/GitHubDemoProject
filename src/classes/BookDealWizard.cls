public with sharing class BookDealWizard {
    
    private static final String RT_LEASE_COMPS = 'Lease';
    private static final String RT_SALE_COMPS = 'Sale';
    
    private static final String RT_LEASE_COMMISSION_ITEM = 'Lease';
    private static final String RT_SALE_COMMISSION_ITEM = 'Sale';
    
    private static Map<string,Id> CompsRecordTypes = RecordTypeManager.GetRecordTypeIdsByDeveloperName(Sale__c.SObjectType);
    private static Map<string,Id> commissionItemRecordTypes = RecordTypeManager.GetRecordTypeIdsByDeveloperName(Commission_Item__c.SObjectType);
    
    public static String RT_LEASE_COMPS_ID {
        get {
            return CompsRecordTypes.get(RT_LEASE_COMPS); 
        } 
        private set;
    }
    
    public static String RT_SALE_COMPS_ID {
        get {
            return CompsRecordTypes.get(RT_SALE_COMPS);
        }
        private set;
    }
    
    private static map<String, Integer> sectionVsStepNumberMap = new map <String, Integer> {
        'Lease Details' => 1,
        'Lease Summary' => 2,
        'Agent Commissions' => 3,
        'Commission Items' => 4,
        'Holdbacks' => 5,
        'Invoices' => 6
    };
    
    public String pageTitle {get; private set;}
    public Integer stepNumber {get; private set;}
    public Integer totalSteps {get; private set;}
    public Sale__c comp {get; set;}
    private ApexPages.StandardController CompController;
    Map<string,Id> CommissionRecordTypes = RecordTypeManager.GetRecordTypeIdsByDeveloperName(Commission__c.SObjectType);
    
    public String sectionToEdit {get; set;}
    
    public BookDealWizard(ApexPages.StandardController stdCon) {
        CompController = stdCon;
        comp = (Sale__c) CompController.getRecord();
        pageTitle = 'Book Deal Wizard';
        stepNumber = 1;
        totalSteps = 7;
        
        // set step number by querystring if passed
        if (ApexPages.currentPage().getParameters().get('step') != null) {
            stepNumber = Integer.valueOf(ApexPages.currentPage().getParameters().get('step'));
        }
        
        // To-Do: get the existing lists from the comp
        ListWrapper[] InternalCommissionsWrapper = new ListWrapper[]{};
        ListWrapper[] ExternalCommissionsWrapper = new ListWrapper[]{};
        ListWrapper[] CommissionItemsWrapper = new ListWrapper[]{};
        ListWrapper[] HoldbacksWrapper = new ListWrapper[]{};
        ListWrapper[] InvoicesWrapper = new ListWrapper[]{};
        ListMap = new map<string,ListWrapper[]>{
            'ExternalCommissions' => wrap((SObject[])[select Agent_Percentage__c, Activity_Date__c, Broker_Contact__c, Agent_Gross_Commission__c from Commission__c 
                                        where Sale__c = :comp.Id and RecordType.DeveloperName = 'External_Broker']),
            'InternalCommissions' => wrap((Sobject[])[select Agent_Percentage__c, Activity_Date__c, Broker__c, Agent_Gross_Commission__c from Commission__c 
                                        where Sale__c = :comp.Id and RecordType.DeveloperName = 'Internal_Broker']),
            'CommissionItems' => wrap((SObject[])[select Id, Type__c, Rent_Sq_Ft__c, Area_Sq_Ft__c, Amount__c, Quantity__c, Total__c, Commission_Percent__c, Commission_Amount__c from Commission_Item__c where Comp__c = :comp.Id]),
            'Holdbacks' => wrap((SObject[])[select Id, Type__c, Amount__c from Holdback__c where Comp__c = :comp.Id]),
            'Invoices' => wrap((SObject[])[select Id, Due_Upon__c, Percent_Due__c, Invoice_Date__c, Due_Date__c, Total_Commissions__c, Tax__c from Invoice__c where Comp__c = :comp.Id])
        };
    }
    
    String[] ListTypes = new String[]{'ExternalCommissions','InternalCommissions','CommissionItems','Holdbacks','Invoices'};
    
    public PageReference next() {
        if (stepNumber < totalSteps) {
            CalculationsAfterStep();
            stepNumber++;
            CalculationsBeforeStep();
        }
        return null;
    }
    
    public pageReference previous() {
        if (stepNumber > 1) {
            stepNumber--;
            CalculationsBeforeStep();
        }
        return null;
    }
    
     /*
        Added by:  Roshan 
        Date: 06-Mar-2014
        Issue #23 
     */
    public Pagereference editParticularSection() {
        stepNumber = (sectionVsStepNumberMap.get(sectionToEdit) != null)? sectionVsStepNumberMap.get(sectionToEdit) : stepNumber;
        return null;
    }
    
    /*
        Modified by:  Roshan 
        Date: 27-Feb-2014
        Issue #2 Book Sale Wizard  
    */
    private void CalculationsBeforeStep(){
        // Put any calculations that need to be calculated at the beginning of the step here
        if(stepNumber == 6){ 
            updateTotalCommission();
            if(ListMap.get('Invoices').size()==0){
                //ListMap.get('Invoices').add(new listWrapper(0,new Invoice__c(comp__c = comp.Id, Percent_due__c = 100, Recipient__c = comp.Tenant_Contact__c)));
                if (comp.RecordTypeId == RT_LEASE_COMPS_ID)
                    ListMap.get('Invoices').add(new listWrapper(0,new Invoice__c(comp__c = comp.Id, Percent_due__c = 100, Recipient__c = comp.Tenant_Contact__c, Invoice_Date__c = comp.Sale_Date__c)));
                else if (comp.RecordTypeId == RT_SALE_COMPS_ID)
                    ListMap.get('Invoices').add(new listWrapper(0,new Invoice__c(comp__c = comp.Id, Percent_due__c = 100, Due_Upon__c='Closing', Recipient__c = comp.Tenant_Contact__c, Invoice_Date__c = comp.Sale_Date__c)));
            }
        } 
        else if (stepNumber == 4 && comp.RecordTypeId == RT_SALE_COMPS_ID && ListMap.get('CommissionItems').size()==0) {
           ListMap.get('CommissionItems').add(new listWrapper(0,new Commission_Item__c(
               comp__c = comp.Id, 
               Amount__c = comp.Sale_Price__c,
               Quantity__c = 1,
               recordTypeId = commissionItemRecordTypes.get(RT_SALE_COMMISSION_ITEM),
               Type__c = '% of Sale Price'
            )));
        }
    }
    
    private void CalculationsAfterStep(){
        
        if(stepNumber == 3){
            if(getTotalPercent()<>100){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Agent Percentages must add up to 100%. Current Total: ' +getTotalPercent()));
                stepNumber--;
            }
        }
        if(stepNumber == 4){
            try{
                upsertObjects(ListMap.get('CommissionItems'));
                ListMap.put('CommissionItems',wrap((SObject[])[select Id, Type__c, Rent_Sq_Ft__c, Area_Sq_Ft__c, Amount__c, Quantity__c, Total__c, Commission_Percent__c, Commission_Amount__c from Commission_Item__c where Comp__c = :comp.Id]));
            }catch(exception ex){
                ApexPages.addmessages(ex);
                stepNumber = 3; // so that it will stay on 4
            }
        }
        if(stepNumber == 6){
            // Validate invoice total
            decimal InvoiceTotal = 0;
            for(ListWrapper item : ListMap.get('Invoices')){
                if(item.getInvoice().Percent_Due__c <> null) invoiceTotal += item.getInvoice().Percent_Due__c;
            }
            if(invoiceTotal <> 100) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Invoices do not add up to 100%'));
        }
    }
    
    private void updateTotalCommission(){
        comp.Commission__c = 0;
        for(ListWrapper item : ListMap.get('CommissionItems')){
            if(item.getCommissionItem().Commission_Amount__c <> null) comp.Commission__c += item.getCommissionItem().Commission_Amount__c;
        }
    }
    
    public PageReference cancel() {
        return new PageReference('/'+comp.Id);
    }
    
    public pageReference bookDeal(){
        try{
            // CompController.save();
            delete ListItemsToDelete;
            Commission__c[] commissions = new Commission__c[]{};
            for(string ListType : ListTypes){
                ListWrapper[] listToupdate = ListMap.get(ListType);
                if(listToUpdate.size()>0&&!ApexPages.hasMessages()){
                    upsertObjects(ListToupdate);
                }
            }
            upsert commissions;
        }catch(exception ex){
            comp.Booked__c = false;
            ApexPages.addMessages(ex);
            return null;
        }
        // NOTE: Have to update the comp to booked last (locks commissions)
        if(!ApexPages.hasMessages()){
            comp.Booked__c = true;
            return CompController.save();
        }else{
            return null;
        }
        
    }
    
    private void upsertObjects(ListWrapper[] wrappers){
        sObject[] objectsToInsert = new sObject[]{};
        sObject[] objectsToUpdate = new sObject[]{};
        for(ListWrapper wrapper : wrappers){
            if(wrapper.listobject.Id==null) objectsToinsert.add(wrapper.listobject);
            else objectsToUpdate.add(wrapper.listobject);
        }
        update objectsToUpdate;
        insert objectsToInsert;
    }
    
    // Code for handling list editing
    public static integer rowNumberForUpdate {get; set;}
    public string currentListType {get; set;}
    public map<string,listWrapper[]> ListMap {get; set;}
    private Integer RowNumTest = 0;
    
    private class listWrapper{
        
        public sobject listobject {get; private set;}
        public Integer RowNum{get; private set;}
        
        // Have to create a get method for each type of sobject since visualforce can't reference generic sobject fields
        public Commission__c getCommission(){return (Commission__c) listobject;}
        public Commission_Item__c getCommissionItem(){return (Commission_Item__c) listobject;}
        public Holdback__c getHoldback(){return (Holdback__c) listobject;}
        public Invoice__c getInvoice(){return (Invoice__c) listobject;}
        
        public listWrapper(integer listNum, sobject newobject){
            listobject = newobject;
            RowNum = listNum;
        }
    }
    
    private static ListWrapper[] wrap(SObject[] sobjs) {
        integer rowNum = 0;
        ListWrapper[] result = new ListWrapper[]{};
        for (SObject sobj : sobjs) {
            result.add(new ListWrapper(rowNum++, sobj));
        }
        return result;
    }
    
    private static SObject[] unwrap(ListWrapper[] wrappers){
        SObject[] result = new SObject[]{};
        for(ListWrapper wrapper : wrappers){
            result.add(wrapper.listobject);
        }
        return result;
    }
    
    public pageReference addItem(){
        System.Debug(ListMap);
        System.Debug(currentListType + ListMap.get(currentListType));
        listWrapper[] currentList = ListMap.get(currentListType);
        currentList.add(new listWrapper(currentList.size(),newItem(currentListType)));
        return null;    
    }
    
    private sObject[] ListItemsToDelete = new sObject[]{};
    
    public pageReference deleteItem(){
        listWrapper[] currentList = (ListMap.get(currentListType) != null)? ListMap.get(currentListType) : new listWrapper[] {} ;
        
        for(integer i=0;i<currentList.size();i++){
            if(currentList[i].RowNum == rowNumberForUpdate){
                if(currentList[i].listobject.Id<>null) ListItemsToDelete.add(currentList[i].listobject);
                currentList.remove(i);
                break;
            }
        }
        for(integer i=0;i<currentList.size();i++){
            currentList[i].RowNum = i;
        }
        return null;
    }
    
    private sObject newItem(string currentListType){
        if(currentListType == 'InternalCommissions'||currentListType=='ExternalCommissions'){
            decimal totalPercent = getTotalPercent();
            Id CommissionRecordType;
            if(currentListType == 'ExternalCommissions') CommissionRecordType = CommissionRecordTypes.get('External_Broker');
            else CommissionRecordType = CommissionRecordTypes.get('Internal_Broker');
            return new Commission__c(sale__c = comp.Id,
                        Agent_Percentage__c = 100-totalPercent, 
                        RecordTypeId = CommissionRecordType);
        }else if(currentListType == 'CommissionItems'){
            return new Commission_Item__c(
                comp__c = comp.Id, 
                Type__c = comp.Rental_Rate_Type__c, 
                Rent_Sq_Ft__c = comp.Rental_Rate__c, 
                Order__c = ListMap.get('CommissionItems').size()+1, 
                recordTypeId = getRecordTypeOfNewCommisionItem(),
                Area_Sq_Ft__c = comp.Square_Footage__c);
                
        }else if(currentListType == 'Holdbacks'){
            return new Holdback__c(comp__c = comp.Id); 
        }else if(currentListType == 'Invoices'){
            return new Invoice__c(comp__c = comp.Id, recipient__c = comp.Tenant_Contact__c);
        }
        return null;
    }
    
    /*
        Added by:  Roshan 
        Date: 06-Mar-2014
        Issue #18
    */
    private Id getRecordTypeOfNewCommisionItem() {
        Id recordTypeId;
        if (comp.RecordTypeId == RT_SALE_COMPS_ID)
            recordTypeId = commissionItemRecordTypes.get(RT_SALE_COMMISSION_ITEM);
        else if (comp.RecordTypeId == RT_LEASE_COMPS_ID)
            recordTypeId = commissionItemRecordTypes.get(RT_LEASE_COMMISSION_ITEM);
        return recordTypeId;
    }
    
    public decimal getTotalPercent(){
        decimal result = 0;
        for(ListWrapper wrapper : ListMap.get('ExternalCommissions')){
            result += wrapper.getCommission().Agent_Percentage__c;
        }
        for(ListWrapper wrapper : ListMap.get('InternalCommissions')){
            result += wrapper.getCommission().Agent_Percentage__c;
        }
        return result;
    }
    
}