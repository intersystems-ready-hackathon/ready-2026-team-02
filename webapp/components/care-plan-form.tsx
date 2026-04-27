"use client";

import { FormEvent, SVGProps, useMemo, useState } from "react";

import {
  CarePlanRequest,
  CarePlanResponse,
  exampleCarePlanRequest,
  exampleCarePlanResponses,
} from "@/lib/care-plan-data";
import {
  carePlanApiEndpoint,
  useMockCarePlanResponse,
} from "@/lib/care-plan-config";

type CarePlanFormState = Omit<
  CarePlanRequest,
  "age" | "malePartnerAge" | "bmi" | "fsh" | "amh" | "policyNumber" | "budget"
> & {
  age: string;
  malePartnerAge: string;
  bmi: string;
  fsh: string;
  amh: string;
  policyNumber: string;
  budget: string;
};

type IconName =
  | "calendar"
  | "document"
  | "goal"
  | "heart"
  | "medical"
  | "partner"
  | "privacy"
  | "sparkle"
  | "user"
  | "workflow";

type RequestStatus = "idle" | "loading" | "success" | "error" | "mock";

const initialFormState: CarePlanFormState = {
  ...exampleCarePlanRequest,
  age: String(exampleCarePlanRequest.age),
  malePartnerAge: String(exampleCarePlanRequest.malePartnerAge ?? ""),
  malePartnerSemenAnalysis: exampleCarePlanRequest.malePartnerSemenAnalysis ?? "",
  bmi: String(exampleCarePlanRequest.bmi),
  fsh: String(exampleCarePlanRequest.fsh),
  amh: String(exampleCarePlanRequest.amh),
  policyNumber: String(exampleCarePlanRequest.policyNumber),
  budget: String(exampleCarePlanRequest.budget),
};

const previewItems = [
  {
    key: "journeyGoal",
    title: "Journey Goal",
    icon: "goal",
  },
  {
    key: "journeySummary",
    title: "Journey Summary",
    icon: "document",
  },
  {
    key: "workflowSummary",
    title: "Workflow Summary",
    icon: "workflow",
  },
  {
    key: "timelineSummary",
    title: "Timeline Summary",
    icon: "calendar",
  },
] as const;

const currencyFormatter = new Intl.NumberFormat("en-IN", {
  currency: "INR",
  maximumFractionDigits: 0,
  style: "currency",
});

