@isTest
public class ListingAdapterTest {

    static testMethod void testGenerateXML() {
        Property__c property = new Property__c(
            rooms__c = 0
        );
    
        Listing__c listing = new Listing__c(
            name = 'listing name',
            asking_price__c = 0,
            
            property__r = property
        );
        
        ListingAdapter adapter = new ListingAdapter();
        
        Test.startTest();
        
        String xml = adapter.generateXML(listing);
        
        Test.stopTest();
        
    }

    static testMethod void testParseListings() {
        String xml =
'<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">'+
'    <s:Header>'+
'        <a:Action s:mustUnderstand="1">http://tempuri.org/IDataExchangeProject/RetrieveProjectResponse</a:Action>'+
'        <a:RelatesTo>urn:uuid:6c6791a3-e0d5-4c56-a962-ab2bf362e11c</a:RelatesTo>'+
'    </s:Header>'+
'    <s:Body>'+
'        <RetrieveProjectResponse xmlns="http://tempuri.org/">'+
'            <RetrieveProjectResult xmlns:b="http://schemas.datacontract.org/2004/07/RCM.DataExchange" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'+
'                <b:Error>false</b:Error>'+
'                <b:Message i:nil="true"/>'+
'                <b:Table>'+
'                    <diffgr:diffgram xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">'+
'                        <DocumentElement xmlns="">'+
'                            <Projects diffgr:id="Projects1" msdata:rowOrder="0">'+
'                                <Name>listing name</Name>'+
'                                <Project_x0020_Type>Investment Sale</Project_x0020_Type>'+
'                                <Asset_x0020_Type>Office - BioTech / Life Sciences</Asset_x0020_Type>'+
'                                <Address>street address</Address>'+
'                                <City>city</City>'+
'                                <State>FL</State>'+
'                                <Zip_x0020__x002F__x0020_Postal>12345</Zip_x0020__x002F__x0020_Postal>'+
'                                <Country>United States</Country>'+
'                                <Year_x0020_Built/>'+
'                                <Units>0</Units>'+
'                                <Unit_x0020_Type>Tenants</Unit_x0020_Type>'+
'                                <Occupancy>0</Occupancy>'+
'                                <Class/>'+
'                                <Client_x0020_ID>1234</Client_x0020_ID>'+
'                                <Custom_x0020_Field_x0020_1_x0020_Name/>'+
'                                <Custom_x0020_Field_x0020_1_x0020_Value/>'+
'                                <Custom_x0020_Field_x0020_2_x0020_Name/>'+
'                                <Custom_x0020_Field_x0020_2_x0020_Value/>'+
'                                <Custom_x0020_Field_x0020_3_x0020_Name/>'+
'                                <Custom_x0020_Field_x0020_3_x0020_Value/>'+
'                                <Custom_x0020_Field_x0020_4_x0020_Name/>'+
'                                <Custom_x0020_Field_x0020_4_x0020_Value/>'+
'                                <Custom_x0020_Field_x0020_5_x0020_Name/>'+
'                                <Custom_x0020_Field_x0020_5_x0020_Value/>'+
'                                <Custom_x0020_Field_x0020_6_x0020_Name/>'+
'                                <Custom_x0020_Field_x0020_6_x0020_Value/>'+
'                                <Link_x0020_Type>Landing Page</Link_x0020_Type>'+
'                                <Project_x0020_Image>no-image-uploaded.jpg</Project_x0020_Image>'+
'                                <Brochure_x0020_File/>'+
'                                <Status>Available</Status>'+
'                                <First_x0020_Display_x0020_Contact>contact name</First_x0020_Display_x0020_Contact>'+
'                                <Contact_x0020_1_x0020_Email>email@server.com</Contact_x0020_1_x0020_Email>'+
'                                <Listing_x0020_Contact>contact name</Listing_x0020_Contact>'+
'                                <Listing_x0020_1_x0020_Email>email@server.com</Listing_x0020_1_x0020_Email>'+
'                                <Sent_x0020_Initial_x0020_Email>0</Sent_x0020_Initial_x0020_Email>'+
'                                <Viewed_x0020_Email>0</Viewed_x0020_Email>'+
'                                <Viewed_x0020_Executive_x0020_Summary>0</Viewed_x0020_Executive_x0020_Summary>'+
'                                <Entered_x0020_VDR>0</Entered_x0020_VDR>'+
'                                <Viewed_x0020_Agreement>0</Viewed_x0020_Agreement>'+
'                                <Executed_x0020_Agreement>0</Executed_x0020_Agreement>'+
'                                <Approved_x0020_Users>0</Approved_x0020_Users>'+
'                                <Downloaded_x0020_Documents>0</Downloaded_x0020_Documents>'+
'                                <Offers>0</Offers>'+
'                                <Listing_x0020_Engines>None</Listing_x0020_Engines>'+
'                                <Summary/>'+
'                                <Description/>'+
'                            </Projects>'+
'                        </DocumentElement>'+
'                    </diffgr:diffgram>'+
'                </b:Table>'+
'                <b:Total>0</b:Total>'+
'            </RetrieveProjectResult>'+
'        </RetrieveProjectResponse>'+
'    </s:Body>'+
'</s:Envelope>';

        ListingAdapter adapter = new ListingAdapter();
        
        Test.startTest();
        
        McLabsObjects.ListingObject[] listings = adapter.parseListings(xml);
        
        Test.stopTest();
        
        System.assertEquals(1, listings.size());
        System.assertEquals('listing name', listings[0].name);
        System.assertEquals(1, listings[0].brokers.size());
    }

}