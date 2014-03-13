public with sharing class ProjectAdapter {

	private final Dom.Document XML_DOC = new Dom.Document();
	private final String S_NAMESPACE = McLabsConstants.RCM1_S_NAMESPACE;
	private final String B_NAMESPACE = McLabsConstants.RCM1_B_NAMESPACE;
	private final String DIFFGR_NAMESPACE = McLabsConstants.RCM1_DIFFGR_NAMESPACE;
	
	public ProjectAdapter(String xmlString){
		this.XML_DOC.load(xmlString);
		parseXml();
	} 
	
	private void parseXml(){
		
		Dom.XmlNode rootElement = this.XML_DOC.getRootElement();
		Dom.Xmlnode bodyElement = rootElement.getChildElement('Body', S_NAMESPACE);
		Dom.Xmlnode retrieveProjectsResponseElement = bodyElement.getChildElement('RetrieveProjectsResponse', 'http://tempuri.org/');
		Dom.Xmlnode retrieveProjectsResultElement = retrieveProjectsResponseElement.getChildElement('RetrieveProjectsResult', 'http://tempuri.org/');
		Dom.Xmlnode tableElement = retrieveProjectsResultElement.getChildElement('Table', B_NAMESPACE);
		Dom.Xmlnode diffgramElement = tableElement.getChildElement('diffgram', DIFFGR_NAMESPACE);
		Dom.Xmlnode documentElement = diffgramElement.getChildElement('DocumentElement', '');
		Dom.Xmlnode[] projects = documentElement.getChildElements();
		
		for(Dom.XmlNode node : projects){
			system.debug('name: ' + node.getChildElement('Name', null).getText() + ' namespace: ' + node.getNamespace());
		}
			
		system.debug('+++++++++++++++++++++++++++');
		system.debug('root: ' + rootElement);
		system.debug('body: ' + bodyElement);
		system.debug('table: ' + tableElement);
		system.debug('diffgr: ' + diffgramElement);
		system.debug('projects: ' + projects);
		
		/*
		Dom.XmlNode rootElement = this.XML_DOC.getRootElement();
		Dom.XmlNode eventsElement = rootElement.getChildElement('Events', this.DC_NAMESPACE);
		Dom.XmlNode eventInfoElement = eventsElement.getChildElement('EventInfo', this.METANGA_NAMESPACE);
		Dom.XmlNode entityElement = eventInfoElement.getChildElement('Entity', this.METANGA_NAMESPACE);
		Dom.XmlNode priceScheduleElement = entityElement.getChildElement('PriceSchedule', this.METANGA_NAMESPACE);
		Dom.XmlNode intervalsElement = priceScheduleElement.getChildElement('Intervals', this.METANGA_NAMESPACE);
		
		// Product
		this.product = new MetangaProduct();
		this.product.description = XMLHelper.xmlMapNode(entityElement, 'Description', this.METANGA_NAMESPACE, 'KeyValueOfstringstring');
		this.product.metangaId = XMLHelper.xmlStringNode(entityElement, 'EntityId', this.METANGA_NAMESPACE);
		this.product.name = XMLHelper.xmlMapNode(entityElement, 'Name', this.METANGA_NAMESPACE, 'KeyValueOfstringstring');
		this.product.rank = XMLHelper.xmlIntegerNode(entityElement, 'Rank', this.METANGA_NAMESPACE);
		this.product.taxable = XMLHelper.xmlBooleanNode(entityElement, 'Taxable', this.METANGA_NAMESPACE);
		this.product.tierQuality = XMLHelper.xmlStringNode(entityElement, 'TierQuantity', this.METANGA_NAMESPACE);
		
		List<MetangaPriceSchedule> mpsList = new List<MetangaPriceSchedule>();
		// Loop through potential multi-Intervals
		for(Dom.XmlNode node :intervalsElement.getChildElements()){
			Dom.XmlNode unitPricesElement = node.getChildElement('UnitPrices', this.METANGA_NAMESPACE);
			MetangaPriceSchedule mps = new MetangaPriceSchedule();
			mps.startDate = XMLHelper.xmlDateNode(node, 'StartDate', this.METANGA_NAMESPACE);
			mps.unitPrices = new List<MetangaUnitPrice>();
			// Loop through potential multi-UnityPrices
			for(Dom.XmlNode unitPriceNode :unitPricesElement.getChildElements()){
				Map<String,String> unitPriceMap = XMLHelper.xmlMapNode(unitPriceNode, 'Price', this.METANGA_NAMESPACE, 'KeyValueOfstringdecimal');
				for(String key : unitPriceMap.keySet()){
					MetangaUnitPrice unitPrice = new MetangaUnitPrice();
					unitPrice.currencyCode = key;
					unitPrice.price = unitPriceMap.get(key);
					mps.unitPrices.add(unitPrice);
				}
			}
			mpsList.add(mps);
		}
		
		this.product.priceSchedules = mpsList;
		*/
	}
}