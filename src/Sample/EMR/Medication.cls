Class Sample.EMR.Medication Extends %Persistent
{

/// Link to the patient
Property Patient As Sample.EMR.Patient [ Required ];

/// Medication name
Property MedicationName As %String(MAXLEN = 500) [ Required ];

/// SNOMED CT code for the medication
Property SNOMEDCode As %String(MAXLEN = 20);

/// SNOMED CT display term
Property SNOMEDTerm As %String(MAXLEN = 500);

/// RxNorm code (North American medication standard)
Property RxNormCode As %String(MAXLEN = 20);

/// Dose amount (e.g. "500 mg")
Property Dose As %String(MAXLEN = 100);

/// Dose unit (e.g. "mg", "mL", "IU")
Property DoseUnit As %String(MAXLEN = 50);

/// Frequency (e.g. "BID", "TID", "QD", "PRN")
Property Frequency As %String(MAXLEN = 100);

/// Route of administration
Property Route As %String(VALUELIST = ",Oral,Intravenous,Intramuscular,Subcutaneous,Topical,Inhalation,Sublingual,Rectal,Ophthalmic,Otic,Nasal,Other");

/// Prescription start date
Property StartDate As %Date [ Required ];

/// Expected or actual end date
Property EndDate As %Date;

/// Status
Property Status As %String(VALUELIST = ",Active,Completed,Discontinued,OnHold") [ InitialExpression = "Active" ];

/// Reason for prescribing
Property Indication As %String(MAXLEN = 500);

/// Reason for discontinuation
Property DiscontinuationReason As %String(MAXLEN = 500);

/// Number of authorized refills
Property Refills As %Integer [ InitialExpression = 0 ];

/// Instructions for the patient
Property PatientInstructions As %String(MAXLEN = 2000);

/// Prescribing clinician
Property PrescribedBy As %String(MAXLEN = 200);

/// Date recorded
Property RecordedDate As %TimeStamp [ InitialExpression = {$ZDATEH($ZDATE($HOROLOG, 3), 3)} ];

Index PatientIndex On Patient;

Index PatientStatusIndex On (Patient, Status);

Storage Default
{
<Data name="MedicationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Patient</Value>
</Value>
<Value name="3">
<Value>MedicationName</Value>
</Value>
<Value name="4">
<Value>SNOMEDCode</Value>
</Value>
<Value name="5">
<Value>SNOMEDTerm</Value>
</Value>
<Value name="6">
<Value>RxNormCode</Value>
</Value>
<Value name="7">
<Value>Dose</Value>
</Value>
<Value name="8">
<Value>DoseUnit</Value>
</Value>
<Value name="9">
<Value>Frequency</Value>
</Value>
<Value name="10">
<Value>Route</Value>
</Value>
<Value name="11">
<Value>StartDate</Value>
</Value>
<Value name="12">
<Value>EndDate</Value>
</Value>
<Value name="13">
<Value>Status</Value>
</Value>
<Value name="14">
<Value>Indication</Value>
</Value>
<Value name="15">
<Value>DiscontinuationReason</Value>
</Value>
<Value name="16">
<Value>Refills</Value>
</Value>
<Value name="17">
<Value>PatientInstructions</Value>
</Value>
<Value name="18">
<Value>PrescribedBy</Value>
</Value>
<Value name="19">
<Value>RecordedDate</Value>
</Value>
</Data>
<DataLocation>^Sample.EMR.MedicationD</DataLocation>
<DefaultData>MedicationDefaultData</DefaultData>
<IdLocation>^Sample.EMR.MedicationD</IdLocation>
<IndexLocation>^Sample.EMR.MedicationI</IndexLocation>
<StreamLocation>^Sample.EMR.MedicationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
