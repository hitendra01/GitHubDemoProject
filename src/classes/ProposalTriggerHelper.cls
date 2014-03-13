/**
 * Shrew Designs
 * Helper class for Proposal Trigger
 *
 *@author: Chetan Garg
 */ 
public class ProposalTriggerHelper {
	private static Map<Id,Id> pToAssignmentMapping;
	//Return Assignment recordType from Propsal RecordTypeId
	public static Id getAssignmentRecordType(Id proposalRecordType){
		if(pToAssignmentMapping == null){
			pToAssignmentMapping = new Map<Id,Id>();
			Map<String,ProposalRecordtypeMapping__c> mapping = ProposalRecordtypeMapping__c.getAll();
			Map<String,Id> mapAssignmentRecordType = new Map<String,Id>();
			for(RecordType rt :[select id, name from RecordType where sObjecttype = 'Listing__c']){
				mapAssignmentRecordType.put(rt.Name,rt.id);
			}
			
			for(RecordType rt :[select id, name from RecordType where sObjecttype = 'Proposal__c']){
				if(mapping.containskey(rt.Name)){
					pToAssignmentMapping.put(rt.id,
							 mapAssignmentRecordType.get(mapping.get(rt.Name).AssignmentRecordType__c)
							);
				}
			} 	
			
		}
		return pToAssignmentMapping.get(proposalRecordType);	
	}
	
	
}