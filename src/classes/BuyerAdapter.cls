public with sharing class BuyerAdapter {

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

    public BuyerAdapter(){
    }

    public String generateXML(Listing__c listing, Contact contact){
        XmlStreamWriter xmlWriter = new XmlStreamWriter();
        
        // <buyer>
        xmlWriter.writeStartElement('', 'buyer', '');
        xmlWriter.writeAttribute('xmlns', '', 'b', McLabsConstants.RCM1_B_NAMESPACE);
        xmlWriter.writeAttribute('xmlns', '', 'i', McLabsConstants.RCM1_I_NAMESPACE);
        
            // <Address></Address>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Address', '', contact.MailingStreet);
            // <City></City>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'City', '', contact.MailingCity);
            // <Company></Company>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Company', '', contact.Company__c);
            // <Country></Country>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Country', '', contact.MailingCountry);
            // <Email></Email>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Email', '', contact.Email);
            // <Extension></Extension>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Extension', '', contact.Phone_Extension__c);
            // <Fax></Fax>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Fax', '', contact.Fax);
            // <Firstname></Firstname>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'FirstName', '', contact.Firstname);
            // <IndustryRole></IndustryRole>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'IndustryRole', '', contact.Industry_Role__c);
            // <Lastname></Lastname>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'LastName', '', contact.Lastname);
            // <Mobile></Mobile>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Mobile', '', contact.MobilePhone);
            // <Phone></Phone>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Phone', '', contact.Phone);
            // <State></State>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'State', '', contact.MailingState);
            // <Zip></Zip>
            XMLHelper.writeGenericNode(xmlWriter, 'b', 'Zip', '', contact.MailingPostalCode);
        
        // </Buyer>
        xmlWriter.writeEndElement();
        
        return xmlWriter.getXmlString();
    }
    
    public McLabsObjects.BuyerObject[] parseBuyers(String xmlString){
        Dom.Document xmlDoc = new Dom.Document();
        xmlDoc.load(xmlString);
        
        McLabsObjects.BuyerObject[] buyers = new List<McLabsObjects.BuyerObject>();
        
        Dom.XmlNode rootElement = xmlDoc.getRootElement();
        Dom.Xmlnode bodyElement = rootElement.getChildElement('Body', S_NAMESPACE);
        Dom.Xmlnode retrieveResponseElement = bodyElement.getChildElement('RetrieveBuyersResponse', 'http://tempuri.org/');
        Dom.Xmlnode retrieveResultElement = retrieveResponseElement.getChildElement('RetrieveBuyersResult', 'http://tempuri.org/');
        Dom.Xmlnode tableElement = retrieveResultElement.getChildElement('Table', B_NAMESPACE);
        Dom.Xmlnode diffgramElement = tableElement.getChildElement('diffgram', DIFFGR_NAMESPACE);
        Dom.Xmlnode documentElement = diffgramElement.getChildElement('DocumentElement', '');
        if(documentElement != null) {
            Dom.Xmlnode[] buyerElems = documentElement.getChildElements();
            
            for(Dom.XmlNode node : buyerElems){
                buyers.Add(parseBuyer(node));
            }
        }
        
        return buyers;
    }
    
    private McLabsObjects.BuyerObject parseBuyer(Dom.XmlNode node){
        McLabsObjects.BuyerObject buyer  = new McLabsObjects.BuyerObject();
        
        buyer.firstName       = XMLHelper.parseStringNode(node, 'Firstname', null);
        buyer.lastName        = XMLHelper.parseStringNode(node, 'Lastname', null);
        buyer.email           = XMLHelper.parseStringNode(node, 'Email', null);
        buyer.industryRole    = XMLHelper.parseStringNode(node, 'IndustryRole', null);
        buyer.company         = XMLHelper.parseStringNode(node, 'Company', null);
        buyer.streetAddress   = XMLHelper.parseStringNode(node, 'Address', null);
        buyer.city            = XMLHelper.parseStringNode(node, 'City', null);
        buyer.state           = XMLHelper.parseStringNode(node, 'State', null);
        buyer.zipCode         = XMLHelper.parseStringNode(node, 'Zip', null);
        buyer.country         = XMLHelper.parseStringNode(node, 'Country', null);
        buyer.phone           = XMLHelper.parseStringNode(node, 'Phone', null);
        buyer.extension       = XMLHelper.parseStringNode(node, 'Extension', null);
        buyer.fax             = XMLHelper.parseStringNode(node, 'Fax', null);
        buyer.mobile          = XMLHelper.parseStringNode(node, 'Mobile', null);

        return buyer;
    }
    
    private void parseAttachments(Dom.XmlNode node, McLabsObjects.BuyerObject buyer){
        
    }

}