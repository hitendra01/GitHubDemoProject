trigger Invoice_Trigger on Invoice__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	// Process paid invoices
	if(Trigger.isAfter && (Trigger.isUpdate || Trigger.IsInsert)){
		Invoice__c[] PaidInvoices = new Invoice__c[]{};
		for(Invoice__c invoice : Trigger.New){
			if(invoice.Paid__c){
				if(Trigger.IsInsert||!Trigger.OldMap.get(invoice.Id).Paid__c){
					PaidInvoices.add(invoice);
				}
			}
		}
		if(PaidInvoices.size()>0){ 
			InvoiceTriggerHelper helper = new InvoiceTriggerHelper();
			PaidInvoices = helper.ProcessPaidInvoices(PaidInvoices);
		}
	} 
	
	// Create Commission Payments
	if(Trigger.isAfter && Trigger.isInsert){
		set<id> CompIds = new Set<Id>();
		for(Invoice__c invoice : Trigger.new){
			CompIds.add(invoice.comp__c);
		}
		Commission_Payment__c[] payments = new Commission_Payment__c[]{};
		for(Sale__c comp : [Select (Select Id From Invoices__r where Id in :Trigger.NewMap.keySet()), (Select Id From Commissions__r) From Sale__c s where Id in :CompIds]){
			for(Invoice__c invoice : comp.Invoices__r){
				for(Commission__c commission : comp.Commissions__r){
					payments.add(new Commission_Payment__c(Invoice__c = Invoice.Id, Commission__c = Commission.Id));
				}
			}
		}
		if(payments.size()>0) insert payments;
	}
}