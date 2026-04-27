Class EMR.JourneyCSVLoader Extends %RegisteredObject
{

/// Import Journey records from embedded semicolon-separated CSV seed data.
/// 
/// Expected columns:
/// - Profile ID
/// - Journey Goal
/// - Journey Summary
/// - Workflow Summary
/// - Timeline Summary
/// - Estimated OOP Low USD
/// - Estimated OOP High USD
ClassMethod Load(clearExisting As %Boolean = 0, basePriority As %Integer = 100) As %String
{
    Set result = ##class(%DynamicObject).%New()
    Set errors = ##class(%DynamicArray).%New()

    Set rowsJson = ..ReadEmbeddedRows()
    If rowsJson = "" {
        Set result.ok = 0
        Set result.message = "No rows returned from embedded CSV parser"
        Quit result.%ToJSON()
    }

    Set rows = ##class(%DynamicArray).%FromJSON(rowsJson)
    Set result.rowsRead = rows.%Size()

    If clearExisting {
        Set sc = ##class(EMR.Journey).%KillExtent()
        If sc '= 1 {
            Set result.ok = 0
            Set result.message = "Unable to clear existing Journey rows"
            Quit result.%ToJSON()
        }
    }

    Set inserted = 0
    Set i = 0
    While i < rows.%Size() {
        Set row = rows.%Get(i)

        Set name = ..AsString(row.%Get("Profile ID"))
        If name = "" {
            Set name = "Journey-" _ (i + 1)
        }

        Set journeyGoal = ..NormalizeText(..AsString(row.%Get("Journey Goal")))
        Set journeySummary = ..NormalizeText(..AsString(row.%Get("Journey Summary")))
        Set workflowSummary = ..NormalizeText(..AsString(row.%Get("Workflow Summary")))
        Set timelineSummary = ..NormalizeText(..AsString(row.%Get("Timeline Summary")))

        If journeyGoal = "" Set journeyGoal = "N/A"
        If journeySummary = "" Set journeySummary = "N/A"
        If workflowSummary = "" Set workflowSummary = "N/A"
        If timelineSummary = "" Set timelineSummary = "N/A"

        Set low = ..ToNumber(row.%Get("Estimated OOP Low USD"))
        Set high = ..ToNumber(row.%Get("Estimated OOP High USD"))
        Set cost = ..ComputeCost(low, high)

        w "11",!,"Processing row ",(i + 2),": ",name
        Set journey = ##class(EMR.Journey).%New()
        Set journey.Name = name
        Set journey.JourneyGoal = journeyGoal
        Set journey.JourneySummary = journeySummary
        Set journey.WorkflowSummary = workflowSummary
        Set journey.TimelineSummary = timelineSummary
        Set journey.CostSummary = cost
        Set journey.MinBudget = low
        Set journey.MaxBudget = high
        Set journey.IsActive = 1
        Set journey.Priority = basePriority + i
        w "11",!,"  Goal: ",journeyGoal
        Set sc = journey.%Save()
        w "11",!,"  sc" = sc
        If sc = 1 {
            Set inserted = inserted + 1
        } Else {
            Do errors.%Push("Row " _ (i + 2) _ ": save failed for profile '" _ name _ "'")
        }

        Set i = i + 1
    }

    w "11",!,"Inserted ",inserted," rows with ",errors.%Size()," errors."
    Set result.ok = $Select(errors.%Size()=0:1, 1:0)
    Set result.inserted = inserted
    Set result.errors = errors
    Set result.message = $Select(errors.%Size()=0:"Import completed",1:"Import completed with errors")
    Quit result.%ToJSON()
}

ClassMethod ComputeCost(low, high) As %Numeric
{
    If (low '= "") && (high '= "") {
        Quit (low + high) / 2
    }
    If low '= "" {
        Quit low
    }
    If high '= "" {
        Quit high
    }
    Quit 0
}

ClassMethod AsString(value) As %String
{
    If '$IsObject(value) {
        Quit $Get(value)
    }
    Quit ""
}

ClassMethod ToNumber(value)
{
    Set s = ..AsString(value)
    If s = "" {
        Quit ""
    }

    Set s = $Translate(s, ",", "")
    If s?1"-".N Quit +s
    If s?.N Quit +s
    If s?1"-".N1".".N Quit +s
    If s?.N1".".N Quit +s
    Quit ""
}

ClassMethod NormalizeText(value As %String) As %String
{
    Set text = $Get(value)
    Set text = $Replace(text, " ? ", " -> ")
    Quit text
}

