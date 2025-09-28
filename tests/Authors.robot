*** Settings ***
Resource          ../Settings.robot
Resource          ../Keywords/GET.resource
Resource          ../Keywords/POST.resource
Resource          ../Keywords/PUT.resource
Resource          ../Keywords/DELETE.resource
Resource          ../Keywords/Validations.resource

Suite Setup       Create Session To API

Suite Teardown    # optionally close session, cleanup

*** Variables ***
${API}            api
${VERSION}        v1

*** Test Cases ***

TC01 Get All Authors
    [Documentation]    Get All Authors
    [Tags]    C201
    GET On [/${API}/${VERSION}/Authors] Endpoint And Validate That Status Code Is [200]
    ${authorlist}=    Get From List    ${JSON_Response}    1
    ${first_author}=  Get From List    ${authorlist}    0
    # Extract fields
    ${id}=            Get From Dictionary    ${first_author}    id
    ${idBook}=        Get From Dictionary    ${first_author}    idBook
    ${firstName}=     Get From Dictionary    ${first_author}    firstName
    ${lastName}=      Get From Dictionary    ${first_author}    lastName
    # Validate values
    Should Be Equal As Integers    ${id}        1
    Should Be Equal As Integers    ${idBook}    1
    Should Be Equal As Strings    ${firstName}     First Name 1
    Should Be Equal As Strings    ${lastName}      Last Name 1

TC02 Get Author By Valid Id
    GET On [/${API}/${VERSION}/Authors/1] Endpoint And Validate That Status Code Is [200]
    Validate That The Response Contains ['id': 1] Data
    Validate That The Response Contains ['idBook': 1] Data
    Validate That The Response Contains ['firstName': 'First Name 1'] Data
    Validate That The Response Contains ['lastName': 'Last Name 1'] Data

TC03 Create Author With Valid Payload
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_idBook}=     Generate Random String    1    123
    ${rnd_firstName}=  Generate Random String    5    [LETTERS]
    ${rnd_lastName}=   Generate Random String    5    [LETTERS]
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    idBook=${rnd_idBook}    firstName=${rnd_firstName}    lastName=${rnd_lastName}
    POST On [/${API}/${VERSION}/Authors] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['id': ${rnd_id}] Data
    Validate That The Response Contains ['firstName': '${rnd_firstName}'] Data
    Validate That The Response Contains ['lastName': '${rnd_lastName}'] Data

TC04 Update Author With Valid Payload
    ${PAYLOAD}=        Create Dictionary    id=1    idBook=1    firstName=UpdatedFirstName    lastName=UpdatedLastName
    PUT On [/${API}/${VERSION}/Authors/1] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['firstName': 'UpdatedFirstName'] Data
    Validate That The Response Contains ['lastName': 'UpdatedLastName'] Data

TC05 Delete Author With Valid Id
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_idBook}=     Generate Random String    1    123
    ${rnd_firstName}=  Generate Random String    5    [LETTERS]
    ${rnd_lastName}=   Generate Random String    5    [LETTERS]
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    idBook=${rnd_idBook}    firstName=${rnd_firstName}    lastName=${rnd_lastName}
    POST On [/${API}/${VERSION}/Authors] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    DELETE On [/${API}/${VERSION}/Authors/${rnd_id}] Endpoint And Validate Status Code Is [200]
    GET On [/${API}/${VERSION}/Authors/${rnd_id}] Endpoint And Validate That Status Code Is [404]

# =========================
# ❌ Negative Scenarios
# =========================

TC06 Get Author By Invalid Id
    GET On [/${API}/${VERSION}/Authors/99999] Endpoint And Validate That Status Code Is [404]

TC07 Get Author With Non-Numeric Id
    GET On [/${API}/${VERSION}/Authors/abc] Endpoint And Validate That Status Code Is [400]

TC08 Create Author With Missing Required Field
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${PAYLOAD}=        Create Dictionary    id=${EMPTY}    idBook=${EMPTY}    firstName=John
    POST On [/${API}/${VERSION}/Authors] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC09 Create Author With Invalid Data Type
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    idBook=abc    firstName=John    lastName=123
    POST On [/${API}/${VERSION}/Authors] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC10 Update Author With Non-Existing Id
    ${PAYLOAD}=        Create Dictionary    id=0a1    idBook=1    firstName=GhostFirst    lastName=GhostLast
    PUT On [/${API}/${VERSION}/Authors/0a1] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC11 Delete Author With Non-Existing Id
    DELETE On [/${API}/${VERSION}/Authors/ABC] Endpoint And Validate Status Code Is [400]
