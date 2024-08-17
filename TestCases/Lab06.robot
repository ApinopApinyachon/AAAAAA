*** Settings ***
Resource        ..//init.robot
Variables          ..//TestData//${SITE}//Lab06.yaml
Suite Setup         Ping Server

*** Test Cases ***
AddUsers
    [Tags]    Post
    AddUsers 

UpdateUsers
    [Tags]    Put
    UpdateUsers  

# Obtain Token
#     [Tags]  Auth
#     Obtain Auth Token

# Get All Bookings IDs
#      [Tags]  Get
#     Get All Booking IDs

# Add New Booking
#     [Tags]  Post
#     Obtain Auth Token
#     Add Booking
#     Delete Bookings by ${NEW_ID}

# Validate New Booking Details
#     [Tags]  Post Get
#     Add Booking
#     Check New Booking Details Are Correct ${NEW_ID}           
#     Delete Bookings by ${NEW_ID}

# Update New Booking
#     [Tags]  Post Put
#     Obtain Auth Token
#     Add Booking
#     Update New Booking
#     Delete Bookings by ${NEW_ID}

# Partial Update New Booking
#     [Tags]  Patch
#     Obtain Auth Token
#     Add Booking
#     Partial Update by Booking ${NEW_ID}
#     Delete Bookings by ${NEW_ID}

# Delete Bookings
#    [Tags]  Delete
#    Obtain Auth Token
#    Add Booking
#    Delete Bookings by ${NEW_ID}