export function CarePlanForm() {
  const [form, setForm] = useState<CarePlanFormState>(initialFormState);
  const [carePlan, setCarePlan] = useState<CarePlanResponse | null>(
    useMockCarePlanResponse ? exampleCarePlanResponses[0] : null,
  );
  const [requestStatus, setRequestStatus] = useState<RequestStatus>(
    useMockCarePlanResponse ? "mock" : "idle",
  );
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [hasPendingChanges, setHasPendingChanges] = useState(false);

  const isLoading = requestStatus === "loading";
  const patientName = useMemo(
    () => [form.firstName, form.lastName].filter(Boolean).join(" "),
    [form.firstName, form.lastName],
  );

  function updateField<K extends keyof CarePlanFormState>(
    field: K,
    value: CarePlanFormState[K],
  ) {
    setForm((current) => ({ ...current, [field]: value }));
    setErrorMessage(null);
    setRequestStatus((current) => (current === "error" ? "idle" : current));
    setHasPendingChanges(true);
  }

  async function handleGenerate(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErrorMessage(null);
    setHasPendingChanges(false);

    if (useMockCarePlanResponse) {
      setCarePlan(exampleCarePlanResponses[0]);
      setRequestStatus("mock");
      return;
    }

    setRequestStatus("loading");

    try {
      const response = await fetch(carePlanApiEndpoint, {
        body: JSON.stringify(toCarePlanRequest(form)),
        headers: {
          "Content-Type": "application/json",
        },
        method: "POST",
      });

      if (!response.ok) {
        throw new Error(`Backend returned ${response.status}`);
      }

      const responseBody: unknown = await response.json();
      const nextCarePlan = readCarePlanResponse(responseBody);

      setCarePlan(nextCarePlan);
      setRequestStatus("success");
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : "The backend request failed.",
      );
      setRequestStatus("error");
    }
  }

  return (
    <main className="min-h-screen overflow-hidden bg-[#070b16] text-slate-100">
      <div className="pointer-events-none fixed inset-0 bg-[radial-gradient(circle_at_top_left,_rgba(124,58,237,0.24),_transparent_32rem),radial-gradient(circle_at_bottom_right,_rgba(14,165,233,0.12),_transparent_28rem)]" />
      <div className="relative mx-auto flex min-h-screen w-full max-w-7xl flex-col">
        <header className="flex items-center justify-between border-b border-white/10 px-5 py-4 sm:px-8">
          <div className="flex items-center gap-3">
            <span className="flex size-10 items-center justify-center rounded-2xl border border-violet-400/40 bg-violet-500/10 text-violet-300">
              <Icon name="heart" className="size-5" />
            </span>
            <span className="text-lg font-semibold tracking-tight">
              Fertility Care
            </span>
          </div>
          <button
            form="fertility-assessment"
            className="inline-flex items-center gap-2 rounded-xl bg-violet-600 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-violet-950/40 transition hover:bg-violet-500 focus:outline-none focus:ring-2 focus:ring-violet-300 focus:ring-offset-2 focus:ring-offset-[#070b16] disabled:cursor-not-allowed disabled:opacity-70"
            disabled={isLoading}
            type="submit"
          >
            <Icon name="sparkle" className="size-4" />
            {isLoading ? "Generating..." : "Generate Care Plan"}
          </button>
        </header>

        <section className="grid flex-1 gap-8 px-5 py-8 sm:px-8 lg:grid-cols-[minmax(0,1.15fr)_minmax(320px,0.78fr)]">
          <div>
            <div className="mb-7">
              <p className="mb-2 text-sm font-medium text-violet-300">
                Connected assessment
              </p>
              <h1 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
                Fertility Assessment
              </h1>
              <p className="mt-3 max-w-2xl text-sm leading-6 text-slate-300">
                Please provide the following information to help us create your
                personalized care plan. Submissions are sent to the configured
                backend unless mock mode is enabled.
              </p>
            </div>

            <form
              id="fertility-assessment"
              onSubmit={handleGenerate}
              className="rounded-2xl border border-white/10 bg-slate-950/60 p-5 shadow-2xl shadow-black/30 backdrop-blur sm:p-8"
            >
              <FormSection
                icon="user"
                title="1. Personal Information"
                description="Basic details for the patient profile."
              >
                <div className="grid gap-4 sm:grid-cols-2">
                  <Field label="First Name" htmlFor="firstName">
                    <input
                      id="firstName"
                      value={form.firstName}
                      onChange={(event) =>
                        updateField("firstName", event.target.value)
                      }
                      placeholder="Enter first name"
                      className={inputClassName}
                    />
                  </Field>
                  <Field label="Last Name" htmlFor="lastName">
                    <input
                      id="lastName"
                      value={form.lastName}
                      onChange={(event) =>
                        updateField("lastName", event.target.value)
                      }
                      placeholder="Enter last name"
                      className={inputClassName}
                    />
                  </Field>
                  <Field label="Age" htmlFor="age">
                    <input
                      id="age"
                      type="number"
                      min="18"
                      value={form.age}
                      onChange={(event) =>
                        updateField("age", event.target.value)
                      }
                      placeholder="Enter age"
                      className={inputClassName}
                    />
                  </Field>
                </div>
              </FormSection>

              <FormSection
                icon="partner"
                title="2. Partner Information"
                description="Partner details are optional unless a male partner is involved."
              >
                <ToggleGroup
                  label="Do you have a male partner?"
                  value={form.malePartner}
                  onChange={(value) => updateField("malePartner", value)}
                />
                <div className="mt-4 grid gap-4 sm:grid-cols-2">
                  <Field label="Male Partner Age" htmlFor="malePartnerAge">
                    <input
                      id="malePartnerAge"
                      type="number"
                      min="18"
                      value={form.malePartnerAge}
                      onChange={(event) =>
                        updateField("malePartnerAge", event.target.value)
                      }
                      placeholder="Enter age"
                      className={inputClassName}
                      disabled={!form.malePartner}
                    />
                  </Field>
                  <Field label="Is your partner married?" htmlFor="partnerMarried">
                    <select
                      id="partnerMarried"
                      value={String(form.malePartnerMarried ?? "")}
                      onChange={(event) =>
                        updateField(
                          "malePartnerMarried",
                          toOptionalBoolean(event.target.value),
                        )
                      }
                      className={inputClassName}
                      disabled={!form.malePartner}
                    >
                      <option value="">Select</option>
                      <option value="true">Yes</option>
                      <option value="false">No</option>
                    </select>
                  </Field>
                </div>
                <Field
                  label="Male Partner Semen Analysis"
                  hint="Base64 file content or a short note for the prototype."
                  htmlFor="semenAnalysis"
                  className="mt-4"
                >
                  <input
                    id="semenAnalysis"
                    value={form.malePartnerSemenAnalysis ?? ""}
                    onChange={(event) =>
                      updateField("malePartnerSemenAnalysis", event.target.value)
                    }
                    placeholder="Enter semen analysis results"
                    className={inputClassName}
                    disabled={!form.malePartner}
                  />
                </Field>
              </FormSection>

              <FormSection
                icon="medical"
                title="3. Medical Information"
                description="Clinical context used by the future care-plan API."
              >
                <Field label="Primary Symptom / Concern" htmlFor="symptom">
                  <input
                    id="symptom"
                    value={form.symptom}
                    onChange={(event) =>
                      updateField("symptom", event.target.value)
                    }
                    placeholder="E.g., Irregular periods, PCOS, Infertility, etc."
                    className={inputClassName}
                  />
                </Field>
                <div className="mt-4 grid gap-4 sm:grid-cols-3">
                  <Field label="BMI" htmlFor="bmi">
                    <input
                      id="bmi"
                      type="number"
                      step="0.1"
                      value={form.bmi}
                      onChange={(event) =>
                        updateField("bmi", event.target.value)
                      }
                      placeholder="Enter BMI"
                      className={inputClassName}
                    />
                  </Field>
                  <Field label="FSH (mIU/mL)" htmlFor="fsh">
                    <input
                      id="fsh"
                      type="number"
                      step="0.1"
                      value={form.fsh}
                      onChange={(event) =>
                        updateField("fsh", event.target.value)
                      }
                      placeholder="Enter FSH"
                      className={inputClassName}
                    />
                  </Field>
                  <Field label="AMH (ng/mL)" htmlFor="amh">
                    <input
                      id="amh"
                      type="number"
                      step="0.1"
                      value={form.amh}
                      onChange={(event) =>
                        updateField("amh", event.target.value)
                      }
                      placeholder="Enter AMH"
                      className={inputClassName}
                    />
                  </Field>
                </div>
                <div className="mt-4">
                  <ToggleGroup
                    label="Have you undergone IVF previously?"
                    value={form.previousIvf}
                    onChange={(value) => updateField("previousIvf", value)}
                  />
                </div>
              </FormSection>

              <FormSection
                icon="privacy"
                title="4. Insurance & Financial Information"
                description="Coverage and budget details for the recommendation."
                isLast
              >
                <div className="grid gap-4 sm:grid-cols-2">
                  <Field label="Insurer Name" htmlFor="insurerName">
                    <input
                      id="insurerName"
                      value={form.insurerName}
                      onChange={(event) =>
                        updateField("insurerName", event.target.value)
                      }
                      placeholder="Enter insurer name"
                      className={inputClassName}
                    />
                  </Field>
                  <Field label="Policy Number" htmlFor="policyNumber">
                    <input
                      id="policyNumber"
                      inputMode="numeric"
                      value={form.policyNumber}
                      onChange={(event) =>
                        updateField("policyNumber", event.target.value)
                      }
                      placeholder="Enter policy number"
                      className={inputClassName}
                    />
                  </Field>
                  <Field label="Budget (₹)" htmlFor="budget">
                    <input
                      id="budget"
                      type="number"
                      value={form.budget}
                      onChange={(event) =>
                        updateField("budget", event.target.value)
                      }
                      placeholder="Enter your budget"
                      className={inputClassName}
                    />
                  </Field>
                </div>
              </FormSection>

              <button
                className="mt-6 inline-flex w-full items-center justify-center gap-2 rounded-xl bg-violet-600 px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-violet-950/40 transition hover:bg-violet-500 focus:outline-none focus:ring-2 focus:ring-violet-300 focus:ring-offset-2 focus:ring-offset-slate-950 disabled:cursor-not-allowed disabled:opacity-70"
                disabled={isLoading}
                type="submit"
              >
                <Icon name="document" className="size-4" />
                {isLoading ? "Generating..." : "Generate Care Plan"}
              </button>
              <p className="mt-4 flex items-center justify-center gap-2 text-xs text-slate-400">
                <Icon name="privacy" className="size-4" />
                Your information is secure and confidential.
              </p>
            </form>
          </div>

          <aside className="self-start rounded-2xl border border-white/10 bg-slate-950/60 p-5 shadow-2xl shadow-black/30 backdrop-blur sm:p-8 lg:sticky lg:top-8">
            <div className="mb-6">
              <div className="mb-2 flex items-center gap-3 text-violet-300">
                <Icon name="sparkle" className="size-5" />
                <h2 className="text-lg font-semibold text-violet-200">
                  Care Plan Preview
                </h2>
              </div>
              <p className="text-sm leading-6 text-slate-300">
                Based on the information provided
                {patientName ? ` for ${patientName}` : ""}.
              </p>
              <p className="mt-2 text-xs text-slate-500">
                {useMockCarePlanResponse
                  ? "Mock data mode is active by configuration."
                  : `Posting to ${carePlanApiEndpoint}.`}
              </p>
              {hasPendingChanges && carePlan ? (
                <p className="mt-2 text-xs text-amber-200">
                  The form has changed. Generate again to refresh this preview.
                </p>
              ) : null}
            </div>

            {useMockCarePlanResponse ? (
              <StatusBanner tone="warning">
                Mock data mode is active. The backend request is skipped by
                configuration.
              </StatusBanner>
            ) : null}

            {requestStatus === "loading" ? (
              <StatusBanner tone="info">
                Sending the assessment JSON to the configured backend.
              </StatusBanner>
            ) : null}

            {requestStatus === "error" ? (
              <StatusBanner tone="error">
                Backend request failed: {errorMessage}. Mock data was not used
                automatically.
              </StatusBanner>
            ) : null}

            <div className="space-y-4">
              {carePlan ? (
                <>
                  {previewItems.map((item) => (
                    <PreviewCard
                      key={item.key}
                      icon={item.icon}
                      title={item.title}
                      body={carePlan[item.key]}
                    />
                  ))}

                  <div className="rounded-2xl border border-emerald-300/10 bg-slate-800/70 p-5">
                    <div className="mb-4 flex items-center gap-4">
                      <span className="flex size-12 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-300">
                        <span className="text-2xl font-semibold">₹</span>
                      </span>
                      <div>
                        <h3 className="font-semibold text-white">Cost Summary</h3>
                        <p className="text-xs text-slate-400">Estimated total</p>
                      </div>
                    </div>
                    <p className="text-3xl font-bold tracking-tight text-emerald-300">
                      {currencyFormatter.format(carePlan.costSummary)}
                    </p>
                    <p className="mt-3 text-sm leading-6 text-slate-300">
                      Estimated total cost of the recommended care plan.
                    </p>
                  </div>
                </>
              ) : (
                <div className="rounded-2xl border border-dashed border-white/15 bg-slate-800/40 p-5 text-sm leading-6 text-slate-300">
                  Generate a care plan to display the backend response here.
                </div>
              )}
            </div>

            <p className="mt-6 flex items-start gap-2 text-xs leading-5 text-slate-500">
              <Icon name="privacy" className="mt-0.5 size-4 shrink-0" />
              This care plan is for guidance only and should be reviewed by a
              fertility specialist.
            </p>
          </aside>
        </section>
      </div>
    </main>
  );
}

