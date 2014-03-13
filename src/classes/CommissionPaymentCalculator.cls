public with sharing class CommissionPaymentCalculator {
	
	public static void checkNewPaymentsAndCalculateCommissions(Commission_Payment__c[] newPayments){
		set<Id> AgentIds = getAgentIdsFromPayments(newPayments);
		Map<Id,Commission_Plan__c> AgentPlans = getAgentPlans(AgentIds);
		Commission_Payment__c[] PaymentsToProcess = new Commission_Payment__c[]{};
		if(AgentPlans.size()>0){
			for(Commission_Payment__c payment : newPayments){
				if(payment.Commission_Record_Type__c == 'Internal_Broker'){
					Commission_Plan__c plan = AgentPlans.get((Id) payment.Broker_Id__c);
					if(plan == null){
						payment.addError('No Commission plan for this broker. Please add them to a commission plan.');
					}else{
						if(plan.Calculate_Splits__c == 'Booked'){
							PaymentsToProcess.add(payment);
						}
					}
				}
			}
		}
		System.debug(PaymentsToProcess);
		if(PaymentsToProcess.size()>0){
			calculateCommissions(PaymentsToProcess);
		}
		
	}
	
	public static Commission_Payment__c[] calculateCommissions(Commission_Payment__c[] payments){
		set<Id> AgentIds = getAgentIdsFromPayments(payments);
		Map<Id,Commission_Plan__c> AgentPlans = getAgentPlans(AgentIds);
		return calculateCommissions(payments,AgentPlans);
	}
	
	public static Commission_Payment__c[] calculateCommissions(Commission_Payment__c[] payments, Map<Id,Commission_Plan__c> AgentPlans){
		// Get previous agent totals
		map<id,decimal> AgentTotals = getAgentTotals(AgentPlans.keySet());
		
		// Calculate Net Commissions
		for(Commission_Payment__c payment : payments){
			payment.Commission_Calculation_Details__c = null;
			if(payment.Commission__r.RecordType.DeveloperName == 'External_Broker'){
				payment.Net_Commission__c = payment.Gross_Commission_Formula__c;
				payment.Commission_Calculation_Details__c = String.ValueOf(date.today().format())+' External Broker - no splits calculated';
			}else{
				Commission_Plan__c agentPlan = AgentPlans.get(payment.Broker_Id__c);
				Decimal AgentTotal = AgentTotals.get(payment.Broker_Id__c);
				payment.Net_Commission__c = 0;
				payment.Commission_Calculation_Details__c = String.ValueOf(date.today().format())+' Recalculated Net Commissions based on Plan: '+AgentPlan.Name;
				payment.Commission_Calculation_Details__c += '\n\rPrevious Gross Commissions: '+AgentTotal;
				for(Commission_Plan_Split__c split : agentPlan.Splits__r){
					Decimal AmountForSplit = 0;
					if(split.Gross_Commission_To__c == null){
						// Special calculation for the last split
						AmountForSplit = AgentTotal+payment.Gross_Commission_Formula__c - Math.Max(AgentTotal,split.Gross_Commission_From__c);
					}else{
						System.Debug('Agent Total: '+AgentTotal);
						System.Debug('payment: '+payment);
						System.Debug('split: '+split);   
						AmountForSplit = Math.Min(AgentTotal+payment.Gross_Commission_Formula__c,split.Gross_Commission_To__c) - Math.Max(AgentTotal,split.Gross_Commission_From__c);
					}
					if(AmountForSplit>0){
						payment.Commission_Calculation_Details__c += '\n\r'+AmountForSplit+' x '+split.Agent_Split__c/100 + ' = '+AmountForSplit*split.Agent_Split__c/100;
						payment.Net_Commission__c += AmountForSplit*split.Agent_Split__c/100;
					}
					
				}
				payment.Commission_Calculation_Details__c += '\n\rTotal Commission: '+payment.Net_Commission__c;
				
			}
			payment.Date_Processed__c = date.today();
		}
		
		return payments;
	}
	
	
	
	private static Map<id,Commission_Plan__c> getAgentPlans(Set<id> AgentIds){
		
		// Get the Commission Plans for the Agents
		Map<Id,Commission_Plan__c> AgentPlans = new Map<id,Commission_Plan__c>();
		for(Commission_Plan_Member__c member : [select Commission_Plan__c, Agent__c from Commission_Plan_Member__c where Agent__c in :AgentIds]){
			AgentPlans.put(member.Agent__c,new Commission_Plan__c(id = member.Commission_Plan__c));
		}
		
		// Get a map of commission plans
		Map<id,Commission_Plan__c> PlanMap = new Map<id,Commission_Plan__c>([Select c.Id, c.Calculate_Splits__c, c.Name, (Select Gross_Commission_From__c, Gross_Commission_To__c, Agent_Split__c From Splits__r order by Gross_Commission_From__c asc) From Commission_Plan__c c where Id in :AgentPlans.Values()]);
		
		// Update the Agent Plan map with the full details of the paln
		for(Id AgentID : AgentPlans.keySet()){
			AgentPlans.put(AgentId,PlanMap.get(AgentPlans.get(AgentId).Id));
		}
		return AgentPlans;
	}
		
	
	private static Map<Id,Decimal> getAgentTotals(set<id> AgentIds){ 
		// Get previous totals for the Agents
		Map<id,decimal> AgentTotals = new Map<Id,decimal>();
		AggregateResult[] groupedResults
		  = [SELECT Commission__r.Broker__c cb, SUM(Gross_Commission_Formula__c)
		      FROM Commission_Payment__c
		      where Date_Processed__c = THIS_FISCAL_YEAR and Commission__r.Broker__c in :AgentIds
		      GROUP BY Commission__r.Broker__c];
		for (AggregateResult ar : groupedResults)  {
			AgentTotals.put((Id) ar.get('cb'), (decimal) ar.get('expr0'));
		}
		
		for(Id AgentID : AgentIds){
			if(!AgentTotals.containsKey(AgentId)) AgentTotals.put(AgentId,0);
		}
		return AgentTotals;
	}
	
	private static set<id> getAgentIdsFromPayments(Commission_Payment__c[] payments){
		Set<Id> AgentIds = new Set<id>();
		for(Commission_Payment__c payment : payments){
			if(payment.Broker_Id__c <> null){
				AgentIds.add(payment.Broker_Id__c);
			}
		}
		return AgentIds;
	}
}