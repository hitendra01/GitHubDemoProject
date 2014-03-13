<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Comp_Calculate_Commission</fullName>
        <field>Commission__c</field>
        <formula>IF( CONTAINS( lower(RecordType.DeveloperName) , &quot;lease&quot;),
 Lease_Total__c * Commission_Percent__c,
Sale_Price__c *  Commission_Percent__c)</formula>
        <name>Comp - Calculate Commission ($)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Comp_Copy_Commission_to_Commission</fullName>
        <field>Commission_Percent__c</field>
        <formula>IF( CONTAINS( lower(RecordType.DeveloperName) , &quot;lease&quot;), 
IF(Lease_Total__c&lt;&gt;0, Commission__c / Lease_Total__c,0),
IF(Sale_Price__c&lt;&gt;0, Commission__c / Sale_Price__c,0))</formula>
        <name>Comp - Copy Commission $ to Commission %</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Comp - Update Commission %28%24%29 from Commission %28%25%29</fullName>
        <actions>
            <name>Comp_Calculate_Commission</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Commission_Percent__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Comp - Update Commission %28%25%29 from Commission %28%24%29</fullName>
        <actions>
            <name>Comp_Copy_Commission_to_Commission</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Commission__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
