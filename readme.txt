# provision cognito user pool and client
cd api-gateway-authorizers/cognito
./provision.sh apply

Outputs:

cognito_client = REDACTED
cognito_user_pool_id = us-east-REDACTED

# create cognito user
aws --profile CHANGEME cognito-idp admin-create-user --user-pool-id us-east-REDACTED --username EricLondon --user-attributes '[{"Name":"email","Value":"REDACTED"},{"Name":"custom:acl_thing","Value":"1,2"},{"Name":"custom:acl_stuff","Value":"3,4"}]'

{
    "User": {
        "Username": "EricLondon",
        "Attributes": [
            {
                "Name": "custom:acl_stuff",
                "Value": "3,4"
            },
            {
                "Name": "sub",
                "Value": "REDACTED"
            },
            {
                "Name": "email",
                "Value": "REDACTED"
            },
            {
                "Name": "custom:acl_thing",
                "Value": "1,2"
            }
        ],
        "UserCreateDate": 1541976566.306,
        "UserLastModifiedDate": 1541976566.306,
        "Enabled": true,
        "UserStatus": "FORCE_CHANGE_PASSWORD"
    }
}

# NOTE: temp password is emailed

# change cognito password and get JWT
node userChangePassword.js

# output:
JWT:  SOMEJWTREDACTED
payload {
  "custom:acl_stuff": "3,4",
  "sub": "REDACTED",
  "aud": "6seaifls35smv0h0kbf1vliks1",
  "event_id": "4348287e-e604-11e8-91b3-25b3384b7f96",
  "token_use": "id",
  "auth_time": 1541976661,
  "iss": "https://cognito-idp.us-east-1.amazonaws.com/us-east-REDACTED",
  "cognito:username": "EricLondon",
  "exp": 1541980261,
  "iat": 1541976661,
  "custom:acl_thing": "1,2",
  "email": "REDACTED"
}

//////////////////////////////////////////////////

# provision api gateway and lambdas
cd api-gateway-authorizers
./provision.sh apply

Outputs:

api_gateway_stuff_base_url = https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/stuff
api_gateway_thing_base_url = https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/thing

//////////////////////////////////////////////////

CURL requests

// access to 1, 2
curl https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/thing/1 -H "Authorization: USER-JWT"
curl https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/thing/2 -H "Authorization: USER-JWT"
curl https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/thing/3 -H "Authorization: USER-JWT"
curl https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/thing/4 -H "Authorization: USER-JWT"

responses:
thing/1: {"resource":"thing","id":1}
thing/2: {"resource":"thing","id":2}
thing/3: {"Message":"User is not authorized to access this resource"
thing/4: {"Message":"User is not authorized to access this resource with an explicit deny"}

// access to 3, 4
curl https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/stuff/1 -H "Authorization: USER-JWT"
curl https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/stuff/2 -H "Authorization: USER-JWT"
curl https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/stuff/3 -H "Authorization: USER-JWT"
curl https://REDACTED-API-ID.execute-api.us-east-1.amazonaws.com/stuff/4 -H "Authorization: USER-JWT"

responses:
stuff/1: {"Message":"User is not authorized to access this resource"}
stuff/2: {"Message":"User is not authorized to access this resource"}
stuff/3: {"resource":"stuff","id":3}
stuff/4: {"resource":"stuff","id":4}
