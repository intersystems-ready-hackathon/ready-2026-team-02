/// Stores reusable care-plan journey templates used by the API/LLM response.
/// 
/// Response mapping:
/// - JourneyGoal -> journeyGoal
/// - JourneySummary -> journeySummary
/// - WorkflowSummary -> workflowSummary
/// - TimelineSummary -> timelineSummary
/// - CostSummary -> costSummary
/// 
/// Selection model:
/// - A journey is considered selectable when IsActive = 1 and optional filters match
///   the patient context (age, budget, partner settings, previous IVF).
/// - Priority can be used to rank candidates when multiple journeys match.
Class Sample.Journey Extends %Persistent
{

/// Human-readable name for this journey template
Property Name As %String(MAXLEN = 200) [ Required ];

/// Main objective returned to the LLM response
Property JourneyGoal As %String(MAXLEN = 2000) [ Required ];

/// High-level patient journey summary
Property JourneySummary As %String(MAXLEN = 4000) [ Required ];

/// Workflow-oriented summary (steps, checks, validation)
Property WorkflowSummary As %String(MAXLEN = 4000) [ Required ];

/// Timeline-oriented summary
Property TimelineSummary As %String(MAXLEN = 4000) [ Required ];

/// Estimated total cost used in API response
Property CostSummary As %Numeric(SCALE = 2) [ Required ];

/// Minimum patient age (inclusive). Empty means no lower age limit.
Property MinAge As %Integer;

/// Maximum patient age (inclusive). Empty means no upper age limit.
Property MaxAge As %Integer;

/// Indicates whether this journey supports cases with a male partner.
/// Empty means no partner constraint.
Property SupportsMalePartner As %Boolean;

/// Minimum accepted budget (inclusive). Empty means no lower budget limit.
Property MinBudget As %Numeric(SCALE = 2);

/// Maximum accepted budget (inclusive). Empty means no upper budget limit.
Property MaxBudget As %Numeric(SCALE = 2);

/// If true, this journey targets patients with previous IVF history.
/// Empty means no IVF-history constraint.
Property RequiresPreviousIVF As %Boolean;

/// Allows soft disabling without deleting data
Property IsActive As %Boolean [ InitialExpression = 1 ];

/// Optional ranking score when multiple journeys match
Property Priority As %Integer [ InitialExpression = 100 ];

/// Creation timestamp in logical %TimeStamp format.
Property CreatedOn As %TimeStamp [ InitialExpression = {$ZDATETIMEH($HOROLOG,3)} ];

/// Last update timestamp. Set by application logic when records are edited.
Property UpdatedOn As %TimeStamp;

/// Speeds up active-journey filtering.
Index ActiveIndex On IsActive;

/// Speeds up ranked selection among matching journeys.
Index PriorityIndex On Priority;

/// Supports budget range pre-filtering.
Index BudgetIndex On (MinBudget, MaxBudget);

/// Supports age range pre-filtering.
Index AgeIndex On (MinAge, MaxAge);

Storage Default
{
<Data name="JourneyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>JourneyGoal</Value>
</Value>
<Value name="4">
<Value>JourneySummary</Value>
</Value>
<Value name="5">
<Value>WorkflowSummary</Value>
</Value>
<Value name="6">
<Value>TimelineSummary</Value>
</Value>
<Value name="7">
<Value>CostSummary</Value>
</Value>
<Value name="8">
<Value>MinAge</Value>
</Value>
<Value name="9">
<Value>MaxAge</Value>
</Value>
<Value name="10">
<Value>SupportsMalePartner</Value>
</Value>
<Value name="11">
<Value>MinBudget</Value>
</Value>
<Value name="12">
<Value>MaxBudget</Value>
</Value>
<Value name="13">
<Value>RequiresPreviousIVF</Value>
</Value>
<Value name="14">
<Value>IsActive</Value>
</Value>
<Value name="15">
<Value>Priority</Value>
</Value>
<Value name="16">
<Value>CreatedOn</Value>
</Value>
<Value name="17">
<Value>UpdatedOn</Value>
</Value>
</Data>
<DataLocation>^Sample.JourneyD</DataLocation>
<DefaultData>JourneyDefaultData</DefaultData>
<IdLocation>^Sample.JourneyD</IdLocation>
<IndexLocation>^Sample.JourneyI</IndexLocation>
<StreamLocation>^Sample.JourneyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
