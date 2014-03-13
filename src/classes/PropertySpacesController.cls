/*
This class contains methods for rendering the stacking plan.
*/

public with sharing class PropertySpacesController {

    public List<String> spaceNames;
    private ApexPages.StandardController stdController;
    public PropertySpacesController (ApexPages.StandardController stdController){
        this.stdController = stdController;
    }
    
    public map<string,list<Spaces__c>> getSpacesbyFloor(){
        map<string,list<Spaces__c>> FloorMap = new map<string,list<Spaces__c>>();
        for(Spaces__c s : getSpaces()){
            string Floor = s.Suite_Floor__c == null ? 'Unknown' : s.Suite_Floor__c.left(1);
            if(FloorMap.containsKey(Floor )){
                FloorMap.get(Floor).add(s);
            }else{
                FloorMap.put(Floor,new list<Spaces__c>{s});
            }
        }
        return FloorMap;
    }
    
    public map<string,decimal> getSquareFootagebyFloor(){
        map<string,decimal> SqFootageMap = new map<string,decimal>();
        for(Spaces__c s : getSpaces()){
            string Floor = s.Suite_Floor__c == null ? 'Unknown' : s.Suite_Floor__c.left(1);
            if(SqFootageMap.containsKey(Floor )){
                SqFootageMap.put(Floor, SqFootageMap.get(Floor) + s.Square_Footage__c);
            }else{
                SqFootageMap.put(Floor,s.Square_Footage__c);
            }
        }
        return SqFootageMap;
    }
    
    public transient list<Spaces__c> spaces;
    public list<Spaces__c> getSpaces(){
        if(spaces==null){
            spaces = [Select m.Suite_Floor__c, m.Status__c, m.Space_Sub_Type__c, m.Property_Type__c, m.Lease_Type__c, m.Lease_Term_Months__c, m.Lease_Expiration_Date__c, 
                m.Date_Available__c, m.Asking_Rate_PSF__c, m.Id, m.Square_Footage__c
                From Spaces__c m 
                WHERE m.Property__c = :stdController.getId()
                Order by m.Suite_Floor__c desc ];
        }
        return spaces;
    }

}