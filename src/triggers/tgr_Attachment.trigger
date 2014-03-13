trigger tgr_Attachment on Attachment (after insert,before delete) {
    String propertySuffix = Property__c.SObjectType.getDescribe().getKeyPrefix();
    Map<Id,Id> propertyToAttachmentId = new Map<Id,Id>();
    if(Trigger.isInsert){
        for(Attachment a : Trigger.New){
        	if(a.Name.contains('.jpg') || a.Name.contains('.png') || a.Name.contains('.jpeg') || a.Name.contains('.tiff')){
	            if(string.valueOf(a.parentId).contains(propertySuffix)  && propertyToAttachmentId.containskey(a.parentId) == false){
	            	if(a.Name.startswith('p_')){
	            		propertyToAttachmentId.put(a.parentId, a.id);
	            	}else{
	            		for(Property__c p: [Select id  from Property__c where id =:a.parentId AND Image_Attachment_Id__c = null]){
	            			propertyToAttachmentId.put(a.parentId, a.id);	
	            		}
	            	}
	            }
        	}
        }
    }else{
        for(Attachment a : Trigger.Old){
            if(string.valueOf(a.parentId).contains(propertySuffix) && propertyToAttachmentId.containskey(a.parentId) == false){
                propertyToAttachmentId.put(a.parentId, a.id);
            }
        }
    }   
    
    if(propertyToAttachmentId.size() > 0){  
        List<Property__c> properties = new List<Property__c>();
        if(Trigger.isInsert){
            for(Property__c p :[Select id from Property__c where id in:propertyToAttachmentId.keyset()]){
                p.Image_Attachment_Id__c = propertyToAttachmentId.get(p.id);
                properties.add(p);
            }
        }else{
            for(Property__c p :[Select id from Property__c where id in:propertyToAttachmentId.keyset() AND  Image_Attachment_Id__c in: propertyToAttachmentId.values()]){
                p.Image_Attachment_Id__c = null;
                properties.add(p);
            }
        }
        update properties;
    }
}