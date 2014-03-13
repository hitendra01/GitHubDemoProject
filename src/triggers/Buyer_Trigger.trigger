trigger Buyer_Trigger on Buyer__c (after insert, after update) {

    if(trigger.isAfter && FutureCallsSemaphore.futureCallAllowed) {
        for(Buyer__c buyer : trigger.new) {
            rcm1Api.sendBuyer(buyer.Listing__c, buyer.Contact__c);
        }
    }

}