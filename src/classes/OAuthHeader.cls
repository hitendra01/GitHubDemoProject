/**
 * An in-code representation of the OAuth Authorization Header
 * that must be sent to the Schoology API for authentication.
 *
 * @author Josh Russell (Riptide Software, Inc.)
 */
global class OAuthHeader {
	
	private final String REALM = 'Schoology API';
	private final String SIGNATURE_METHOD = 'PLAINTEXT';
	private final String VERSION = '1.0';
	private final Integer NONCE_LENGTH = 15;
	private final Integer CHAR_SET_SIZE = 62;
	private final String[] CHAR_SET = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
													   'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
													   'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
													   'w','x','y','z','1','2','3','4','5','6','7','8','9','0'};
	
	private final String consumerKey;
	private final String secretyKey;
	private final String nonce;
	private final String timestamp;
	
	global OAuthHeader(String consumerKey, String secretKey){
		this.consumerKey = consumerKey;
		this.secretyKey = secretKey;
		this.nonce = this.createNonce(); 
		this.timestamp = DateTimeUtil.timestampString();
	}
	
	/**
	 * Create a string representation of the OAuthHeader that can be sent across the wire.
	 */
	global override String toString(){
		String stringValue = 'OAuth realm="'+this.REALM+'",oauth_consumer_key="'+this.consumerKey+'",';
		stringValue += 'oauth_token="",oauth_nonce="'+this.nonce+'",oauth_timestamp="'+this.timestamp+'",';
		stringValue += 'oauth_signature_method="'+this.SIGNATURE_METHOD+'",oauth_version="'+this.VERSION+'",';
		stringValue += 'oauth_signature="'+this.secretyKey+'%26"';
		return stringValue;
	}
	
	/**
	 * A method that will generate a random String for us.
	 */
	private String createNonce(){
		String nonce = '';
		for(Integer i = 0; i < this.NONCE_LENGTH; i++){
			// Create a random index from which to pull a character in CHAR_SET
			Double randomIndex = Math.round((Math.random() * (this.CHAR_SET_SIZE - 1)));
			nonce += this.CHAR_SET[Integer.valueOf(randomIndex)];
		}
		return nonce;
	}
	
	private static testMethod void test(){
    	OAuthHeader o = new OAuthHeader('test','test');
    	o.toString();
    	o.createNonce();
    }

}