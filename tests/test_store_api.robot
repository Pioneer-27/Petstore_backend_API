*** Settings ***
Suite Setup       Set Base URL    ${BASE_URL}
Resource          ../keywords/petstore_keywords.robot
Variables         ../testdata/testable/pet_testdata.yaml
Variables         ../testdata/main/generic_testdata.yaml
Library           Collections
Library           RequestsLibrary
Library           OperatingSystem

*** Test Cases ***
Get Store Inventory
    [Documentation]    Test for retrieving a petstore Inventory
    [Tags]    store_inventory    get    positive
    Create Session    petstore_inventory    ${BASE_URL}
    ${response}=    Get Request    petstore_inventory    ${BASE_URL}/store/inventory
    Should Be Equal As Strings    ${response.status_code}    ${success_status}
    ${inventory} =    Set Variable    ${response.json()}
    Should Not Be Empty    ${inventory}
    Dictionary Should Contain Key    ${inventory}    sold    message= Attribute 'sold' found

Place Inventory Order
    [Documentation]    Test for creating a petstore Inventory order
    [Tags]    store_inventory    post    positive
    ${post_data}=    Create Dictionary    id=${store_orderId}    petId=${pet_postid}    quantity=${store_orderQuantity}
    ${headers}=    Create Dictionary    Content-Type=application/json
    Create Session    petstore_inventory    ${BASE_URL}
    ${response}=    Post Request    petstore_inventory    ${BASE_URL}/store/order    data=${post_data}    headers=${headers}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    Should Be Equal As Numbers    ${response.status_code}    ${success_status}
    ${response_code}=    Set Variable    ${response.status_code}
    Run Keyword If    ${response_code} == 200    Get Json Data    ${response}
    Run Keywords    Log To Console    ${data}
    ...    AND    Should Be Equal    ${data['id']}    ${store_orderId}
    ...    AND    Should Be Equal    ${data['petId']}    ${pet_postid}

Get Order By Id
    [Documentation]    Test for retrieving a petstore Inventory order by ID
    [Tags]    store_inventory    get    positive
    Create Session    petstore_order    ${BASE_URL}
    ${response}=    Get Request    petstore_order    ${BASE_URL}/store/order/${storeOrder_orderId}
    Should Be Equal As Strings    ${response.status_code}    ${success_status}
    ${order} =    Set Variable    ${response.json()}
    Should Not Be Empty    ${order}
    Should Be Equal    ${order['id']}    ${6}

Get Order By Invalid Id
    [Documentation]    Test for retriving an order by ID
    [Tags]    store_inventory    get    negative
    ${error_msg}    ${response}=    Run Keyword And Ignore Error    GET On Session    petstore_order    ${BASE_URL}/store/order/8
    # Ensure the request failed
    Should Not Be Equal As Strings    ${error_msg}    OK # Ensure we received an error
    # If the response is an error message, log it
    Log    Received error response: ${response}
    # Check if the response is a string indicating an error
    Should Contain    ${response}    HTTPError
    Should Contain    ${response}    Not Found
    Should Contain    ${response}    404 Client Error
    Should Contain    ${response}    ${BASE_URL}/store/order/8

Delete Pet By Id
    [Documentation]    Test for deleting an order by ID
    [Tags]    store_inventory    delete    positive
    ${response}=    DELETE On Session    petstore_inventory    ${BASE_URL}/store/order/${store_orderId}
    Should Be Equal As Strings    ${response.status_code}    ${success_status}
    ${order} =    Set Variable    ${response.json()}
    Should Not Be Empty    ${order}
    Should Be Equal    ${order['type']}    ${delJson_errorType}
    ${store_orderId_as_string} =    Convert To String    ${store_orderId}
    Should Be Equal    ${order['message']}    ${store_orderId_as_string}

Delete Pet By Invalid Id
    [Documentation]    Test for deleting an order by ID
    [Tags]    store_inventory    delete    negative
    ${error_msg}    ${response}=    Run Keyword And Ignore Error    DELETE On Session    petstore_inventory    ${BASE_URL}/store/order/44
    # Ensure the request failed
    Should Not Be Equal As Strings    ${error_msg}    OK # Ensure we received an error
    # If the response is an error message, log it
    Log    Received error response: ${response}
    # Check if the response is a string indicating an error
    Should Contain    ${response}    HTTPError
    Should Contain    ${response}    Not Found
    Should Contain    ${response}    404 Client Error
    Should Contain    ${response}    ${BASE_URL}/store/order/44
