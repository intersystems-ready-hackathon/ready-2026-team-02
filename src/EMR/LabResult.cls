Class EMR.LabResult Extends %Persistent
{

/// Link to the patient
Property Patient As EMR.Patient [ Required ];

/// Name of the lab test (e.g. "Hemoglobin", "Glucose", "Creatinine")
Property TestName As %String(MAXLEN = 500) [ Required ];

/// SNOMED CT code for the test
Property SNOMEDCode As %String(MAXLEN = 20);

/// SNOMED CT display term
Property SNOMEDTerm As %String(MAXLEN = 500);

/// LOINC code (standard for lab observations)
Property LOINCCode As %String(MAXLEN = 20);

/// Numeric result value
Property ResultValue As %Decimal(SCALE = 6);

/// Text result (for non-numeric results, e.g. "Positive", "Negative", "Detected")
Property ResultText As %String(MAXLEN = 500);

/// Unit of measure (e.g. "g/dL", "mmol/L", "mg/dL")
Property ResultUnit As %String(MAXLEN = 100);

/// Lower bound of normal range
Property NormalRangeLow As %Decimal(SCALE = 6);

/// Upper bound of normal range
Property NormalRangeHigh As %Decimal(SCALE = 6);

/// Whether the result is within normal range
Property IsNormal As %Boolean;

/// Interpretation flag
Property Interpretation As %String(VALUELIST = ",Normal,Low,High,CriticalLow,CriticalHigh,Abnormal,Positive,Negative,Indeterminate");

/// Status of the result
Property Status As %String(VALUELIST = ",Preliminary,Final,Corrected,Cancelled") [ InitialExpression = "Final" ];

/// Date and time the specimen was collected
Property CollectedDate As %TimeStamp [ Required ];

/// Date and time the result was reported
Property ReportedDate As %TimeStamp;

/// Ordering clinician
Property OrderedBy As %String(MAXLEN = 200);

/// Performing laboratory
Property PerformingLab As %String(MAXLEN = 200);

/// Additional notes or comments
Property Notes As %String(MAXLEN = 2000);

/// Date recorded
Property RecordedDate As %TimeStamp [ InitialExpression = {$ZDATEH($ZDATE($HOROLOG, 3), 3)} ];

Index PatientIndex On Patient;

Index PatientDateIndex On (Patient, CollectedDate);

Index PatientTestIndex On (Patient, TestName);

Storage Default
{
<Data name="LabResultDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Patient</Value>
</Value>
<Value name="3">
<Value>TestName</Value>
</Value>
<Value name="4">
<Value>SNOMEDCode</Value>
</Value>
<Value name="5">
<Value>SNOMEDTerm</Value>
</Value>
<Value name="6">
<Value>LOINCCode</Value>
</Value>
<Value name="7">
<Value>ResultValue</Value>
</Value>
<Value name="8">
<Value>ResultText</Value>
</Value>
<Value name="9">
<Value>ResultUnit</Value>
</Value>
<Value name="10">
<Value>NormalRangeLow</Value>
</Value>
<Value name="11">
<Value>NormalRangeHigh</Value>
</Value>
<Value name="12">
<Value>IsNormal</Value>
</Value>
<Value name="13">
<Value>Interpretation</Value>
</Value>
<Value name="14">
<Value>Status</Value>
</Value>
<Value name="15">
<Value>CollectedDate</Value>
</Value>
<Value name="16">
<Value>ReportedDate</Value>
</Value>
<Value name="17">
<Value>OrderedBy</Value>
</Value>
<Value name="18">
<Value>PerformingLab</Value>
</Value>
<Value name="19">
<Value>Notes</Value>
</Value>
<Value name="20">
<Value>RecordedDate</Value>
</Value>
</Data>
<DataLocation>^EMR.LabResultD</DataLocation>
<DefaultData>LabResultDefaultData</DefaultData>
<IdLocation>^EMR.LabResultD</IdLocation>
<IndexLocation>^EMR.LabResultI</IndexLocation>
<StreamLocation>^EMR.LabResultS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
