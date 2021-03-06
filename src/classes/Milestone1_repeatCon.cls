public with sharing class Milestone1_repeatCon {

 public List<SelectOption> filterList {get;set;}
 public String filterItem {get;set;}
 private final String ALL_ITEMS = 'All Items';
 private final String MY_TASKS = 'My Tasks Only';
 private final String MY_MILESTONES_ONLY = 'My Milestones Only';
 private final String MY_PROJECTS_AND_ITEMS = 'My Projects And Sub-Project Items';
 private Date currentDay;
  public void next() { 
    addMonth(1);
  }

  public void prev() { 
    addMonth(-1); 
  }

  public void fiveDayView()
  {
    setMonth(currentDay);
    month.getCurrentWeek(currentDay);
    month.fiveDayView = true; 
  
  }

  public void monthView()
  {
    month = new Milestone1_Month(currentDay);
    filter();
  }

  public Milestone1_repeatCon() {
 
   currentDay = system.today();  // default to today 
   Integer mo = currentDay.month(); 
   String m_param = System.currentPageReference().getParameters().get('mo');
   String y_param = System.currentPageReference().getParameters().get('yr');
   
   // allow a month to be passed in on the url as mo=10
   if (m_param != null) { 
        Integer mi = Integer.valueOf(m_param); 
        if (mi > 0 && mi <= 12) {
          currentDay = Date.newInstance(currentDay.year(),mi,currentDay.day());
        }
   }
   // and year as yr=2008
   if (y_param != null) { 
        Integer yr = Integer.valueOf(y_param); 
        currentDay = Date.newInstance(yr, currentDay.month(), currentDay.day());
   }
    
   filterList = new List<SelectOption>{new SelectOption(ALL_ITEMS,ALL_ITEMS),new SelectOption(MY_PROJECTS_AND_ITEMS,MY_PROJECTS_AND_ITEMS),new SelectOption(MY_TASKS,MY_TASKS),new SelectOption(MY_MILESTONES_ONLY,MY_MILESTONES_ONLY)};    
    
   setMonth(currentDay);
   fiveDayView();
  }
 
  public List<Milestone1_Month.Week> getWeeks() { 
    system.assert(month!=null,'month is null');
    return month.getWeeks();
  }
  
  public Milestone1_Month getMonth() { return month; } 


  public void filter()
  {
    List<Milestone1_Calendar_Item> filteredItems = new List<Milestone1_Calendar_Item>();
    month.clearEvents();
    if(filterItem == ALL_ITEMS)
    {
        filteredItems = getAllItems(month.getValidDateRange());
    }else if(filterItem == MY_TASKS)
    {
        filteredItems = getMyTasksOnly(month.getValidDateRange());
    }else if(filterItem == MY_MILESTONES_ONLY)
    { 
        filteredItems = getMyMilestonesOnly(month.getValidDateRange());
    }else if(filterItem == MY_PROJECTS_AND_ITEMS)
    {
        filteredItems = getMyProjectsAndItems(month.getValidDateRange());
    }
    month.setEvents(filteredItems);
  }

  private void setMonth(Date d) { 
    month = new Milestone1_Month(d);  
    system.assert(month != null); 
 
    Date[] da = month.getValidDateRange();  // gather events that fall in this month
    
    month.setEvents(getAllItems(da));  // merge those events into the month class
  }
  
  private List<Milestone1_Calendar_Item> getAllItems(Date[] da)
  {
    List<Escrow__c> projects = [Select Id, Close_of_Escrow__c, Name from Escrow__c where Close_of_Escrow__c >=:da[0] and Close_of_Escrow__c <= :da[1]];
    List<Milestone1_Milestone__c> milestones = [Select Id, Deadline__c, Name from Milestone1_Milestone__c where Deadline__c >=:da[0] and Deadline__c <= :da[1]];
    List<Escrow_Task__c> tasks = [Select Id, Due_Date__c, Name from Escrow_Task__c where Due_Date__c >=:da[0] and Due_Date__c <= :da[1]];
    List<Milestone1_Calendar_Item> events = new List<Milestone1_Calendar_Item>();
    for(Escrow__c proj : projects)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(proj.Id,proj.Name,proj.Close_of_Escrow__c,Milestone1_Calendar_Item.PROJECT_TYPE);
        events.add(calItem);
    }
    for(Milestone1_Milestone__c milestone : milestones)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(milestone.Id,milestone.Name,milestone.Deadline__c,Milestone1_Calendar_Item.MILESTONE_TYPE);
        events.add(calItem);
    }
    for(Escrow_Task__c currTask : tasks)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(currTask.Id,currTask.Name,currTask.Due_Date__c,Milestone1_Calendar_Item.TASK_TYPE);
        events.add(calItem);
    }
    return events;
  }
  
  private List<Milestone1_Calendar_Item> getMyProjectsAndItems(Date[] da)
  {
    List<Milestone1_Calendar_Item> events = new List<Milestone1_Calendar_Item>();
    
    List<Escrow__c> projects = [Select Id, Close_of_Escrow__c, Name from Escrow__c where Close_of_Escrow__c >=:da[0] and Close_of_Escrow__c <= :da[1] and OwnerId =:UserInfo.getUserId()];
    List<String> projectIds = new List<String>();
    for(Escrow__c proj : projects)
    {
        projectIds.add(proj.Id);
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(proj.Id,proj.Name,proj.Close_of_Escrow__c,Milestone1_Calendar_Item.PROJECT_TYPE);
        events.add(calItem);
    }
    
    List<Milestone1_Milestone__c> milestones = [Select Id, Deadline__c, Name from Milestone1_Milestone__c where Deadline__c >=:da[0] and Deadline__c <= :da[1] and Escrow__c in :projectIds];
    List<String> milestoneIds = new List<String>();
    for(Milestone1_Milestone__c milestone : milestones)
    {
        milestoneIds.add(milestone.Id);
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(milestone.Id,milestone.Name,milestone.Deadline__c,Milestone1_Calendar_Item.MILESTONE_TYPE);
        events.add(calItem);
    }
    
    List<Escrow_Task__c> tasks = [Select Id, Due_Date__c, Name from Escrow_Task__c where Due_Date__c >=:da[0] and Due_Date__c <= :da[1] and Project_Milestone__c in:milestoneIds];
    for(Escrow_Task__c currTask : tasks)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(currTask.Id,currTask.Name,currTask.Due_Date__c,Milestone1_Calendar_Item.TASK_TYPE);
        events.add(calItem);
    }
    
    return events;
  }

  private List<Milestone1_Calendar_Item> getMyMilestonesOnly(Date[] da)
  {
    List<Milestone1_Milestone__c> milestones = [Select Id, Deadline__c, Name from Milestone1_Milestone__c where Deadline__c >=:da[0] and Deadline__c <= :da[1] and OwnerId =:UserInfo.getUserId()];
    List<Milestone1_Calendar_Item> events = new List<Milestone1_Calendar_Item>();
    for(Milestone1_Milestone__c milestone : milestones)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(milestone.Id,milestone.Name,milestone.Deadline__c,Milestone1_Calendar_Item.MILESTONE_TYPE);
        events.add(calItem);
    }
    return events;
  }
  
  private List<Milestone1_Calendar_Item> getMyTasksOnly(Date[] da)
  {
    List<Escrow_Task__c> tasks = [Select Id, Due_Date__c, Name from Escrow_Task__c where Due_Date__c >=:da[0] and Due_Date__c <= :da[1] and Assigned_To__c =:UserInfo.getUserId()];
    List<Milestone1_Calendar_Item> events = new List<Milestone1_Calendar_Item>();
    for(Escrow_Task__c currTask : tasks)
    {
        Milestone1_Calendar_Item calItem = new Milestone1_Calendar_Item(currTask.Id,currTask.Name,currTask.Due_Date__c,Milestone1_Calendar_Item.TASK_TYPE);
        events.add(calItem);
    }
    return events;
  }
  
  
  private void addMonth(Integer val) { 
    Date d = month.getFirstDate();
    d = d.addMonths(val);
    setMonth(d);
  }

  private Milestone1_Month month;
  
  
  static testMethod void testController()
  {
        Escrow__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'In Escrow';
        testProject.Close_of_Escrow__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Escrow_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        system.assert(controller.getMonth() != null);
        system.assert(weeksList != null);
  }
  
  static testMethod void testControllerFilterTasks()
  {
        Escrow__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'In Escrow';
        testProject.Close_of_Escrow__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Escrow_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.filterItem = 'My Tasks Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        system.assert(controller.getMonth() != null);
        system.assert(weeksList != null);
  }
  
  static testMethod void testControllerFilterMilestones()
  {
        Escrow__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'In Escrow';
        testProject.Close_of_Escrow__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Escrow_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.filterItem = 'My Milestones Only';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        system.assert(controller.getMonth() != null);
        system.assert(weeksList != null);
  }
  
  static testMethod void testControllerFilterMyProjects()
  {
        Escrow__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.Status__c = 'In Escrow';
        testProject.Close_of_Escrow__c = Date.today();
        insert testProject;
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Deadline__c = Date.today();
        testMilestone.Complete__c = false;
        insert testMilestone;

        Escrow_Task__c testTask = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        testTask.Complete__c = false;
        testTask.Start_Date__c = Date.today();
        testTask.Due_Date__c = Date.today();
        insert testTask;
        test.startTest();
        Milestone1_repeatCon controller = new Milestone1_repeatCon();
        controller.next();
        controller.prev();
        controller.filterItem = 'My Projects And Sub-Project Items';
        controller.filter();
        List<Milestone1_Month.Week> weeksList = controller.getWeeks();
        test.stopTest();
        system.assert(controller.getMonth() != null);
        system.assert(weeksList != null);
  }
  
}