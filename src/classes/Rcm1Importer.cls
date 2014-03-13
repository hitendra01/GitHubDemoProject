global class Rcm1Importer implements Database.Batchable<String>, Database.AllowsCallouts {

    private Rcm1Api rcm1ApiObj;

    public Rcm1Importer() {
        rcm1ApiObj = new Rcm1Api();
    }
    
    public Rcm1Importer(Rcm1Api rcm1ApiObj) {
        this.rcm1ApiObj = rcm1ApiObj;
    }
    
    global List<String> start(Database.BatchableContext ctx) {
        HttpResponse response = rcm1ApiObj.getListings();
        
        Dom.Document xmlDoc = new Dom.Document();
        xmlDoc.Load(response.getBody());
        Dom.XmlNode root = xmlDoc.getRootElement();
        
        Dom.XmlNode[] nodes = getElementsByTagName(root, 'ClientId');
        
        String[] rcm1ids = new String[]{};
        
        for(Dom.XmlNode node : nodes) {
            rcm1ids.add(node.getText());
        }
        
        system.debug('listings to import: ' + rcm1ids);
        
        return rcm1ids;
    }
    
    global void execute(Database.BatchableContext ctx, List<String> listingIds) {
        FutureCallsSemaphore.futureCallAllowed = false;
    
        system.debug('importing listings: ' + listingIds);
    
        Map<String, Account>     accountsToUpdate   = new Map<String, Account>();
        Map<String, Contact>     contactsToUpdate   = new Map<String, Contact>();
        
        Listing__c[]  listingsToUpdate   = new Listing__c[]{};
        Property__c[] propertiesToUpdate = new Property__c[]{};
        Broker__c[]   brokersToInsert    = new Broker__c[]{};
        Buyer__c[]    buyersToInsert     = new Buyer__c[]{};
        
        Broker__c[]   brokersToDelete    = new Broker__c[]{};
        Buyer__c[]    buyersToDelete     = new Buyer__c[]{};
        
        Map<String, Listing__c> existingListings = new Map<String, Listing__c>();
        for(Listing__c listing : [select Id, Rcm1id__c, Name, Status__c, Asking_Price__c, Offering_Notes__c, Loan_Type__c, Loan_Performance__c, Interest_Rate__c, Project_Type__c
                                  , Property__r.Id
                                  , Property__r.Property_Address__c, Property__r.City__c, Property__r.State__c, Property__r.Zip_Code__c, Property__r.County__c, Property__r.Country__c
                                  , Property__r.RecordType.Name, Property__r.Primary_Use__c, Property__r.Year_Built__c, Property__r.Square_Footage__c, Property__r.Land_Acres__c
                                  , Property__r.Occupancy__c, Property__r.Class__c, Property__r.Unit_Type__c, Property__r.Units__c, Property__r.Rooms__c, Property__r.Parking_Spaces__c
                                  , (select Id, User__r.Username, User__r.Email from Brokers1__r)
                                  , (select Id from Buyers__r)
                                  from Listing__c
                                  where rcm1id__c in :listingIds])
        {
            existingListings.put(listing.Rcm1id__c, listing);
            
            brokersToDelete.addAll(listing.Brokers1__r);
            buyersToDelete.addAll(listing.Buyers__r);
        }
        
        ListingAdapter listingAdapter = new ListingAdapter();
        BuyerAdapter buyerAdapter = new BuyerAdapter();
        
        McLabsObjects.ListingObject[] listings = new McLabsObjects.ListingObject[]{};
        Map<String, McLabsObjects.BuyerObject[]> buyersMap = new Map<String, McLabsObjects.BuyerObject[]>();

        // get the data from rcm1 (listing, buyers)
        for(String rcm1id : listingIds) {
            // retrieve listing
            HttpResponse response = rcm1ApiObj.getListing(rcm1id);
            listings.addAll(listingAdapter.parseListings(response.getBody()));
            
            // retrieve buyers
            
            McLabsObjects.BuyerObject[] buyers = buyersMap.get(rcm1id);
            if(buyers == null) {
                buyersMap.put(rcm1id, buyers = new McLabsObjects.BuyerObject[]{});
            }
            
            response = rcm1ApiObj.getBuyers(rcm1id);
            buyers.addAll(buyerAdapter.parseBuyers(response.getBody()));
            
            system.debug('got (' + buyers.size() + ') buyers for listing ' + rcm1id);
        }
        
        // retrieve the list of users that should be used as brokers
        Map<String, User> users = new Map<String, User>();
        retrieveBrokers(listings, users);
        
        // retrieve the list of contacts that should be used as buyers
        Map<String, Contact> contacts = new Map<String, Contact>();
        // retrieve the list of accounts
        Map<String, Account> accounts = new Map<String, Account>();
        
        retrieveBuyers(buyersMap, contacts, accounts);
        
        // process the actual listing data
        for(McLabsObjects.ListingObject listing : listings) {
            // create/update the listing
            Listing__c sfListing = updateListing(existingListings.get(listing.rcm1id), listing);
            listingsToUpdate.add(sfListing);

            // create/upate the property associated with the listing
            sfListing.Property__r = updateProperty(sfListing.Property__r, listing.property);
            propertiesToUpdate.add(sfListing.Property__r);
            
            // create the brokers
            for(McLabsObjects.BrokerObject broker : listing.brokers) {
                User user = users.get(broker.email);
                if(user != null) {
                    brokersToInsert.add(new Broker__c(
                        Listing__r = sfListing,
                        User__c = user.Id
                    ));
                }
            }

            // create/update the buyers
            for(McLabsObjects.BuyerObject buyer : buyersMap.get(listing.rcm1id)) {
                if(buyer.email != null && buyer.email != '') {
                    Account account = updateAccount(accounts.get(buyer.company), buyer);
                    Contact contact = updateContact(contacts.get(buyer.email), buyer);
                    
                    if(account != null) {
                        contact.Account = account;
                        
                        accounts.put(account.Name, account);
                        accountsToUpdate.put(account.Name, account);
                    }
                    
                    contacts.put(contact.Email, contact);
                    contactsToUpdate.put(contact.Email, contact);
                    
                    buyersToInsert.add(new Buyer__c(
                        Listing__r = sfListing,
                        Contact__r = contact
                    ));
                }
            }
        }
        
        // delete existing link between listings and brokers (users)
        // the link will later be reconstructed
        delete brokersToDelete;
        
        // delete existing link between listings and buyers (contacts)
        // the link will later be reconstructed
        delete buyersToDelete;
    
        // insert/update data
        
        system.debug('properties to update: ' + propertiesToUpdate);
        upsert propertiesToUpdate;
    
        // set the listing->property association
        for(Listing__c listing : listingsToUpdate) {
            listing.Property__c = listing.Property__r.Id;
        }
        system.debug('listings to update: ' + listingsToUpdate);
        upsert listingsToUpdate;
        
        system.debug('accounts to update: ' + accountsToUpdate);
        upsert accountsToUpdate.values();
        // update the contact->account relationship
        for(Contact contact : contactsToUpdate.values()) {
            if(contact.Account != null)
                contact.AccountId = contact.Account.Id;
        }
        
        system.debug('contacts to update: ' + contactsToUpdate);
        upsert contactsToUpdate.values();
        // update the buyers relationships
        for(Buyer__c buyer : buyersToInsert) {
            buyer.Listing__c = buyer.Listing__r.Id;
            buyer.Contact__c = buyer.Contact__r.Id;
        }
        
        system.debug('buyers to insert: ' + buyersToInsert);
        insert buyersToInsert;
        // update the brokers relationsips
        for(Broker__c broker : brokersToInsert) {
            broker.Listing__c = broker.Listing__r.Id;
        }
        
        system.debug('brokers to insert: ' + brokersToInsert);
        
        insert brokersToInsert;
    }
    
    global void finish(Database.BatchableContext ctx) {
        Rcm1ActivitiesImporter.schedule(0);
    }
    
    private void retrieveBrokers(McLabsObjects.ListingObject[] listings, Map<String, User> users) {
        // prepare the list of emails to query users
        String[] brokerEmails = new String[]{};
        for(McLabsObjects.ListingObject listing : listings) {
            for(McLabsObjects.BrokerObject broker : listing.brokers) {
                broker.email = broker.email.toLowerCase();
                brokerEmails.add(broker.email);
            }
        }
        
        // retrieve the list of users that should be used as brokers
        for(User user : [select Id, Username, Email
                         from User
                         where Email in :brokerEmails])
        {
            users.put(user.Email.toLowerCase(), user);
        }
    }
    
    private void retrieveBuyers(Map<String, McLabsObjects.BuyerObject[]> buyersMap, Map<String, Contact> contacts, Map<String, Account> accounts) {
        // prepare the list of emails to query contacts
        String[] contactEmails = new String[]{};
        // prepare the list of names to query accounts
        String[] accountNames = new String[]{};
        for(McLabsObjects.BuyerObject[] buyers : buyersMap.values())
            for(McLabsObjects.BuyerObject buyer : buyers) {
                buyer.email = buyer.email.toLowerCase();
                contactEmails.add(buyer.email);
                accountNames.add(buyer.company);
            }
        
        system.debug('reusing contact emails: (' + contactEmails.size() + ') ' + contactEmails);

        // retrieve the list of contacts that should be used as buyers
        for(Contact contact : [select Firstname, Lastname, Email, Industry_Role__c, Company__c
                               , MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                               , Phone, Fax, Phone_Extension__c
                               from Contact
                               where Email in :contactEmails])
        {
            contacts.put(contact.Email.toLowerCase(), contact);
        }
        
        // retrieve the list of accounts
        for(Account account : [select Id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode
                               from Account
                               where Name in :accountNames])
        {
            accounts.put(account.Name, account);
        }
        
        system.debug('reusing contacts: (' + contacts.size() + ') ' + contacts.keyset());
    }
    
    private Listing__c updateListing(Listing__c target, McLabsObjects.ListingObject source) {
        system.debug('copying listing data: ' + source);
    
        if(target == null)
            target = new Listing__c(
                OwnerId = Userinfo.getUserId()
            );
        
        target.Name                   = source.name;
        target.rcm1id__c              = source.rcm1id;
        target.Status__c              = source.status;
        target.Asking_Price_Actual__c = source.askingPrice;
        target.Offering_Notes__c      = source.notes;
        target.Loan_Type__c           = source.loanType;
        target.Loan_Performance__c    = source.loanPerformance;
        //target.Interest_Rate__c       = source.interestRate;//Commented Due to mismatch type [Shrew Designs, 1/10/13]
        target.Project_Type__c        = source.projectType;
        
        return target;
    }
    
    private Property__c updateProperty(Property__c target, McLabsObjects.PropertyObject source) {
        if(target == null)
            target = new Property__c();
        
        target.Property_Address__c = source.streetAddress;
        target.City__c             = source.city;
        target.County__c           = source.county;
        target.State__c            = source.state;
        target.Zip_Code__c         = source.zipCode;
        target.Country__c          = source.country;
        target.Year_Built__c       = source.yearBuilt;
        target.Square_Footage__c   = source.squareFootage;
        target.Land_Acres__c       = source.landAcres;
        target.Occupancy__c        = source.occupancy;
        target.Class__c            = source.clazz;
		if(source.recordTypeId != null){//Added Due to test class Error [Shrew Designs, 1/10/13]
        	target.RecordTypeId        = source.recordTypeId;
		}	
        target.Primary_Use__c      = source.primaryUse;

        target.Units__c            = source.units;
        target.Unit_Type__c        = source.unitType;
        target.Rooms__c            = source.rooms;
        target.Parking_Spaces__c   = source.parkingSpaces;
        
        return target;
    }
    
    private Account updateAccount(Account target, McLabsObjects.BuyerObject source) {
        if(source.company == null || source.company.trim() == '')
            return null;
    
        if(target == null)
            target = new Account();

        target.Name                = source.company;
        /*
        target.ShippingStreet      = source.streetAddress;
        target.ShippingCity        = source.city;
        target.ShippingState       = source.state;
        target.ShippingPostalCode  = source.zipCode;
        target.ShippingCountry     = source.country;
        */
        
        return target;
    }
    
    private Contact updateContact(Contact target, McLabsObjects.BuyerObject source) {
        if(target == null)
            target = new Contact();
            
        target.Firstname          = source.firstname;
        target.Lastname           = source.lastname;
        target.Email              = source.email;
        target.Industry_Role__c   = source.industryRole;
        target.Phone              = source.phone;
        target.Phone_Extension__c = source.extension;
        target.Fax                = source.fax;
        target.MobilePhone        = source.mobile;
        target.Company__c         = source.company;
        target.Rcm1_Sync__c       = true;
        
        //target.Company__c         = source.company;
        target.MailingStreet      = source.streetAddress;
        target.MailingCity        = source.city;
        target.MailingState       = source.state;
        target.MailingPostalCode  = source.zipCode;
        target.MailingCountry     = source.country;
        
        return target;
        
    }
    
    private static Dom.XmlNode[] getElementsByTagName(Dom.XmlNode node, String tagName) {
        Dom.XmlNode[] nodes = new Dom.XmlNode[] {};
        getElementsByTagName(node, tagName, nodes);
        return nodes;
    }
    
    private static void getElementsByTagName(Dom.XmlNode node, String tagName, Dom.XmlNode[] nodes) {
        if(node.getName() == tagName) {
            nodes.Add(node);
            return;
        }
        for(Dom.XmlNode child : node.getChildElements()) {
            getElementsByTagName(child, tagName, nodes);
        }
    }
    
}