<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EmailAlertOnOrderApproval</fullName>
        <description>EmailAlertOnOrderApproval</description>
        <protected>false</protected>
        <recipients>
            <field>CustomerAuthorizedById</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/NotifyOrderApproveToSupplier</template>
    </alerts>
    <alerts>
        <fullName>EmailAlertOnOrderRejection</fullName>
        <description>EmailAlertOnOrderRejection</description>
        <protected>false</protected>
        <recipients>
            <field>CustomerAuthorizedById</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/NotifyOrderRejectionToSupplier</template>
    </alerts>
    <fieldUpdates>
        <fullName>Order_Status_Update_1</fullName>
        <field>Status</field>
        <literalValue>Submitted</literalValue>
        <name>Order Status Update 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_Status_Update_2</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Order Status Update 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_Status_Update_3</fullName>
        <field>Status</field>
        <literalValue>Rejected</literalValue>
        <name>Order Status Update 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_Status_Update_4</fullName>
        <description>Update Order Status to &apos;Approved&apos;</description>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Order Status Update 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_Status_Update_5</fullName>
        <description>Update Order Status to Approved</description>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Order Status Update 5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TEST</fullName>
        <field>Status</field>
        <literalValue>Submitted</literalValue>
        <name>TEST</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Catalogue Order Status Update</fullName>
        <actions>
            <name>Order_Status_Update_4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>Catalogue Item Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>Order Status is updated to &apos;Approved&apos; for &apos;Catalogue Orders&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
