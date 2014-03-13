public class ActivityAdapter {

    public static McLabsObjects.ActivityObject[] parseActivities(String xmlString) {
        McLabsObjects.ActivityObject[] activities = new McLabsObjects.ActivityObject[]{};

        Dom.Document xmlDoc = new Dom.Document();
        xmlDoc.load(xmlString);
            
        Dom.XmlNode rootElement = xmlDoc.getRootElement();
        Dom.Xmlnode bodyElement = rootElement.getChildElement('Body', McLabsConstants.RCM1_S_NAMESPACE);
        Dom.Xmlnode retrieveResponseElement = bodyElement.getChildElement('RetrieveBuyersActivityResponse', 'http://tempuri.org/');
        Dom.Xmlnode retrieveResultElement = retrieveResponseElement.getChildElement('RetrieveBuyersActivityResult', 'http://tempuri.org/');
        Dom.Xmlnode tableElement = retrieveResultElement.getChildElement('Table', McLabsConstants.RCM1_B_NAMESPACE);
        if(tableElement != null) {
            Dom.Xmlnode diffgramElement = tableElement.getChildElement('diffgram', McLabsConstants.RCM1_DIFFGR_NAMESPACE);
            if(diffgramElement != null) {
                Dom.Xmlnode documentElement = diffgramElement.getChildElement('DocumentElement', '');
        
                if(documentElement != null) {
                    Dom.Xmlnode[] activityElems = documentElement.getChildElements();
                    
                    for(Dom.XmlNode node : activityElems){
                        activities.Add(parseActivity(node));
                    }
                }
            }
        }
        
        return activities;
    }
    
    private static McLabsObjects.ActivityObject parseActivity(Dom.XmlNode elem) {
        McLabsObjects.ActivityObject activity = new McLabsObjects.ActivityObject();

        activity.email = XmlHelper.parseStringNode(elem, 'Email', null);
        activity.actDate = XmlHelper.parseDateNode(elem, 'Date', null);
        activity.action = XmlHelper.parseStringNode(elem, 'Action', null);
        
        return activity;
    }

}