trigger Space_Trigger on Spaces__c (after delete, after insert, after update) {
    
    //Ids of Land Rep Assignment where Commision will be updated
    Set<Id> landRepAssignmentIds = new Set<Id>();
    if(Trigger.isInsert){
        for(Spaces__c space : Trigger.New){
            if(space.Landlord_Representation_Assignment__c != null){
                landRepAssignmentIds.add(space.Landlord_Representation_Assignment__c);
            }
        }
    }else if(Trigger.isupdate){
        for(Spaces__c space : Trigger.New){
            if(space.Landlord_Representation_Assignment__c != null 
                    &&  space.Commission_Factor__c != Trigger.OldMap.get(space.id).Commission_Factor__c){
                landRepAssignmentIds.add(space.Landlord_Representation_Assignment__c);
            }
        }
    }else if(Trigger.isDelete){
        for(Spaces__c space : Trigger.Old){
            if(space.Landlord_Representation_Assignment__c != null){
                landRepAssignmentIds.add(space.Landlord_Representation_Assignment__c);
            }
        }
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