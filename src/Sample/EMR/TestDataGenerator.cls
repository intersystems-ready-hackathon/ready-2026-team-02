/// Utility class to generate test data for the Sample.EMR package.
/// Call Sample.EMR.TestDataGenerator:GenerateAll() to populate all tables.
Class Sample.EMR.TestDataGenerator
{

/// Generate all test data (patients, problems, diagnoses, medications, lab results)
ClassMethod GenerateAll(patientCount As %Integer = 10) As %Status
{
    Set sc = $$$OK

    Write "Deleting existing test data...", !
    $$$ThrowOnError(..DeleteAll())

    Write "Generating ", patientCount, " patients...", !
    For i = 1:1:patientCount {
        Set patient = ..CreatePatient(i)
        $$$ThrowOnError(patient.%Save())

        Do ..CreateProblems(patient)
        Do ..CreateDiagnoses(patient)
        Do ..CreateMedications(patient)
        Do ..CreateLabResults(patient)
    }

    Write "Done.", !
    Return sc
}

/// Delete all existing EMR test data
ClassMethod DeleteAll() As %Status
{
    $$$ThrowOnError(##class(Sample.EMR.LabResult).%KillExtent())
    $$$ThrowOnError(##class(Sample.EMR.Medication).%KillExtent())
    $$$ThrowOnError(##class(Sample.EMR.Diagnosis).%KillExtent())
    $$$ThrowOnError(##class(Sample.EMR.Problem).%KillExtent())
    $$$ThrowOnError(##class(Sample.EMR.Patient).%KillExtent())
    Return $$$OK
}

/// Create a single test patient
ClassMethod CreatePatient(index As %Integer) As Sample.EMR.Patient
{
    Set firstNames = $ListBuild("James","Mary","Robert","Patricia","John","Jennifer","Michael","Linda","William","Barbara",
                                "David","Susan","Richard","Jessica","Joseph","Sarah","Thomas","Karen","Charles","Lisa")
    Set lastNames  = $ListBuild("Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Martinez","Wilson",
                                "Anderson","Taylor","Thomas","Hernandez","Moore","Martin","Jackson","Thompson","White","Lopez")
    Set physicians = $ListBuild("Dr. Emily Carter","Dr. James Nguyen","Dr. Sofia Patel","Dr. Marcus Lee","Dr. Anna Kowalski")
    Set genders    = $ListBuild("Male","Female","Other")
    Set bloodTypes = $ListBuild("A+","A-","B+","B-","AB+","AB-","O+","O-")
    Set states     = $ListBuild("NY","CA","TX","FL","IL","PA","OH","GA","NC","MI")

    Set fn = $List(firstNames, ((index - 1) # $ListLength(firstNames)) + 1)
    Set ln = $List(lastNames,  ((index - 1) # $ListLength(lastNames))  + 1)

    Set p = ##class(Sample.EMR.Patient).%New()
    Set p.FirstName       = fn
    Set p.LastName        = ln
    Set p.MRN             = "MRN-" _ $Translate($Justify(index, 6), " ", "0")
    Set p.SSN             = $Translate($Justify($Random(900000000) + 100000000, 9), " ", "0")
    Set p.DateOfBirth     = $ZDH($Translate($Justify(1950 + $Random(50), 4), " ", "0") _ "-" _$Translate($Justify($Random(12) + 1, 2), " ", "0") _ "-" _$Translate($Justify($Random(28) + 1, 2), " ", "0"), 3)
    Set p.Gender          = $List(genders, $Random($ListLength(genders)) + 1)
    Set p.Email           = $ZConvert(fn, "L") _ "." _ $ZConvert(ln, "L") _ index _ "@example.com"
    Set p.Phone           = "555-" _ $Translate($Justify($Random(9000) + 1000, 4), " ", "0")
    Set p.Address         = (100 + $Random(9900)) _ " Main St"
    Set p.City            = "Springfield"
    Set p.State           = $List(states, $Random($ListLength(states)) + 1)
    Set p.ZipCode         = $Translate($Justify($Random(90000) + 10000, 5), " ", "0")
    Set p.BloodType       = $List(bloodTypes, $Random($ListLength(bloodTypes)) + 1)
    Set p.PrimaryPhysician = $List(physicians, $Random($ListLength(physicians)) + 1)

    Return p
}

/// Create sample problems for a patient
ClassMethod CreateProblems(patient As Sample.EMR.Patient)
{
    Set problems = $ListBuild(
        $ListBuild("Allergy",          "Penicillin allergy",              "416098002", "Allergy to penicillin",         "Severe",   "Anaphylaxis"),
        $ListBuild("Allergy",          "Latex allergy",                   "300916003", "Allergy to latex",              "Moderate", "Urticaria"),
        $ListBuild("MedicationHistory","Metformin - prior use",           "372567009", "Metformin",                     "",         ""),
        $ListBuild("SurgicalHistory",  "Appendectomy",                    "80146002",  "Excision of appendix",          "",         ""),
        $ListBuild("SurgicalHistory",  "Cholecystectomy",                 "38102005",  "Cholecystectomy",               "",         ""),
        $ListBuild("ChronicCondition", "Hypertension",                    "38341003",  "Hypertensive disorder",         "Moderate", ""),
        $ListBuild("FamilyHistory",    "Father - coronary artery disease","53741008",  "Coronary arteriosclerosis",     "",         "")
    )

    Set count = $Random(3) + 1
    For i = 1:1:count {
        Set idx = $Random($ListLength(problems)) + 1
        Set item = $List(problems, idx)

        Set prob = ##class(Sample.EMR.Problem).%New()
        Set prob.Patient     = patient
        Set prob.ProblemType = $List(item, 1)
        Set prob.Description = $List(item, 2)
        Set prob.SNOMEDCode  = $List(item, 3)
        Set prob.SNOMEDTerm  = $List(item, 4)
        Set prob.Severity    = $List(item, 5)
        Set prob.Reaction    = $List(item, 6)
        Set prob.OnsetDate   = $ZDH("2020-01-" _ $Translate($Justify($Random(28) + 1, 2), " ", "0"), 3)
        Set prob.Status      = $Select($Random(5) = 0: "Resolved", 1: "Active")
        Set prob.RecordedBy  = patient.PrimaryPhysician
        $$$ThrowOnError(prob.%Save())
    }
}

/// Create sample diagnoses for a patient
ClassMethod CreateDiagnoses(patient As Sample.EMR.Patient)
{
    Set diagnoses = $ListBuild(
        $ListBuild("Primary",     "Type 2 Diabetes mellitus",        "44054006",  "Diabetes mellitus type 2",                "Active",   "Moderate"),
        $ListBuild("Primary",     "Essential hypertension",           "59621000",  "Essential hypertension",                  "Active",   "Mild"),
        $ListBuild("Primary",     "Community-acquired pneumonia",     "385093006", "Community acquired pneumonia",            "Resolved", "Moderate"),
        $ListBuild("Secondary",   "Chronic kidney disease stage 3",   "433144002", "Chronic kidney disease stage 3",          "Active",   "Moderate"),
        $ListBuild("Secondary",   "Hyperlipidemia",                   "55822004",  "Hyperlipidemia",                          "Active",   "Mild"),
        $ListBuild("Differential","Acute myocardial infarction",      "57054005",  "Acute myocardial infarction",             "Resolved", "Critical"),
        $ListBuild("Admitting",   "Acute appendicitis",               "85189001",  "Acute appendicitis",                      "Resolved", "Severe"),
        $ListBuild("Discharge",   "Urinary tract infection",          "68566005",  "Urinary tract infectious disease",        "Resolved", "Mild")
    )

    Set count = $Random(3) + 1
    For i = 1:1:count {
        Set idx = $Random($ListLength(diagnoses)) + 1
        Set item = $List(diagnoses, idx)

        Set diag = ##class(Sample.EMR.Diagnosis).%New()
        Set diag.Patient       = patient
        Set diag.DiagnosisType = $List(item, 1)
        Set diag.Description   = $List(item, 2)
        Set diag.SNOMEDCode    = $List(item, 3)
        Set diag.SNOMEDTerm    = $List(item, 4)
        Set diag.Status        = $List(item, 5)
        Set diag.Severity      = $List(item, 6)
        Set diag.DiagnosisDate = $ZDH("2022-" _ $Translate($Justify($Random(12) + 1, 2), " ", "0") _ "-01", 3)
        Set diag.DiagnosedBy   = patient.PrimaryPhysician
        Set diag.RecordedBy    = patient.PrimaryPhysician
        $$$ThrowOnError(diag.%Save())
    }
}

/// Create sample medications for a patient
ClassMethod CreateMedications(patient As Sample.EMR.Patient)
{
    Set meds = $ListBuild(
        $ListBuild("Metformin",      "372567009", "Metformin",              "860975",  "500",  "mg",  "BID",  "Oral",          "Type 2 Diabetes"),
        $ListBuild("Lisinopril",     "386873009", "Lisinopril",             "104375",  "10",   "mg",  "QD",   "Oral",          "Hypertension"),
        $ListBuild("Atorvastatin",   "373444002", "Atorvastatin",           "617310",  "20",   "mg",  "QD",   "Oral",          "Hyperlipidemia"),
        $ListBuild("Amoxicillin",    "372687004", "Amoxicillin",            "723",     "500",  "mg",  "TID",  "Oral",          "Infection"),
        $ListBuild("Insulin glargine","411529005","Insulin glargine",       "274783",  "20",   "IU",  "QD",   "Subcutaneous",  "Type 2 Diabetes"),
        $ListBuild("Ibuprofen",      "387207008", "Ibuprofen",              "5640",    "400",  "mg",  "PRN",  "Oral",          "Pain"),
        $ListBuild("Salbutamol",     "372897005", "Salbutamol",             "435",     "100",  "mcg", "PRN",  "Inhalation",    "Asthma"),
        $ListBuild("Omeprazole",     "372726003", "Omeprazole",             "7646",    "20",   "mg",  "QD",   "Oral",          "GERD")
    )

    Set count = $Random(3) + 1
    For i = 1:1:count {
        Set idx = $Random($ListLength(meds)) + 1
        Set item = $List(meds, idx)

        Set med = ##class(Sample.EMR.Medication).%New()
        Set med.Patient              = patient
        Set med.MedicationName       = $List(item, 1)
        Set med.SNOMEDCode           = $List(item, 2)
        Set med.SNOMEDTerm           = $List(item, 3)
        Set med.RxNormCode           = $List(item, 4)
        Set med.Dose                 = $List(item, 5)
        Set med.DoseUnit             = $List(item, 6)
        Set med.Frequency            = $List(item, 7)
        Set med.Route                = $List(item, 8)
        Set med.Indication           = $List(item, 9)
        Set med.StartDate            = $ZDH("2023-01-" _ $Translate($Justify($Random(28) + 1, 2), " ", "0"), 3)
        Set med.Status               = $Select($Random(5) = 0: "Discontinued", 1: "Active")
        Set med.Refills              = $Random(5)
        Set med.PrescribedBy         = patient.PrimaryPhysician
        $$$ThrowOnError(med.%Save())
    }
}

/// Create sample lab results for a patient
ClassMethod CreateLabResults(patient As Sample.EMR.Patient)
{
    // $ListBuild(TestName, SNOMEDCode, SNOMEDTerm, LOINCCode, low, high, unit)
    Set tests = $ListBuild(
        $ListBuild("Hemoglobin",          "38082009",  "Hemoglobin",                      "718-7",   120, 175, "g/L"),
        $ListBuild("Glucose (fasting)",   "33747003",  "Blood glucose measurement",       "1558-6",  3.9, 5.5, "mmol/L"),
        $ListBuild("Creatinine",          "70901006",  "Creatinine measurement",          "2160-0",  44,  106, "umol/L"),
        $ListBuild("HbA1c",               "43396009",  "Haemoglobin A1c measurement",     "4548-4",  4.0, 5.6, "%"),
        $ListBuild("Total Cholesterol",   "166842003", "Total cholesterol measurement",   "2093-3",  0,   5.2, "mmol/L"),
        $ListBuild("WBC Count",           "767002",    "White blood cell count",          "6690-2",  4.0, 11.0,"10^9/L"),
        $ListBuild("Platelet Count",      "61928009",  "Platelet count",                  "777-3",   150, 400, "10^9/L"),
        $ListBuild("Sodium",              "39972003",  "Sodium measurement",              "2951-2",  136, 145, "mmol/L"),
        $ListBuild("Potassium",           "59573005",  "Potassium measurement",           "2823-3",  3.5, 5.0, "mmol/L"),
        $ListBuild("TSH",                 "61167004",  "Thyroid stimulating hormone",     "3016-3",  0.4, 4.0, "mIU/L")
    )

    Set count = $Random(5) + 2
    For i = 1:1:count {
        Set idx = $Random($ListLength(tests)) + 1
        Set item = $List(tests, idx)

        Set low  = $List(item, 5)
        Set high = $List(item, 6)
        // Generate a value slightly outside range 20% of the time
        Set range = high - low
        Set value = low + (range * ($Random(140) / 100)) - (range * 0.1)
        Set value = $FNumber(value, "", 2)

        Set lab = ##class(Sample.EMR.LabResult).%New()
        Set lab.Patient         = patient
        Set lab.TestName        = $List(item, 1)
        Set lab.SNOMEDCode      = $List(item, 2)
        Set lab.SNOMEDTerm      = $List(item, 3)
        Set lab.LOINCCode       = $List(item, 4)
        Set lab.NormalRangeLow  = low
        Set lab.NormalRangeHigh = high
        Set lab.ResultValue     = value
        Set lab.ResultUnit      = $List(item, 7)
        Set lab.IsNormal        = (value >= low) && (value <= high)
        Set lab.Interpretation  = $Select(value < low: $Select(value < (low * 0.8): "CriticalLow", 1: "Low"),
                                          value > high: $Select(value > (high * 1.2): "CriticalHigh", 1: "High"),
                                          1: "Normal")
        Set lab.Status          = "Final"
        Set lab.CollectedDate   = $ZDateTime($Horolog - $Random(365), 3)
        Set lab.ReportedDate    = lab.CollectedDate
        Set lab.OrderedBy       = patient.PrimaryPhysician
        Set lab.PerformingLab   = "Central Laboratory"
        $$$ThrowOnError(lab.%Save())
    }
}

}
