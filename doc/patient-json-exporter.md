# Patient JSON Exporter

## Overview

`EMR.PatientJSONExporter` exports one patient or multiple patients as JSON, including related clinical data:

- Problems
- Diagnoses
- Medications
- Lab results

## Class

`EMR.PatientJSONExporter`

## Available Methods

### ExportPatient

Returns one patient payload by internal patient ID.

```objectscript
Write ##class(EMR.PatientJSONExporter).ExportPatient(1)
```

Signature:

```objectscript
ClassMethod ExportPatient(patientID As %Integer) As %String
```

### ExportPatientFormatted

Same as `ExportPatient`, but pretty-printed JSON.

```objectscript
Write ##class(EMR.PatientJSONExporter).ExportPatientFormatted(1)
```

Signature:

```objectscript
ClassMethod ExportPatientFormatted(patientID As %Integer) As %String
```

### ExportPatientByMRN

Returns one patient payload by MRN.

```objectscript
Write ##class(EMR.PatientJSONExporter).ExportPatientByMRN("MRN-000001")
```

Signature:

```objectscript
ClassMethod ExportPatientByMRN(mrn As %String) As %String
```

### ExportPatientByMRNFormatted

Same as `ExportPatientByMRN`, but pretty-printed JSON.

```objectscript
Write ##class(EMR.PatientJSONExporter).ExportPatientByMRNFormatted("MRN-000001")
```

Signature:

```objectscript
ClassMethod ExportPatientByMRNFormatted(mrn As %String) As %String
```

### ExportAllPatients

Returns all patients as a JSON array.

```objectscript
Write ##class(EMR.PatientJSONExporter).ExportAllPatients()
```

Signature:

```objectscript
ClassMethod ExportAllPatients() As %String
```

## Response Structure

`ExportPatient*` and `ExportPatientByMRN*` return a JSON object:

```json
{
  "id": 1,
  "firstName": "James",
  "lastName": "Smith",
  "mrn": "MRN-000001",
  "ssn": "123456789",
  "dateOfBirth": 54321,
  "gender": "Male",
  "email": "james.smith1@example.com",
  "phone": "555-1234",
  "address": "123 Main St",
  "city": "Springfield",
  "state": "NY",
  "zipCode": "10001",
  "bloodType": "O+",
  "primaryPhysician": "Dr. Emily Carter",
  "problems": [],
  "diagnoses": [],
  "medications": [],
  "labResults": []
}
```

`ExportAllPatients` returns an array of objects with the same structure:

```json
[
  {
    "id": 1,
    "firstName": "James",
    "lastName": "Smith",
    "mrn": "MRN-000001",
    "problems": [],
    "diagnoses": [],
    "medications": [],
    "labResults": []
  }
]
```

## Nested Objects

### problems[]

Fields:

- `id`
- `type`
- `description`
- `snomedCode`
- `snomedTerm`
- `onsetDate`
- `resolutionDate`
- `status`
- `severity`
- `reaction`
- `notes`
- `recordedDate`
- `recordedBy`

### diagnoses[]

Fields:

- `id`
- `type`
- `description`
- `snomedCode`
- `snomedTerm`
- `diagnosisDate`
- `resolutionDate`
- `status`
- `severity`
- `diagnosedBy`
- `recordedBy`
- `notes`
- `recordedDate`

### medications[]

Fields:

- `id`
- `name`
- `snomedCode`
- `snomedTerm`
- `rxNormCode`
- `dose`
- `doseUnit`
- `frequency`
- `route`
- `startDate`
- `endDate`
- `status`
- `indication`
- `discontinuationReason`
- `refills`
- `patientInstructions`
- `prescribedBy`
- `recordedDate`

### labResults[]

Fields:

- `id`
- `testName`
- `snomedCode`
- `snomedTerm`
- `loincCode`
- `resultValue`
- `resultText`
- `resultUnit`
- `normalRangeLow`
- `normalRangeHigh`
- `isNormal`
- `interpretation`
- `status`
- `collectedDate`
- `reportedDate`
- `orderedBy`
- `performingLab`
- `notes`
- `recordedDate`

## Error Responses

If no patient is found:

```json
{"error":"Patient not found"}
```

If MRN is not found:

```json
{"error":"Patient with MRN 'MRN-XXXXXX' not found"}
```

## Notes

- `%Date` values are exported in IRIS logical format (integer), not ISO string.
- `%TimeStamp` values are exported as IRIS timestamp values.
- Related collections (`problems`, `diagnoses`, `medications`, `labResults`) are always present as arrays.
