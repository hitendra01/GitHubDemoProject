global class Rcm1ActivitiesImporter implements Database.Batchable<ActivitiesRequest>, Database.AllowsCallouts, Database.Stateful, Schedulable {

    Integer index, total;
    
    Listing__c listing;
    
    Rcm1Api rcm1ApiObj = new Rcm1Api();
    
    String[] statuses = new String[]{};
    
    public Rcm1ActivitiesImporter(Integer index) {
        this.index = index;
        for(PicklistEntry picklistEntry : Marketing__c.Status__c.getDescribe().getPicklistValues()) {
            statuses.add(picklistEntry.getValue());
        }
    }
    
    public static void schedule(Integer index) {
        DateTime scheduleTime = DateTime.now().addSeconds(1);
        System.schedule('Activities Importer for index: ' + index, scheduleTime.format('s m H \'* * ?\''), new Rcm1ActivitiesImporter(index));
    }
    
    public static void process(Integer index) {
        Database.executeBatch(new Rcm1ActivitiesImporter(index), 1);
    }
    
    // Schedulable execute method
    global void execute(SchedulableContext ctx) {
        // disable the current job as it's meant to run only once
        System.abortJob(ctx.getTriggerID());
        
        Rcm1ActivitiesImporter.process(index);
    }

    global List<ActivitiesRequest> start(Database.BatchableContext ctx) {
        Listing__c[] listings = [
            select Id, rcm1id__c
            from Listing__c
            order by Id
        ];
        
        List<ActivitiesRequest> requests = new List<ActivitiesRequest>();

        total = listings.size();

        if(index < total) {
            listing = listings[index];
            
            System.debug('using listing: ' + listing);
        
            DateTime startDate = ConfigurationService.getActivitiesImportDate();
            if(startDate == null)
                startDate = DateTime.newInstance(2010, 1, 1);
            DateTime endDate = DateTime.Now();
            while(startDate < endDate) {
                ActivitiesRequest req = new ActivitiesRequest();
                req.startDate = startDate;
                req.endDate = startDate = startDate.addMonths(6);
                
                requests.add(req);
            }
        }
        
        return requests;
    }
    
    // batchable execute method
    global void execute(Database.BatchableContext ctx, List<ActivitiesRequest> requests) {
        Marketing__c[] activitiesToInsert = new Marketing__c[]{};
        Marketing__c[] activitiesToDelete = new Marketing__c[]{};
        
        Map<ID, Buyer__c> buyersToUpdate = new Map<ID, Buyer__c>();
    
        for(ActivitiesRequest req : requests) {
            System.debug('Requesting activities for: ' + listing.rcm1id__c + ', interval: ' + req.startDate + ', ' + req.endDate);
            
            activitiesToDelete.addAll([select Id from Marketing__c where Listing__c = :listing.Id and DateTime__c >= :req.startDate and DateTime__c <= :req.endDate]);

            Integer recOffset = 0;
            Integer recLimit = 100;
            Boolean finished = false;
            
            while(!finished) {
                HttpResponse resp = rcm1ApiObj.getActivities(listing.rcm1id__c, req.startDate, req.endDate, recOffset, recLimit);
                McLabsObjects.ActivityObject[] activities = ActivityAdapter.parseActivities(resp.getBody());
                
                createActivities(activities, activitiesToInsert, buyersToUpdate);
                
                if(activities.size() < 100)
                    finished = true;
                else
                    recOffset += recLimit;
            }
        }
        
        delete activitiesToDelete;
        insert activitiesToInsert;
        
        FutureCallsSemaphore.FutureCallAllowed = false;
        update buyersToUpdate.values();
    }
    
    global void finish(Database.BatchableContext ctx) {
        Boolean finished = true;
        if(listing != null) {
            if((index + 1) < total) {
                System.debug('scheduling new job for index: ' + (index + 1) );
                Rcm1ActivitiesImporter.schedule(index + 1);
                finished = false;
            }
        }
        if(finished) {
            ConfigurationService.setActivitiesImportDate(Date.today().addDays(-1));
            ConfigurationService.updateConfig();
        }
    }
 
    private void createActivities(McLabsObjects.ActivityObject[] activities, Marketing__c[] activitiesToInsert, Map<ID, Buyer__c> buyersToUpdate) {
        // prepare the list of emails to retrieve contacts
        Set<String> emails = new Set<String>();
        for(McLabsObjects.ActivityObject activity : activities) {
            emails.add(activity.email);
        }
        // retrieve the list of contact ids
        Map<String, ID> contactsMap = new Map<String, ID>();
        for(Contact contact : [select Id, Email from Contact where email in :emails]) {
            contactsMap.put(contact.email, contact.id);
        }
        
        Map<ID, Buyer__c> buyersMap = new Map<ID, Buyer__c>();
        for(Buyer__c buyer : [select Id, Status__c, Contact__c from Buyer__c where Contact__c = :contactsMap.values()]) {
            buyersMap.put(buyer.Contact__c, buyer);
        }
        
        // create the activities
        for(McLabsObjects.ActivityObject activity : activities) {
            ID contactId = contactsMap.get(activity.email);
            if(contactId != null) {
                Buyer__c buyer = buyersToUpdate.get(contactId);
                if(buyer == null)
                    buyer = buyersMap.get(contactId);
                
                Integer buyerStatusIndex = getStatusIndex(buyer.Status__c);
                Integer activityStatusIndex = getStatusIndex(activity.action);
                
                if(activityStatusIndex > buyerStatusIndex) {
                    buyer.Status__c = statuses[activityStatusIndex];
                    buyersToUpdate.put(contactId, buyer);
                }
            
                activitiesToInsert.add(new Marketing__c(
                    Contact__c = contactId,
                    Listing__c = listing.Id,
                    DateTime__c = activity.actDate,
                    Status__c = getStatus(activity.action)
                ));
            }
        }
    }
    
    private String getStatus(String value) {
        Integer index = getStatusIndex(value);
        return index >= 0 ? statuses[index] : '';
    }
    
    private Integer getStatusIndex(String value) {
        if(value != null) {
            for(Integer i = 0; i < statuses.size(); i++) {
                if(value.contains(statuses[i])) {
                    return i;
                }
            }
        }
        return -1;
    }
 
    global class ActivitiesRequest {
        public DateTime startDate;
        public DateTime endDate;
    }

}