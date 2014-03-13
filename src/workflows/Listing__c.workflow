<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Copy_Comm_Actual_to_Comm_Input</fullName>
        <field>Commission_Input__c</field>
        <formula>Commission_Actual__c</formula>
        <name>Copy Comm_Actual to Comm_Input</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Comm_Input_to_Comm</fullName>
        <field>Commission__c</field>
        <formula>Commission_Input__c / Asking_Price_Actual__c</formula>
        <name>Copy Comm_Input to Comm_%</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Off_Market2</fullName>
        <field>Date_Off_Market__c</field>
        <formula>Today()</formula>
        <name>Date Off-Market</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Today_Off_Market</fullName>
        <field>Status__c</field>
        <literalValue>Off-Market</literalValue>
        <name>Today Off-Market</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Date Off-Market</fullName>
        <actions>
            <name>Today_Off_Market</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Listing__c.Date_Off_Market__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Listing Off-Market</fullName>
        <actions>
            <name>Date_Off_Market2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Listing__c.Status__c</field>
            <operation>contains</operation>
            <value>Off-Market,Dead,In Escrow,Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Commission %28%25%29 from Commission %28%24%29</fullName>
        <actions>
            <name>Copy_Comm_Input_to_Comm</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(  Commission_Input__c  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Commission from Calculated Commission</fullName>
        <actions>
            <name>Copy_Comm_Actual_to_Comm_Input</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Commission_Actual__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
