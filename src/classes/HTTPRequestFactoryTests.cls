/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class HTTPRequestFactoryTests { 
	
	private static final String endpoint = 'http://example.com';
    private static final String body = '{ body:body }';
    private static OAuthHeader authHeader = new OAuthHeader('123abc456def', 'ghi789lmn');
	
    static testMethod void testNewPutRequest() {
        HttpRequest testRequest = HTTPRequestFactory.newPutRequest(endpoint, authHeader, body);
        System.assertEquals('PUT', testRequest.getMethod());
        System.assertEquals(endpoint, testRequest.getEndpoint());
        System.assertEquals(body, testRequest.getBody());        
    } 
    
    static testMethod void testNewGetRequest() {
        HttpRequest testRequest = HTTPRequestFactory.newGetRequest(endpoint, authHeader);
        System.assertEquals('GET', testRequest.getMethod());
        System.assertEquals(endpoint, testRequest.getEndpoint());
        System.assertEquals(McLabsConstants.CONTENT_TYPE_XML, testRequest.getHeader('Accept'));        
    }
    
    static testMethod void testNewPostRequest() {
        HttpRequest testRequest = HTTPRequestFactory.newPostRequest(endpoint, authHeader, McLabsConstants.CONTENT_TYPE_XML);
        System.assertEquals('POST', testRequest.getMethod());
        System.assertEquals(endpoint, testRequest.getEndpoint());
    }
    
    static testMethod void testNewPostOverloadRequest() {
        HttpRequest testRequest = HTTPRequestFactory.newPostRequest(endpoint, authHeader, McLabsConstants.CONTENT_TYPE_XML, McLabsConstants.CONTENT_TYPE_XML, '');
        System.assertEquals('POST', testRequest.getMethod());
        System.assertEquals(endpoint, testRequest.getEndpoint());
    }
    
    static testMethod void testNewDeleteRequest() {
        HttpRequest testRequest = HTTPRequestFactory.newDeleteRequest(endpoint, authHeader);
        System.assertEquals('DELETE', testRequest.getMethod());
        System.assertEquals(endpoint, testRequest.getEndpoint());
    }
}