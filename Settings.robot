*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           String
Library           BuiltIn
Library           JSONLibrary


*** Variables ***
${BASE_URL}        https://fakerestapi.azurewebsites.net
${API_PREFIX}      /api/v1    # if the swagger’s endpoints are under /api/v1 (check swagger)
${CONTENT_TYPE}    application/json
${HEADERS}         {"accept: text/plain; v=1.0"}
${API}            api
${VERSION}        v1

*** Keywords ***
Create Session To API
    Create Session        fakerestapi       ${BASE_URL}       verify=${False}        disable_warnings=${True}