/// Read rows from embedded semicolon-delimited CSV seed data into a JSON array.
ClassMethod ReadEmbeddedRows() As %String [ Language = python ]
{
    import csv
    import io
    import json

    csv_text = """Profile ID;Journey Goal;Journey Summary;Workflow Summary;Timeline Summary;Estimated OOP Low USD;Estimated OOP High USD
P0001;Have a biological child with donor sperm as quickly as practical;"Age 43 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;14859;28496
P0002;Have a biological child with donor sperm as quickly as practical;"Age 40 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0003;Have a biological child with donor sperm as quickly as practical;"Age 41 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0004;Have a biological child with donor sperm as quickly as practical;"Age 39 single intended parent pursuing IVF in San Diego with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;14859;28496
P0005;Have a biological child with donor sperm as quickly as practical;"Age 42 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0006;Have a biological child with donor sperm as quickly as practical;"Age 38 single intended parent pursuing IVF in San Diego with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0007;Have a biological child with donor sperm as quickly as practical;"Age 37 single intended parent pursuing IVF in San Diego with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0008;Have a biological child with donor sperm as quickly as practical;"Age 40 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0009;Have a biological child with donor sperm as quickly as practical;"Age 39 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0010;Have a biological child with donor sperm as quickly as practical;"Age 38 single intended parent pursuing IVF in Los Angeles with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0011;Have a biological child with donor sperm as quickly as practical;"Age 43 single intended parent pursuing IVF in San Diego with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0012;Have a biological child with donor sperm as quickly as practical;"Age 37 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0013;Have a biological child with donor sperm as quickly as practical;"Age 37 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0014;Have a biological child with donor sperm as quickly as practical;"Age 40 single intended parent pursuing IVF in Los Angeles with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;14859;28496
P0015;Have a biological child with donor sperm as quickly as practical;"Age 40 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0016;Have a biological child with donor sperm as quickly as practical;"Age 42 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0017;Have a biological child with donor sperm as quickly as practical;"Age 40 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;14859;28496
P0018;Have a biological child with donor sperm as quickly as practical;"Age 37 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0019;Have a biological child with donor sperm as quickly as practical;"Age 38 single intended parent pursuing IVF in Los Angeles with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0020;Have a biological child with donor sperm as quickly as practical;"Age 41 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0021;Have a biological child with donor sperm as quickly as practical;"Age 39 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0022;Have a biological child with donor sperm as quickly as practical;"Age 42 single intended parent pursuing IVF in San Diego with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0023;Have a biological child with donor sperm as quickly as practical;"Age 43 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0024;Have a biological child with donor sperm as quickly as practical;"Age 40 single intended parent pursuing IVF in Los Angeles with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0025;Have a biological child with donor sperm as quickly as practical;"Age 39 single intended parent pursuing IVF in Los Angeles with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;14859;28496
P0026;Have a biological child with donor sperm as quickly as practical;"Age 41 single intended parent pursuing IVF in San Francisco with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0027;Have a biological child with donor sperm as quickly as practical;"Age 42 single intended parent pursuing IVF in San Diego with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0028;Have a biological child with donor sperm as quickly as practical;"Age 40 single intended parent pursuing IVF in San Diego with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0029;Have a biological child with donor sperm as quickly as practical;"Age 40 single intended parent pursuing IVF in Los Angeles with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;14859;28496
P0030;Have a biological child with donor sperm as quickly as practical;"Age 39 single intended parent pursuing IVF in San Diego with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.";A1 intake + reserve labs ? A2 advanced-age pathway recommendation ? A3 donor-sperm/FDA consents ? A4 IVF + PGT-A care plan ? A5 clinic/cryobank matching ? A6 cycle, meds, and transfer orchestration.;Expected 8-11 weeks: consult and donor selection ? stimulation and retrieval ? embryo creation/PGT-A ? frozen transfer prep.;13689;25376
P0031;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in Los Angeles; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1540;4704
P0032;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in Orange County; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0033;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Jose; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0034;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in Los Angeles; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1540;4830
P0035;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Francisco; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0036;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Jose; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0037;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in Los Angeles; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1540;4704
P0038;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Francisco; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1540;4704
P0039;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Diego; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0040;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Jose; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1540;4830
P0041;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Francisco; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0042;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Jose; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1680;5334
P0043;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in Los Angeles; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0044;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Diego; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1540;4704
P0045;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Francisco; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0046;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Diego; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0047;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in San Jose; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0048;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in Orange County; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1680;5334
P0049;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in Los Angeles; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1400;4200
P0050;Pursue first child using covered IVF pathway;"Insured heterosexual couple pursuing first-child IVF in Los Angeles; uses coverage to move directly from workup into stimulation and transfer.";A1 couple intake ? A2 standard IVF recommendation ? A3 benefits validation ? A4 stimulation / retrieval / transfer plan ? A5 in-network provider match ? A6 operational scheduling and utilization management.;Expected 7-9 weeks: diagnostics and benefits ? stimulation ? retrieval ? fresh/frozen transfer depending embryo and progesterone profile.;1540;4704
"""

    rows = []
    reader = csv.DictReader(io.StringIO(csv_text), delimiter=';')
    for row in reader:
        if any((str(value).strip() if value is not None else "") for value in row.values()):
            rows.append(row)

    return json.dumps(rows, ensure_ascii=True)
}

}
