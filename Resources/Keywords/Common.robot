*** Settings ***
Library    RequestsLibrary
*** Keywords ***
Ping Server
    log          ${BASE_URL.${SITE}}  
    Create Session      SessionPing        ${BASE_URL.${SITE}}     verify=True
    ${response}=        GET On Session     SessionPing        ping 
    Should Be Equal As Strings      ${response.status_code}     201



AddUsers
    ${HEADERS}=          Create Dictionary
    ...                 Content-Type=application/json
    ${data}=    Create Dictionary     
    ...    name=${${TEST NAME}.name}     
    ...    job=${${TEST NAME}.job}
    Create Session      AddUsers     ${BASE_URL2.${SITE}}    verify=True
    ${response}=        POST On Session        AddUsers     ${BASE_URL2.${SITE}}      data=${data}
    Status Should Be        201     ${response}
    Log     ${response.json()} 
    ${new_user_id}=          Select Elements        ${response.json()}      .id
    Set Suite Variable              ${UID}            ${new_user_id}[0]


UpdateUsers
    [Arguments]         ${ID}=${UID}
    ${HEADERS}=          Create Dictionary
    ...                 Content-Type=application/json
    ${data}=             Create Dictionary
    ...                 name=${${TEST NAME}.name}
    ...                 job=${${TEST NAME}.job}
    Create Session      UpdateUsers     ${BASE_URL2.${SITE}}    headers=${HEADERS}    verify=True
    
    ${response}=        PUT On Session    UpdateUsers    ${BASE_URL2.${SITE}}/users/${ID}     json=${data}
    Status Should Be    200    ${response}
    Log                ${response.json()}








Obtain Auth Token
    ${HEADERS}=         Create Dictionary
    ...                 Content-Type=application/json
    Create Session      Obtain Token         ${BASE_URL.${SITE}}     verify=True
    ${response}=        POST On Session        Obtain Token        ${${TEST NAME}.PathAuth}     data={"username":"${${TEST NAME}.USERNAME}","password":"${${TEST NAME}.PASSWORD}"}      headers=${HEADERS}
    log             ${response.content}   
    Should Be Equal As Strings      ${response.status_code}     200
    Element should exist            ${response.json()}         $.token
    ${TOKEN}=                       Get From Dictionary             ${response.json()}      token
    Set Suite Variable          ${TOKEN}        ${TOKEN}



Add Booking
    ${bookingdates}=   Create Dictionary
    ...                checkin=${${TEST NAME}.CHECKIN}
    ...                checkout=${${TEST NAME}.CHECKOUT}

    ${newbooking}=      Create Dictionary
    ...                 firstname=${${TEST NAME}.FIRSTNAME}
    ...                 lastname=${${TEST NAME}.LASTNAME}
    ...                 totalprice=${${TEST NAME}.TOTALPRICE} 
    ...                 depositpaid=${${TEST NAME}.DEPOSITPAID} 
    ...                 additionalneeds=${${TEST NAME}.ADDITIONALNEEDS}
    ...                 bookingdates=${bookingdates} 

    ${HEADERS}=          Create Dictionary
    ...                 Content-Type=application/json
    log                  ${newbooking}
    Create Session      Add Booking      ${BASE_URL.${SITE}}       verify=True
    ${response}=        POST On Session    Add Booking      ${${TEST NAME}.PathAddBooking}  json=${newbooking}  headers=${HEADERS}
    Should Be Equal As Strings      ${response.status_code}     200
    Element should exist             ${response.json()}          .bookingid
    ${newid}=                       Select Elements              ${response.json()}      .bookingid
    Set Suite Variable              ${NEW_ID}                    ${newid}[0]


Update New Booking
    [Arguments]         ${ID}=${NEW_ID}
    ${bookingdates}=   Create Dictionary
    ...                checkin=${${TEST NAME}.CHECKIN}
    ...                checkout=${${TEST NAME}.CHECKOUT}
    ${updatebooking}=   Create Dictionary
    ...                 firstname=${${TEST NAME}.FIRSTNAME}
    ...                 lastname=${${TEST NAME}.LASTNAME}
    ...                 totalprice=${${TEST NAME}.TOTALPRICE} 
    ...                 depositpaid=${${TEST NAME}.DEPOSITPAID} 
    ...                 additionalneeds=${${TEST NAME}.ADDITIONALNEEDS}
    ...                 bookingdates=${bookingdates} 
    ${HEADERS}=          Create Dictionary
    ...                  Content-Type=application/json
    ...                  Cookie=token=${TOKEN}
    Create Session      Update Booking      ${BASE_URL.${SITE}}       verify=True
    ${response}=       PUT On Session    Update Booking     ${${TEST NAME}.PathUpdateBooking}/${ID}      json=${updatebooking}       headers=${HEADERS}
    Should Be Equal As Strings          ${response.status_code}     200


