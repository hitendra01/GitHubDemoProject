/**
 * Shrew Designs
 * Helper class for Project Trigger
 *@author: Chetan Garg
 */ 
public class EscrowTriggerHelper {
	//Project to Comp Record Type Mapping
	private static Map<Id,Id> escrowToCompRecordType;
	//Return Assignment recordType from Propsal RecordTypeId
	public static Id getCompRecordTypeId(Id projectRecordTypeId){
		if(escrowToCompRecordType == null){
			escrowToCompRecordType = new Map<Id,Id>();
			Map<String,ProjectRecordTypeMapping__c> mapping = ProjectRecordTypeMapping__c.getAll();
			Map<String,Id> mapSaleRecordType = new Map<String,Id>();
			for(RecordType rt :[select id, name from RecordType where sObjecttype = 'Sale__c']){
				mapSaleRecordType.put(rt.Name,rt.id);
			}
			
			for(RecordType rt : [select id, name from RecordType where sObjecttype = 'Escrow__c']){
				if(mapping.containskey(rt.Name)){
					escrowToCompRecordType.put(rt.id,
							 mapSaleRecordType.get(mapping.get(rt.Name).CompRecordType__c)
							);
				}
			} 	
			
		}
		return escrowToCompRecordType.get(projectRecordTypeId);	
	}
	
	
}