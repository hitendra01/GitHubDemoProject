@isTest
public class BuyerAdapterTest {

    static testMethod void testGenerateXML() {
        Contact contact = new Contact(
            firstname         = 'firstname',
            lastname          = 'lastname',
            email             = 'email@server.com',
            industry_role__c  = 'industry role',
            mailingstreet     = 'street address',
            mailingcity       = 'city',
            mailingstate      = 'state',
            mailingpostalcode = '12345',
            mailingcountry    = 'country'
        );
    
        BuyerAdapter adapter = new BuyerAdapter();
        
        Test.startTest();
        
        String xml = adapter.generateXML(null, contact);
        
        Test.stopTest();
        
        Dom.Document xmlDoc = new Dom.Document();
        xmlDoc.load(xml);
        
        Dom.XmlNode rootElement = xmlDoc.getRootElement();
    }

    static testMethod void testParseBuyers() {
        String xml = 
'<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing">'+
'    <s:Header>'+
'        <a:Action s:mustUnderstand="1">http://tempuri.org/IDataExchangeBuyer/RetrieveBuyersResponse</a:Action>'+
'        <a:RelatesTo>urn:uuid:6c6791a3-e0d5-4c56-a962-ab2bf362e11c</a:RelatesTo>'+
'    </s:Header>'+
'    <s:Body>'+
'        <RetrieveBuyersResponse xmlns="http://tempuri.org/">'+
'            <RetrieveBuyersResult xmlns:b="http://schemas.datacontract.org/2004/07/RCM.DataExchange" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'+
'                <b:Error>false</b:Error>'+
'                <b:Message i:nil="true"/>'+
'                <b:Table>'+
'                    <diffgr:diffgram xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">'+
'                        <DocumentElement xmlns="">'+
'                            <Buyers diffgr:id="Buyers1" msdata:rowOrder="0">'+
'                                <Firstname>firstname1</Firstname>'+
'                                <Lastname>lastname1</Lastname>'+
'                                <Email>email1@mail.com</Email>'+
'                                <IndustryRole>Principal</IndustryRole>'+
'                                <Company>company1</Company>'+
'                                <Address>street 1</Address>'+
'                                <City>city1</City>'+
'                                <State>FL</State>'+
'                                <Zip>11111</Zip>'+
'                                <Country>United States</Country>'+
'                                <Phone>111-111-1111</Phone>'+
'                                <Extension>111</Extension>'+
'                                <Fax>111-111-1111</Fax>'+
'                            </Buyers>'+
'                            <Buyers diffgr:id="Buyers2" msdata:rowOrder="1">'+
'                                <Firstname>firstname2</Firstname>'+
'                                <Lastname>lastname2</Lastname>'+
'                                <Email>email2@mail.com</Email>'+
'                                <IndustryRole>Principal</IndustryRole>'+
'                                <Company>company2</Company>'+
'                                <Address>street 2</Address>'+
'                                <City>city2</City>'+
'                                <State>FL</State>'+
'                                <Zip>22222</Zip>'+
'                                <Country>United States</Country>'+
'                                <Phone>222-222-2222</Phone>'+
'                                <Extension>2222</Extension>'+
'                                <Fax>222-222-2222</Fax>'+
'                            </Buyers>'+
'                        </DocumentElement>'+
'                    </diffgr:diffgram>'+
'                </b:Table>'+
'                <b:Total>50</b:Total>'+
'            </RetrieveBuyersResult>'+
'        </RetrieveBuyersResponse>'+
'    </s:Body>'+
'</s:Envelope>';

        Test.startTest();
        
        BuyerAdapter adapter = new BuyerAdapter();
        McLabsObjects.BuyerObject[] buyers = adapter.parseBuyers(xml);
        
        Test.stopTest();
        
        System.assertEquals(2, buyers.size());
        System.assertEquals('firstname1', buyers[0].firstname);
        System.assertEquals('lastname1', buyers[0].lastname);
        
    }

}