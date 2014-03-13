@isTest
private class Milestone1_Time_Trigger_Tst  
{
    static testMethod void testTimeTrigger()
    {
        Escrow__c proj = Milestone1_Test_Utility.sampleProject('proj');
        insert proj;
        
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        ms1.Alias__c = 'unit_test';
        insert ms1;
       
        Escrow_Task__c task1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        insert task1;
        
        
        
    }

}