/* This controls the functionality on the Edit Commissions Page.
The page is accessible from the commissions related list on the Proposals, Listings, Projects, or Comps */

public with sharing class EditCommissionsController {
     
    public list<Commission__c> ExternalCommissions {get;set;}
    public list<Commission__c> InternalCommissions {get;set;}
    Commission__c[] CommissionsToDelete = new Commission__c[]{};
    private map<string,Id> CommissionRecordTypes;
    
    public EditCommissionsController(ApexPages.StandardController stdCon){
        getParentObject();
        CommissionRecordTypes = RecordTypeManager.GetRecordTypeIdsByDeveloperName(Commission__c.SObjectType);
        if(!CommissionRecordTypes.containsKey('External_Broker')&&!CommissionRecordTypes.containsKey('Internal_Broker')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Error: You do not have access to the correct record types for the Commissions object. Please contact Apto support.'));
        }
        ExternalCommissions = [select Agent_Percentage__c, Activity_Date__c, Broker_Contact__c, Agent_Gross_Commission__c from Commission__c 
            where (Proposal__c = :parentobject.Id or Listing__c = :parentobject.Id or Escrow__c = :parentobject.Id or Sale__c = :parentobject.Id) and RecordType.DeveloperName = 'External_Broker'];
        InternalCommissions = [select Agent_Percentage__c, Activity_Date__c, Broker__c, Agent_Gross_Commission__c from Commission__c 
            where (Proposal__c = :parentobject.Id or Listing__c = :parentobject.Id or Escrow__c = :parentobject.Id or Sale__c = :parentobject.Id) and RecordType.DeveloperName = 'Internal_Broker'];
    }
    
    public EditCommissionsController(){
        getParentObject();
        CommissionRecordTypes = RecordTypeManager.GetRecordTypeIdsByDeveloperName(Commission__c.SObjectType);
        if(!CommissionRecordTypes.containsKey('External_Broker')&&!CommissionRecordTypes.containsKey('Internal_Broker')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Error: You do not have access to the correct record types for the Commissions object. Please contact Apto support.'));
        }
        ExternalCommissions = [select Agent_Percentage__c, Activity_Date__c, Broker_Contact__c, Agent_Gross_Commission__c from Commission__c 
            where (Proposal__c = :parentobject.Id or Listing__c = :parentobject.Id or Escrow__c = :parentobject.Id or Sale__c = :parentobject.Id) and RecordType.DeveloperName = 'External_Broker'];
        InternalCommissions = [select Agent_Percentage__c, Activity_Date__c, Broker__c, Agent_Gross_Commission__c from Commission__c 
            where (Proposal__c = :parentobject.Id or Listing__c = :parentobject.Id or Escrow__c = :parentobject.Id or Sale__c = :parentobject.Id) and RecordType.DeveloperName = 'Internal_Broker'];
    }
    
    public class ParentRecord{
        public string Name {get; set;}
        public string ObjectType {get; set;}
        public string ObjectLabel {get; set;}
        public Id Id {get; set;}
        public double Commissions {get; set;}
    }
    
    public decimal getTotalpercent(){
        Commission__c[] commissions = new Commission__c[]{};
        commissions.addAll(ExternalCommissions);
        commissions.addAll(InternalCommissions);
        decimal totalPercent = 0;
        for(Commission__c c : commissions){
            totalPercent += c.Agent_Percentage__c/100;
        }
        return totalPercent;
    }
    
    private ParentRecord parentobject;
    
    public ParentRecord getParentObject(){
        if(parentobject==null){
            parentobject = new ParentRecord();
            parentobject.Id = (Id) ApexPages.CurrentPage().getparameters().get('Id');
            if(parentobject.Id == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'System Error: No ID Specified. Please go back and try again. If the problem continues, contact Apto Support'));
            }else{
                parentobject.ObjectType = parentobject.Id.GetSObjectType().getDescribe().getName();
                parentobject.ObjectLabel = parentobject.Id.GetSObjectType().getDescribe().getLabel();
            }
            if(parentobject.ObjectType<>null){
                if(parentobject.ObjectType.containsIgnoreCase('Proposal__c')){
                    Proposal__c proposal = [Select p.Name, p.Id, p.Commission__c From Proposal__c p where p.id = :parentobject.Id];
                    parentObject.Name = proposal.Name;
                    parentObject.Commissions = proposal.Commission__c;
                }else if(parentobject.ObjectType.containsIgnoreCase('Listing__c')){
                    Listing__c listing = [Select l.Name, l.Id, l.Commission_Input__c From Listing__c l where l.id = :parentobject.Id];
                    parentObject.Name = listing.Name;
                    parentObject.Commissions = listing.Commission_Input__c;
                }else if(parentobject.ObjectType.containsIgnoreCase('Escrow__c')){
                    Escrow__c escrow = [Select p.Name, p.Id, p.Escrow__c From Escrow__c p where id = :parentobject.Id];
                    parentObject.Name = escrow.Name;
                    parentObject.Commissions = escrow.Escrow__c;
                }else if(parentobject.ObjectType.containsIgnoreCase('Sale__c')){
                    Sale__c sale = [Select p.Name, p.Id, p.Commission__c From Sale__c p where id = :parentobject.Id];
                    parentObject.Name = sale.Name;
                    parentObject.Commissions = sale.Commission__c;
                }
            }
        }
        return parentobject;
    }
    
    public pageReference save(){
        if(getTotalPercent()<>1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'The Agent Percentages must add to 100%'));
            return null;
        }
        Commission__c[] CommissionsToInsert = new Commission__c[]{};
        Commission__c[] CommissionsToUpdate = new Commission__c[]{};
        for(Commission__c c : ExternalCommissions){
            if(c.Id==null) CommissionstoInsert.add(c);
            else CommissionstoUpdate.add(c);
        }
        for(Commission__c c : InternalCommissions){
            if(c.Id==null) CommissionstoInsert.add(c);
            else CommissionstoUpdate.add(c);
        }
        try{
            if(CommissionsToDelete.size()>0) delete CommissionsToDelete;
            if(CommissionsToUpdate.size()>0) update CommissionsToUpdate;
            if(CommissionsToInsert.size()>0) insert CommissionsToInsert;
        }catch(System.DMLexception e){
            for (Integer i = 0; i < e.getNumDml(); i++) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Error updating commissions: '+e.getDmlMessage(i))); 
            }
            
        }
        if(ApexPages.hasMessages()){
            return null;
        }else if(ApexPages.currentPage().getUrl().containsignorecase('bookdealwizard')){
            return null;
        }else{
            return new PageReference('/'+parentobject.Id);
        }
    }
    
    public pageReference cancel(){
        return new PageReference('/'+parentobject.Id);
    }
    
    public pageReference addExternalCommission(){
        Decimal totalPercent = 1 - getTotalPercent();
        if(totalPercent<0) totalPercent = 0;
        Commission__c newCommission = new Commission__c(RecordTypeId = CommissionRecordTypes.get('External_Broker'), Agent_Percentage__c = totalPercent*100);
        newCommission = addParentId(newCommission,parentObject);
        ExternalCommissions.add(newCommission);
        return null;
    }
    
    public pageReference addInternalCommission(){
        Decimal totalPercent = 1 - getTotalPercent();
        if(totalPercent<0) totalPercent = 0;
        Commission__c newCommission = new Commission__c(RecordTypeId = CommissionRecordTypes.get('Internal_Broker'), Agent_Percentage__c = totalPercent*100);
        newCommission = addParentId(newCommission,parentObject);
        InternalCommissions.add(newCommission);
        return null;
    }
    
    private Commission__c addParentId(Commission__c com, parentRecord parent){
        if(parent.ObjectType.containsIgnoreCase('Proposal__c')){
            com.Proposal__c = parent.Id;
        }else if(parent.ObjectType.containsIgnoreCase('Listing__c')){
            com.Listing__c = parent.Id;
        }else if(parent.ObjectType.containsIgnoreCase('Escrow__c')){
            com.Escrow__c = parent.Id;
        }else if(parent.ObjectType.containsIgnoreCase('Sale__c')){
            com.Sale__c = parent.Id;
        }
        return com;
    }
    
    public Integer numberOfRowToRemove {get; set;}
    public pageReference removeExternalCommission(){
    	system.debug('ExternalCommissions-------------'+ExternalCommissions);
        if(ExternalCommissions.get(numberofRowToRemove).Id<>null) CommissionsToDelete.add(ExternalCommissions.get(numberofRowToRemove));
        ExternalCommissions.remove(numberOfRowToRemove);
        return null;
    }
    
    public pageReference removeInternalCommission(){
    	system.debug('InternalCommissions-------------'+InternalCommissions);
        if(InternalCommissions.get(numberofRowToRemove).Id<>null) CommissionsToDelete.add(InternalCommissions.get(numberofRowToRemove));
        InternalCommissions.remove(numberOfRowToRemove);
        return null;
    }
    
}