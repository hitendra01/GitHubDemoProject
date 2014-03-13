/**
 * Shrew Designs
 * This trigger will update Account Lookup field with Contact.Account from separate Contact lookup field 
 *
 *@author: Chetan Garg
 */ 
trigger Ownership_Contact_Trigger on Ownership__c (before insert) {
    Map<Id,List<Ownership__c>> mapOwnership = new Map<Id,List<Ownership__c>>();
    for(Ownership__c ownership : Trigger.New){
        if(mapOwnership .containskey(ownership.Contact__c)){
            mapOwnership.get(ownership.Contact__c).add(ownership);
        }else{
            mapOwnership.put(ownership.Contact__c, new List<Ownership__c>{ownership});
        }
    }
    
    if(mapOwnership.size() > 0){
        for(Contact con : [Select id,AccountId from Contact where id in: mapOwnership.keyset()]){
            for(Ownership__c ownership : mapOwnership.get(con.id)){
                ownership.CompanyTrigger__c = con.AccountId;
            }        
        }
    }

}