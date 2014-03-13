// This class controls the commission plan page
public with sharing class EditCommissionPlanController {
	
	public class SplitWrapper{
		public Commission_Plan_Split__c split {get; private set;}
		public Integer SplitNum{get; private set;}
		
		public SplitWrapper(Integer NewSplitNum, Decimal GrossCommissionStart, Id CompId){
			SplitNum = NewSplitNum;
			split = new Commission_Plan_Split__c(Gross_Commission_From__c = GrossCommissionStart, Commission_Plan__c = CompId);
		}
		
		public SplitWrapper(Integer NewSplitNum, Commission_Plan_Split__c existingSplit){
			splitNum = NewSplitNum;
			split = existingSplit;
		}
	}
	
	public class MemberWrapper{
		public Commission_Plan_Member__c member {get; private set;}
		public Integer MemberNum {get; private set;}
		
		public MemberWrapper(Integer NewSplitNum, Id CompId){
			MemberNum = NewSplitNum;
			member = new Commission_Plan_Member__c(Commission_Plan__c = CompId);
		}
		
		public MemberWrapper(Integer NewMemberNum, Commission_Plan_Member__c existingMember){
			memberNum = NewMemberNum;
			member = existingMember;
		}
	}
	
	private final Commission_Plan__c compPlan;
	public SplitWrapper[] splitWrappers {get; set;}
	public MemberWrapper[] memberWrappers {get; set;}
	
	// Variable to store the row number that is being updated
	public static integer rowNumber {get; set;}
	private integer nextMemberNum=0;
	private integer nextSplitNum=0;
	
	// To store records to be deleted
	private Commission_Plan_Split__c[] SplitsToDelete = new Commission_Plan_Split__c[]{};
	private Commission_Plan_Member__c[] MembersToDelete = new Commission_Plan_Member__c[]{};
	
	public EditCommissionPlanController(ApexPages.StandardController con){
		this.compPlan = (Commission_Plan__c) con.getRecord();
		SplitWrappers = new SplitWrapper[]{};
		for(Commission_Plan_Split__c split : [Select c.Gross_Commission_To__c, c.Gross_Commission_From__c, c.Agent_Split__c, c.Commission_Plan__c 
												From Commission_Plan_Split__c c 
												where c.Commission_Plan__c = :compPlan.Id
												order by c.Gross_Commission_From__c asc
												]){
			SplitWrappers.add(new SplitWrapper(nextSplitNum++,split));
		}
		memberWrappers = new MemberWrapper[]{};
		for(Commission_Plan_Member__c member : [Select c.Id, c.Commission_Plan__c, c.Agent__c 
												From Commission_Plan_Member__c c 
												where c.Commission_Plan__c = :compPlan.Id
												order by c.Agent__c asc]){
			memberWrappers.add(new memberWrapper(nextMemberNum++,member));
		}
		 
	}
	
	public pageReference addSplit(){
		decimal largestValue = 0;
		for(SplitWrapper wrapper : splitWrappers){
			if(wrapper.split.Gross_Commission_To__c <> null) largestValue = Math.max(wrapper.split.Gross_Commission_To__c,largestValue);
		}
		splitWrappers.add(new splitwrapper(nextSplitNum++,largestValue,compPlan.Id));
		return null;
	}
	
	public pageReference addMember(){
		memberWrappers.add(new MemberWrapper(nextMemberNum++,compPlan.Id));
		return null;
	}
	
	public pageReference deleteMember(){
		for(integer i=0;i<memberWrappers.size();i++){
			if(memberWrappers[i].memberNum == rowNumber){
				if(memberWrappers[i].member.Id<>null) MembersToDelete.add(memberWrappers[i].member);
				memberWrappers.remove(i);
				break;
			}
		}
		return null;
	}
	
	public pageReference deleteSplit(){
		for(integer i=0;i<splitWrappers.size();i++){
			if(splitWrappers[i].splitNum == rowNumber){
				if(splitWrappers[i].split.Id<>null) SplitsToDelete.add(splitWrappers[i].split);
				splitWrappers.remove(i);
				break;
			}
		}
		return null;
	}
	
	public pageReference save(){
		try{
			upsert compPlan;
			Commission_Plan_Split__c[] splits = new Commission_Plan_Split__c[]{};
			for(SplitWrapper wrapper : SplitWrappers){
				if(wrapper.split.Commission_Plan__c == null) wrapper.split.Commission_Plan__c = compPlan.Id;
				splits.add(wrapper.split);
			}
			Commission_Plan_Member__c[] members = new Commission_Plan_Member__c[]{};
			for(MemberWrapper wrapper : MemberWrappers){
				if(wrapper.member.Commission_Plan__c == null) wrapper.member.Commission_Plan__c = compPlan.Id;
				members.add(wrapper.member);
			}
			upsert splits;
			upsert members;
			if(SplitsToDelete.size()>0) delete SplitsToDelete;
			if(MembersToDelete.size()>0) delete MembersToDelete;
		}catch(Exception ex){
			Apexpages.AddMessages(ex);
			return null;
		}
		return new PageReference('/'+compPlan.Id);
	}
	
	public pageReference cancel(){
		return new PageReference('/'+compPlan.Id);
	}
}