function toCarePlanRequest(form: CarePlanFormState): CarePlanRequest {
  return {
    age: Number(form.age),
    amh: Number(form.amh),
    bmi: Number(form.bmi),
    budget: Number(form.budget),
    firstName: form.firstName,
    fsh: Number(form.fsh),
    insurerName: form.insurerName,
    lastName: form.lastName,
    malePartner: form.malePartner,
    malePartnerAge: form.malePartner
      ? toOptionalNumber(form.malePartnerAge)
      : null,
    malePartnerMarried: form.malePartner ? form.malePartnerMarried : null,
    malePartnerSemenAnalysis: form.malePartner
      ? form.malePartnerSemenAnalysis || null
      : null,
    policyNumber: Number(form.policyNumber),
    previousIvf: form.previousIvf,
    symptom: form.symptom,
  };
}

function toOptionalBoolean(value: string) {
  if (value === "") {
    return null;
  }

  return value === "true";
}

function toOptionalNumber(value: string) {
  return value === "" ? null : Number(value);
}

function readCarePlanResponse(value: unknown): CarePlanResponse {
  if (!Array.isArray(value) || !isCarePlanResponse(value[0])) {
    throw new Error(
      "Backend response did not match the expected care-plan array.",
    );
  }

  return value[0];
}

function isCarePlanResponse(value: unknown): value is CarePlanResponse {
  if (!value || typeof value !== "object") {
    return false;
  }

  const candidate = value as Partial<Record<keyof CarePlanResponse, unknown>>;

  return (
    typeof candidate.journeyGoal === "string" &&
    typeof candidate.journeySummary === "string" &&
    typeof candidate.workflowSummary === "string" &&
    typeof candidate.timelineSummary === "string" &&
    typeof candidate.costSummary === "number"
  );
}

