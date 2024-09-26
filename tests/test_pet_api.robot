*** Settings ***
Suite Setup       Set Base URL    ${BASE_URL}
Resource          ../keywords/petstore_keywords.robot
Variables         ../testdata/testable/pet_testdata.yaml
Variables         ../testdata/main/generic_testdata.yaml
Library           Collections
Library           RequestsLibrary
Library           OperatingSystem

*** Variables ***

*** Test Cases ***
Create Pet Successfully
    [Documentation]    Create a pet with the given JSON data and verify the response
    [Tags]    pet    post
    ${post_data}=    Create Dictionary    id=${pet_postid}    name=${pet_postname}    status=available
    ${headers}=    Create Dictionary    Content-Type=application/json
    Create Session    petstore    ${BASE_URL}
    ${response}=    Post Request    petstore    ${BASE_URL}/pet    data=${post_data}    headers=${headers}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    Should Be Equal As Numbers    ${response.status_code}    ${success_status}
    ${response_code}=    Set Variable    ${response.status_code}
    Run Keyword If    ${response_code} == 200    Get Json Data    ${response}
    Run Keywords    Log To Console    ${data}
    ...    AND    Should Be Equal    ${data['id']}    ${pet_postid}
    ...    AND    Should Be Equal    ${data['name']}    ${pet_postname}
    #    Should Contain    ${response_body}    "${pet_postname}"
    #    Should Contain    ${response_body}    "available"

Get Pet By Id
    [Documentation]    Test for retrieving a pet by ID
    [Tags]    pet    get    positive
    #    Create Session    petstore    ${BASE_URL}
    ${response}=    GET    ${BASE_URL}/pet/${pet_postid}
    Should Be Equal As Strings    ${response.status_code}    ${success_status}
    ${pet} =    Set Variable    ${response.json()}
    Should Not Be Empty    ${pet}
    Should Be Equal    ${pet['id']}    ${pet_postid}

Get Pet By Invalid Id
    [Documentation]    Test for retrieving an Invalid pet by ID
    [Tags]    pet    get    negative
    Create Session    negative_petstore    ${BASE_URL}
    ${response}=    Get Request    negative_petstore    ${BASE_URL}/pet/${pet_getInvalidId}
    Should Be Equal As Strings    ${response.status_code}    ${failure_status}
    ${pet} =    Set Variable    ${response.json()}
    Should Not Be Empty    ${pet}
    Should Be Equal    ${pet['type']}    ${json_errorType}
    Should Be Equal    ${pet['message']}    ${json_petErrorMsg}

Get Pet By Status
    [Documentation]    Test for retrieving a pet by status
    [Tags]    pet    get    positive
    ${response}=    GET    ${BASE_URL}/pet/findByStatus    params=status=${pet_status_sold}
    Should Be Equal As Strings    ${response.status_code}    ${success_status}
    ${pets} =    Set Variable    ${response.json()}
    Should Not Be Empty    ${pets}
    FOR    ${pet}    IN    @{pets}
            Should Be Equal    ${pet["status"]}    ${pet_status_sold}
    END

Get Pet By tags
    [Documentation]    Test for retrieving a pet by tags
    [Tags]    pet    get    positive
    # Note: Create a tag named as 'Exotic' manually first otherwise the tc will fail.
    ${response}=    GET    ${BASE_URL}/pet/findByTags    params=tags=${pet_getTag}
    Should Be Equal As Strings    ${response.status_code}    ${success_status}
    # ${pets} =    Set Variable    ${response.json()}
    # Should Not Be Empty    ${pets}
    # FOR    ${pet}    IN    @{pets}
    # ${tags} =    Set Variable    ${pet['tags']}
        # FOR    ${tag}    IN    @{tags}
            # Should Be Equal    ${tag['name']}    ${pet_getTag}
        # END
    # END

Delete Pet By Id
    [Documentation]    Test for deleting a pet by ID
    [Tags]    pet    delete    positive
    ${response}=    DELETE    ${BASE_URL}/pet/${pet_postid}
    Should Be Equal As Strings    ${response.status_code}    ${success_status}
    ${pet} =    Set Variable    ${response.json()}
    Should Not Be Empty    ${pet}
    Should Be Equal    ${pet['type']}    ${delJson_errorType}
    Should Be Equal    ${pet['code']}    ${success_status}

Delete Pet By Invalid Id
    [Documentation]    Test for deleting an Invalid pet by ID
    [Tags]    pet    delete    negative
    ${response}=    Delete Request    negative_petstore    ${BASE_URL}/pet/${pet_getInvalidId}
    Should Be Equal As Strings    ${response.status_code}    ${failure_status}
