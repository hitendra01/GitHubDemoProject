trigger Commission_Payment_Trigger on Commission_Payment__c (before insert) {
	CommissionPaymentCalculator.checkNewPaymentsAndCalculateCommissions(Trigger.New);
}