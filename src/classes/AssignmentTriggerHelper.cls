/**
 * Shrew Designs
 * Helper class for Assignment Trigger
 *@author: Chetan Garg
 */ 
public class AssignmentTriggerHelper {
	
	public static boolean hasRun = false;
	
	public static Map<Id,RecordType> AssignmentRecordType;
	
	static{
		AssignmentRecordType = new Map<Id,RecordType>([Select r.SobjectType, r.NamespacePrefix, r.Name, r.DeveloperName 
										From RecordType r Where sObjectType ='Listing__c']);
	}
	
	//Assignment to Project Record Type Mapping
	private static Map<Id,Id> aToProjectRtMapping;
	//Return Assignment recordType from Propsal RecordTypeId
	public static Id getProjectRecordTypeId(Id listingRecordTypeId){
		if(aToProjectRtMapping == null){
			aToProjectRtMapping = new Map<Id,Id>();
			Map<String,AssignmentRecordTypeMapping__c> mapping = AssignmentRecordTypeMapping__c.getAll();
			Map<String,Id> mapProjectTypeRecord = new Map<String,Id>();
			for(RecordType rt :[select id, name from RecordType where sObjecttype = 'Escrow__c']){
				mapProjectTypeRecord.put(rt.Name,rt.id);
			}
			
			for(RecordType rt :AssignmentRecordType.values()){
				if(mapping.containskey(rt.Name)){
					aToProjectRtMapping.put(rt.id,
							 mapProjectTypeRecord.get(mapping.get(rt.Name).ProjectRecordType__c)
							);
				}
			} 	
			
		}
		return aToProjectRtMapping.get(listingRecordTypeId);	
	}
	
	
	/*
	*	When a Property is added to the Property Lookup field on a Landlord Representation Assignment record type, 
	*	Query all spaces associated with the Property and update their Landlord Representation Assignment lookup to match
	*/	
	public static void runListingTrigger(Map<Id,Listing__c> oldListingMap, List<Listing__c> listings, Boolean isInsert){
		//Ids of Land Rep Assignment where Commision will be updated
		Set<Id> landRepAssignmentIds = new Set<Id>();
		Map<Id,Id> mapPropertyAssignments = new Map<Id,Id>();
		for(Listing__c assignment: listings){
			Listing__c oldListing = (isInsert ? new Listing__c() : oldListingMap.get(assignment.id));
			if(oldListing.Property__c != assignment.Property__c && assignment.Property__c != null 
					&& AssignmentRecordType.get(assignment.RecordTypeId).developerName == 'Landlord_Representation'){
				mapPropertyAssignments.put(assignment.Property__c, assignment.id);
			}
			
			if(isInsert == false && assignment.Commission_Factor__c != oldListingMap.get(assignment.id).Commission_Factor__c){
				landRepAssignmentIds.add(assignment.id);
			}
		}
		
		if(mapPropertyAssignments.size() > 0){
			List<Spaces__c> spaces = new List<Spaces__c>();
			for(Spaces__c space : [Select id, Property__c, Landlord_Representation_Assignment__c 
								From Spaces__c 
								where Property__c in :mapPropertyAssignments.keyset()]){
				space.Landlord_Representation_Assignment__c = mapPropertyAssignments.get(space.Property__c);
				spaces.add(space);
			} 
			update spaces;
		}
		
		
		//Roll-on Logic
		if(landRepAssignmentIds.size() > 0){
			List<Listing__c> masterLRAssingments = new List<Listing__c>();
			for(Listing__c listing : [Select m.Commission_Input__c, Commission_Factor__c
										, (Select Commission_Factor__c From Spaces__r where Commission_Factor__c <> 0 AND Commission_Factor__c <> null) 
									From Listing__c m where id in:landRepAssignmentIds ]){
				decimal commission = 0;
				for(Spaces__c space : listing.Spaces__r){
					commission = listing.Commission_Factor__c * space.Commission_Factor__c;
				}
				listing.Commission_Input__c = commission;
			}
			
			update masterLRAssingments;
			
		}
	}
}