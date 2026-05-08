---
name: fhir-generator
description: FHIR R4 resource generation and validation for healthcare interoperability. Converts medical data into FHIR-compliant JSON resources (Patient, Observation, MedicationRequest, Condition, etc.). Use when creating FHIR resources, validating healthcare data structures, or preparing data for EHR integration.
license: MIT
allowed-tools:
  - python
  - bash
metadata:
  version: "1.0.0"
  category: healthcare
  fhir-version: "R4"
  standard: "HL7 FHIR"
---

# FHIR R4 Resource Generator Skill

## Overview

This skill enables Claude to generate valid FHIR R4 (Fast Healthcare Interoperability Resources) resources from extracted medical data. FHIR is the industry standard for healthcare data exchange.

## When to Use This Skill

Use this skill when you need to:
- Convert OCR-extracted medical data to FHIR resources
- Create Patient, Observation, MedicationRequest resources
- Validate FHIR resource structure
- Prepare data for EHR (Electronic Health Record) integration
- Generate HL7 FHIR bundles for data exchange

## Core FHIR Resources

### 1. Patient Resource

```python
def create_fhir_patient(patient_data):
    """Generate FHIR R4 Patient resource"""
    return {
        "resourceType": "Patient",
        "id": patient_data.get('id', 'example-patient'),
        "identifier": [{
            "use": "official",
            "system": "http://hospital.example.org",
            "value": patient_data.get('mrn', 'MRN12345')
        }],
        "active": True,
        "name": [{
            "use": "official",
            "family": patient_data.get('last_name', ''),
            "given": [patient_data.get('first_name', '')]
        }],
        "gender": patient_data.get('gender', 'unknown'),
        "birthDate": patient_data.get('birth_date', ''),
        "address": [{
            "use": "home",
            "line": [patient_data.get('address_line', '')],
            "city": patient_data.get('city', ''),
            "state": patient_data.get('state', ''),
            "postalCode": patient_data.get('zip', ''),
            "country": patient_data.get('country', 'US')
        }],
        "telecom": [{
            "system": "phone",
            "value": patient_data.get('phone', ''),
            "use": "mobile"
        }]
    }
```

### 2. MedicationRequest Resource

```python
def create_medication_request(medication_data, patient_reference):
    """Generate FHIR R4 MedicationRequest"""
    return {
        "resourceType": "MedicationRequest",
        "id": medication_data.get('id', 'med-request-1'),
        "status": "active",
        "intent": "order",
        "medicationCodeableConcept": {
            "coding": [{
                "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
                "code": medication_data.get('rxnorm_code', ''),
                "display": medication_data.get('name', '')
            }],
            "text": medication_data.get('name', '')
        },
        "subject": {
            "reference": patient_reference,
            "display": "Patient"
        },
        "authoredOn": medication_data.get('date', ''),
        "dosageInstruction": [{
            "text": medication_data.get('sig', ''),
            "timing": {
                "repeat": {
                    "frequency": medication_data.get('frequency', 1),
                    "period": 1,
                    "periodUnit": "d",
                    "when": [medication_data.get('timing', 'MORN')]
                }
            },
            "route": {
                "coding": [{
                    "system": "http://snomed.info/sct",
                    "code": medication_data.get('route_code', '26643006'),
                    "display": medication_data.get('route', 'Oral')
                }]
            },
            "doseAndRate": [{
                "doseQuantity": {
                    "value": medication_data.get('dose_value', 0),
                    "unit": medication_data.get('dose_unit', 'mg'),
                    "system": "http://unitsofmeasure.org",
                    "code": medication_data.get('ucum_code', 'mg')
                }
            }]
        }],
        "dispenseRequest": {
            "quantity": {
                "value": medication_data.get('quantity', 30),
                "unit": "tablet"
            },
            "expectedSupplyDuration": {
                "value": medication_data.get('days_supply', 30),
                "unit": "days"
            }
        }
    }
```

### 3. Observation Resource (Lab Results, Vitals)

