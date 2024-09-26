# ..petstore_keywords.robot
*** Settings ***
Library           RequestsLibrary
Variables         ../testdata/main/generic_testdata.yaml

*** Keywords ***
Create Petstore Session
    Create Session    petstore    ${BASE_URL}

Set Base URL
    [Arguments]    ${url}
    Set Global Variable    ${BASE_URL}    ${url}

Set API Key
    [Arguments]    ${key}
    Set Global Variable    ${API_KEY}    ${key}

Get Json Data
    [Arguments]    ${response}
    ${data}=    To Json    ${response.content}
    Set Global Variable    ${data}
