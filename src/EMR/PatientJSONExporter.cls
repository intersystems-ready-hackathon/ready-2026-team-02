/// Utility class to export patient data as JSON
Class EMR.PatientJSONExporter
{

/// Export a single patient and all related data to JSON
ClassMethod ExportPatient(patientID As %Integer) As %String
{
    Set patient = ##class(EMR.Patient).%OpenId(patientID)
    If ($IsObject(patient) = 0) {
        Return "{""error"":""Patient not found""}"
    }
    
    Set json = ##class(%Library.DynamicObject).%New()
    
    // Patient data
    Do ..AddPatientData(.json, patient)
    
    // Problems
    Do ..AddProblems(.json, patient)
    
    // Diagnoses
    Do ..AddDiagnoses(.json, patient)
    
    // Medications
    Do ..AddMedications(.json, patient)
    
    // Lab Results
    Do ..AddLabResults(.json, patient)
    
    Return json.%ToJSON()
}

/// Export a patient by MRN (Medical Record Number) and all related data to JSON
ClassMethod ExportPatientByMRN(mrn As %String) As %String
{
    Set patientID = ""
    
    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Patient WHERE MRN = ?",
        mrn
    )
    
    If rs.%Next() {
        Set patientID = rs.%Get("ID")
    } Else {
        Return "{""error"":""Patient with MRN '" _ mrn _ "' not found""}"
    }
    
    Return ..ExportPatient(patientID)
}

/// Export a patient by MRN with formatted JSON
ClassMethod ExportPatientByMRNFormatted(mrn As %String) As %String
{
    Set jsonStr = ..ExportPatientByMRN(mrn)
    Set json = ##class(%Library.DynamicObject).%FromJSON(jsonStr)
    Return json.%ToJSON(, , 2)
}

/// Export all patients to JSON array
ClassMethod ExportAllPatients() As %String
{
    Set array = ##class(%Library.DynamicArray).%New()
    
    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Patient ORDER BY ID"
    )
    
    While rs.%Next() {
        Set patientID = rs.%Get("ID")
        Set patient = ##class(EMR.Patient).%OpenId(patientID)
        
        Set patientJson = ##class(%Library.DynamicObject).%New()
        Do ..AddPatientData(.patientJson, patient)
        Do ..AddProblems(.patientJson, patient)
        Do ..AddDiagnoses(.patientJson, patient)
        Do ..AddMedications(.patientJson, patient)
        Do ..AddLabResults(.patientJson, patient)
        
        Do array.%Push(patientJson)
    }
    
    Return array.%ToJSON()
}

/// Add patient base information to JSON object
ClassMethod AddPatientData(json As %Library.DynamicObject, patient As EMR.Patient)
{
    Set json.id = patient.%Id()
    Set json.firstName = patient.FirstName
    Set json.lastName = patient.LastName
    Set json.mrn = patient.MRN
    Set json.ssn = patient.SSN
    Set json.dateOfBirth = patient.DateOfBirth
    Set json.gender = patient.Gender
    Set json.email = patient.Email
    Set json.phone = patient.Phone
    Set json.address = patient.Address
    Set json.city = patient.City
    Set json.state = patient.State
    Set json.zipCode = patient.ZipCode
    Set json.bloodType = patient.BloodType
    Set json.primaryPhysician = patient.PrimaryPhysician
}

/// Add all problems for the patient to JSON
ClassMethod AddProblems(json As %Library.DynamicObject, patient As EMR.Patient)
{
    Set problems = ##class(%Library.DynamicArray).%New()
    
    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Problem WHERE Patient = ? ORDER BY OnsetDate DESC",
        patient.%Id()
    )
    
    While rs.%Next() {
        Set problemID = rs.%Get("ID")
        Set problem = ##class(EMR.Problem).%OpenId(problemID)
        
        Set prob = ##class(%Library.DynamicObject).%New()
        Set prob.id = problem.%Id()
        Set prob.type = problem.ProblemType
        Set prob.description = problem.Description
        Set prob.snomedCode = problem.SNOMEDCode
        Set prob.snomedTerm = problem.SNOMEDTerm
        Set prob.onsetDate = problem.OnsetDate
        Set prob.resolutionDate = problem.ResolutionDate
        Set prob.status = problem.Status
        Set prob.severity = problem.Severity
        Set prob.reaction = problem.Reaction
        Set prob.notes = problem.Notes
        Set prob.recordedDate = problem.RecordedDate
        Set prob.recordedBy = problem.RecordedBy
        
        Do problems.%Push(prob)
    }
    
    Set json.problems = problems
}

