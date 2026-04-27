export type CarePlanRequest = {
  firstName: string;
  lastName: string;
  age: number;
  malePartner: boolean;
  malePartnerAge: number | null;
  malePartnerMarried: boolean | null;
  malePartnerSemenAnalysis: string | null;
  symptom: string;
  bmi: number;
  fsh: number;
  amh: number;
  previousIvf: boolean;
  insurerName: string;
  policyNumber: number;
  budget: number;
};

export type CarePlanResponse = {
  journeyGoal: string;
  journeySummary: string;
  workflowSummary: string;
  timelineSummary: string;
  costSummary: number;
};

export const exampleCarePlanRequest: CarePlanRequest = {
  firstName: "Anna",
  lastName: "Meyer",
  age: 34,
  malePartner: true,
  malePartnerAge: 36,
  malePartnerMarried: true,
  malePartnerSemenAnalysis: "JVBERi0xLjQKJcTl8uXrp...",
  symptom: "Irregular cycle",
  bmi: 23.4,
  fsh: 7.8,
  amh: 2.1,
  previousIvf: false,
  insurerName: "HealthCare Plus",
  policyNumber: 123456789,
  budget: 5000,
};

export const exampleCarePlanResponses: CarePlanResponse[] = [
  {
    journeyGoal:
      "Achieve a successful fertility treatment outcome based on the patient's medical profile and available budget.",
    journeySummary:
      "The patient will start with a fertility specialist consultation, followed by diagnostic checks and an individualized treatment recommendation.",
    workflowSummary:
      "The workflow includes medical review, hormone value assessment, partner-related analysis if applicable, insurance validation, and care plan creation.",
    timelineSummary:
      "The initial assessment and diagnostics are expected within the first two weeks, followed by treatment planning in week three.",
    costSummary: 190719,
  },
];
