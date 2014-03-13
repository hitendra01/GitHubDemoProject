public class DateTimeUtil {

	public static String timestampString(){
		return String.valueOf(DateTime.now().getTime());
	}
	
	public static String unixTimestampString(){
		return String.valueOf(DateTime.now().getTime()/1000);
	}

	static testMethod void DateTimeUtilTests() {
       	timestampString();
       	unixTimestampString();
    }
}