/// Add all diagnoses for the patient to JSON
ClassMethod AddDiagnoses(json As %Library.DynamicObject, patient As EMR.Patient)
{
    Set diagnoses = ##class(%Library.DynamicArray).%New()
    
    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Diagnosis WHERE Patient = ? ORDER BY DiagnosisDate DESC",
        patient.%Id()
    )
    
    While rs.%Next() {
        Set diagID = rs.%Get("ID")
        Set diag = ##class(EMR.Diagnosis).%OpenId(diagID)
        
        Set d = ##class(%Library.DynamicObject).%New()
        Set d.id = diag.%Id()
        Set d.type = diag.DiagnosisType
        Set d.description = diag.Description
        Set d.snomedCode = diag.SNOMEDCode
        Set d.snomedTerm = diag.SNOMEDTerm
        Set d.diagnosisDate = diag.DiagnosisDate
        Set d.resolutionDate = diag.ResolutionDate
        Set d.status = diag.Status
        Set d.severity = diag.Severity
        Set d.diagnosedBy = diag.DiagnosedBy
        Set d.recordedBy = diag.RecordedBy
        Set d.notes = diag.Notes
        Set d.recordedDate = diag.RecordedDate
        
        Do diagnoses.%Push(d)
    }
    
    Set json.diagnoses = diagnoses
}

/// Add all medications for the patient to JSON
ClassMethod AddMedications(json As %Library.DynamicObject, patient As EMR.Patient)
{
    Set medications = ##class(%Library.DynamicArray).%New()
    
    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Medication WHERE Patient = ? ORDER BY StartDate DESC",
        patient.%Id()
    )
    
    While rs.%Next() {
        Set medID = rs.%Get("ID")
        Set med = ##class(EMR.Medication).%OpenId(medID)
        
        Set m = ##class(%Library.DynamicObject).%New()
        Set m.id = med.%Id()
        Set m.name = med.MedicationName
        Set m.snomedCode = med.SNOMEDCode
        Set m.snomedTerm = med.SNOMEDTerm
        Set m.rxNormCode = med.RxNormCode
        Set m.dose = med.Dose
        Set m.doseUnit = med.DoseUnit
        Set m.frequency = med.Frequency
        Set m.route = med.Route
        Set m.startDate = med.StartDate
        Set m.endDate = med.EndDate
        Set m.status = med.Status
        Set m.indication = med.Indication
        Set m.discontinuationReason = med.DiscontinuationReason
        Set m.refills = med.Refills
        Set m.patientInstructions = med.PatientInstructions
        Set m.prescribedBy = med.PrescribedBy
        Set m.recordedDate = med.RecordedDate
        
        Do medications.%Push(m)
    }
    
    Set json.medications = medications
}

/// Add all lab results for the patient to JSON
ClassMethod AddLabResults(json As %Library.DynamicObject, patient As EMR.Patient)
{
    Set labResults = ##class(%Library.DynamicArray).%New()
    
    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.LabResult WHERE Patient = ? ORDER BY CollectedDate DESC",
        patient.%Id()
    )
    
    While rs.%Next() {
        Set labID = rs.%Get("ID")
        Set lab = ##class(EMR.LabResult).%OpenId(labID)
        
        Set l = ##class(%Library.DynamicObject).%New()
        Set l.id = lab.%Id()
        Set l.testName = lab.TestName
        Set l.snomedCode = lab.SNOMEDCode
        Set l.snomedTerm = lab.SNOMEDTerm
        Set l.loincCode = lab.LOINCCode
        Set l.resultValue = lab.ResultValue
        Set l.resultText = lab.ResultText
        Set l.resultUnit = lab.ResultUnit
        Set l.normalRangeLow = lab.NormalRangeLow
        Set l.normalRangeHigh = lab.NormalRangeHigh
        Set l.isNormal = lab.IsNormal
        Set l.interpretation = lab.Interpretation
        Set l.status = lab.Status
        Set l.collectedDate = lab.CollectedDate
        Set l.reportedDate = lab.ReportedDate
        Set l.orderedBy = lab.OrderedBy
        Set l.performingLab = lab.PerformingLab
        Set l.notes = lab.Notes
        Set l.recordedDate = lab.RecordedDate
        
        Do labResults.%Push(l)
    }
    
    Set json.labResults = labResults
}

/// Pretty-print JSON (with formatting)
ClassMethod ExportPatientFormatted(patientID As %Integer) As %String
{
    Set jsonStr = ..ExportPatient(patientID)
    Set json = ##class(%Library.DynamicObject).%FromJSON(jsonStr)
    Return json.%ToJSON(, , 2)
}

}
