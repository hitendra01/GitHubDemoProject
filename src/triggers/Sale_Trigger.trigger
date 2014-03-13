/**
* Revision : Shrew Designs (04/14/2013)  Updates the Space. Available__c to False when a Lease Comp is created. 
* Revision : Shrew Designs (04/14/2013)  When a new Comp ( Record Type = Sale) is created or edited and the Last
*                                        Sale Date is the most recent of the associated Sale Comps a new trigger should update each 
*                                        of the two fields above with the Last Sale Date (populated from the Comp.Sale_Date__c) 
*                                        and Last Sale Price (Updated from Comp.Sale_Price__c)
**/
trigger Sale_Trigger on Sale__c (before insert, before update, after insert,after update) {
    if(Trigger.isAfter){
        //This list hold all the sold properties  of Sale Comp Id (where Sale Price or sale date is insert/changed)
        Map<Id,Property__c> soldProperties = new Map<Id,Property__c>();
        Map<Id,Sale__c> mapPropertySale = new Map<Id,Sale__c>();
        Set<Id> externalRecordTypes = new Set<Id>();
        for(RecordType rt : [Select id ,developername from RecordType where sObjectType = 'Sale__c' and developerName in('Lease_External' ,'Sale_External')]){
            externalRecordTypes.add(rt.id);
        }
           List<Spaces__c> spaces = new List<Spaces__c>();
        //After Insert Trigger
        if(Trigger.isInsert && Trigger.isAfter){
            List<Commission__c> commissionList = new List<Commission__c>();
         
            
            for(Sale__c p :  trigger.new){
                if(p.System_Commis__c != true && externalRecordTypes.contains(p.recordTypeId) == false){
                    Commission__c comm = new Commission__c();
                    comm.broker__c = p.OwnerId;
                    comm.sale__c = p.id;
                    commissionList.add(comm);
                }
                
                //ShewDesigns(04/14/2013) Find Spaces for the comp where Record Type = 'Sale'
                if(p.RecordTypeId == RecordTypeManager.leaseCompRecordTypeId && p.Space__c != null){
                    Spaces__c space = new Spaces__c(id = p.Space__c);
                    space.Available__c = false;
                    space.Current_Tenant__c = p.Tenant__c;
                    space.Current_Lease__c = p.Lease_Type__c;
                    space.Lease_Expiration_Date__c = p.Lease_Expiration_Date__c;
                    space.Current_Rental_Rate__c  = p.Rental_Rate__c;
                    space.Current_Rental_Rate_Type__c = p.Rental_Rate_Type__c;                  
                    spaces.add(space);
                } 
                
                //ShewDesigns(04/14/2013) Find Sale Comp where Sale Price or sale date is insert/changed) and add it to soldProperties
                if(p.RecordTypeId == RecordTypeManager.saleCompRecordTypeId && p.Property__c != null){
                    Property__c property = new Property__c(id = p.Property__c);
                    //if(soldProperties.containsKey(p.Property__c)){
                        //property = soldProperties.get(p.Property__c);
                    //}
                    //property.Last_Sale_Price__c = p.Sale_Price__c;
                    //property.Last_Sale_Date__C = p.Sale_Date__c;
                    //soldProperties.put(p.Property__c, property);
                    mapPropertySale.put( p.Property__c, p);
                }
            }   
            upsert commissionList;
            
            //ShewDesigns(04/14/2013) Update space.Available__c = false
            //-Tenant Company pushes to Current Tenant (New Space Field)
            //-Rental Rate pushes to Current Rental Rate (New Space Field)
            //-Rental Rate Type pushes to Current Rental Rate Type(New Space Field)
            //-Lease Type pushes to Current Current Lease (New Space Field)
            //-Lease Expiration Date pushes to Current Lease Expiration Date (New Space Field)
            if(spaces.size() > 0){
                update spaces;
            }
        }
        
        //After Update Trigger
        if(Trigger.isAfter && Trigger.isUpdate){
            for(Sale__c comp : Trigger.New){
                //If Sale Comp 's Sale Price or Sale Date is changed,  
                if(comp.recordTypeId == RecordTypeManager.saleCompRecordTypeId && 
                        ( (comp.Sale_Price__c != null && comp.Sale_Price__c != Trigger.OldMap.get(comp.id).Sale_Price__c)
                            ||
                             (comp.Sale_Date__c != null && comp.Sale_Date__c != Trigger.OldMap.get(comp.id).Sale_Date__c)
                        )){
                    //Update assoicated Property's Last Sale Date and Last Sale Price
                    //Property__c property = new Property__c(id = comp.Property__c);
                    //if(soldProperties.containsKey(comp.Property__c)){
                        //property = soldProperties.get(comp.Property__c);
                    //}
                    //property.Last_Sale_Price__c = comp.Sale_Price__c;
                    //property.Last_Sale_Date__C = comp.Sale_Date__c;
                    
                    
                    //soldProperties.put(comp.Property__c, property);
                    mapPropertySale.put( comp.Property__c, comp);
                    
                }   
                
                //ShewDesigns(04/14/2013) Find Spaces for the comp where Record Type = 'Sale'
                if(comp.RecordTypeId == RecordTypeManager.leaseCompRecordTypeId && comp.Space__c != null){
                    Spaces__c space = new Spaces__c(id = comp.Space__c);
                    space.Available__c = false;
                    space.Current_Tenant__c = comp.Tenant__c;
                    space.Current_Lease__c = comp.Lease_Type__c;
                    space.Lease_Expiration_Date__c = comp.Lease_Expiration_Date__c;
                    space.Current_Rental_Rate__c  = comp.Rental_Rate__c;
                    space.Current_Rental_Rate_Type__c = comp.Rental_Rate_Type__c;
                    spaces.add(space);
                } 
            }
            
            if(spaces.size() > 0){
                update spaces;
            }
        }
        
        
        //Update Sold Properties
        if(mapPropertySale.size() > 0){
            for(Property__c p : [Select id, Last_Sale_Price__c, Last_Sale_Date__C from Property__c where id in: mapPropertySale.keyset()]){
                Date pDate = p.Last_Sale_Date__C;
                Sale__c sale = mapPropertySale.get(p.id);
                if(pDate != null && pDate > sale.Sale_Date__c){
                    //Do nothing
                }else{
                    p.Last_Sale_Price__c = sale.Sale_Price__c;
                    p.Last_Sale_Date__C = sale.Sale_Date__c;
                    soldProperties.put(sale.Property__c, p);
                }
            }
	        try{
	            update soldProperties.values();
	        }catch(exception ex){
	        	Trigger.New[0].addError('Error updating related Property: '+ex.getMessage());
	        }
        }
    }else if(Trigger.isBefore){
        Map<Id,List<Sale__c>> contactMapBuyer = new Map<Id,List<Sale__c>>();
        Map<Id,List<Sale__c>> contactMapLandlord = new Map<Id,List<Sale__c>>();
        Map<Id,List<Sale__c>> contactMapSeller = new Map<Id,List<Sale__c>>();
        Map<Id,List<Sale__c>> contactMapTenant = new Map<Id,List<Sale__c>>();
        if(Trigger.isInsert){
            for(Sale__c p : Trigger.new){       
                if(contactMapBuyer.containskey(p.Buyer__c) && p.Buyer__c != null){
                    contactMapBuyer.get(p.Buyer__c).add(p);
                }else if(p.Buyer__c != null){
                    contactMapBuyer.put(p.Buyer__c,new List<Sale__c>{p});
                }  
                
                if(contactMapLandlord.containskey(p.Landlord_Contact__c) && p.Landlord_Contact__c != null){
                    contactMapLandlord.get(p.Landlord_Contact__c).add(p);
                }else if(p.Landlord_Contact__c != null){
                    contactMapLandlord.put(p.Landlord_Contact__c,new List<Sale__c>{p});
                }  
                
                if(contactMapSeller.containskey(p.Seller__c) && p.Seller__c != null){
                    contactMapSeller.get(p.Seller__c).add(p);
                }else if(p.Seller__c != null){
                    contactMapSeller.put(p.Seller__c,new List<Sale__c>{p});
                } 
                
                if(contactMapTenant.containskey(p.Tenant_Contact__c) && p.Tenant_Contact__c != null){
                    contactMapTenant.get(p.Tenant_Contact__c).add(p);
                }else if(p.Tenant_Contact__c != null){
                    contactMapTenant.put(p.Tenant_Contact__c,new List<Sale__c>{p});
                }    
                    
            }
        }else if(Trigger.isUpdate){
            for(Sale__c p : Trigger.new){       
                if(p.Landlord_Contact__c != Trigger.OldMap.get(p.id).Landlord_Contact__c && p.Landlord_Contact__c != null){
                    if(contactMapLandlord.containskey(p.Landlord_Contact__c)){
                        contactMapLandlord.get(p.Landlord_Contact__c).add(p);
                    }else{
                        contactMapLandlord.put(p.Landlord_Contact__c,new List<Sale__c>{p});
                    }   
                }
                
                if(p.Buyer__c != Trigger.OldMap.get(p.id).Buyer__c && p.Buyer__c != null){
                    if(contactMapBuyer.containskey(p.Buyer__c)){
                        contactMapBuyer.get(p.Buyer__c).add(p);
                    }else{
                        contactMapBuyer.put(p.Buyer__c,new List<Sale__c>{p});
                    }   
                }
                
                
                if(p.Seller__c != Trigger.OldMap.get(p.id).Seller__c && p.Seller__c != null){
                    if(contactMapSeller.containskey(p.Seller__c)){
                        contactMapSeller.get(p.Seller__c).add(p);
                    }else{
                        contactMapSeller.put(p.Seller__c,new List<Sale__c>{p});
                    }   
                }
                
                
                if(p.Tenant_Contact__c != Trigger.OldMap.get(p.id).Tenant_Contact__c && p.Tenant_Contact__c != null){
                    if(contactMapTenant.containskey(p.Tenant_Contact__c)){
                        contactMapTenant.get(p.Tenant_Contact__c).add(p);
                    }else{
                        contactMapTenant.put(p.Tenant_Contact__c,new List<Sale__c>{p});
                    }   
                }   
            }
        }
        for(Contact c : [Select id,AccountId from Contact 
                where id in: contactMapBuyer.keyset() OR id in: contactMapLandlord.keyset() OR id in: contactMapSeller.keyset() 
                    OR id in:  contactMapTenant.keyset()]){
            
            if(contactMapBuyer.containskey(c.id)){
                for(Sale__c p : contactMapBuyer.get(c.id)){       
                    p.Buyer_Company__c = c.AccountId;
                }
            }
            
            if(contactMapLandlord.containskey(c.id)){
                for(Sale__c p : contactMapLandlord.get(c.id)){       
                    p.Landlord__c = c.AccountId;
                }
            }
            
            if(contactMapSeller.containskey(c.id)){
                for(Sale__c p : contactMapSeller.get(c.id)){       
                    p.Seller_Company__c = c.AccountId;
                }
            }
            
            if(contactMapTenant.containskey(c.id)){
                for(Sale__c p : contactMapTenant.get(c.id)){       
                    p.Tenant__c = c.AccountId;
                }
            }
        }
        
        if(Trigger.isUpdate && Trigger.isAfter){
            
            for(Sale__c sale : Trigger.New){
                
            }   
        }
        
    } 
    
    if(Trigger.isAfter){
    	//Update Related Transcation's Buyer/Seller if Sale.Buyer or Sale.Seller get updated
        Set<Id> saleIdsForbuyers = new Set<Id>();
        Set<Id> saleIdsForSellers = new Set<Id>();    
	    if(Trigger.isUpdate){
	            
	            for(Sale__c sale : Trigger.New){
	                if( (sale.Seller__c != Trigger.OldMap.get(Sale.id).Seller__c  && sale.Seller__c != null)
	                    || (sale.Seller_Company__c != Trigger.OldMap.get(Sale.id).Seller_Company__c  && sale.Seller_Company__c != null)){
	                    saleIdsForSellers.add(sale.Id);
	                }
	                
	                if( (sale.Buyer__c != Trigger.OldMap.get(Sale.id).Buyer__c  && sale.Buyer__c != null)
	                    || (sale.Buyer_Company__c != Trigger.OldMap.get(Sale.id).Buyer_Company__c  && sale.Buyer_Company__c != null)){
	                    saleIdsForbuyers.add(sale.Id);
	                }
	            }
	    }else if(Trigger.isInsert) {
	    	for(Sale__c sale : Trigger.New){
	                if( sale.Seller__c != null || sale.Seller_Company__c != null){
	                    saleIdsForSellers.add(sale.Id);
	                }
	                
	                if( sale.Buyer__c != null || sale.Buyer_Company__c != null){
	                    saleIdsForbuyers.add(sale.Id);
	                }
	                
	            }
	    }
	        
            if(saleIdsForSellers.size() > 0 || saleIdsForbuyers.size() > 0){
                List<Transaction__c> transcations = new List<Transaction__c>();
                for(Transaction__c t : [Select id, Role__c , Sale__c from Transaction__c 
                            where role__c in('Buyer','Seller') AND (Sale__c in:saleIdsForSellers OR Sale__c in:saleIdsForbuyers)]){
                    if(saleIdsForSellers.contains(t.sale__c)){
                        t.Contact__c = Trigger.NewMap.get(t.sale__c).Seller__c;
                        t.Transcation_Company__c = Trigger.NewMap.get(t.sale__c).Seller_Company__c;
                        saleIdsForSellers.remove(t.sale__c);
                    }
                    
                    if(saleIdsForbuyers.contains(t.sale__c)){
                        t.Contact__c = Trigger.NewMap.get(t.sale__c).Buyer__c;
                        t.Transcation_Company__c = Trigger.NewMap.get(t.sale__c).Buyer_Company__c;
                        saleIdsForbuyers.remove(t.sale__c);
                    }
                    transcations.add(t);
                }
                
                for(Id saleId : saleIdsForSellers){
            		Transaction__c t = new Transaction__c();
            		 t.Contact__c = Trigger.NewMap.get(saleId).Seller__c;
                     t.Transcation_Company__c = Trigger.NewMap.get(saleId).Seller_Company__c;
                     t.Sale__c = saleId;
                     t.Role__c = 'Seller';
                     transcations.add(t);
            	}  
            	
            	for(Id saleId : saleIdsForbuyers){
            		Transaction__c t = new Transaction__c();
            		 t.Contact__c = Trigger.NewMap.get(saleId).Buyer__c;
                     t.Transcation_Company__c = Trigger.NewMap.get(saleId).Buyer_Company__c;
                     t.Sale__c = saleId;
                     t.Role__c = 'Buyer';
                     transcations.add(t);
            	}  
                
                upsert transcations;
            }
            
             
        }
    
    
}