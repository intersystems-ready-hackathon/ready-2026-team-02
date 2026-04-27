Class Rest.VIF Extends %CSP.REST
{
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/vif" Method="POST" Call="CreateCarePlan"/>
    <Route Url="/ping" Method="GET" Call="Ping"/>
</Routes>
}

ClassMethod Test() As %Status
{
    Set sc = $$$OK
    Try {
        Set patientform = {
    "firstName": "Anna",
    "lastName": "Meyer",
    "age": 34,
    "malePartner": true,
    "malePartnerAge": 36,
    "malePartnerMarried": true,
    "malePartnerSemenAnalysis": "JVBERi0xLjQKJcTl8uXrp...",
    "symptom": "Irregular cycle",
    "bmi": 23.4,
    "fsh": 7.8,
    "amh": 2.1,
    "previousIvf": false,
    "insurerName": "HealthCare Plus",
    "policyNumber": 123456789,
    "budget": 5000
    }

        Set agent = ##class(Sample.Agent).%New()
        $$$TOE(sc, agent.%Init())
        w !,"init done"
        Set session = agent.CreateSession()
        w !,"session created"
        // This requires using both tools defined in Sample.Tools and packaged in Sample.ToolSet
        Set request = "Please create the care plan for the following patient: " _ patientform.%ToJSON() _ " use the tools available retrieve addition information."
        w !,"request created"
        Set response = agent.Chat(session, request)
        w !,!, "Response: ", response.Content
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

ClassMethod CreateCarePlan() As %Status
{
    Set sc = $$$OK

    Try {
        Set patientform = {}.%FromJSON(%request.Body)

        Set agent = ##class(Sample.Agent).%New()
        $$$TOE(sc, agent.%Init())
        Set session = agent.CreateSession()
        // This requires using both tools defined in Sample.Tools and packaged in Sample.ToolSet
        Set request = "Please create the care plan for the following patient: " _ patientform.%ToJSON() _ " use the tools available retrieve addition information."
        Set response = agent.Chat(session, request)
        Write response.Content

    }
    Catch ex {

        Set sc = ex.AsStatus()
    }

    Return sc
}

ClassMethod Ping()
{
    Write {"message": "pong"}.%ToJSON()
    Return $$$OK

}
}