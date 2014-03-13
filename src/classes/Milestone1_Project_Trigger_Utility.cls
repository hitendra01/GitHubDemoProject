public with sharing class Milestone1_Project_Trigger_Utility {
    
    //TODO What happens if we don't do this?  Do projects get out of sync with the Milestones 
    //if the projects change or is that just when milestones change?
    //this is more of a general truing utility than something that needs to run
    //with every project update
    public static void handleProjectUpdateTrigger( List<Escrow__c> recs ){
        
        //Milestone1_GoogleChartUtility googleChartUtility = new Milestone1_GoogleChartUtility();
         
        Map<Id, Escrow__c> projectsById = new Map<Id, Escrow__c>();
        
        for( Escrow__c rec : recs ){
            System.debug('*** Project "' + rec.Name + '" with Id ' + rec.Id + ' begin trigger');
            projectsById.put(rec.Id, rec);
            rec.Number_of_Incomplete_Top_Milestones__c = 0;
            rec.Number_of_Incomplete_Milestones__c = 0;
            rec.Next_Project_Top_Milestone_Due_Date__c = null;
            rec.Next_Project_Milestone_Due_Date__c = null;
            rec.Total_Hours_Incurred__c = 0;
            rec.Total_Hours_Estimate__c = 0;
            rec.Total_Expense_Incurred__c = 0;
            rec.Total_Expense_Estimate__c = 0;
            rec.Total_Hours_Budget_from_Milestones__c = 0;
            rec.Total_Expense_Budget_from_Milestones__c = 0;
            rec.Total_Complete_Task_Count__c = 0;
            rec.Total_Open_Task_Count__c = 0;
            rec.Total_Blocked_Task_Count__c = 0;
            rec.Total_Late_Task_Count__c = 0;
            //rec.GoogleGanntUrl__c = GoogleChartUtility.getGoogleGannt( rec ); //Was removed for bulkify issue, cant do Querys into loops.
        }
        
        //Here we calls GoogleChartUtility.getGoogleGanntList with a List of recs
        //recs = GoogleChartUtility.getGoogleGanntList( recs ); 
        
        System.debug('*** project key set: ' + projectsById.keySet());
        
        List<Milestone1_Milestone__c> milestones = [SELECT Id,
                                                           Name,
                                                           Escrow__c,
                                                           Parent_Milestone__c,
                                                           Complete__c,
                                                           Deadline__c,
                                                           Total_Actual_Hours__c,
                                                           Total_Estimated_Hours__c,
                                                           Total_Actual_Expense__c,
                                                           Total_Estimated_Expense__c,
                                                           Total_Hours_Budget__c,
                                                           Total_Expense_Budget__c,
                                                           Total_Complete_Tasks__c,
                                                           Total_Open_Tasks__c,
                                                           Total_Late_Tasks__c,
                                                           Total_Blocked_Tasks__c
                                                    FROM Milestone1_Milestone__c
                                                    WHERE Escrow__c IN :projectsById.keySet()
                                                   ];
        System.debug('*** milestones queried for projects: ' + milestones.size());
        
        for(Milestone1_Milestone__c ms : milestones){
            Escrow__c proj = projectsById.get(ms.Escrow__c);
            System.debug('*** Adding values to project from ' + ms.Name);
            System.debug('*** Old values: ' + proj);
            System.debug('*** Values being added: ' + ms);
            if(ms.Complete__c == false){
                proj.Number_of_Incomplete_Milestones__c++;
                if(ms.Parent_Milestone__c == null){
                    proj.Number_of_Incomplete_Top_Milestones__c++;
                }
                if(ms.Deadline__c != null){
                    System.debug('*** Deadline found: ' + ms.Deadline__c);
                    if(proj.Next_Project_Milestone_Due_Date__c == null){
                        System.debug('*** adopting deadline as initial due date');
                        proj.Next_Project_Milestone_Due_Date__c = ms.Deadline__c;
                    } else if(ms.Deadline__c < proj.Next_Project_Milestone_Due_Date__c){
                        System.debug('*** adopting deadline as new due date');
                        proj.Next_Project_Milestone_Due_Date__c = ms.Deadline__c;
                    }
                    if(ms.Parent_Milestone__c == null){
                        System.debug('*** milestone is top');
                        if(proj.Next_Project_Top_Milestone_Due_Date__c == null){
                            System.debug('*** adopting deadline as initial top due date');
                            proj.Next_Project_Top_Milestone_Due_Date__c = ms.Deadline__c;
                        } else if(ms.Deadline__c < proj.Next_Project_Top_Milestone_Due_Date__c){
                            System.debug('*** adopting deadline as new top due date');
                            proj.Next_Project_Top_Milestone_Due_Date__c = ms.Deadline__c;
                        }
                    }
                }
            }
            if(ms.Parent_Milestone__c == null){
                proj.Total_Hours_Incurred__c += ms.Total_Actual_Hours__c;
                proj.Total_Hours_Estimate__c += ms.Total_Estimated_Hours__c;
                proj.Total_Expense_Incurred__c += ms.Total_Actual_Expense__c;
                proj.Total_Expense_Estimate__c += ms.Total_Estimated_Expense__c;
                proj.Total_Hours_Budget_from_Milestones__c += ms.Total_Hours_Budget__c;
                proj.Total_Expense_Budget_from_Milestones__c += ms.Total_Expense_Budget__c;
                proj.Total_Complete_Task_Count__c += ms.Total_Complete_Tasks__c;
                proj.Total_Open_Task_Count__c += ms.Total_Open_Tasks__c;
                proj.Total_Blocked_Task_Count__c += ms.Total_Blocked_Tasks__c;
                proj.Total_Late_Task_Count__c += ms.Total_Late_Tasks__c;
            }
            System.debug('*** New values: ' + proj);
        }
        
    }


	//cascade delete from Project to Milestones (which then goes to Tasks, Times, Expenses, etc.)
    public static void handleProjectDeleteTrigger(List<Escrow__c> recs){
        Map<Id, Escrow__c> projectsById = new Map<Id, Escrow__c>();
        for(Escrow__c rec : recs){
            System.debug('*** Project "' + rec.Name + '" with Id ' + rec.Id + ' begin delete trigger');
            projectsById.put(rec.Id, rec);
        }
        
        List<Milestone1_Milestone__c> milestones = [SELECT Id
                                                    FROM Milestone1_Milestone__c
                                                    WHERE Escrow__c IN :projectsById.keySet()
                                                   ];
        
        // Delete / Batch delete milestones
        if( milestones.size() > 0 ){
	    	if( milestones.size() + Limits.getDMLRows() > Limits.getLimitDmlRows() ){
				Database.executeBatch( new Milestone1_Milestone_Batch_Delete(milestones) );
			}
			else{
		        delete milestones;
			}
        }
    }

    
    /**
    * Avoid duplicates names
    * @param triggerList
    */
    public static void handleProjectInsertTrigger( List<Escrow__c> triggerList ){
    	List<String> nameList = new List<String>();
    	for( Escrow__c tm : triggerList ){ nameList.add( tm.Name ); }
    	Integer projectCount = [SELECT count() FROM Escrow__c WHERE Name IN: nameList limit 1];
    	
    	//TODO Flesh out to be more specific -- right now this flags every project as problematic even if only one has a duplicate name
    	if( projectCount > 0 ) {
    		for( Escrow__c tm : triggerList ){ 
    			tm.Name.addError( 'Project Name is already used.' );
    		}
    	}
    	
    }
    
    /**
	* Test milestone delete
	*/
	public static testmethod void testMilestoneDelete(){
		// Create project
		Escrow__c project = Milestone1_Test_Utility.sampleProject('My Test Project');
		
		insert project;
		
		// Create milestones
		List<Milestone1_Milestone__c> mList = new List<Milestone1_Milestone__c>();
		
		for(Integer i = 0; i < 101; i++){
			mList.add( Milestone1_Test_Utility.sampleMilestone(project.Id, null, 'My Test Milestone ' + i) );
		}

		try{
			insert mList;
		}
		catch(Exception e){
			system.assert( false, e.getMessage() );
		}

		// Delete and check if it was successful
		try{
			Test.startTest();
			handleProjectDeleteTrigger( new List<Escrow__c>{ project } );
			Test.stopTest();
			
			system.assertEquals(0, [SELECT count() FROM Milestone1_Milestone__c WHERE Escrow__c = :project.Id]);
		}
		catch(Exception e){
			system.assert( false, e.getMessage() );
		}
	}
}