# Journey JSON Exporter

## Overview

EMR.JourneyJSONExporter exports one journey or multiple journeys as JSON.

The class supports:

- Full export for administration and debugging
- Active-only export
- LLM-ready export with only response fields

## Class

EMR.JourneyJSONExporter

## Available Methods

### ExportJourney

Returns one journey payload by internal ID.

```objectscript
Write ##class(EMR.JourneyJSONExporter).ExportJourney(1)
```

Signature:

```objectscript
ClassMethod ExportJourney(journeyID As %Integer) As %String
```

### ExportJourneyByName

Returns one journey payload by name.

```objectscript
Write ##class(EMR.JourneyJSONExporter).ExportJourneyByName("Standard IVF Journey")
```

Signature:

```objectscript
ClassMethod ExportJourneyByName(name As %String) As %String
```

### ExportAllJourneys

Returns all journeys as a JSON array (ordered by priority, then ID).

```objectscript
Write ##class(EMR.JourneyJSONExporter).ExportAllJourneys()
```

Signature:

```objectscript
ClassMethod ExportAllJourneys() As %String
```

### ExportActiveJourneys

Returns only active journeys as a JSON array.

```objectscript
Write ##class(EMR.JourneyJSONExporter).ExportActiveJourneys()
```

Signature:

```objectscript
ClassMethod ExportActiveJourneys() As %String
```

### ExportActiveJourneysForLLM

Returns active journeys in the exact response format expected by the LLM/API layer.

```objectscript
Write ##class(EMR.JourneyJSONExporter).ExportActiveJourneysForLLM()
```

Signature:

```objectscript
ClassMethod ExportActiveJourneysForLLM() As %String
```

### ExportJourneyFormatted

Pretty-printed version of ExportJourney.

```objectscript
Write ##class(EMR.JourneyJSONExporter).ExportJourneyFormatted(1)
```

Signature:

```objectscript
ClassMethod ExportJourneyFormatted(journeyID As %Integer) As %String
```

### ExportAllJourneysFormatted

Pretty-printed version of ExportAllJourneys.

```objectscript
Write ##class(EMR.JourneyJSONExporter).ExportAllJourneysFormatted()
```

Signature:

```objectscript
ClassMethod ExportAllJourneysFormatted() As %String
```

## Response Structure

### Full Journey Object

ExportJourney, ExportJourneyByName, ExportAllJourneys, and ExportActiveJourneys return this structure:

```json
{
  "id": 1,
  "name": "Standard IVF Journey",
  "journeyGoal": "Achieve a successful fertility treatment outcome based on the patient's profile.",
  "journeySummary": "The patient starts with specialist consultation and diagnostics.",
  "workflowSummary": "Medical review, hormonal workup, insurance check, and care plan definition.",
  "timelineSummary": "Diagnostics in weeks 1-2 and treatment planning in week 3.",
  "costSummary": 190719,
  "minAge": 28,
  "maxAge": 40,
  "supportsMalePartner": true,
  "minBudget": 3000,
  "maxBudget": 15000,
  "requiresPreviousIVF": false,
  "isActive": true,
  "priority": 100,
  "createdOn": "2026-04-27 12:30:00",
  "updatedOn": null
}
```

### LLM/API Response Object

ExportActiveJourneysForLLM returns an array of objects with only these fields:

```json
[
  {
    "journeyGoal": "Achieve a successful fertility treatment outcome based on the patient's medical profile and available budget.",
    "journeySummary": "The patient will start with a fertility specialist consultation, followed by diagnostic checks and an individualized treatment recommendation.",
    "workflowSummary": "The workflow includes medical review, hormone value assessment, partner-related analysis if applicable, insurance validation, and care plan creation.",
    "timelineSummary": "The initial assessment and diagnostics are expected within the first two weeks, followed by treatment planning in week three.",
    "costSummary": 190719
  }
]
```

## Error Responses

If no journey is found by ID:

```json
{"error":"Journey not found"}
```

If no journey is found by name:

```json
{"error":"Journey with name 'Some Name' not found"}
```

## Notes

- ExportAllJourneys and ExportActiveJourneys are ordered by Priority then ID.
- ExportActiveJourneysForLLM is intended for direct API response payload generation.
- Numeric and date/time serialization follows IRIS JSON conversion behavior.