Check New Booking Details Are Correct ${ID}
    Create Session      Get Booking      ${BASE_URL.${SITE}}       verify=True
    ${response}=        GET On Session      Get Booking     ${${TEST NAME}.PathGetBooking}/${ID} 
    Should Be Equal As Strings      ${response.status_code}     200
    Element Should Exist        ${response.json()}     .firstname:contains("${${TEST NAME}.FIRSTNAME}")
    Element Should Exist  ${response.json()}  .lastname:contains("${${TEST NAME}.LASTNAME}")
    Element Should Exist  ${response.json()}  .totalprice:(${${TEST NAME}.TOTALPRICE})
    Element Should Exist  ${response.json()}  .depositpaid:(${${TEST NAME}.DEPOSITPAID})
    Element Should Exist  ${response.json()}  .additionalneeds:contains("${${TEST NAME}.ADDITIONALNEEDS}")
    ${BOOKING_DATES_STRING}=        Json To String      ${response.json()["bookingdates"]}
    Element Should Exist        ${BOOKING_DATES_STRING}     .checkin:(${${TEST NAME}.CHECKIN})
    Element Should Exist        ${BOOKING_DATES_STRING}     .checkout:(${${TEST NAME}.CHECKOUT})


Get All Booking IDs
    Create Session      Get All       ${BASE_URL.${SITE}}       verify=True
    ${response}=        GET On Session      Get All     ${${TEST NAME}.PathGetBooking}
    Should Be Equal As Strings      ${response.status_code}     200
    @{BOOKINGIDS}=      Create List
    ${COUNTER}         Set Variable            ${1}
    FOR     ${item}     IN      @{response.json()}
        log             ${item}
        Insert Into List        ${BOOKINGIDS}       ${COUNTER}      ${item}[bookingid]
        ${COUNTER}=     Set Variable        ${COUNTER+1}
    END
    
    log list             ${BOOKINGIDS}
    

Get New Booking ID By Name
    Create Session      Get BY        ${BASE_URL.${SITE}}       verify=True
    ${response}=        GET On Session      Get BY      url=${${TEST NAME}.PathGetBooking}/?firstname=${${TEST NAME}.FIRSTNAME}&lastname=${${TEST NAME}.LASTNAME}
    Should Be Equal As Strings      ${response.status_code}     200
    Element Should Exist    ${response.json()}  .firstname:contains("${${TEST NAME}.FIRSTNAME}")
    Element Should Exist    ${response.json()}  .lastname:contains("${${TEST NAME}.LASTNAME}")


Get New Booking ID By Date
    Create Session      Get BY        ${BASE_URL.${SITE}}       verify=True
    ${response}=        GET On Session      Get BY      url=${${TEST NAME}.PathGetBooking}/?checkin=${${TEST NAME}.CHECKIN}&checkout=${${TEST NAME}.CHECKOUT}
    Should Be Equal As Strings      ${response.status_code}     200
    ${BOOKING_DATES_STRING}=        Json To String      ${response.json()["bookingdates"]}
    Element Should Exist        ${BOOKING_DATES_STRING}     .checkin:(${${TEST NAME}.CHECKIN})
    Element Should Exist        ${BOOKING_DATES_STRING}     .checkout:(${${TEST NAME}.CHECKOUT})


Delete Bookings by ${ID}
    ${HEADERS}=          Create Dictionary
    ...                  Content-Type=application/json
    ...                  Cookie=token=${TOKEN}
    Create Session      Delete Booking      ${BASE_URL.${SITE}}       verify=True
    ${response}=        Delete On Session      Delete Booking        ${${TEST NAME}.PathDeleteBooking}/${ID}         headers=${HEADERS}
    Should Be Equal As Strings      ${response.status_code}     201

Partial Update by Booking ${ID}
    ${partialupdatebooking}=        Create Dictionary
    ...                             totalprice=1000
    ${HEADERS}=          Create Dictionary
    ...                  Content-Type=application/json
    ...                  Cookie=token=${TOKEN}
    Create Session      Partial Booking      ${BASE_URL.${SITE}}       verify=True
    ${response}=        PATCH On Session      Partial Booking       ${${TEST NAME}.PathPartialBooking}/${ID}      json=${partialupdatebooking}        headers=${HEADERS}
    Should Be Equal As Strings      ${response.status_code}     200



