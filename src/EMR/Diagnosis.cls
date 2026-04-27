Class EMR.Diagnosis Extends %Persistent
{

/// Link to the patient
Property Patient As EMR.Patient [ Required ];

/// Diagnosis type
Property DiagnosisType As %String(VALUELIST = ",Primary,Secondary,Differential,Admitting,Discharge") [ Required ];

/// Description of the diagnosis (e.g. "Type 2 Diabetes", "Community-acquired pneumonia")
Property Description As %String(MAXLEN = 500) [ Required ];

/// SNOMED CT code (e.g. "44054006" for Type 2 Diabetes)
Property SNOMEDCode As %String(MAXLEN = 20);

/// SNOMED CT display term
Property SNOMEDTerm As %String(MAXLEN = 500);

/// Date the diagnosis was made
Property DiagnosisDate As %Date [ Required ];

/// Date the diagnosis was resolved (empty if still active)
Property ResolutionDate As %Date;

/// Status
Property Status As %String(VALUELIST = ",Active,Resolved,Inactive") [ InitialExpression = "Active" ];

/// Severity
Property Severity As %String(VALUELIST = ",Mild,Moderate,Severe,Critical");

/// Diagnosing clinician
Property DiagnosedBy As %String(MAXLEN = 200);

/// Additional notes
Property Notes As %String(MAXLEN = 2000);

/// Date recorded in the chart
Property RecordedDate As %TimeStamp [ InitialExpression = {$ZDATEH($ZDATE($HOROLOG, 3), 3)} ];

/// Clinician who recorded the diagnosis
Property RecordedBy As %String(MAXLEN = 200);

Index PatientIndex On Patient;

Index PatientTypeIndex On (Patient, DiagnosisType);

Index PatientStatusIndex On (Patient, Status);

Storage Default
{
<Data name="DiagnosisDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Patient</Value>
</Value>
<Value name="3">
<Value>DiagnosisType</Value>
</Value>
<Value name="4">
<Value>Description</Value>
</Value>
<Value name="5">
<Value>SNOMEDCode</Value>
</Value>
<Value name="6">
<Value>SNOMEDTerm</Value>
</Value>
<Value name="7">
<Value>DiagnosisDate</Value>
</Value>
<Value name="8">
<Value>ResolutionDate</Value>
</Value>
<Value name="9">
<Value>Status</Value>
</Value>
<Value name="10">
<Value>Severity</Value>
</Value>
<Value name="11">
<Value>DiagnosedBy</Value>
</Value>
<Value name="12">
<Value>Notes</Value>
</Value>
<Value name="13">
<Value>RecordedDate</Value>
</Value>
<Value name="14">
<Value>RecordedBy</Value>
</Value>
</Data>
<DataLocation>^EMR.DiagnosisD</DataLocation>
<DefaultData>DiagnosisDefaultData</DefaultData>
<IdLocation>^EMR.DiagnosisD</IdLocation>
<IndexLocation>^EMR.DiagnosisI</IndexLocation>
<StreamLocation>^EMR.DiagnosisS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