function StatusBanner({
  children,
  tone,
}: {
  children: React.ReactNode;
  tone: "error" | "info" | "warning";
}) {
  const toneClassName = {
    error: "border-red-300/20 bg-red-500/10 text-red-100",
    info: "border-sky-300/20 bg-sky-500/10 text-sky-100",
    warning: "border-amber-300/20 bg-amber-500/10 text-amber-100",
  }[tone];

  return (
    <div
      className={`mb-4 rounded-2xl border p-4 text-sm leading-6 ${toneClassName}`}
    >
      {children}
    </div>
  );
}

function FormSection({
  children,
  description,
  icon,
  isLast = false,
  title,
}: {
  children: React.ReactNode;
  description: string;
  icon: IconName;
  isLast?: boolean;
  title: string;
}) {
  return (
    <section
      className={`border-white/10 py-6 first:pt-0 ${
        isLast ? "" : "border-b"
      }`}
    >
      <div className="mb-5 flex items-start gap-3">
        <span className="mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-xl bg-violet-500/10 text-violet-300">
          <Icon name={icon} className="size-4" />
        </span>
        <div>
          <h2 className="font-semibold text-white">{title}</h2>
          <p className="mt-1 text-sm leading-6 text-slate-400">{description}</p>
        </div>
      </div>
      {children}
    </section>
  );
}

