@isTest
public class Rcm1ImporterTest {

    static testMethod void testStart() {
        Rcm1Importer importer = new Rcm1Importer(new Rcm1ApiMock());
        List<String> ids = importer.start(null);
        
        System.assertEquals(2, ids.size());
        System.assertEquals('APT-1', ids[0]);
        System.assertEquals('APT-2', ids[1]);
    }
    
    static testMethod void testExecute() {
        setupListings();
        
        Listing__c listing = new Listing__c(
            Rcm1id__c = 'APT-1'
        );
        insert listing;
        
        Rcm1Importer importer = new Rcm1Importer(new Rcm1ApiMock(listingMap));
        
        List<String> ids = new String[]{};
        ids.addAll(listingMap.keySet());
        
        Test.startTest();
        
        importer.execute(null, ids);
        
        Test.stopTest();
        
        Listing__c[] listings = [
            select Name, Rcm1id__c
            from Listing__c
        ];
        
        System.assertEquals(2, listings.size());
    }
    
    private static void setupListings() {
        listingMap = new Map<String, Map<String, String>>{
            'APT-1' => new Map<String, String>{
                'Name' => 'Listing APT-1',
                'RecordType' => 'Office',
                'PrimaryUse' => 'BioTech / Life Sciences',
                'Street' => 'Street Address 1',
                'City' => 'City 1',
                'State' => 'State 1',
                'ZipCode' => '11111'
            },
            'APT-2' => new Map<String, String>{
                'Name' => 'Listing APT-2',
                'RecordType' => 'Multi-family',
                'PrimaryUse' => 'Garden Apartments',
                'Street' => 'Street Address 2',
                'City' => 'City 2',
                'State' => 'State 2',
                'ZipCode' => '22222'
            }
        };
        
    }
    
    private static Map<String, Map<String, String>> listingMap;
    
    class Rcm1ApiMock extends Rcm1Api {
    
        private Map<String, Map<String, String>> listings;
    
        public Rcm1ApiMock() {
        }
    
        public Rcm1ApiMock(Map<String, Map<String, String>> listings) {
            this.listings = listings;
        }
        
        public override HttpResponse getListings() {
            HttpResponse resp = new HttpResponse();
            
            String body = 
'<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">'+
'    <s:Header>'+
'        <a:Action s:mustUnderstand="1">http://tempuri.org/IDataExchangeProject/RetrieveProjectListResponse</a:Action>'+
'        <a:RelatesTo>urn:uuid:ddfe866f-2a93-4fc4-9a80-a923d5842415</a:RelatesTo>'+
'    </s:Header>'+
'    <s:Body>'+
'        <RetrieveProjectListResponse xmlns="http://tempuri.org/">'+
'            <RetrieveProjectListResult xmlns:b="http://schemas.datacontract.org/2004/07/RCM.DataExchange" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'+
'                <b:Error>false</b:Error>'+
'                <b:Message i:nil="true"/>'+
'                <b:Table>'+
'                    <diffgr:diffgram xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">'+
'                        <DocumentElement xmlns="">'+
'                            <Projects diffgr:id="Projects1" msdata:rowOrder="0" diffgr:hasChanges="inserted">'+
'                                <ClientId>APT-1</ClientId>'+
'                            </Projects>'+
'                            <Projects diffgr:id="Projects2" msdata:rowOrder="1" diffgr:hasChanges="inserted">'+
'                                <ClientId>APT-2</ClientId>'+
'                            </Projects>'+
'                        </DocumentElement>'+
'                    </diffgr:diffgram>'+
'                </b:Table>'+
'                <b:Total>0</b:Total>'+
'            </RetrieveProjectListResult>'+
'        </RetrieveProjectListResponse>'+
'    </s:Body>'+
'</s:Envelope>';

            resp.setBody(body);
            
            return resp;
        }
        
