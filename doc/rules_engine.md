Backend rule engine that takes the intake fields, derives structured flags, and then populates the output fields.
The raw inputs you listed are enough to generate a useful first-pass pathway recommendation, but it should be framed as coordination and decision support, not diagnosis. That is especially important because ovarian reserve testing does not by itself determine fertility, and semen analysis abnormalities typically need confirmation and clinical context.  ￼
What the engine is doing: ingest → classify → assemble pathway → write outputs
Use deterministic rules for classification and pathway branching

from:

* name
* age
* partner (y/n)
* partner age
* semen analysis image
* AMH
* FSH
* BMI
* location
* insurance
* policy

it produces:

* Journey Goal
* Journey Summary
* Workflow Summary
* Timeline Summary
* Cost Summary


Step A — Normalize inputs into internal flags

* advanced_reproductive_age
* partner_present
* male_factor_flag
* diminished_ovarian_reserve_flag
* high_bmi_flag
* insurance_known
* donor_sperm_needed
* urgent_pathway_flag
* location_market

⸻

Step B — Rules for ovarian reserve / age

* if age >= 40 → advanced_reproductive_age = true
* if AMH < 1.0 → reduced_ovarian_reserve_signal = true
* if FSH > 10 → elevated_fsh_signal = true
* if both AMH low and FSH high → diminished_ovarian_reserve_flag = true

Logic: ASRM explains that lower AMH and higher early follicular FSH are associated with lower ovarian reserve, but these tests do not directly prove infertility.  ￼

Step C — Rules for semen analysis

Logic: WHO lower reference limits commonly used include:

* semen volume 1.4 mL
* sperm concentration 16 million/mL
* total sperm number 39 million/ejaculate
* progressive motility 30%
* morphology 4% normal forms
* vitality 54%.  ￼

Extract numeric values from the image/report and classify them.

PtP semen-analysis rules

* if concentration = 0 → azoospermia_flag = true
* else if concentration < 16 → low_concentration_flag = true
* if progressive_motility < 30 → low_motility_flag = true
* if morphology < 4 → low_morphology_flag = true
* if 2 or more abnormal semen flags → male_factor_flag = true

Logic: If partner = no, then semen-analysis logic is skipped and the engine can infer:
donor_sperm_needed = true for a single intended mother pursuing IVF with donor sperm


Step D — BMI and cycle management flags

Logic: BMI can affect workflow complexity, medication, anesthesia, and clinic requirements. 
It can change outcomes:
* clinic matching
* prep steps
* timing
* counseling notes

* if BMI >= 30 → higher_cycle_complexity_flag = true
* if BMI >= 35 → anesthesia_or_clinic_constraint_review = true


Step E — Partner logic

If partner = no, set donor_sperm_needed = true

If partner = yes and semen analysis abnormal, set male_factor_pathway = true

If partner = yes and semen analysis normal, male factor branch stays off

⸻

Step F — Insurance / policy logic

This should affect:
* cost summary
* workflow summary
* provider matching
* urgency / triage

Rules:
* if insurance is blank or unknown → coverage_uncertain_flag = true
* if policy includes fertility benefit → fertility_benefit_flag = true
* if donor sperm / cryobank likely uncovered → add uncovered-cost note
* if PGT-A likely not covered → add uncovered-cost note

4. Pathway assembly logic

Once the flags are set, the engine chooses a journey template.
* IVF with own eggs
* IVF with donor sperm
* IVF with donor egg
* IVF + PGT-A
* male factor IVF/ICSI
* urgent fertility preservation
* gestational carrier / surrogacy pathway



5. Rule logic for your sample case

Output

1. Journey Goal
    Have a biological child with donor sperm as quickly as practical
2. Journey Summary
    Age 43 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A before transfer.
3. Workflow Summary
    A1 intake + reserve labs → A2 advanced-age pathway recommendation → A3 donor-sperm/FDA consents → A4 IVF + PGT-A care plan → A5 clinic/cryobank matching → A6 cycle, meds, and transfer orchestration.
4. Timeline Summary
    Expected 8–11 weeks: consult and donor selection → stimulation and retrieval → embryo creation/PGT-A → frozen transfer prep
5. Estimated Oop High USD
   14,000
6. Estimated Oop Low USD 
   28,000
   


Example input

* name: Jane Doe
* age: 43
* partner: no
* AMH: 0.8
* FSH: 11.5
* BMI: 24
* location: Sacramento, CA
* insurance: commercial
* policy: no donor benefit listed / fertility benefit limited


Derived flags

* advanced_reproductive_age = true
* reduced_ovarian_reserve_signal = true
* elevated_fsh_signal = true
* diminished_ovarian_reserve_flag = true
* partner_present = false
* donor_sperm_needed = true
* location_market = sacramento_ca
* coverage_uncertain_or_limited = true


