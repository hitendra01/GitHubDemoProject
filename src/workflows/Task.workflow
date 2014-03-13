<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Comments_Short_Update</fullName>
        <field>Description__c</field>
        <formula>TRIM(LEFT( Description , 255))</formula>
        <name>Comments Short Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update ShortComments from Comments</fullName>
        <actions>
            <name>Comments_Short_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( Description__c =&quot;&quot;, ISCHANGED( Description ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
