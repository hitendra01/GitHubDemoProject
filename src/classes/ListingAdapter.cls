public with sharing class ListingAdapter {

    private final String S_NAMESPACE = McLabsConstants.RCM1_S_NAMESPACE;
    private final String B_NAMESPACE = McLabsConstants.RCM1_B_NAMESPACE;
    private final String DIFFGR_NAMESPACE = McLabsConstants.RCM1_DIFFGR_NAMESPACE;
    

    private static final Map<String, String> CONTENT_TYPES = new Map<String, String>{
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'gif'  => 'image/gif',
        'tiff' => 'image/tiff',
        
        'pdf'  => 'application/pdf',
        'txt'  => 'text/plain',
        'html' => 'text/html',
        'doc'  => 'application/msword',
        'docx' => 'application/msword2007',
        'xls'  => 'application/msexcel',
        'xlsx' => 'application/msexcel2007',
        'zip'  => 'compressed/zip',
        'rar'  => 'compressed/rar'
    };
    /*
        FILE_EXT_MAP.put("image/png", "png");
        FILE_EXT_MAP.put("image/jpeg", "jpg");
        FILE_EXT_MAP.put("image/jpeg", "jpeg");
        FILE_EXT_MAP.put("image/pjpeg", "jpg");
        FILE_EXT_MAP.put("image/gif", "gif");
        FILE_EXT_MAP.put("image/tiff", "tiff");
        FILE_EXT_MAP.put("application/pdf", "pdf");
        FILE_EXT_MAP.put("video/mpeg", "mpeg");
        FILE_EXT_MAP.put("video/mp4", "mp4");
        FILE_EXT_MAP.put("video/quicktime", "mov");
        FILE_EXT_MAP.put("video/x-ms-wmv", "wmv");
        FILE_EXT_MAP.put("text/html", "html");
        FILE_EXT_MAP.put("text/plain", "txt");
        FILE_EXT_MAP.put("text/xml", "xml");
        FILE_EXT_MAP.put("text/csv", "csv");
        FILE_EXT_MAP.put("application/msword", "doc");
        FILE_EXT_MAP.put("application/msword2007+", "docx");
        FILE_EXT_MAP.put("application/msexcell", "xls");
        FILE_EXT_MAP.put("application/msexcell2007+", "xlsx");
        FILE_EXT_MAP.put("audio/mpeg", "mp3");
        FILE_EXT_MAP.put("video/octet-stream", "flv");
        FILE_EXT_MAP.put("compressed/zip", "zip");
        FILE_EXT_MAP.put("compressed/rar", "rar");
    */

    public ListingAdapter(){
    }

    public String generateXML(Listing__c listing){
        XmlStreamWriter xmlWriter = new XmlStreamWriter();
        Property__c property;
        if(listing.Property__r == null) property = new Property__c();
        else property = listing.Property__r;
        
        // <project>
        xmlWriter.writeStartElement('', 'project', '');
        xmlWriter.writeAttribute('xmlns', '', 'b', McLabsConstants.RCM1_B_NAMESPACE);
        xmlWriter.writeAttribute('xmlns', '', 'i', McLabsConstants.RCM1_I_NAMESPACE);

            // <Address></Address>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Address', '', property.Property_Address__c);

            // <AssetType></AssetType>
            String assetType = property.RecordType.Name;
            if(property.Primary_Use__c != null)
                assetType += ' - ' + property.Primary_Use__c;
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'AssetType', '', assetType);
            
            if(property.Unit_Type__c == 'Bedrooms')
                // <Bedrooms></Bedrooms>
                xmlHelper.writeGenericNode(xmlWriter, 'b', property.Unit_Type__c, '', String.valueOf(property.Units__c));

            if(property.Unit_Type__c == 'Beds')
                // <Beds></Beds>
                xmlHelper.writeGenericNode(xmlWriter, 'b', property.Unit_Type__c, '', String.valueOf(property.Units__c));

            // <City></City>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'City', '', property.City__c);
            // <Class></Class>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Class', '', property.Class__c);
            // <ClientId></ClientId>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'ClientId', '', listing.rcm1id__c);

            // <Contacts>
            xmlWriter.writeStartElement('b', 'Contacts', '');
            xmlWriter.writeAttribute('xmlns', '', 'c', McLabsConstants.RCM1_ARRAY_NAMESPACE);
                Integer i = 1;
                for(Broker__c broker : listing.Brokers1__r) {
                    XMLHelper.writeGenericNode(xmlWriter, 'c', 'string', '', broker.User__r.Email);
                }
            // </Contacts>
            xmlWriter.writeEndElement();
    
            // <Country></Country>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Country', '', property.Country__c);
            // <County></County>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'County', '', property.County__c);
            // <LoanInterest></LoanInterest>          
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'LoanInterest', '', String.valueOf(listing.Interest_Rate__c));
            // <LoanPerformance></LoanPerformance>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'LoanPerformance', '', listing.Loan_Performance__c);
            // <LoanType></LoanType>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'LoanType', '', listing.Loan_Type__c);
            // <Name></Name>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Name', '', listing.Name);
            // <Occupancy></Occupancy>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Occupancy', '', String.valueOf(property.Occupancy__c));
            // <ParcelSize></ParcelSize>
            xmlHelper.writeGenericNode(xmlWriter, 'b', 'ParcelSize', '', String.valueOf(property.Land_Acres__c));
            // <ProjectImage></ProjectImage>
            // <ProjectImageData></ProjectImageData>

            // <ProjectType></ProjectType>
            xmlHelper.writeGenericNode(xmlWriter, 'b', 'ProjectType', '', listing.Project_Type__c);
            

            if(property.Unit_Type__c == 'Rooms')
                // <Rooms></Rooms>
                XMLHelper.writeGenericNode(xmlWriter, 'b', 'Rooms', '', String.valueOf(property.Rooms__c));
                
            // <SquareFeet></SquareFeet>
            xmlHelper.writeGenericNode(xmlWriter, 'b', 'SquareFeet', '', String.valueOf(property.Square_Footage__c));
            // <State></State>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'State', '', property.State__c);
            // <Status></Status>
            xmlHelper.writeGenericNode(xmlWriter, 'b', 'Status', '', listing.Status__c);

            if(property.Unit_Type__c == 'Spaces')
                // <Spaces></Spaces>
                XMLHelper.writeGenericNode(xmlWriter, 'b', 'Spaces', '', String.valueOf(property.Parking_Spaces__c));
                
            // <Summary></Summary>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Summary', '', listing.Offering_Notes__c);
            
            if(property.Unit_Type__c == 'Tenants')
                // <Tenants></Tenants>
                xmlHelper.writeGenericNode(xmlWriter, 'b', property.Unit_Type__c, '', String.valueOf(property.Units__c));

            if(property.Unit_Type__c == 'Units')
                // <Units></Units>
                xmlHelper.writeGenericNode(xmlWriter, 'b', property.Unit_Type__c, '', String.valueOf(property.Units__c));
            
            // <Value></Value>          
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Value', '', String.valueOf(listing.Asking_Price_Actual__c));
            // <YearBuilt></YearBuilt>
            xmlHelper.writeGenericNode(xmlWriter, 'b', 'YearBuilt', '', property.Year_Built__c);
            // <Zip></Zip>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Zip', '', property.Zip_Code__c);
            
        // </project>
        xmlWriter.writeEndElement();
        
        return xmlWriter.getXmlString();
    }
    
    public McLabsObjects.ListingObject[] parseListings(String xmlString){
        Dom.Document xmlDoc = new Dom.Document();
        xmlDoc.load(xmlString);
        
        Dom.XmlNode rootElement = xmlDoc.getRootElement();
        Dom.Xmlnode bodyElement = rootElement.getChildElement('Body', S_NAMESPACE);
        Dom.Xmlnode retrieveProjectsResponseElement = bodyElement.getChildElement('RetrieveProjectResponse', 'http://tempuri.org/');
        Dom.Xmlnode retrieveProjectsResultElement = retrieveProjectsResponseElement.getChildElement('RetrieveProjectResult', 'http://tempuri.org/');
        Dom.Xmlnode tableElement = retrieveProjectsResultElement.getChildElement('Table', B_NAMESPACE);
        Dom.Xmlnode diffgramElement = tableElement.getChildElement('diffgram', DIFFGR_NAMESPACE);
        Dom.Xmlnode documentElement = diffgramElement.getChildElement('DocumentElement', '');
        Dom.Xmlnode[] projects = documentElement.getChildElements();

       McLabsObjects.ListingObject[] listings = new McLabsObjects.ListingObject[] {};
        
        for(Dom.XmlNode node : projects) {
            listings.add(parseListing(node));
        }
        
        return listings;
    }
    
    private McLabsObjects.ListingObject parseListing(Dom.XmlNode node){
        McLabsObjects.ListingObject listing   = new McLabsObjects.ListingObject();
        McLabsObjects.PropertyObject property = new McLabsObjects.PropertyObject();
        
        listing.name             = XMLHelper.parseStringNode(node,  'Name', null);

        property.streetAddress   = XMLHelper.parseStringNode(node,  'Address', null);
        property.city            = XMLHelper.parseStringNode(node,  'City', null);
        property.state           = XMLHelper.parseStringNode(node,  'State', null);
        property.zipCode         = XMLHelper.parseStringNode(node,  'Zip_x0020__x002F__x0020_Postal', null);
        property.county          = XMLHelper.parseStringNode(node,  'County', null);
        property.country         = XMLHelper.parseStringNode(node,  'Country', null);
        
        parseAssetType(node, property);
        listing.projectType      = XMLHelper.parseStringNode(node,  'Project_x0020_Type', null);
        
        listing.status           = XMLHelper.parseStringNode(node,  'Status', null);
        listing.askingPrice      = XMLHelper.parseDecimalNode(node, 'Value', null);
        
        property.yearBuilt       = XMLHelper.parseStringNode(node,  'Year_x0020_Built', null);
        property.squareFootage   = XMLHelper.parseIntegerNode(node, 'Square_x0020_Feet', null);
        property.landAcres       = XMLHelper.parseDecimalNode(node, 'Parcel_x0020_Size', null);
        
        parseUnits(node, property);
        
        property.occupancy       = XMLHelper.parseDecimalNode(node, 'Occupancy', null);
        property.clazz           = XMLHelper.parseStringNode(node,  'Class', null);
        
        listing.notes            = XMLHelper.parseStringNode(node,  'Summary', null);
        listing.rcm1id           = XMLHelper.parseStringNode(node,  'Client_x0020_ID', null);
        listing.loanType         = XMLHelper.parseStringNode(node,  'Loan_x0020_Type', null);
        listing.loanPerformance  = XMLHelper.parseStringNode(node,  'Loan_x0020_Performance', null);
        listing.interestRate     = XMLHelper.parseStringNode(node,  'Loan_x0020_Interest', null);
        
        parseAttachments(node, property);
        
        listing.property         = property;
        
        Integer i = 1;
        String email;
        while((email = XMLHelper.parseStringNode(node, 'Contact_x0020_' + i++ + '_x0020_Email', null)) != null) {
            McLabsObjects.BrokerObject broker = new McLabsObjects.BrokerObject();
            broker.email = email;
            
            listing.brokers.add(broker);
            
            system.debug('adding broker: ' + email + ' (' + listing.brokers.size() +  ')');
        }

        return listing;
    }
    
    private void parseAssetType(Dom.XmlNode node, McLabsObjects.PropertyObject property){
        String assetType = XMLHelper.parseStringNode(node, 'Asset_x0020_Type', null);
        if(assetType == null) return;
        String[] assetTypeArr = assetType.split(' - ');
        
        String recordTypeStr = assetTypeArr[0];
        String primaryUseStr = (assetTypeArr.size() > 1) ? assetTypeArr[1] : null;
        
        //recordTypeStr = recordTypeStr.replaceAll('[^\\w]', '_');
        //system.debug('record type: ' + recordTypeStr);
        
        RecordType[] recordTypes = [select Id from RecordType where Name = :recordTypeStr];
        
        if(recordTypes != null && !recordTypes.isEmpty())
            property.recordTypeId = recordTypes[0].Id;
        
        property.primaryUse = primaryUseStr;
    }
    
    private void parseUnits(Dom.XmlNode node, McLabsObjects.PropertyObject property){
        String unitType = XMLHelper.parseStringNode(node, 'Unit_x0020_Type', null);
        if     (unitType == 'Units'   ) property.units          = XMLHelper.parseIntegerNode(node, 'Units',    null);
        else if(unitType == 'Bedrooms') property.units          = XMLHelper.parseIntegerNode(node, 'Bedrooms', null);
        else if(unitType == 'Beds'    ) property.units          = XMLHelper.parseIntegerNode(node, 'Beds',     null);
        else if(unitType == 'Rooms'   ) property.rooms          = XMLHelper.parseIntegerNode(node, 'Rooms',    null);
        else if(unitType == 'Spaces'  ) property.parkingSpaces  = XMLHelper.parseIntegerNode(node, 'Spaces',   null);
        else if(unitType == 'Tenants' ) property.units          = XMLHelper.parseIntegerNode(node, 'Tenants',  null);
        
        property.unitType = unitType;
    }
    
    private void parseAttachments(Dom.XmlNode node, McLabsObjects.PropertyObject property){
        
    }
        
}