const defaultCarePlanApiEndpoint = "localhost:59773/csp/demo/vif";

function normalizeApiEndpoint(endpoint: string) {
  if (/^https?:\/\//i.test(endpoint)) {
    return endpoint;
  }

  return `http://${endpoint}`;
}

export const carePlanApiEndpoint = normalizeApiEndpoint(
  process.env.NEXT_PUBLIC_CARE_PLAN_API_URL ?? defaultCarePlanApiEndpoint,
);

export const useMockCarePlanResponse =
  process.env.NEXT_PUBLIC_CARE_PLAN_USE_MOCK === "true";
