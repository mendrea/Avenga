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

TC01 Get All CoverPhotos
    [Documentation]    Get All CoverPhotos
    [Tags]    C301
    GET On [/${API}/${VERSION}/CoverPhotos] Endpoint And Validate That Status Code Is [200]
    ${coverlist}=     Get From List    ${JSON_Response}    1
    ${first_cover}=   Get From List    ${coverlist}    0
    # Extract fields
    ${id}=            Get From Dictionary    ${first_cover}    id
    ${idBook}=        Get From Dictionary    ${first_cover}    idBook
    ${url}=           Get From Dictionary    ${first_cover}    url
    # Validate values
    Should Be Equal As Integers    ${id}        1
    Should Be Equal As Integers    ${idBook}    1
    Should Contain                 ${url}       http

TC02 Get CoverPhoto By Valid Id
    GET On [/${API}/${VERSION}/CoverPhotos/1] Endpoint And Validate That Status Code Is [200]
    Validate That The Response Contains ['id': 1] Data
    Validate That The Response Contains ['idBook': 1] Data
    Validate That The Response Contains ['url': 'https://placeholdit.imgix.net/~text?txtsize=33&txt=Book 1&w=250&h=350] Data

TC03 Create CoverPhoto With Valid Payload
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_idBook}=     Generate Random String    1    123
    ${rnd_url}=        Set Variable        https://example.com/${rnd_id}.jpg
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    idBook=${rnd_idBook}    url=${rnd_url}
    POST On [/${API}/${VERSION}/CoverPhotos] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['id': ${rnd_id}] Data
    Validate That The Response Contains ['url': '${rnd_url}'] Data

TC04 Update CoverPhoto With Valid Payload
    ${PAYLOAD}=        Create Dictionary    id=1    idBook=1    url=https://example.com/updated1.jpg
    PUT On [/${API}/${VERSION}/CoverPhotos/1] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['url': 'https://example.com/updated1.jpg'] Data

TC05 Delete CoverPhoto With Valid Id
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_idBook}=     Generate Random String    1    123
    ${rnd_url}=        Set Variable        https://example.com/${rnd_id}.jpg
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    idBook=${rnd_idBook}    url=${rnd_url}
    POST On [/${API}/${VERSION}/CoverPhotos] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    DELETE On [/${API}/${VERSION}/CoverPhotos/${rnd_id}] Endpoint And Validate Status Code Is [200]
    GET On [/${API}/${VERSION}/CoverPhotos/${rnd_id}] Endpoint And Validate That Status Code Is [404]

# =========================
# ❌ Negative Scenarios
# =========================

TC06 Get CoverPhoto By Invalid Id
    GET On [/${API}/${VERSION}/CoverPhotos/99999] Endpoint And Validate That Status Code Is [404]

TC07 Get CoverPhoto With Non-Numeric Id
    GET On [/${API}/${VERSION}/CoverPhotos/abc] Endpoint And Validate That Status Code Is [400]

TC08 Create CoverPhoto With Missing Required Field
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${PAYLOAD}=        Create Dictionary    id=${EMPTY}    idBook=${EMPTY}    url=${EMPTY}
    POST On [/${API}/${VERSION}/CoverPhotos] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC09 Create CoverPhoto With Invalid Data Type
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${PAYLOAD}=        Create Dictionary    id=${rnd_id}    idBook=abc    url=invalid_url
    POST On [/${API}/${VERSION}/CoverPhotos] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC10 Update CoverPhoto With Non-Existing Id
    ${PAYLOAD}=        Create Dictionary    id=avb1    idBook=1    url=https://example.com/ghost.jpg
    PUT On [/${API}/${VERSION}/CoverPhotos/avb] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC11 Delete CoverPhoto With Non-Existing Id
    DELETE On [/${API}/${VERSION}/CoverPhotos/ABC] Endpoint And Validate Status Code Is [400]
