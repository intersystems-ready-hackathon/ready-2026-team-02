/// Utility class to export Journey data as JSON
Class EMR.JourneyJSONExporter
{

/// Export a single journey by internal ID
ClassMethod ExportJourney(journeyID As %Integer) As %String
{
    Set journey = ##class(EMR.Journey).%OpenId(journeyID)
    If ($IsObject(journey) = 0) {
        Return "{""error"":""Journey not found""}"
    }

    Set json = ##class(%Library.DynamicObject).%New()
    Do ..AddJourneyData(.json, journey)
    Return json.%ToJSON()
}

/// Export a single journey by Name
ClassMethod ExportJourneyByName(name As %String) As %String
{
    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Journey WHERE Name = ? ORDER BY ID",
        name
    )

    If rs.%Next() {
        Return ..ExportJourney(rs.%Get("ID"))
    }

    Return "{""error"":""Journey with name '" _ name _ "' not found""}"
}

/// Export all journeys to a JSON array
ClassMethod ExportAllJourneys() As %String
{
    Set array = ##class(%Library.DynamicArray).%New()

    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Journey ORDER BY Priority, ID"
    )

    While rs.%Next() {
        Set journey = ##class(EMR.Journey).%OpenId(rs.%Get("ID"))
        Set json = ##class(%Library.DynamicObject).%New()
        Do ..AddJourneyData(.json, journey)
        Do array.%Push(json)
    }

    Return array.%ToJSON()
}

/// Export only active journeys to a JSON array
ClassMethod ExportActiveJourneys() As %String
{
    Set array = ##class(%Library.DynamicArray).%New()

    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Journey WHERE IsActive = 1 ORDER BY Priority, ID"
    )

    While rs.%Next() {
        Set journey = ##class(EMR.Journey).%OpenId(rs.%Get("ID"))
        Set json = ##class(%Library.DynamicObject).%New()
        Do ..AddJourneyData(.json, journey)
        Do array.%Push(json)
    }

    Return array.%ToJSON()
}

/// Export active journeys in the exact API response format expected by the LLM layer
ClassMethod ExportActiveJourneysForLLM() As %String
{
    Set array = ##class(%Library.DynamicArray).%New()

    Set rs = ##class(%SQL.Statement).%ExecDirect(
        , "SELECT ID FROM EMR.Journey WHERE IsActive = 1 ORDER BY Priority, ID"
    )

    While rs.%Next() {
        Set journey = ##class(EMR.Journey).%OpenId(rs.%Get("ID"))
        Set item = ##class(%Library.DynamicObject).%New()

        Set item.journeyGoal = journey.JourneyGoal
        Set item.journeySummary = journey.JourneySummary
        Set item.workflowSummary = journey.WorkflowSummary
        Set item.timelineSummary = journey.TimelineSummary
        Set item.costSummary = journey.CostSummary

        Do array.%Push(item)
    }

    Return array.%ToJSON()
}

/// Pretty-print one journey by ID
ClassMethod ExportJourneyFormatted(journeyID As %Integer) As %String
{
    Set jsonStr = ..ExportJourney(journeyID)
    Set json = ##class(%Library.DynamicObject).%FromJSON(jsonStr)
    Return json.%ToJSON(, , 2)
}

/// Pretty-print all journeys
ClassMethod ExportAllJourneysFormatted() As %String
{
    Set jsonStr = ..ExportAllJourneys()
    Set json = ##class(%Library.DynamicArray).%FromJSON(jsonStr)
    Return json.%ToJSON(, , 2)
}

/// Populate one JSON object with all Journey fields
ClassMethod AddJourneyData(json As %Library.DynamicObject, journey As EMR.Journey)
{
    Set json.id = journey.%Id()
    Set json.name = journey.Name

    Set json.journeyGoal = journey.JourneyGoal
    Set json.journeySummary = journey.JourneySummary
    Set json.workflowSummary = journey.WorkflowSummary
    Set json.timelineSummary = journey.TimelineSummary
    Set json.costSummary = journey.CostSummary

    Set json.minAge = journey.MinAge
    Set json.maxAge = journey.MaxAge
    Set json.supportsMalePartner = journey.SupportsMalePartner
    Set json.minBudget = journey.MinBudget
    Set json.maxBudget = journey.MaxBudget
    Set json.requiresPreviousIVF = journey.RequiresPreviousIVF

    Set json.isActive = journey.IsActive
    Set json.priority = journey.Priority
    Set json.createdOn = journey.CreatedOn
    Set json.updatedOn = journey.UpdatedOn
}

}