Pathway chosen

IVF with donor sperm, advanced-age pathway, embryo selection / possible PGT-A counseling

Why this is reasonable:

* advancing maternal age is clinically relevant in IVF decision-making and embryo aneuploidy risk discussions
* ASRM notes PGT-A may be considered in select patients of advanced reproductive age expected to have multiple embryos available, but does not support routine universal PGT-A for all IVF cases.  ￼


6. How each output field gets generated

1) Journey Goal

This comes from:

* partner status
* patient goal template
* age urgency
* donor need
* speed preference if present

Rule pattern

* if partner = no → include “with donor sperm”
* if age >= 40 → include urgency language like “as quickly as practical”
* if no preservation goal and wants pregnancy → “have a biological child”

Example

Have a biological child with donor sperm as quickly as practical


2) Journey Summary

This is a compressed narrative assembled from:

* age
* family-building structure
* location
* main pathway
* priorities

Template
Age [age] [single intended parent / partnered patient] pursuing [pathway] in [location]; prioritizes [priority 1], [priority 2], and [priority 3].

Example
Age 43 single intended parent pursuing IVF in Sacramento with donor sperm; prioritizes speed, embryo quality review, and PGT-A counseling before transfer.


3) Workflow Summary

This should come from a fixed library of workflow blocks.

Example workflow blocks

* A1 intake + reserve labs
* A2 advanced-age pathway review
* A3 donor-sperm selection + required consents
* A4 IVF stimulation / retrieval plan
* A5 embryology + possible PGT-A branch
* A6 transfer planning and medication orchestration

Then the engine concatenates them.


4) Timeline Summary

This comes from the selected workflow template.

Example timing assumptions

For a donor-sperm IVF cycle with retrieval plus possible PGT-A:

* consult + donor selection: 1–3 weeks
* stimulation + retrieval: 2–3 weeks
* embryo development + PGT-A turnaround if chosen: 2–3 weeks
* frozen transfer prep: 2–3 weeks

So 8–11 weeks is a reasonable product estimate for a first-pass pathway summary, as long as it is presented as an estimate rather than a promise.


5) Cost Summary

Cost Summary output example

Estimated out-of-pocket range: $26K–$50K+, depending on medication response, donor sperm selection, embryology services, and whether PGT-A is performed. Insurance coverage for donor sperm and genetic testing should be verified separately.


Recommended backend flow

Engine flow

1. parse input
2. extract semen-analysis values if partner = yes
3. compute clinical/operational flags
4. select journey template
5. attach workflow blocks
6. attach timeline assumptions
7. attach cost ranges
8. render user-facing summaries


Pseudocode

flags = []
if age >= 40:
    flags.append("advanced_reproductive_age")
if amh is not None and amh < 1.0:
    flags.append("low_amh")
if fsh is not None and fsh > 10:
    flags.append("high_fsh")
if "low_amh" in flags and "high_fsh" in flags:
    flags.append("diminished_ovarian_reserve_signal")
if partner == "n":
    flags.append("donor_sperm_needed")
else:
    semen = parse_semen_analysis(semen_report_image)
    if semen["concentration"] == 0:
        flags.append("azoospermia")
    else:
        if semen["concentration"] < 16:
            flags.append("low_concentration")
        if semen["progressive_motility"] < 30:
            flags.append("low_motility")
        if semen["morphology"] < 4:
            flags.append("low_morphology")
    if len([f for f in flags if f in ["low_concentration","low_motility","low_morphology","azoospermia"]]) >= 2:
        flags.append("male_factor_pathway")

Then:

if "donor_sperm_needed" in flags and "advanced_reproductive_age" in flags:
    template = "advanced_age_ivf_donor_sperm"
elif "male_factor_pathway" in flags:
    template = "male_factor_ivf_icsi"
elif "diminished_ovarian_reserve_signal" in flags:
    template = "reduced_reserve_ivf"
else:
    template = "standard_fertility_workup"

⸻

Best product framing

The rule engine should decide:

* pathway family
* workflow blocks
* timeline band
* cost band
* summary text ingredients

The LLM should only turn those structured outputs into polished sentences.


For each case, generate this object:

{
  "journey_goal": "",
  "journey_template": "",
  "derived_flags": [],
  "journey_summary": "",
  "workflow_steps": [],
  "workflow_summary": "",
  "timeline_weeks_low": 0,
  "timeline_weeks_high": 0,
  "timeline_summary": "",
  "cost_items": [],
  "cost_total_low": 0,
  "cost_total_high": 0,
  "cost_summary": "",
  "governance_notes": []
}

