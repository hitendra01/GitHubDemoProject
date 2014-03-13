/**
 * This class is responsible for creating any HttpRequest objects
 * we may need. Methods for PUT, POST, GET, DELETE are provided.
 *
 * @author Josh Russell (Riptide Software, Inc.)
 * @auther Alex Acosta 	(Riptide Software, Inc.)
 */
public class HTTPRequestFactory {
	
	private static final String CONTENT_TYPE = 'application/soap+xml';
	private static final String HOST = ConfigurationService.getHost();

	/**
	 * Create a PUT request.
	 * @param String endpoint - the url of the endpoint to be used
	 * @param OAuthHeader oAuthHeader - the OAuthHeader object to be used in creating this request
	 * @param String body - the body of the put request
	 * @return HttpRequest - a new HttpRequest that is set for PUT
	 */
	public static HttpRequest newPutRequest(String endpoint, OAuthHeader oAuthHeader, String body){ 
		HttpRequest request = new HttpRequest();
		request.setBody(body);
		//request.setHeader('Authorization', oAuthHeader.toString());
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Host', HOST);
		request.setHeader('Accept', CONTENT_TYPE);
		request.setMethod('PUT');
		request.setEndpoint(endpoint);
		return request;
	}
	
	/**
	 * Create a GET request.
	 * @param String endpoint - the url of the endpoint to be used
	 * @param OAuthHeader oAuthHeader - the OAuthHeader object to be used in creating this request
	 * @param String body - the body of the put request
	 * @return HttpRequest - a new HttpRequest that is set for GET
	 */
	public static HttpRequest newGetRequest(String endpoint, OAuthHeader oAuthHeader){
		HttpRequest request = new HttpRequest();
		//request.setHeader('Authorization', oAuthHeader.toString());
		request.setHeader('Host', HOST);
		request.setHeader('Accept', CONTENT_TYPE);
		request.setMethod('GET');
		request.setEndpoint(endpoint);
		return request;
	}
	
	/**
	 * Create a POST request.
	 * @param String endpoint - the url of the endpoint to be used
	 * @param OAuthHeader oAuthHeader - the OAuthHeader object to be used in creating this request
	 * @param String body - the body of the put request
	 * @return HttpRequest - a new HttpRequest that is set for POST
	 */
	public static HttpRequest newPostRequest(String endpoint, OAuthHeader oAuthHeader, String body){
		HttpRequest request = new HttpRequest();
		request.setBody(body);
		//request.setHeader('Authorization', oAuthHeader.toString());
		//request.setHeader('Host', HOST);
		request.setHeader('Content-Type', CONTENT_TYPE);
		request.setHeader('Accept', CONTENT_TYPE);
		request.setMethod('POST');
		request.setEndpoint(endpoint);
		
		return request;
	}
	
	/**
	 * Create a POST request.
	 * @param String endpoint - the url of the endpoint to be used
	 * @param OAuthHeader oAuthHeader - the OAuthHeader object to be used in creating this request
	 * @param String body - the body of the put request
	 * @return HttpRequest - a new HttpRequest that is set for POST
	 */
	public static HttpRequest newPostRequest(String endpoint, OAuthHeader oAuthHeader, String contentTypeSent, String contentTypeReceive, String body){
		HttpRequest request = new HttpRequest();
		request.setBody(body);
		//request.setHeader('Authorization', oAuthHeader.toString());
		request.setHeader('Host', HOST);
		request.setHeader('Content-Type', contentTypeSent);
		request.setHeader('Accept', contentTypeReceive);
		request.setMethod('POST');
		request.setEndpoint(endpoint);
		return request;
	}
	
	/**
	 * Create a DELETE request.
	 * @param String endpoint - the url of the endpoint to be used
	 * @param OAuthHeader oAuthHeader - the OAuthHeader object to be used in creating this request
	 * @return HttpRequest - a new HttpRequest that is set for DELETE
	 */
	public static HttpRequest newDeleteRequest(String endpoint, OAuthHeader oAuthHeader){
		HttpRequest request = new HttpRequest();
		//request.setHeader('Authorization', oAuthHeader.toString());
		request.setHeader('Host', HOST);
		request.setMethod('DELETE');
		request.setEndpoint(endpoint);
		return request;
	}

}