```python
def create_observation(obs_data, patient_reference):
    """Generate FHIR R4 Observation for lab results or vitals"""
    return {
        "resourceType": "Observation",
        "id": obs_data.get('id', 'obs-1'),
        "status": "final",
        "category": [{
            "coding": [{
                "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                "code": obs_data.get('category', 'laboratory'),
                "display": obs_data.get('category_display', 'Laboratory')
            }]
        }],
        "code": {
            "coding": [{
                "system": "http://loinc.org",
                "code": obs_data.get('loinc_code', ''),
                "display": obs_data.get('test_name', '')
            }],
            "text": obs_data.get('test_name', '')
        },
        "subject": {
            "reference": patient_reference
        },
        "effectiveDateTime": obs_data.get('date', ''),
        "valueQuantity": {
            "value": obs_data.get('value', 0),
            "unit": obs_data.get('unit', ''),
            "system": "http://unitsofmeasure.org",
            "code": obs_data.get('ucum_code', '')
        },
        "referenceRange": [{
            "low": {
                "value": obs_data.get('ref_low', 0),
                "unit": obs_data.get('unit', '')
            },
            "high": {
                "value": obs_data.get('ref_high', 0),
                "unit": obs_data.get('unit', '')
            }
        }]
    }
```

### 4. Condition/Diagnosis Resource

```python
def create_condition(diagnosis_data, patient_reference):
    """Generate FHIR R4 Condition resource"""
    return {
        "resourceType": "Condition",
        "id": diagnosis_data.get('id', 'condition-1'),
        "clinicalStatus": {
            "coding": [{
                "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
                "code": diagnosis_data.get('clinical_status', 'active')
            }]
        },
        "verificationStatus": {
            "coding": [{
                "system": "http://terminology.hl7.org/CodeSystem/condition-ver-status",
                "code": "confirmed"
            }]
        },
        "category": [{
            "coding": [{
                "system": "http://terminology.hl7.org/CodeSystem/condition-category",
                "code": "encounter-diagnosis",
                "display": "Encounter Diagnosis"
            }]
        }],
        "severity": {
            "coding": [{
                "system": "http://snomed.info/sct",
                "code": diagnosis_data.get('severity_code', '24484000'),
                "display": diagnosis_data.get('severity', 'Severe')
            }]
        },
        "code": {
            "coding": [{
                "system": "http://snomed.info/sct",
                "code": diagnosis_data.get('snomed_code', ''),
                "display": diagnosis_data.get('diagnosis_name', '')
            }, {
                "system": "http://hl7.org/fhir/sid/icd-10-cm",
                "code": diagnosis_data.get('icd10_code', ''),
                "display": diagnosis_data.get('diagnosis_name', '')
            }],
            "text": diagnosis_data.get('diagnosis_name', '')
        },
        "subject": {
            "reference": patient_reference
        },
        "onsetDateTime": diagnosis_data.get('onset_date', ''),
        "recordedDate": diagnosis_data.get('recorded_date', '')
    }
```

### 5. DiagnosticReport Resource

```python
def create_diagnostic_report(report_data, patient_reference, observations):
    """Generate FHIR R4 DiagnosticReport"""
    return {
        "resourceType": "DiagnosticReport",
        "id": report_data.get('id', 'report-1'),
        "status": "final",
        "category": [{
            "coding": [{
                "system": "http://terminology.hl7.org/CodeSystem/v2-0074",
                "code": "LAB",
                "display": "Laboratory"
            }]
        }],
        "code": {
            "coding": [{
                "system": "http://loinc.org",
                "code": report_data.get('loinc_code', ''),
                "display": report_data.get('report_name', '')
            }],
            "text": report_data.get('report_name', '')
        },
        "subject": {
            "reference": patient_reference
        },
        "effectiveDateTime": report_data.get('date', ''),
        "issued": report_data.get('issued_date', ''),
        "result": [
            {"reference": f"Observation/{obs_id}"}
            for obs_id in observations
        ],
        "conclusion": report_data.get('conclusion', '')
    }
```

