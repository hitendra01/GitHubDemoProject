trigger Contact_Trigger on Contact (after insert, after update) {

    if(FutureCallsSemaphore.futureCallAllowed) {
        for(Contact contact : trigger.new) {
            if(contact.Rcm1_Sync__c)
                rcm1Api.sendBuyer(null, contact.id);
        }
    }

}