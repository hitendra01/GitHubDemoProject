public with sharing class InvoiceTriggerHelper {
	
	public Invoice__c[] ProcessPaidInvoices(Invoice__c[] PaidInvoices){
		// Get a set of Ids
		Set<Id> invoiceIds = new set<id>();
		for(Invoice__c invoice : PaidInvoices){
			invoiceIds.add(invoice.Id);
		}
		
		// Get the Commission Payables
		// To-do: Bulkify this since there could be many payments per invoice
		Commission_Payment__c[] payments = [Select c.Commission__r.RecordType.DeveloperName, c.Invoice__c, c.Broker_Id__c, c.Commission__r.Broker__c, c.Commission__r.Broker_Contact__c, c.Gross_Commission_Formula__c, c.Net_Commission__c, c.Commission_Calculation_Details__c From Commission_Payment__c c where c.Invoice__c in :InvoiceIds and c.Date_Processed__c = null];
		 
		CommissionPaymentCalculator.calculateCommissions(payments);
		update payments;
		
		// Return Invoices
		return PaidInvoices;
	}
}