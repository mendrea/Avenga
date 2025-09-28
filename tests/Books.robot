*** Settings ***
Resource          ../Settings.robot
Resource          ../Keywords/GET.resource
Resource          ../Keywords/POST.resource
Resource          ../Keywords/PUT.resource
Resource          ../Keywords/DELETE.resource
Resource          ../Keywords/Validations.resource

Suite Setup       Create Session To API

Suite Teardown    # optionally close session, cleanup

*** Test Cases ***

TC01 Get All Books
    [Documentation]    Get All Books
    [Tags]    C001
    GET On [/${API}/${VERSION}/Books] Endpoint And Validate That Status Code Is [200]
    #Get the first book from the list
    ${booklist}=    Get From List    ${JSON_Response}    1
    ${first_book}=    Get From List    ${booklist}    0
    # Extract fields
    ${id}=            Get From Dictionary    ${first_book}    id
    ${title}=         Get From Dictionary    ${first_book}    title
    ${description}=   Get From Dictionary    ${first_book}    description
    ${pageCount}=     Get From Dictionary    ${first_book}    pageCount
    ${excerpt}=       Get From Dictionary    ${first_book}    excerpt
    ${publishDate}=   Get From Dictionary    ${first_book}    publishDate
    # Validate values
    Should Be Equal As Integers    ${id}    1
    Should Be Equal    ${title}    Book 1
    Should Contain     ${description}    Lorem lorem lorem.
    Should Be Equal As Integers    ${pageCount}    100
    Should Contain     ${excerpt}    Lorem lorem lorem.
    Should Match Regexp    ${publishDate}    ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?([+-]\\d{2}:\\d{2}|Z)$


TC02 Get Book By Valid Id
    [Documentation]    Get Book By Valid Id
    [Tags]    C002
    GET On [/${API}/${VERSION}/Books/1] Endpoint And Validate That Status Code Is [200]
    Validate That The Response Contains ['id': 1] Data
    Validate That The Response Contains ['title': 'Book 1'] Data

TC03 Create Book With Valid Payload
    [Documentation]    Create Book With Valid Payload
    [Tags]    C003
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    [NUMBERS]
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_title}    Generate Random String            5        [LETTERS]
    ${rnd_desc}    Generate Random String            15        [LETTERS]
    ${PAYLOAD}=    Create Dictionary    id=${rnd_id}    title=${rnd_title}    description=${rnd_desc}    pageCount=200    excerpt=Sample excerpt    publishDate=2025-01-01T00:00:00
    POST On [/${API}/${VERSION}/Books] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['id': ${rnd_id}] Data
    Validate That The Response Contains ['title': '${rnd_title}'] Data
    Validate That The Response Contains ['description': '${rnd_desc}'] Data

TC04 Update Book With Valid Payload
    [Documentation]    Update Book With Valid Payload
    [Tags]    C004
    ${PAYLOAD}=    Create Dictionary    id=1    title=Updated Book    description=Updated Desc    pageCount=150    excerpt=Updated excerpt    publishDate=2025-01-01T00:00:00
    PUT On [/${API}/${VERSION}/Books/1] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    Validate That The Response Contains ['title': 'Updated Book'] Data

TC05 Delete Book With Valid Id
    [Documentation]    Delete Book With Valid Id
    [Tags]    C005
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    [NUMBERS]
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${rnd_title}    Generate Random String            5        [LETTERS]
    ${rnd_desc}    Generate Random String            15        [LETTERS]
    ${PAYLOAD}=    Create Dictionary    id=${rnd_id}    title=${rnd_title}    description=${rnd_desc}    pageCount=200    excerpt=Sample excerpt    publishDate=2025-01-01T00:00:00
    POST On [/${API}/${VERSION}/Books] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [200]
    DELETE On [/${API}/${VERSION}/Books/${rnd_id}] Endpoint and Validate Status Code Is [200]
    GET On [/${API}/${VERSION}/Books/${rnd_id}] Endpoint And Validate That Status Code Is [404]

# =========================
# Negative Scenarios
# =========================

TC06 Get Book By Invalid Id
    [Documentation]    Get Book By Invalid Id
    [Tags]    C006
    GET On [/${API}/${VERSION}/Books/99999] Endpoint And Validate That Status Code Is [404]

TC07 Get Book With Non-Numeric Id
    [Documentation]    Get Book With Non-Numeric Id
    [Tags]    C007
    GET On [/${API}/${VERSION}/Books/abc] Endpoint And Validate That Status Code Is [400]

TC08 Create Book With Missing Required Field
    [Documentation]    Create Book With Missing Required Field
    [Tags]    C008
    ${PAYLOAD}=    Create Dictionary    id=${EMPTY}    pageCount=120
    POST On [/${API}/${VERSION}/Books] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC09 Create Book With Invalid Data Type
    [Documentation]    Create Book With Invalid Data Type
    [Tags]    C009
    ${first_digit}=    Generate Random String    1    123456789
    ${rest}=           Generate Random String    4    0123456789
    ${rnd_id}=         Set Variable        ${first_digit}${rest}
    ${PAYLOAD}=    Create Dictionary    id=${rnd_id}    title=Invalid Book    description=Bad    pageCount=one hundred    excerpt=Bad excerpt    publishDate=2025-01-01T00:00:00
    POST On [/${API}/${VERSION}/Books] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC10 Update Book With Non-Existing Id
    [Documentation]    Update Book With Non-Existing Id
    [Tags]    C010
    ${PAYLOAD}=    Create Dictionary    id=abv123    title=Ghost Book    description=None    pageCount=10    excerpt=None    publishDate=2025-01-01T00:00:00
    PUT On [/${API}/${VERSION}/Books/99999] Endpoint With Payload [${PAYLOAD}] And Validate Status Code Is [400]

TC11 Delete Book With Non-Existing Id
    [Documentation]    Delete Book With Non-Existing Id
    [Tags]    C011
    DELETE On [/${API}/${VERSION}/Books/ABC] Endpoint and Validate Status Code Is [400]
