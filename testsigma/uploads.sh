#!/bin/bash
#********GLOBAL variables**********
TESTSIGMA_API_KEY=$TESTSIGMA_API_KEY
TESTSIGMA_PROJECT_ID=17
TESTIGMA_APPLICATION_ID=39
TESTIGMA_UPLOAD_ID=40
TESTIGMA_FILE_PATH=@/bitrise/deploy/app-uat-debug.apk
TESTIGMA_FILE_NAME=app-uat-debug
TESTIGMA_UPLOAD_TYPE=APK
TESTIGMA_PLATFORM_TYPE=TestsigmaLab
TESTIGMA_PUBLIC_STATUS=TRUE
TESTIGMA_UPLOAD_URL=https://app.testsigma.com/api/v1/uploads
#**********************************
 
function getJsonValue() {
  json_key=$1
  awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/\042'$json_key'\042/){print $(i+1)}}}' | tr -d '"'
}
 
function setExitCode(){
  if [[ $UPLOAD_ID_RESULT =~ $TESTIGMA_UPLOAD_ID ]];then
    EXITCODE=0
  else
    EXITCODE=1
  fi
}
#******************************************************
 
echo "************ Testsigma: Start executing update APK/IPA ************"
echo "ipa path: $BITRISE_IPA_PATH"
 
# Call Update APK/IPA Endpoint  
HTTP_RESPONSE=$(curl -H "Authorization:Bearer $TESTSIGMA_API_KEY"\
  -H "Content-Type: multipart/form-data" \
  -F "fileContent=$TESTIGMA_FILE_PATH" \
  -F "projectId=$TESTSIGMA_PROJECT_ID" \
  -F "name=$TESTIGMA_FILE_NAME" \
  -F "uploadType=$TESTIGMA_UPLOAD_TYPE" \
  -F "platformType=$TESTIGMA_PLATFORM_TYPE" \
  -F "isPublic=$TESTIGMA_PUBLIC_STATUS" \
  -F "applicationId=$TESTIGMA_APPLICATION_ID" \
  --silent --write-out "HTTPSTATUS:%{http_code}" \
  -X PUT $TESTIGMA_UPLOAD_URL/$TESTIGMA_UPLOAD_ID)
 
echo "HTTP_RESPONSE: $HTTP_RESPONSE"
     
# extract the body
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')  
echo "HTTP BODY: $HTTP_BODY"
 
# extract upload id
UPLOAD_ID_RESULT=$(echo $HTTP_RESPONSE | getJsonValue id)
 
# extract the status code from response
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
echo "HTTP_STATUS: $HTTP_STATUS"
 
# print the upload id or the error message
NUMBERS_REGEX="^[0-9].*"
if [[ $UPLOAD_ID_RESULT =~ $NUMBERS_REGEX ]]; then
  echo "Upload ID: $UPLOAD_ID_RESULT"
else
  echo "$UPLOAD_ID_RESULT"
fi
 
EXITCODE=0
 
# Check status and response body
if [ ! $HTTP_STATUS -eq 200  ]; then
  echo "Failed to upload file!"
  echo "$HTTP_RESPONSE"
  EXITCODE=1
else
 # setExitCode
  EXITCODE=0
fi
 
sleep 1m
 
echo "************************************************"
echo "Result JSON Response: $HTTP_BODY"
echo "************ Testsigma: Completed update file (APK/IPA) ************"
exit $EXITCODE