function Field({
  children,
  className = "",
  hint,
  htmlFor,
  label,
}: {
  children: React.ReactNode;
  className?: string;
  hint?: string;
  htmlFor: string;
  label: string;
}) {
  return (
    <div className={className}>
      <label
        htmlFor={htmlFor}
        className="mb-2 block text-sm font-medium text-slate-200"
      >
        {label}
      </label>
      {children}
      {hint ? <p className="mt-2 text-xs text-slate-500">{hint}</p> : null}
    </div>
  );
}

function ToggleGroup({
  label,
  onChange,
  value,
}: {
  label: string;
  onChange: (value: boolean) => void;
  value: boolean;
}) {
  return (
    <div>
      <p className="mb-2 text-sm font-medium text-slate-200">{label}</p>
      <div className="inline-flex rounded-xl border border-white/10 bg-slate-950/70 p-1">
        {[true, false].map((option) => (
          <button
            key={String(option)}
            type="button"
            aria-pressed={value === option}
            onClick={() => onChange(option)}
            className={`rounded-lg px-5 py-2 text-sm font-semibold transition focus:outline-none focus:ring-2 focus:ring-violet-300 ${
              value === option
                ? "bg-violet-600 text-white shadow-lg shadow-violet-950/40"
                : "text-slate-300 hover:bg-white/5 hover:text-white"
            }`}
          >
            {option ? "Yes" : "No"}
          </button>
        ))}
      </div>
    </div>
  );
}

