<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Activity_Date</fullName>
        <field>Activity_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Activity Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Activity_Date_Sale_Date</fullName>
        <field>Activity_Date__c</field>
        <formula>Sale__r.Sale_Date__c</formula>
        <name>Update Activity Date-Sale Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_to_Assignment</fullName>
        <field>Stage__c</field>
        <literalValue>Assignment</literalValue>
        <name>Update Stage to Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_to_Closed</fullName>
        <field>Stage__c</field>
        <literalValue>Closed</literalValue>
        <name>Update Stage to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_to_Project</fullName>
        <field>Stage__c</field>
        <literalValue>Project</literalValue>
        <name>Update Stage to Project</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_to_Proposal</fullName>
        <field>Stage__c</field>
        <literalValue>Proposal</literalValue>
        <name>Update Stage to Proposal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active Pipeline</literalValue>
        <name>Update Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Closed</fullName>
        <field>Status__c</field>
        <literalValue>Closed Pipeline</literalValue>
        <name>Update Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Convert to Assignment</fullName>
        <actions>
            <name>Update_Activity_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Stage_to_Assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(  Listing__c ) = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Convert to Close %28Comp%29</fullName>
        <actions>
            <name>Update_Activity_Date_Sale_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Stage_to_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(  Sale__c  ) = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Convert to Project</fullName>
        <actions>
            <name>Update_Activity_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Stage_to_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(   Escrow__c  ) = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Convert to Proposal</fullName>
        <actions>
            <name>Update_Activity_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Stage_to_Proposal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK( Proposal__c ) = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
