/**
 * This class is responsible for all communication with the Schoology API.
 * Because this class is responsible for callouts and callouts cannot be
 * made in Apex test methods, as much of the setup logic should be done
 * externally to this class to maintain testability. We can test the classes
 * called from this class independently and then we don't need to worry about
 * writing coverage for this class. All callouts should be protected from 
 * executing in test methods, however, as this class will be called by other
 * classes that we will need to write coverage for. If we keep any code that's
 * not strictly dependant on the callout outside the Test check, we should
 * at least get some coverage on this class from other classes/triggers
 * calling it.
 * 
 * @author Josh Russell (Riptide Software, Inc.)
 * @auther Alex Acosta  (Riptide Software, Inc.)
 */
//public virtual class Rcm1Api {
global virtual class Rcm1Api {
      
    private static final String HOST = ConfigurationService.getHost();

    /**
     * Http callout to Schoology.
     * @param String contentType - The content-type excepted within the response
     * @param String endpoint - URL endpoint that comes after the inital https callout
     *                          ie: 'role/<id>'
     */
    private static HttpResponse httpGetCallout(final String endpoint){
        
        HttpResponse response = new HttpResponse();
        
        // Get an HttpRequest to use in this update
        HttpRequest httpRequest = HTTPRequestFactory.newGetRequest(HOST + endpoint, null);
                                                 
        Http http = new Http();
        
        if(!Test.isRunningTest()){
            httpRequest.setTimeout(60000); // one minute
            response = http.send(httpRequest);
        }
        return response;
    }
    
    /**
     * Http callout to Schoology.
     * @param String contentType - The content-type excepted within the response
     * @param String endpoint - URL endpoint that comes after the inital https callout
     *                          ie: 'role/<id>'
     */
    private static HttpResponse httpPostCallout(final String endpoint, final String body){
        
        HttpResponse response = new HttpResponse();
        
        // Get an HttpRequest to use in this update
        HttpRequest httpRequest = HTTPRequestFactory.newPostRequest(HOST + endpoint, null, body);     
        Http http = new Http();
        
        system.debug('endpoint: ' + HOST + endpoint);
        system.debug('api key: ' + ConfigurationService.getApiKey());
        
        if(!Test.isRunningTest()){
            httpRequest.setTimeout(60000); // one minute
            response = http.send(httpRequest);
        }
        
        return response;
    }
    
    public virtual HttpResponse getListings(){
        final String endpoint = '/project.svc';
        
        String request = '';
        request += '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">';
            request += '<s:Header>';
                request += '<a:Action s:mustUnderstand="1">http://tempuri.org/IDataExchangeProject/RetrieveProjectList</a:Action>';
                request += '<a:MessageID>urn:uuid:ddfe866f-2a93-4fc4-9a80-a923d5842415</a:MessageID>';
                request += '<a:ReplyTo>';
                    request += '<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>';
                request += '</a:ReplyTo>';
                request += '<a:To s:mustUnderstand="1">' + HOST + endpoint + '</a:To>';
            request += '</s:Header>';
            request += '<s:Body>';
                request += '<RetrieveProjectList xmlns="http://tempuri.org/">';
                    request += '<key>' + ConfigurationService.getApiKey() + '</key>';
                request += '</RetrieveProjectList>';
            request += '</s:Body>';
        request += '</s:Envelope>';
        
        system.debug('getListings request: ' + request);
        
        HttpResponse response = httpPostCallout(endpoint, request);

        system.debug('getListings response: ' + response.getBody());

        return response;
    }
    
    public virtual HttpResponse getListing(String rcm1Id) {
        final String endpoint = '/project.svc';
        
        String body = '';
        body = '<RetrieveProject xmlns="http://tempuri.org/">';
            body += '<key>' + ConfigurationService.getApiKey() + '</key>';
            body += '<clientId>' + rcm1Id + '</clientId>';
        body += '</RetrieveProject>';
        
        String request = prepareRequest(endpoint, 'http://tempuri.org/IDataExchangeProject/RetrieveProject', body);
        
        system.debug('getListing request: ' + request);
        
        HttpResponse response = HttpPostCallout(endpoint, request);
        
        system.debug('getListing response: ' + response.getBody());
        
        return response;
    }
    
    public virtual HttpResponse getUsers(){
        final String endpoint = '/user.svc';
        
        String body = '';
        body += '<RetrieveUsers xmlns="http://tempuri.org/">';
            body += '<key>' + ConfigurationService.getApiKey() + '</key>';
        body += '</RetrieveUsers>';

        String request = prepareRequest(endpoint, 'http://tempuri.org/IDataExchangeUser/RetrieveUsers', body);
        
        HttpResponse response = httpPostCallout(endpoint, request);

        return response;
    }
    
    public virtual HttpResponse getBuyers(String listingId) {
        return getBuyers(listingId, 0, 100);
    }
    
    public virtual HttpResponse getBuyers(String listingId, Integer recordsOffset, Integer recordsLimit) {
        String endpoint = '/buyer.svc';
        
        String body = '';
        body = '<RetrieveBuyers xmlns="http://tempuri.org/">';
            body += '<key>' + ConfigurationService.getApiKey() + '</key>';
            body += '<clientId>' + listingId + '</clientId>';
            body += '<start>' + recordsOffset + '</start>';
            body += '<count>' + recordsLimit + '</count>';
        body += '</RetrieveBuyers>';
        
        String request = prepareRequest(endpoint, 'http://tempuri.org/IDataExchangeBuyer/RetrieveBuyers', body);
        
        system.debug('getBuyers request: ' + request);
        
        HttpResponse response = httpPostCallout(endpoint, request);
        
        system.debug('getBuyers response: ' + response.getBody());
        
        return response;
    }
    
    public virtual HttpResponse getActivities(String listingId, DateTime startDate, DateTime endDate) {
        return getActivities(listingId, startDate, endDate, 0, 1000);
    }
    
    public virtual HttpResponse getActivities(String listingId, DateTime startDate, DateTime endDate, Integer recordsOffset, Integer recordsLimit) {
        String endpoint = '/buyer.svc';
        
        String body = '';
        body = '<RetrieveBuyersActivity xmlns="http://tempuri.org/">';
            body += '<key>' + ConfigurationService.getApiKey() + '</key>';
            body += '<clientId>' + listingId + '</clientId>';
            body += '<begin>' + startDate.format('yyyy-MM-dd\'T\'HH:mm:ss') + '</begin>';
            body += '<end>' + endDate.format('yyyy-MM-dd\'T\'HH:mm:ss') + '</end>';
//            body += '<end>' + Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + '</end>';
            body += '<start>' + recordsOffset + '</start>';
            body += '<count>' + recordsLimit + '</count>';
        body += '</RetrieveBuyersActivity>';
        
        String request = prepareRequest(endpoint, 'http://tempuri.org/IDataExchangeBuyer/RetrieveBuyersActivity', body);
        
        system.debug('getActivities request: ' + request);
        
        HttpResponse response = httpPostCallout(endpoint, request);
        
        system.debug('getActivities response: ' + response.getBody());
        
        return response;
    }
    
    public static void sendProperty(String id) {
        if(!FutureCallsSemaphore.futureCallAllowed)
            return;
    
        Property__c[] properties = [
            select Id, (select Id from Listings__r)
            from Property__c
            where Id = :id
            limit 1
        ];
        
        if(!properties.isEmpty()) {
            for(Listing__c listing : properties[0].Listings__r) {
                sendListing(listing.id);
            }
        }
    }
    
   @future(callout=true)
   public static void sendListing(String id){
      FutureCallsSemaphore.futureCallAllowed = false;
      sendListingFromJavascript(id);
   }
   
   
   
   // WebService public static void sendListing(String id){
    WebService static string sendListingFromJavascript(String id){
  
  
        Boolean needUpdate = false;
  
    
        Listing__c listing = [select Id, Name, Status__c, Asking_Price__c, Offering_Notes__c, Rcm1id__c, Loan_Type__c, Loan_Performance__c, Interest_Rate__c
                              , Asking_Price_Actual__c, Project_Type__c
                              , Property__r.Property_Address__c, Property__r.City__c, Property__r.State__c, Property__r.Zip_Code__c, Property__r.County__c, Property__r.Country__c
                              , Property__r.RecordType.Name, Property__r.Primary_Use__c, Property__r.Year_Built__c, Property__r.Square_Footage__c, Property__r.Land_Acres__c
                              , Property__r.Occupancy__c, Property__r.Class__c, Property__r.Unit_Type__c, Property__r.Units__c, Property__r.Rooms__c, Property__r.Parking_Spaces__c
                              , (select User__r.Firstname, User__r.Lastname, User__r.Email from Brokers1__r)
                              from Listing__c
                              where Id = :id];

//Keith - sanity checking.....

       List<String> rcm_legal_asset_type_array = new List<String>();
       rcm_legal_asset_type_array.add('Multi-family - Garden Apartments');
       rcm_legal_asset_type_array.add('Multi-family - High Rise Apartments');
       rcm_legal_asset_type_array.add('Multi-family - Affordable / Low Income Housing / Bond');
       rcm_legal_asset_type_array.add('Multi-family - Senior / Assisted Living');
       rcm_legal_asset_type_array.add('Multi-family - Student Housing');
       rcm_legal_asset_type_array.add('Multi-family - Mobile / Manufactured Housing');
       rcm_legal_asset_type_array.add('Multi-family - Condo Conversion');
       rcm_legal_asset_type_array.add('Multi-family - Mid-Rise');
       rcm_legal_asset_type_array.add('Office - Low / Mid Rise');
       rcm_legal_asset_type_array.add('Office - High Rise');
       rcm_legal_asset_type_array.add('Office - Office Park');
       rcm_legal_asset_type_array.add('Office - Single Tenant');
       rcm_legal_asset_type_array.add('Office - Unique & Mixed Use Office');
       rcm_legal_asset_type_array.add('Office - BioTech / Life Sciences');
       rcm_legal_asset_type_array.add('Office - Data Center');
       rcm_legal_asset_type_array.add('Office - Government Leased');
       rcm_legal_asset_type_array.add('Industrial - Industrial Single Tenant');
       rcm_legal_asset_type_array.add('Industrial - Warehouse / Distribution');
       rcm_legal_asset_type_array.add('Industrial - Industrial Park');
       rcm_legal_asset_type_array.add('Industrial - Manufacturing');
       rcm_legal_asset_type_array.add('Industrial - R & D');
       rcm_legal_asset_type_array.add('Industrial - Self Storage');
       rcm_legal_asset_type_array.add('Industrial - Parking');
       rcm_legal_asset_type_array.add('Industrial - Flex');
       rcm_legal_asset_type_array.add('Retail - NNN / Free Standing Retail');
       rcm_legal_asset_type_array.add('Retail - Strip / Convenience Center');
       rcm_legal_asset_type_array.add('Retail - Shopping Center');
       rcm_legal_asset_type_array.add('Retail - Power Center');
       rcm_legal_asset_type_array.add('Retail - Mall');
       rcm_legal_asset_type_array.add('Retail - Outlet / Specialty Center');
       rcm_legal_asset_type_array.add('Hospitality - Motel');
       rcm_legal_asset_type_array.add('Hospitality - Hotel');
       rcm_legal_asset_type_array.add('Hospitality - Resort');
       rcm_legal_asset_type_array.add('Land - Single Family Residential');
       rcm_legal_asset_type_array.add('Land - Multi-family');
       rcm_legal_asset_type_array.add('Land - Office');
       rcm_legal_asset_type_array.add('Land - Retail');
       rcm_legal_asset_type_array.add('Land - Industrial');
       rcm_legal_asset_type_array.add('Land - Mixed Use');
       rcm_legal_asset_type_array.add('Land - Master Planned');
       rcm_legal_asset_type_array.add('Land - Hospitality');
       rcm_legal_asset_type_array.add('Land - Golf Course');
       rcm_legal_asset_type_array.add('Healthcare - Assisted Living');
       rcm_legal_asset_type_array.add('Healthcare - Hospital');
       rcm_legal_asset_type_array.add('Healthcare - Office');
       rcm_legal_asset_type_array.add('Specialty - Bank Branch');
       rcm_legal_asset_type_array.add('Specialty - Car Dealership');
       rcm_legal_asset_type_array.add('Specialty - Casino');
       rcm_legal_asset_type_array.add('Specialty - Church');
       rcm_legal_asset_type_array.add('Specialty - Country Club / Golf Course');
       rcm_legal_asset_type_array.add('Specialty - Gas Station');
       rcm_legal_asset_type_array.add('Specialty - Marina');
       rcm_legal_asset_type_array.add('Specialty - Movie Theater');
       rcm_legal_asset_type_array.add('Specialty - School');
       rcm_legal_asset_type_array.add('Specialty - Sports Complex');
       rcm_legal_asset_type_array.add('Single-family - Home Portfolio (5+)');
       rcm_legal_asset_type_array.add('Single-family - Home (1-4)');
       rcm_legal_asset_type_array.add('Single-family - Condo (1-4)');
       rcm_legal_asset_type_array.add('Single-family - Other');
       rcm_legal_asset_type_array.add('REO Portfolio');              

        String test_this_string = listing.Property__r.RecordType.Name + ' - ' + listing.Property__r.Primary_Use__c;
        
        system.debug('test_this_string: ' + test_this_string);
        system.debug('the name is ' + listing.Name);
        
        Boolean matched = false;
        for( String test_against : rcm_legal_asset_type_array)
        {
            if(test_this_string == test_against)
            {
                system.debug('matched on the string ' + test_this_string + ' and ' + test_against);
                matched = true;          
            }        
        }
        if(matched == false)
        {
            return 'The RecordType PrimaryUse combination of the property associated with this listing,\n\n   ' + test_this_string + '\n\n  is not supported by RCM1';
        }
        
                              
        if(listing.Rcm1id__c == null || listing.Rcm1id__c == '') {
            listing.Rcm1id__c = listing.id;
            needUpdate = true;
        }
                              
        ListingAdapter adapter = new ListingAdapter();
                              
        final String endpoint = '/project.svc';
        
        String body = '';
        body += '<SyncProject xmlns="http://tempuri.org/">';
            body += '<key>' + ConfigurationService.getApiKey() + '</key>';
            body += adapter.generateXML(listing);
        body += '</SyncProject>';
        
        String request = prepareRequest(endpoint, 'http://tempuri.org/IDataExchangeProject/SyncProject', body);
        
        system.debug('sendListing request: ' + request);
                              
        HttpResponse response = httpPostCallout(endpoint, request);
        
        system.debug('sendListing response: ' + response.getBody());
        
        if(response.getBody().contains('<Error>true</Error>')) 
        {
            return 'Your attempt to create/synchronize this RCM1 project was unsuccessful';
        }
        
        if(needUpdate)
            update listing;
            
        return '';    
    }
    
    @future(callout=true)
    public static void sendBuyer(String listingId, String contactId) {
            sendBuyerFromJavascript(listingId,contactId);
    }    
    
    WebService static string sendBuyerFromJavascript(String listingId, String contactId) {
        system.debug('in sendBuyer');
        String queryString = ' select Contact__r.Firstname, Contact__r.Lastname, Contact__r.Email, Contact__r.Industry_Role__c ' +
                             ' , Contact__r.Company__c, Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState ' +
                             ' , Contact__r.MailingPostalCode, Contact__r.MailingCountry, Contact__r.Phone, Contact__r.Phone_Extension__c ' +
                             ' , Contact__r.Fax, Contact__r.MobilePhone ' +
                             ' , Listing__r.Rcm1id__c ' +
                             ' from Buyer__c ' +
                             ' where Contact__c = \'' + contactId + '\'' +
                             (listingId != null ? ' and Listing__c = \'' + listingId + '\'' : '') +
                             ' limit 1';
        Buyer__c[] buyers = Database.query(queryString);
        
        if(buyers.isEmpty()) {
            system.debug('Could not send updated buyer: buyer not found (' + listingId + ', ' + contactId + ')');
            return 'Could not send updated buyer: buyer not found';
        }
        
        if(buyers[0].Contact__r.Industry_Role__c == null || buyers[0].Contact__r.Industry_Role__c == '')
        {
            return 'You must define an Industry Role for this buyer\'s contact';
        }
        
        Contact contact = buyers[0].Contact__r;
        Listing__c listing = buyers[0].Listing__r;
        
        if(listing == null) {
            system.debug('Buyer is not associated with any Listing');
            return 'The buyer is not associated with any Listing';
        }
    
        BuyerAdapter adapter = new BuyerAdapter();
    
        final String endpoint = '/buyer.svc';
        
        String body = '';
        body += '<SyncBuyer xmlns="http://tempuri.org/">';
            body += '<key>' + ConfigurationService.getApiKey() + '</key>';
            body += '<clientId>' + listing.Rcm1id__c + '</clientId>';
            body += adapter.generateXML(listing, contact);
        body += '</SyncBuyer>';
                
        String request = prepareRequest(endpoint, 'http://tempuri.org/IDataExchangeBuyer/SyncBuyer', body);
        
        system.debug('send buyer request: ' + request);
                              
        HttpResponse response = httpPostCallout(endpoint, request);
        
        system.debug('send buyer response: ' + response.getBody());
        string theBody = response.getBody();
        if(theBody.contains('<b:Error>true</b:Error>'))
        {
            //return 'Your attempt to create/synchronize this buyer was unsuccessful:\n\n';
            integer message_start = theBody.indexOf('<b:Message>');
            integer message_stop = theBody.indexOf('</b:Message>'); 
            string the_message = theBody.substring(message_start,message_stop);
            system.debug(the_message );
            the_message = the_message.replaceAll('<b:Message>','');
            system.debug(the_message );
            return 'Your attempt to create/synchronize this buyer was unsuccessful:\n\n' + the_message;
        }
        return '';
    }
    
    private static String prepareRequest(String endpoint, String action, String body) {
        String request = '';
        request += '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">';
            request += '<s:Header>';
                request += '<a:Action s:mustUnderstand="1">' + action + '</a:Action>';
                request += '<a:MessageID>urn:uuid:6c6791a3-e0d5-4c56-a962-ab2bf362e11c</a:MessageID>';
                request += '<a:ReplyTo>';
                    request += '<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>';
                request += '</a:ReplyTo>';
                request += '<a:To s:mustUnderstand="1">' + HOST + endpoint + '</a:To>';
            request += '</s:Header>';
            request += '<s:Body>';
                request += body;
            request += '</s:Body>';
            /*
                request += '<CreateProject xmlns="http://tempuri.org/">';
                    request += '<key>' + ConfigurationService.getApiKey() + '</key>';
                    request += adapter.generateXML(listing);
                request += '</CreateProject>';
            request += '</s:Body>';
            */
        request += '</s:Envelope>';
        
        return request;
    }
    /*
    private static OAuthHeader createOAuthHeader(){
        return new OAuthHeader('test','test');  
    }
    */
}