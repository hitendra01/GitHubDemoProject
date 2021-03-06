public with sharing class Milestone1_XML_Import_Utility {
    
    public with sharing class XML_Metadata {
     String ExportVersion;
     String ExportAuthor;
     String ExportPackage;
     String ExportOrganization;
     DateTime ExportCreateDate;
   }
    
    Escrow__c project;
    List<Milestone1_Milestone__c> milestones;
    List<Milestone1_Milestone__c> subMilestones;
    List<Escrow_Task__c> tasks;
    List<Escrow_Task__c> subTasks;
    //List<Milestone1_Time__c> times;
    XML_Metadata metadata = new XML_Metadata();

    public Milestone1_XML_Import_Utility()
    {
        project = new Escrow__c();
        milestones = new List<Milestone1_Milestone__c>();
        subMilestones = new List<Milestone1_Milestone__c>();
        tasks = new List<Escrow_Task__c>();
        subTasks = new List<Escrow_Task__c>();
        //times = new List<Milestone1_Time__c>();
    }
    
    public Escrow__c importProject(String xml) {
		
		Savepoint sp = Database.setSavepoint();
		try{        
	        Xmlstreamreader reader = new Xmlstreamreader(xml);
	        while (reader.hasNext()) {
	            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_META) {
	                //System.debug(LoggingLevel.warn, 'Parse XML Metadata');
	                parseMeta(reader);
	            } 
	            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_PROJECT) {
	                //System.debug(LoggingLevel.warn, 'Parse XML Project');
					parseProject(reader);
	            }           
	            reader.next();
	        }
	        insertSalesforceObjects();
		}catch(Exception ex){
			Database.rollback(sp);
			throw ex;
			//throw new Milestone1_Import_Exception(Milestone1_Import_Exception.ERROR_INVALID_XML);
		}
        return project;
    }

    private void insertSalesforceObjects()
    {
        //System.debug('Number of Milestones: ' + this.milestones.size());
        //System.debug('Number of Tasks: ' + this.tasks.size());
        if(project == null || project.Name == null || project.ImportID__c == null || project.ImportID__c.length() < 15)
        {
            throw new Milestone1_Import_Exception('The Project cannot be null. This is a critical error during import of XML. Please try exporting and re-importing.');
        }
        
        //attempt to validate 10 variations of the name
        String targetName = '%' + project.Name + '%';
        Integer existingLikeName = [Select Count() from Escrow__c where Name LIKE :targetName];
        if(existingLikeName!=null && existingLikeName > 0)
        {
            project.Name = project.Name + ' Copy ' + (existingLikeName +1);
        }
        
        insert project; 
        //system.debug('Project ID after insert == ' + project.Id);
        for(Milestone1_Milestone__c currentMilestone : milestones)
        {
            currentMilestone.Escrow__c = project.Id;
        }
        
        insert milestones;
        
        for(Milestone1_Milestone__c currentMilestone : milestones)
        {
            currentMilestone.Escrow__c = project.Id;
            matchMilestonesToMilestones(subMilestones,currentMilestone);
        }
        
        insert subMilestones;
        
        //System.debug('NUMBER OF TASKS == ' + tasks.size());
        for(Escrow_Task__c currentTask : tasks)
        {
            //System.debug('Task Parent Milestone ID == ' + currentTask.Project_Milestone__c);
            Boolean foundMatch = false;
            foundMatch = matchTaskToMilestone(milestones,currentTask);
            foundMatch = matchTaskToMilestone(subMilestones,currentTask);
        }
        
        insert tasks;
    }
    
    void matchMilestonesToMilestones(List<Milestone1_Milestone__c> milestones, Milestone1_Milestone__c currentMilestone){
        for(Milestone1_Milestone__c currentSubMilestone : milestones)
        {
            if(currentSubMilestone.Parent_Milestone__c == currentMilestone.ImportID__c)
            {
                currentSubMilestone.Parent_Milestone__c = currentMilestone.Id;
                currentSubMilestone.Escrow__c = currentMilestone.Escrow__c;
            }
        }
    }
    
    Boolean matchTaskToMilestone(List<Milestone1_Milestone__c> milestones, Escrow_Task__c currentTask){
        for(Milestone1_Milestone__c currentMilestone : milestones){
            if(currentTask.Project_Milestone__c == currentMilestone.ImportID__c){
                currentTask.Project_Milestone__c = currentMilestone.Id;
                return true;
            }
        }
        return false;
    }

	/*Boolean matchTimeToTask(List<Escrow_Task__c> tasks, Milestone1_Time__c currentTime){
		for(Escrow_Task__c currentTask : tasks){
			if(currentTime.Project_Task__c == currentTask.ImportID__c){
				currentTime.Project_Task__c = currentTask.Id;
				return true;
			}
		}
		return false;
	}*/
	
    void parseProject(Xmlstreamreader reader) {
        //name goes to name
        //id goes to importid
        //System.debug(LoggingLevel.warn, 'in Project');
        while (reader.hasNext()) {
            //handle name field
            //system.debug(reader.getLocalName());
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                //system.debug('Processing Project Name');
                reader.next();
                project.Name = getDecodedString(reader);
                if (project.Name.length() == 0) {
                    throw new Milestone1_Import_Exception('Invalid name (length cannot be zero)');
                } 
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                //system.debug('Processing Project Desc');
                reader.next();
                project.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Total_Hours_Budget__c') {
                //system.debug('Processing Project Est');
                reader.next();
                String val = getDecodedString(reader); 
                if(val == null || val == 'null')
                    val = '0.0';
                project.Total_Hours_Budget__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Total_Expense_Budget__c') {
                //system.debug('Processing Project Budg');
                reader.next();
                String val = getDecodedString(reader); 
                if(val == null || val == 'null')
                    val = '0.0';
                project.Total_Expense_Budget__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Status__c') {
                //system.debug('Processing Project Stat');
                reader.next();
                project.Status__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE) {
                //system.debug('Processing Project Milestone');
                reader.next();
                parseMilestone(reader,null);
                } 
            //handle import id field
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                //System.debug(LoggingLevel.warn, 'in id');
                reader.next();
                project.ImportId__c = getDecodedString(reader);
                //system.debug('Import ID == ' + project.ImportID__c);
                if (project.ImportId__c.length() > 15) {
                    project.ImportId__c = project.ImportId__c.substring(0,15);
                }
                if (project.ImportId__c.length() != 15) {
                    throw new Milestone1_Import_Exception('Invalid Import ID (length must be 15)');
                }
            }
            //validate that we're done
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_PROJECT){
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();
        }
    }
    
    void parseMilestone(Xmlstreamreader reader, Milestone1_Milestone__c parentMilestone)
    {
        
        Milestone1_Milestone__c currentMilestone = new Milestone1_Milestone__c();
        if(parentMilestone != null)
        {
            //System.debug(LoggingLevel.warn, 'in SUB Milestone');
            currentMilestone.Parent_Milestone__c = parentMilestone.ImportID__c;
        }else
        {
            //System.debug(LoggingLevel.warn, 'in Milestone');
        }
        currentMilestone.Escrow__c = project.ImportID__c;
        
        while (reader.hasNext()){
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                currentMilestone.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                currentMilestone.Name = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Expense_Budget__c') {
                reader.next();
                String val = getDecodedString(reader); 
                if(val == null || val == 'null')
                    val = '0.0';
                currentMilestone.Expense_Budget__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                currentMilestone.Description__c = getDecodedString(reader);
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Hours_Budget__c') {
                reader.next();
                String val = getDecodedString(reader); 
                if(val == null || val == 'null')
                    val = '0.0';
                currentMilestone.Hours_Budget__c = Decimal.valueOf(val);
            }
          
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE) {
                //system.debug('Processing Sub Milestone');
                reader.next();
                parseMilestone(reader,currentMilestone);
            } 
           
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TASK) {
                //system.debug('Processing Sub Tasks');
                reader.next();
                parseTask(reader,currentMilestone);
            } 
            //system.debug('Current Milestone ---- Name == ' + currentMilestone.Name + ' ImportID__c ' + currentMilestone.ImportID__c + ' Expense Budget ' + currentMilestone.Expense_Budget__c + ' Nag ' + currentMilestone.Nag__c + ' Description ' + currentMilestone.Description__c + ' Hours Budget ' + currentMilestone.Hours_Budget__c);
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE)
            {
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();
        }
        if(parentMilestone != null)
        {
            subMilestones.add(currentMilestone);
        }else
        {
            milestones.add(currentMilestone);
        }
    }
    
    void parseTask(XMLStreamreader reader, Milestone1_Milestone__c currentMilestone){
        Escrow_Task__c currentTask = new Escrow_Task__c();
        currentTask.Project_Milestone__c = currentMilestone.ImportID__c;
        while(reader.hasNext())
        {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                currentTask.ImportID__c = getDecodedString(reader); 
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                currentTask.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                currentTask.Name = getDecodedString(reader);
                if(currentTask.Name == null){system.debug('Name is NULL '); currentTask.Name = 'Name Blank';}
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Estimated_Hours__c') {
                reader.next();
                String val = getDecodedString(reader); 
                if(val == null || val == 'null')
                    val = '0.0';currentTask.Estimated_Hours__c = Decimal.valueOf(val);
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Estimated_Hours__c') {
                reader.next();
                String val = getDecodedString(reader); 
                if(val == null || val == 'null')
                    val = '0.0';currentTask.Estimated_Hours__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Estimated_Expense__c') {
                reader.next();
                String val = getDecodedString(reader); 
                if(val == null || val == 'null')
                    val = '0.0';
                currentTask.Estimated_Expense__c = Decimal.valueOf(val);
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TIME) {
                //system.debug('Processing Sub Milestone');
                reader.next();
                //parseTime(reader,currentTask);
            }
            
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TASK)
            {
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();      
        }
        
        tasks.add(currentTask);
    }
    
    /*void parseTime(XMLStreamreader reader, Escrow_Task__c currentTask){
        //Milestone1_Time__c currentTime = new Milestone1_Time__c();
        //currentTime.Project_Task__c = currentTask.ImportID__c;
        while(reader.hasNext())
        {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                currentTime.ImportID__c = getDecodedString(reader); 
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                currentTime.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Hours__c') {
                reader.next();
                String val = getDecodedString(reader); 
                if(val != null || val != 'null'){
                    currentTime.Hours__c = Decimal.valueOf(val);
                }
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TIME)
            {
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();      
        }
        //times.add(currentTime);
    }*/
    
    void parseMeta(Xmlstreamreader reader) {
        //system.debug('Process Metadata');
        while (reader.hasNext()) {
            //handle name field
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_VERSION) {
                reader.next();
                metadata.ExportVersion = getDecodedString(reader);
                //system.debug('Version == ' + metadata.ExportVersion);
                //system.debug('Org Version == ' + Milestone1_Constants.XML_EXPORT_VERSION_VAL);
                if(metadata.ExportVersion != Milestone1_Constants.XML_EXPORT_VERSION_VAL)
                {
                    //system.debug('Throw the Exception');
                    throw new Milestone1_Import_Exception('Invalid Version. This project was exported from a different version(' + metadata.ExportVersion + ') than this organizations version(' + Milestone1_Constants.XML_EXPORT_VERSION_VAL + '). Projects must be exported and imported in same version. ');
                }
            }   
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_PACKAGE) {
                reader.next();
                metadata.ExportPackage = getDecodedString(reader);
            }        
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_AUTHOR) {
                reader.next();
                metadata.ExportAuthor = getDecodedString(reader);
            }       
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_ORG) {
                reader.next();
                metadata.ExportOrganization = getDecodedString(reader);
            }       
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_DATE) {
                reader.next();
                metadata.ExportCreateDate = DateTime.valueOf(getDecodedString(reader));
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_META)
            {
                //system.debug('Break out of TASK');
                break;
            }
            reader.next();      
        }
    }
    
    String getDecodedString(Xmlstreamreader reader) {
        return EncodingUtil.urlDecode(reader.getText(), 'UTF-8').trim();
    }
}