*** Settings ***
Suite Setup       Set Base URL    ${BASE_URL}
Resource          ../keywords/petstore_keywords.robot
Variables         ../testdata/testable/pet_testdata.yaml
Variables         ../testdata/main/generic_testdata.yaml
Library           Collections
Library           RequestsLibrary
Library           OperatingSystem

*** Test Cases ***
Add New User
    [Documentation]    Add a user with the given JSON data and verify the response
    [Tags]    user    post    positive
    ${post_data}=    Create Dictionary    id=${user_id}    username=${user_name}    firstName=${user_firstName}    lastName=${user_lastName}    email=${user_email}    password=${user_password}    phone=${user_phone}
    ${headers}=    Create Dictionary    Content-Type=application/json
    Create Session    user_info    ${BASE_URL}
    ${response}=    Post Request    user_info    ${BASE_URL}/user    data=${post_data}    headers=${headers}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    Should Be Equal As Numbers    ${response.status_code}    ${success_status}
    ${response_code}=    Set Variable    ${response.status_code}
    Run Keyword If    ${response_code} == ${success_status}    Get Json Data    ${response}
    # Log the response JSON data
    Log To Console    Response JSON Data: ${data}
    # Assert the response data
    Should Be Equal    ${data['code']}    ${success_status}
    # Ensure message is compared as string if needed
    ${expected_message}=    Set Variable    ${user_id}    # Ensure this is the correct expected value
    Should Be Equal As Strings    ${data['message']}    ${expected_message}

Add Invalid User
    [Documentation]    Add an Invalid user with the given JSON data and verify the response
    [Tags]    user    post    negative
    ${post_data}=    Create Dictionary    id=${user_id}    username=${user_name}    email=dummydata37@example.com    phone=${NULL}
    ${headers}=    Create Dictionary    Content-Type=application/json
    Create Session    invalid_user_info    ${BASE_URL}
    ${response}=    Post Request    invalid_user_info    ${BASE_URL}/user    data=${post_data}    headers=${headers}
    Log To Console    Response Status: ${response.status_code}
    Log To Console    ${response.content}
    Should Not Be Equal As Numbers    ${response.status_code}    500
    ${response_code}=    Set Variable    ${response.status_code}
    Run Keyword If    ${response_code} == 200    Get Json Data    ${response}
    # Log the response JSON data
    Log To Console    Response JSON Data: ${data}
    # Assert the response data
    Run Keyword And Ignore Error    Should Be Equal    ${data['code']}    500
    # Ensure message is compared as string if needed
    Run Keyword And Ignore Error    Should Be Equal As Strings    ${data['message']}    something bad happened

Get User By UserName
    [Documentation]    Test for retrieving a user by ID
    [Tags]    user    get    negative
    #    Create Session    petstore    ${BASE_URL}
    ${response}=    GET    ${BASE_URL}/user/${user_name}
    Should Be Equal As Strings    ${response.status_code}    ${success_status}
    ${userDetail} =    Set Variable    ${response.json()}
    Should Not Be Empty    ${userDetail}
    Should Be Equal    ${userDetail['username']}    ${user_name}

Get User By Invaid UserName
    [Documentation]    Sends a GET request to fetch user info and expects a 404 Not Found error.
    [Tags]    user    get    error    negative
    # Run the GET request and expect an HTTPError (404)
    Run Keyword And Expect Error    HTTPError: 404 Client Error: Not Found for url: ${BASE_URL}/user/Swati25    Get User Info    ${BASE_URL}/user/Swati25

*** Keywords ***
Get User Info
    [Arguments]    ${url}
    ${response}=    GET    ${url}
    # Check if response status code is not 200, raise HTTPError
    Run Keyword If    ${response.status_code} != 200    Raise Exception    HTTPError: ${response.status_code} Client Error: ${response.reason} for url: ${url} for url: ${url}
    [Return]    ${response}