## FHIR Bundle Creation

```python
def create_fhir_bundle(entries, bundle_type="transaction"):
    """Create FHIR Bundle to group multiple resources"""
    return {
        "resourceType": "Bundle",
        "type": bundle_type,
        "entry": [
            {
                "fullUrl": f"urn:uuid:{entry.get('id', '')}",
                "resource": entry,
                "request": {
                    "method": "POST",
                    "url": entry.get('resourceType', '')
                }
            }
            for entry in entries
        ]
    }
```

## Medical Coding Systems

### Common Code Systems

```python
CODE_SYSTEMS = {
    "rxnorm": {
        "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
        "description": "RxNorm - Medication names"
    },
    "snomed": {
        "system": "http://snomed.info/sct",
        "description": "SNOMED CT - Clinical terms"
    },
    "loinc": {
        "system": "http://loinc.org",
        "description": "LOINC - Lab tests and observations"
    },
    "icd10": {
        "system": "http://hl7.org/fhir/sid/icd-10-cm",
        "description": "ICD-10-CM - Diagnoses"
    },
    "cpt": {
        "system": "http://www.ama-assn.org/go/cpt",
        "description": "CPT - Procedures"
    },
    "ucum": {
        "system": "http://unitsofmeasure.org",
        "description": "UCUM - Units of measure"
    }
}
```

### Common LOINC Codes

```python
COMMON_LOINC_CODES = {
    "glucose": "2345-7",  # Glucose [Mass/volume] in Serum or Plasma
    "hba1c": "4548-4",    # Hemoglobin A1c/Hemoglobin.total in Blood
    "cholesterol": "2093-3",  # Cholesterol [Mass/volume] in Serum or Plasma
    "hdl": "2085-9",      # HDL Cholesterol [Mass/volume] in Serum or Plasma
    "ldl": "2089-1",      # LDL Cholesterol [Mass/volume] in Serum or Plasma
    "triglycerides": "2571-8",  # Triglyceride [Mass/volume] in Serum or Plasma
    "creatinine": "2160-0",  # Creatinine [Mass/volume] in Serum or Plasma
    "hemoglobin": "718-7",   # Hemoglobin [Mass/volume] in Blood
    "wbc": "6690-2",      # Leukocytes [#/volume] in Blood
    "platelets": "777-3",  # Platelets [#/volume] in Blood
    "bp_systolic": "8480-6",   # Systolic blood pressure
    "bp_diastolic": "8462-4",  # Diastolic blood pressure
    "heart_rate": "8867-4",    # Heart rate
    "temperature": "8310-5",   # Body temperature
    "weight": "29463-7",   # Body weight
    "height": "8302-2"     # Body height
}
```

## FHIR Validation

```python
def validate_fhir_resource(resource):
    """Basic FHIR resource validation"""
    errors = []
    
    # Required fields
    if 'resourceType' not in resource:
        errors.append("Missing required field: resourceType")
    
    # Resource-specific validation
    resource_type = resource.get('resourceType')
    
    if resource_type == 'Patient':
        if 'name' not in resource or not resource['name']:
            errors.append("Patient must have at least one name")
    
    elif resource_type == 'MedicationRequest':
        if 'status' not in resource:
            errors.append("MedicationRequest must have status")
        if resource.get('status') not in ['active', 'on-hold', 'cancelled', 'completed']:
            errors.append(f"Invalid status: {resource.get('status')}")
    
    elif resource_type == 'Observation':
        if 'status' not in resource:
            errors.append("Observation must have status")
        if 'code' not in resource:
            errors.append("Observation must have code")
    
    return {
        "valid": len(errors) == 0,
        "errors": errors
    }
```

## Complete Medical Document → FHIR Pipeline

