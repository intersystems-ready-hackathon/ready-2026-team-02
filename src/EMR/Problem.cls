Class EMR.Problem Extends %Persistent
{

/// Link to the patient
Property Patient As EMR.Patient [ Required ];

/// Type of problem
Property ProblemType As %String(VALUELIST = ",Allergy,MedicationHistory,SurgicalHistory,ChronicCondition,FamilyHistory,Other") [ Required ];

/// Description of the problem (e.g. "Penicillin", "Appendectomy", "Type 2 Diabetes")
Property Description As %String(MAXLEN = 500) [ Required ];

/// SNOMED CT code (e.g. "416098002" for allergy to penicillin, "44054006" for Type 2 Diabetes)
Property SNOMEDCode As %String(MAXLEN = 20);

/// SNOMED CT display term
Property SNOMEDTerm As %String(MAXLEN = 500);

/// Onset date / date of the event
Property OnsetDate As %Date;

/// Resolution date (empty if still active)
Property ResolutionDate As %Date;

/// Status
Property Status As %String(VALUELIST = ",Active,Resolved,Inactive") [ InitialExpression = "Active" ];

/// Severity (especially for allergies)
Property Severity As %String(VALUELIST = ",Mild,Moderate,Severe,LifeThreatening");

/// Observed reaction (for allergies)
Property Reaction As %String(MAXLEN = 500);

/// Additional notes
Property Notes As %String(MAXLEN = 2000);

/// Date recorded in the chart
Property RecordedDate As %TimeStamp [ InitialExpression = {$ZDATEH($ZDATE($HOROLOG, 3), 3)} ];

/// Clinician who recorded the problem
Property RecordedBy As %String(MAXLEN = 200);

Index PatientIndex On Patient;

Index PatientTypeIndex On (Patient, ProblemType);

Storage Default
{
<Data name="ProblemDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Patient</Value>
</Value>
<Value name="3">
<Value>ProblemType</Value>
</Value>
<Value name="4">
<Value>Description</Value>
</Value>
<Value name="5">
<Value>ICD10Code</Value>
</Value>
<Value name="6">
<Value>OnsetDate</Value>
</Value>
<Value name="7">
<Value>ResolutionDate</Value>
</Value>
<Value name="8">
<Value>Status</Value>
</Value>
<Value name="9">
<Value>Severity</Value>
</Value>
<Value name="10">
<Value>Reaction</Value>
</Value>
<Value name="11">
<Value>Notes</Value>
</Value>
<Value name="12">
<Value>RecordedDate</Value>
</Value>
<Value name="13">
<Value>RecordedBy</Value>
</Value>
<Value name="14">
<Value>SNOMEDCode</Value>
</Value>
<Value name="15">
<Value>SNOMEDTerm</Value>
</Value>
<Value name="16">
<Value>DiagnosisType</Value>
</Value>
<Value name="17">
<Value>ICD10Description</Value>
</Value>
<Value name="18">
<Value>DiagnosedBy</Value>
</Value>
<Value name="19">
<Value>DiagnosisDate</Value>
</Value>
</Data>
<DataLocation>^EMR.ProblemD</DataLocation>
<DefaultData>ProblemDefaultData</DefaultData>
<IdLocation>^EMR.ProblemD</IdLocation>
<IndexLocation>^EMR.ProblemI</IndexLocation>
<StreamLocation>^EMR.ProblemS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
