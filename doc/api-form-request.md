# Patient Intake JSON Format

## Schema

```json
{
  "firstName": "String",
  "lastName": "String",
  "age": "Number",
  "malePartner": "Boolean",
  "malePartnerAge": "Number | null",
  "malePartnerMarried": "Boolean | null",
  "malePartnerSemenAnalysis": "String | null",
  "symptom": "String",
  "bmi": "Number",
  "fsh": "Number",
  "amh": "Number",
  "previousIvf": "Boolean",
  "insurerName": "String",
  "policyNumber": "Number",
  "budget": "Number"
}
```

Partner-related fields are nullable because they are only required when `malePartner` is `true`.

## Example JSON

### With Male Partner

```json
{
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
```

### Without Male Partner

```json
{
  "firstName": "Laura",
  "lastName": "Schmidt",
  "age": 31,
  "malePartner": false,
  "malePartnerAge": null,
  "malePartnerMarried": null,
  "malePartnerSemenAnalysis": null,
  "symptom": "Endometriosis",
  "bmi": 21.9,
  "fsh": 6.5,
  "amh": 3.0,
  "previousIvf": true,
  "insurerName": "MediSecure",
  "policyNumber": 987654321,
  "budget": 7500
}
```

## Field Notes

- `malePartnerSemenAnalysis` contains the file content as a Base64-encoded string.
- Numeric medical values such as `bmi`, `fsh`, and `amh` may contain decimal values.
- `policyNumber` is represented as a number in this format.