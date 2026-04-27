Class EMR.Patient Extends %Persistent
{

Property FirstName As %String(MAXLEN = 100) [ Required ];

Property LastName As %String(MAXLEN = 100) [ Required ];

Property DateOfBirth As %Date;

Property Gender As %String(VALUELIST = ",Male,Female,Other,Unknown");

Property MRN As %String(MAXLEN = 50) [ Required ];

Property SSN As %String(MAXLEN = 11);

Property Email As %String(MAXLEN = 255);

Property Phone As %String(MAXLEN = 20);

Property Address As %String(MAXLEN = 500);

Property City As %String(MAXLEN = 100);

Property State As %String(MAXLEN = 50);

Property ZipCode As %String(MAXLEN = 10);

Property BloodType As %String(VALUELIST = ",A+,A-,B+,B-,AB+,AB-,O+,O-,Unknown");

Property PrimaryPhysician As %String(MAXLEN = 200);

Index MRNIndex On MRN [ Unique ];

Storage Default
{
<Data name="PatientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FirstName</Value>
</Value>
<Value name="3">
<Value>LastName</Value>
</Value>
<Value name="4">
<Value>DateOfBirth</Value>
</Value>
<Value name="5">
<Value>Gender</Value>
</Value>
<Value name="6">
<Value>MRN</Value>
</Value>
<Value name="7">
<Value>SSN</Value>
</Value>
<Value name="8">
<Value>Email</Value>
</Value>
<Value name="9">
<Value>Phone</Value>
</Value>
<Value name="10">
<Value>Address</Value>
</Value>
<Value name="11">
<Value>City</Value>
</Value>
<Value name="12">
<Value>State</Value>
</Value>
<Value name="13">
<Value>ZipCode</Value>
</Value>
<Value name="14">
<Value>BloodType</Value>
</Value>
<Value name="15">
<Value>Allergies</Value>
</Value>
<Value name="16">
<Value>PrimaryPhysician</Value>
</Value>
</Data>
<DataLocation>^EMR.PatientD</DataLocation>
<DefaultData>PatientDefaultData</DefaultData>
<IdLocation>^EMR.PatientD</IdLocation>
<IndexLocation>^EMR.PatientI</IndexLocation>
<StreamLocation>^EMR.PatientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
