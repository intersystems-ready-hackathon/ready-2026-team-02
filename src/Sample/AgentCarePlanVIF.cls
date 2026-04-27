Class Sample.AgentCarePlanVIF Extends %AI.Agent
{
/// LLM Provider
Parameter PROVIDER = "openai";

/// LLM Model
Parameter MODEL = "gpt-5-nano";

/// Toolsets that the agent can use
Parameter TOOLSETS = "Sample.ToolSet";

/// System Prompt
XData INSTRUCTIONS [ MimeType = text/markdown ]
{
# Sample Assistant

You are a agent to create a care plan based on the patient information provided.
You have also access to a tool to retrieve patient additional information from a json document.
}

Method %CreateProvider() As %Status {
    Set apiKey = $System.Util.GetEnviron("OPENAI_API_KEY")
    If apiKey = "" {
        Quit $$$ERROR($$$GeneralError, "OPENAI_API_KEY is not set")
    }

    Set sc = $$$OK
    Try {
        Set settings = {"api_key": (apiKey)}
        Set ..Provider = ##class(%AI.Provider).Create(..#PROVIDER, settings)
    } Catch ex {
        Set sc = $$$ERROR($$$GeneralError, "Failed to create provider '" _ ..#PROVIDER _ "': " _ ex.DisplayString())
    }

    If $$$ISERR(sc) Quit sc
    Quit $$$OK
}


}
