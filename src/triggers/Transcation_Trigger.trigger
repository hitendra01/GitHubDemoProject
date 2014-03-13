trigger Transcation_Trigger on Transaction__c (after insert, before insert, before update) {
    Set<Id> tIds4Onrship = new Set<Id>();
    Set<Id> saleIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    if(Trigger.isAfter){
        if(Trigger.isInsert){
        system.debug('--Trigger.new--' + Trigger.new);
            for(Transaction__c p : Trigger.new){       
                if( p.Sale__c != null && (p.Role__c == 'Buyer' || p.Role__c == 'Seller')   
                 && ( p.Contact__c != null || p.Transcation_Company__c != null)
                       ){                        
                        
                    saleIds.add(p.Sale__c);
                    tIds4Onrship.add(p.id); 
                    contactIds.add(p.Contact__c);   
                }   
                    
            }
        }   
    }else  if(Trigger.isBefore){
        Map<Id,List<Transaction__c>> contactMap = new Map<Id,List<Transaction__c>>();
        if(Trigger.isInsert){
            for(Transaction__c p : Trigger.new){       
                if(contactMap.containskey(p.Contact__c)){
                    contactMap.get(p.Contact__c).add(p);
                }else{
                    contactMap.put(p.Contact__c,new List<Transaction__c>{p});
                }   
                    
            }
        }else if(Trigger.isUpdate){
            
            
            for(Transaction__c p : Trigger.new){       
                if(p.Contact__c != Trigger.OldMap.get(p.id).Contact__c){
                    if(contactMap.containskey(p.Contact__c)){
                        contactMap.get(p.Contact__c).add(p);
                    }else{
                        contactMap.put(p.Contact__c,new List<Transaction__c>{p});
                    }   
                }
                
                if( p.Sale__c != null && (p.Role__c == 'Buyer' || p.Role__c == 'Seller')                     
                    && ( (p.Contact__c != Trigger.OldMap.get(p.id).Contact__c  && p.Contact__c != null)
                            || (p.Transcation_Company__c != Trigger.OldMap.get(p.id).Transcation_Company__c  && p.Transcation_Company__c != null)
                            || (p.Sale__c != Trigger.OldMap.get(p.id).Sale__c)
                        
                        )){
                        
                        
                    saleIds.add(p.Sale__c);
                    tIds4Onrship.add(p.id); 
                    contactIds.add(p.Contact__c);   
                }   
            }
            
            
        }
        if(contactMap.size()> 0){
            for(Contact c : [Select id,AccountId from Contact where id in: contactMap.keyset()]){
                for(Transaction__c p : contactMap.get(c.id)){       
                    p.Transcation_Company__c = c.AccountId;
                }
            }
        }
        
    }
    system.debug('-tIds4Onrship ---' + tIds4Onrship);
        if(tIds4Onrship.size() > 0){
            Map<Id,Id> mapProperty = new Map<Id,Id>();
            for(Sale__c s : [Select id, Property__c from Sale__c where id in:saleIds ]){
                mapProperty.put(s.id, s.property__c);
            }
            system.debug('-mapProperty---' + mapProperty);
            List<Ownership__c> listOwnerships = new List<Ownership__c>();
            for(Ownership__c owner : [Select m.Property__c, m.Contact__c, m.Contact_Role__c 
                                                From Ownership__c m where Property__c in :mapProperty.values() 
                                                AND Contact__c IN :contactIds]){
                for(Transaction__c p : Trigger.new){
                    if(tIds4Onrship.contains(p.id) && mapProperty.get(p.Sale__c) == owner.Property__c && owner.Contact__c ==p.contact__c){
                        if(p.Role__c == 'Buyer'){
                            owner.Contact_Role__c = 'Owner'; 
                            owner.Primary_Contact__c = true;                              
                        }else if(p.Role__c == 'Seller'){
                            owner.Contact_Role__c = 'Former Owner';
                            owner.Primary_Contact__c = false;                              
                        }
                        listOwnerships.add(owner);
                        tIds4Onrship.remove(p.id);
                        break;
                    }
                }
            }
            system.debug('-listOwnerships---' + listOwnerships);
            for(Id tId: tIds4Onrship){
                Transaction__c p = Trigger.NewMap.get(tId);
                Ownership__c owner = new Ownership__c();
                owner.Property__c = mapProperty.get(p.Sale__c);
                owner.Contact__c = p.Contact__c;
                //owenr.Company__c = p.Transcation_Company__c;
                if(p.Role__c == 'Buyer'){
                    owner.Contact_Role__c = 'Owner'; 
                    owner.Primary_Contact__c = true;                              
                }else if(p.Role__c == 'Seller'){
                    owner.Contact_Role__c = 'Former Owner';
                    owner.Primary_Contact__c = false;                              
                }
                listOwnerships.add(owner);
                 
            }
            
            upsert listOwnerships;
        }
}