```python
def medical_data_to_fhir_bundle(medical_data):
    """Convert complete medical document to FHIR Bundle"""
    
    # Create Patient resource
    patient = create_fhir_patient(medical_data.get('patient', {}))
    patient_ref = f"Patient/{patient['id']}"
    
    resources = [patient]
    
    # Add MedicationRequests
    for med in medical_data.get('medications', []):
        med_request = create_medication_request(med, patient_ref)
        resources.append(med_request)
    
    # Add Observations (lab results, vitals)
    for obs in medical_data.get('observations', []):
        observation = create_observation(obs, patient_ref)
        resources.append(observation)
    
    # Add Conditions (diagnoses)
    for dx in medical_data.get('diagnoses', []):
        condition = create_condition(dx, patient_ref)
        resources.append(condition)
    
    # Create Bundle
    bundle = create_fhir_bundle(resources, bundle_type="transaction")
    
    # Validate all resources
    validation_results = [
        validate_fhir_resource(res) for res in resources
    ]
    
    return {
        "bundle": bundle,
        "validation": validation_results,
        "resource_count": len(resources)
    }
```

## Example Workflows

### Example 1: Prescription → FHIR

```python
# Input: OCR extracted prescription data
prescription_data = {
    "patient": {
        "id": "pat-001",
        "first_name": "John",
        "last_name": "Doe",
        "mrn": "MRN123456",
        "birth_date": "1980-01-15"
    },
    "medications": [{
        "id": "med-001",
        "name": "Metformin",
        "rxnorm_code": "860975",
        "dose_value": 500,
        "dose_unit": "mg",
        "frequency": 2,
        "route": "Oral",
        "quantity": 60,
        "days_supply": 30,
        "sig": "Take 500mg by mouth twice daily with meals"
    }]
}

# Generate FHIR Bundle
result = medical_data_to_fhir_bundle(prescription_data)
print(f"Created {result['resource_count']} FHIR resources")
```

### Example 2: Lab Results → FHIR

```python
# Input: OCR extracted lab results
lab_data = {
    "patient": {
        "id": "pat-001",
        "mrn": "MRN123456"
    },
    "observations": [
        {
            "id": "obs-glucose",
            "test_name": "Glucose",
            "loinc_code": "2345-7",
            "value": 126,
            "unit": "mg/dL",
            "ucum_code": "mg/dL",
            "ref_low": 70,
            "ref_high": 99,
            "category": "laboratory",
            "date": "2024-11-22T10:30:00Z"
        },
        {
            "id": "obs-hba1c",
            "test_name": "Hemoglobin A1c",
            "loinc_code": "4548-4",
            "value": 7.2,
            "unit": "%",
            "ucum_code": "%",
            "ref_low": 4.0,
            "ref_high": 5.6,
            "category": "laboratory",
            "date": "2024-11-22T10:30:00Z"
        }
    ]
}

# Generate FHIR Bundle
result = medical_data_to_fhir_bundle(lab_data)
```

## Best Practices

1. **Always validate** FHIR resources before submission
2. **Use standard code systems** (LOINC, SNOMED, RxNorm, ICD-10)
3. **Include meaningful text** alongside coded values
4. **Provide reference ranges** for observations
5. **Use appropriate status codes** (active, final, entered-in-error, etc.)
6. **Include timestamps** (effectiveDateTime, authoredOn, etc.)
7. **Link resources properly** using references
8. **Document source** of data (OCR extraction, manual entry, etc.)

## Integration with Agents

This skill integrates with:
- **HEALTHCARELINC**: Receives structured medical data
- **COMPLIANCELINC**: Validates HIPAA compliance
- **Medical-OCR**: Receives OCR-extracted data

## Resources

- [FHIR R4 Specification](https://hl7.org/fhir/R4/)
- [LOINC Codes](https://loinc.org/)
- [SNOMED CT](https://www.snomed.org/)
- [RxNorm](https://www.nlm.nih.gov/research/umls/rxnorm/)
- [FHIR Validator](https://www.hl7.org/fhir/validation.html)

---

**Version**: 1.0.0  
**Last Updated**: 2024-11-22  
**FHIR Version**: R4  
**Maintainer**: Doctors-Linc Development Team
