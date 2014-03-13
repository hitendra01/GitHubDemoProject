public with sharing class McLabsGalleryController {

    public List<String> images {get;set;}
    public boolean imageAvailable {get;set;}

    public McLabsGalleryController(ApexPages.StandardController stdController){
        images = new LIst<String>();
        imageAvailable = true;
        
        for(Attachment a :[SELECT Id FROM Attachment WHERE parentId = :stdController.getId() AND ContentType like '%image%']){
            images.add('/servlet/servlet.FileDownload?file=' + a.id);
        }
        
        if( images.size() == 0 )
        {
            images.add('/resource/noImage');
            imageAvailable = false;
        }
    }
    
    private static testMethod void test(){
        Property__c p = new Property__c();
        McLabsGalleryController controller = new McLabsGalleryController(new ApexPages.Standardcontroller(p));
    }
}