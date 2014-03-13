public with sharing class XMLHelper {

    public static String parseStringNode(Dom.XmlNode node, String elementName, String nameSpace){
        return parseStringNode( node, elementName, nameSpace, false);
    }
    
    public static String parseStringNode(Dom.XmlNode node, String elementName, String nameSpace, Boolean ifNullReturnBlankValue){       
        String returnValue = (null != node.getChildElement(elementName, nameSpace)) ? node.getChildElement(elementName, nameSpace).getText() : null;        
        if(ifNullReturnBlankValue && null == returnValue){
            returnValue = '';
        }
        return returnValue;
    }
    
    public static Date parseDateNode(Dom.XmlNode node, String elementName, String nameSpace){
        String returnedString = parseStringNode(node, elementName, nameSpace);
        if(null != returnedString && '' != returnedString)
            return Date.valueOf(returnedString);
        else
            return null;
    }
    
    public static Integer parseIntegerNode(Dom.XmlNode node, String elementName, String nameSpace){
        String returnedString = parseStringNode(node, elementName, nameSpace);
        if(null != returnedString && '' != returnedString)
            return Integer.valueOf(returnedString);
        else
            return null;
    }
    
    public static Decimal parseDecimalNode(Dom.XmlNode node, String elementName, String nameSpace){
        String returnedString = parseStringNode(node, elementName, nameSpace);
        if(null != returnedString && returnedString.length() > 0)
            return Decimal.valueOf(returnedString);
        else
            return null;
    }
    
    public static Boolean parseBooleanNode(Dom.XmlNode node, String elementName, String nameSpace){
        String returnedString = parseStringNode(node, elementName, nameSpace);
        if(null != returnedString && '' != returnedString)
            return false;
        else
            return Boolean.valueOf(returnedString);
    }
    
    public static XmlStreamWriter createXMLStructure(Double versionNumber, String encoding){
        if(null == versionNumber)
            versionNumber = 1.0;
            
        XmlStreamWriter xmlStreamWriter = new XmlStreamWriter();    
        xmlStreamWriter.writeStartDocument(encoding, String.valueOf(versionNumber));
            
        return xmlStreamWriter;
    }
    
    public static XmlStreamWriter writeXMLComment(XmlStreamWriter xmlStreamWriter, String comment){
        if(null == xmlStreamWriter)
            return null;
            
        xmlStreamWriter.writeComment(comment);
            
        return xmlStreamWriter;
    }
    
    public static XmlStreamWriter writeGenericNode(XmlStreamWriter xmlWriter, String nodeName, String nodeValue){
        return writeGenericNode(xmlWriter, '', nodeName, '', nodeValue);
    }
    
    public static XmlStreamWriter writeGenericNode(XmlStreamWriter xmlWriter, String nodePrefix, String nodeName, String nodeNamespace, String nodeValue){
        xmlWriter.writeStartElement(nodePrefix, nodeName, nodeNamespace);
        if(nodeValue != null)
            xmlWriter.writeCharacters(nodeValue);
        xmlWriter.writeEndElement();
        return xmlWriter;
    }
    
}