# Starter
Do ##class(EMR.TestDataGenerator).GenerateAll()
Write ##class(EMR.JourneyCSVLoader).Load(1, 100)

## Goal

This file contains the two main load commands to initialize demo data in the project:

- patient and EMR test data
- journey seed data

## Load Patients

Generate patients and related EMR records:

```objectscript
Do ##class(EMR.TestDataGenerator).GenerateAll()
```

Generate a specific number of patients:

```objectscript
Do ##class(EMR.TestDataGenerator).GenerateAll(50)
```

What it creates:

- Patients
- Problems
- Diagnoses
- Medications
- Lab results

## Load Journeys

Load embedded journey seed data into `EMR.Journey`:

```objectscript
Write ##class(EMR.JourneyCSVLoader).Load()
```

Reload journeys and clear existing rows first:

```objectscript
Write ##class(EMR.JourneyCSVLoader).Load(1, 100)
```

Parameters:

- first argument: `clearExisting`
- second argument: `basePriority`

## Suggested Startup Order

```objectscript
Do ##class(EMR.TestDataGenerator).GenerateAll(10)
Write ##class(EMR.JourneyCSVLoader).Load(1, 100)
```

## Quick Verification

Check loaded patients:

```objectscript
Write ##class(EMR.PatientJSONExporter).ExportPatient(1)
```

Check loaded journeys:

```objectscript
Write ##class(EMR.JourneyJSONExporter).ExportAllJourneys()
```