function PreviewCard({
  body,
  icon,
  title,
}: {
  body: string;
  icon: IconName;
  title: string;
}) {
  return (
    <article className="rounded-2xl border border-white/10 bg-slate-800/70 p-5">
      <div className="flex gap-4">
        <span className="flex size-12 shrink-0 items-center justify-center rounded-full bg-violet-500/20 text-violet-300">
          <Icon name={icon} className="size-5" />
        </span>
        <div>
          <h3 className="font-semibold text-white">{title}</h3>
          <p className="mt-3 text-sm leading-6 text-slate-300">{body}</p>
        </div>
      </div>
    </article>
  );
}

function Icon({
  className,
  name,
}: {
  className?: string;
  name: IconName;
}) {
  const props: SVGProps<SVGSVGElement> = {
    "aria-hidden": true,
    className,
    fill: "none",
    stroke: "currentColor",
    strokeLinecap: "round",
    strokeLinejoin: "round",
    strokeWidth: 1.8,
    viewBox: "0 0 24 24",
  };

  switch (name) {
    case "calendar":
      return (
        <svg {...props}>
          <path d="M8 2v4M16 2v4M4 9h16M5 5h14a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1Z" />
        </svg>
      );
    case "document":
      return (
        <svg {...props}>
          <path d="M7 3h7l4 4v14H7a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1Z" />
          <path d="M14 3v5h5M9 13h6M9 17h6" />
        </svg>
      );
    case "goal":
      return (
        <svg {...props}>
          <path d="M12 21a9 9 0 1 0-9-9" />
          <path d="M12 17a5 5 0 1 0-5-5" />
          <path d="M12 13a1 1 0 1 0-1-1M12 12l7-7M17 5h2v2" />
        </svg>
      );
    case "heart":
      return (
        <svg {...props}>
          <path d="M12 20s-7-4.5-9-9.5C1.7 7.2 3.6 4 7 4c2 0 3.2 1.1 4 2.3C11.8 5.1 13 4 15 4c3.4 0 5.3 3.2 4 6.5C19 15.5 12 20 12 20Z" />
          <path d="M8.5 9.5h2l1.5 3 2.5-5 1.5 2h2" />
        </svg>
      );
    case "medical":
      return (
        <svg {...props}>
          <path d="M9 3h6v4h4v6h-4v8H9v-8H5V7h4V3Z" />
        </svg>
      );
    case "partner":
      return (
        <svg {...props}>
          <path d="M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM17 12a2.5 2.5 0 1 0 0-5" />
          <path d="M3 20a6 6 0 0 1 12 0M14 15.5a5 5 0 0 1 7 4.5" />
        </svg>
      );
    case "privacy":
      return (
        <svg {...props}>
          <path d="M12 3 5 6v5c0 4.5 2.9 8.5 7 10 4.1-1.5 7-5.5 7-10V6l-7-3Z" />
          <path d="m9.5 12 1.7 1.7 3.3-3.7" />
        </svg>
      );
    case "sparkle":
      return (
        <svg {...props}>
          <path d="m12 3 1.5 5L18 10l-4.5 2L12 17l-1.5-5L6 10l4.5-2L12 3ZM5 16l.7 2.3L8 19l-2.3.7L5 22l-.7-2.3L2 19l2.3-.7L5 16ZM19 2l.7 2.3L22 5l-2.3.7L19 8l-.7-2.3L16 5l2.3-.7L19 2Z" />
        </svg>
      );
    case "user":
      return (
        <svg {...props}>
          <path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM5 21a7 7 0 0 1 14 0" />
        </svg>
      );
    case "workflow":
      return (
        <svg {...props}>
          <path d="M7 7h4v4H7zM13 13h4v4h-4zM4 17h4v4H4zM16 3h4v4h-4z" />
          <path d="M11 9h3a4 4 0 0 0 4-4M9 17h2a4 4 0 0 0 4-4" />
        </svg>
      );
  }
}

const inputClassName =
  "h-12 w-full rounded-xl border border-white/10 bg-slate-950/70 px-4 text-sm text-white outline-none transition placeholder:text-slate-500 focus:border-violet-300 focus:ring-2 focus:ring-violet-400/30 disabled:cursor-not-allowed disabled:opacity-50";
