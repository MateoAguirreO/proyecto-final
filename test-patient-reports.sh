#!/bin/bash

echo "=================================="
echo "Testing Patient Reports Endpoint"
echo "=================================="
echo ""

BASE_URL="http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

# 1. Login to get JWT token
echo "1. Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass123"}' \
  "${BASE_URL}/api/auth/login")

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | sed 's/"token":"//')
echo "   Token obtained: ${TOKEN:0:20}..."
echo ""

# 2. Get existing variants
echo "2. Getting existing variants..."
VARIANTS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "${BASE_URL}/api/genomica/v1/variants/")

echo "   Variants available:"
echo "$VARIANTS_RESPONSE" | grep -o '"id":"[^"]*' | head -3
VARIANT_ID=$(echo "$VARIANTS_RESPONSE" | grep -o '"id":"[^"]*' | head -1 | sed 's/"id":"//')
echo "   Using variant ID: $VARIANT_ID"
echo ""

# 3. Get existing patients from Clinica
echo "3. Getting existing patients from Clinica..."
PATIENTS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "${BASE_URL}/api/clinica/patients/")

echo "   Patients available:"
echo "$PATIENTS_RESPONSE" | grep -o '"_id":"[^"]*' | head -3
PATIENT_ID=$(echo "$PATIENTS_RESPONSE" | grep -o '"_id":"[^"]*' | head -1 | sed 's/"_id":"//')
echo "   Using patient ID: $PATIENT_ID"
echo ""

# 4. List existing patient reports
echo "4. Listing existing patient reports (GET)..."
curl -s -H "Authorization: Bearer $TOKEN" \
  "${BASE_URL}/api/genomica/v1/patient-reports/" | head -c 500
echo ""
echo ""

# 5. Create a new patient report
echo "5. Creating new patient report (POST)..."
CREATE_DATA="{
  \"patient_id\": \"$PATIENT_ID\",
  \"variant\": \"$VARIANT_ID\",
  \"detection_date\": \"2024-11-15\",
  \"allele_frequency\": 0.4523,
  \"sample_type\": \"Biopsia tumoral\",
  \"notes\": \"Variante patogénica detectada. Seguimiento cada 6 meses\"
}"

echo "   Request body:"
echo "$CREATE_DATA"
echo ""

CREATE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
  -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$CREATE_DATA" \
  "${BASE_URL}/api/genomica/v1/patient-reports/")

HTTP_STATUS=$(echo "$CREATE_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
RESPONSE_BODY=$(echo "$CREATE_RESPONSE" | sed '/HTTP_STATUS/d')

echo "   Response (HTTP $HTTP_STATUS):"
echo "$RESPONSE_BODY"
echo ""

# 6. Get the created report if successful
if [ "$HTTP_STATUS" = "201" ]; then
    REPORT_ID=$(echo "$RESPONSE_BODY" | grep -o '"id":"[^"]*' | sed 's/"id":"//')
    echo "6. Getting created report (GET by ID)..."
    curl -s -H "Authorization: Bearer $TOKEN" \
      "${BASE_URL}/api/genomica/v1/patient-reports/$REPORT_ID/"
    echo ""
fi

echo ""
echo "=================================="
echo "Testing completed!"
echo "=================================="
