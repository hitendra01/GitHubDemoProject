public class McLabsObjects {

    public class ListingObject {
        public String  id;
        public String  name;

        public String  status;
        public Decimal askingPrice;
        
        public String  notes;
        public String  rcm1id;
        public String  loanType;
        public String  loanPerformance;
        public String  interestRate;
        public String  projectType;

        public PropertyObject property;
        public BrokerObject[] brokers = new List<BrokerObject>();
    }
    
    public class PropertyObject {
        public String streetAddress;
        public String city;
        public String state;
        public String zipCode;
        public String county;
        public String country;
        
        public String recordTypeId;
        public String primaryUse;
        
        public String yearBuilt;
        public Integer squareFootage;
        public Decimal landAcres;
        
        public Decimal occupancy;
        public String clazz;
        

        public String unitType;
        public Integer units;
        public Integer rooms;
        public Integer parkingSpaces;
    }
    
    public class BrokerObject {
        public String email;
    }
    
    public class BuyerObject {
        public String rcm1id;
        public String firstName;
        public String lastName;
        public String email;
        public String industryRole;
        public String company;
        public String streetAddress;
        public String city;
        public String state;
        public String zipCode;
        public String country;
        public String phone;
        public String extension;
        public String fax;
        public String mobile;
    }
    
    public class ActivityObject {
        public String email;
        public Date actDate;
        public String action;
    }
    
}