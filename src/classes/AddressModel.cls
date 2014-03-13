/**
@ name            AddressModel
@ author          iBirds Services
@ date            14 May, 2011
@ description     The model which contains the addresses info like info, lat, long and address
*/
public class AddressModel{
    public List<Address> addresslist {get;set;}
    public string getDefault(){
        if(addresslist.size() > 0)
            return addresslist.get(0).address;
        return '';
    }
    public AddressModel(){
        addresslist = new List<Address>();    
    }
    public void add(string address, string lat, string lng, string info){
        addresslist.add(new Address(address, lat, lng, info));
    }
    public class Address{
        public string address {get;set;}
        public string lat {get;set;}
        public string lng {get;set;}
        public string info {get;set;}
        
        public Address(string address, string lat, string lng, string info){
            this.address = address;
            this.lat = lat;
            this.lng = lng;
            this.info = info;
        }
    }
    
    private static testMethod void test(){
    	AddressModel am = new AddressModel();
    	am.getDefault();
    	am.add('address','lat','lng','info');
    	am.getDefault();
    }
}