        public override HttpResponse getListing(String rcm1Id) {
            Map<String, String> listing = listings.get(rcm1id);
            
            system.debug('listing data (' + rcm1id + '): ' + listing);
        
            HttpResponse resp = new HttpResponse();
            
            String body = 
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
'                                <Name>Name ' + listing.get('Name') + '</Name>'+
'                                <Project_x0020_Type>Investment Sale</Project_x0020_Type>'+
'                                <Asset_x0020_Type>' + listing.get('RecordType') + ' - ' + listing.get('PrimaryUse') + '</Asset_x0020_Type>'+
'                                <Address>' + listing.get('Street') + '</Address>'+
'                                <City>' + listing.get('City') + '</City>'+
'                                <State>' + listing.get('State') + '</State>'+
'                                <Zip_x0020__x002F__x0020_Postal>' + listing.get('ZipCode') + '</Zip_x0020__x002F__x0020_Postal>'+
'                                <Country>United States</Country>'+
'                                <Year_x0020_Built/>'+
'                                <Units>0</Units>'+
'                                <Unit_x0020_Type>Units</Unit_x0020_Type>'+
'                                <Occupancy>0</Occupancy>'+
'                                <Class/>'+
'                                <Client_x0020_ID>' + rcm1id + '</Client_x0020_ID>'+
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
'                                <First_x0020_Display_x0020_Contact>Tanner McGraw</First_x0020_Display_x0020_Contact>'+
'                                <Contact_x0020_1_x0020_Email>tm@aptotude.com</Contact_x0020_1_x0020_Email>'+
'                                <Listing_x0020_Contact>Tanner McGraw</Listing_x0020_Contact>'+
'                                <Listing_x0020_1_x0020_Email>tm@aptotude.com</Listing_x0020_1_x0020_Email>'+
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

            resp.setBody(body);
            
            return resp;
        }
        
        public override HttpResponse getBuyers(String rcm1id) {
            HttpResponse resp = new HttpResponse();
            
            String body = 
'<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">'+
'   <s:Header>'+
'       <a:Action s:mustUnderstand="1">http://tempuri.org/IDataExchangeBuyer/RetrieveBuyersResponse</a:Action>'+
'       <a:RelatesTo>urn:uuid:6c6791a3-e0d5-4c56-a962-ab2bf362e11c</a:RelatesTo>'+
'   </s:Header>'+
'   <s:Body>'+
'       <RetrieveBuyersResponse xmlns="http://tempuri.org/">'+
'           <RetrieveBuyersResult xmlns:b="http://schemas.datacontract.org/2004/07/RCM.DataExchange" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'+
'               <b:Error>false</b:Error>'+
'               <b:Message i:nil="true"/>'+
'               <b:Table>'+
'                   <diffgr:diffgram xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">'+
'                       <DocumentElement xmlns="">'+
'                           <Buyers diffgr:id="Buyers1" msdata:rowOrder="0">'+
'                               <Firstname>SurCandace</Firstname>'+
'                               <Lastname>Hoyt</Lastname>'+
'                               <Email>parturient.montes.nascetur@arcu.com</Email>'+
'                               <IndustryRole>Principal</IndustryRole>'+
'                               <Company>Adobe Test</Company>'+
'                               <Address>Ap #100-9675 Pede. Ave</Address>'+
'                               <City>Morrison</City>'+
'                               <State>LA</State>'+
'                               <Zip>27930</Zip>'+
'                               <Country>United States</Country>'+
'                               <Phone>1207150287</Phone>'+
'                               <Extension>8852</Extension>'+
'                               <Fax>7249415275</Fax>'+
'                           </Buyers>'+
'                           <Buyers diffgr:id="Buyers2" msdata:rowOrder="1">'+
'                               <Firstname>Adrian</Firstname>'+
'                               <Lastname>SurQuinlan</Lastname>'+
'                               <Email>sed.dui.Fusce@tortor.com</Email>'+
'                               <IndustryRole>Principal</IndustryRole>'+
'                               <Company>Adobe Test</Company>'+
'                               <Address>479-6506 Justo Rd.</Address>'+
'                               <City>New Kensington</City>'+
'                               <State>TX</State>'+
'                               <Zip>64538</Zip>'+
'                               <Country>United States</Country>'+
'                               <Phone>9318571893</Phone>'+
'                               <Extension>611</Extension>'+
'                               <Fax>6964980504</Fax>'+
'                           </Buyers>'+
'                       </DocumentElement>'+
'                   </diffgr:diffgram>'+
'               </b:Table>'+
'               <b:Total>50</b:Total>'+
'           </RetrieveBuyersResult>'+
'       </RetrieveBuyersResponse>'+
'   </s:Body>'+
'</s:Envelope>';

            resp.setBody(body);
            
            return resp;
        }
        
    }

}