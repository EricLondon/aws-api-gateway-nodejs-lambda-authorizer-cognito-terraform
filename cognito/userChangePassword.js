global.fetch = require('node-fetch')

const AWS_REGION_STRING = process.env.AWS_REGION || 'us-east-1'

const AWS = require('aws-sdk')
AWS.config.update({
  region: AWS_REGION_STRING
})

const userName = 'EricLondon'
const userPasswordCurrent = ''
const userPasswordNew = ''
const userPoolId = ''
const clientId = ''

const authenticationData = {
  Username: userName,
  Password: userPasswordCurrent
}

const AmazonCognitoIdentity = require('amazon-cognito-identity-js')
const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData)

const poolData = {
  UserPoolId: userPoolId,
  ClientId: clientId
}

const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData)

const userData = {
  Username: userName,
  Pool: userPool
}

const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData)

cognitoUser.authenticateUser(authenticationDetails, {
  onSuccess: function (result) {
    // console.log('result', JSON.stringify(result, null, 2));

    // var accessToken = result.getAccessToken().getJwtToken();
    // console.log('accessToken', accessToken)

    let jwtWithAttributes = result.idToken.jwtToken
    let payload = result.idToken.payload

    console.log('JWT: ', jwtWithAttributes)
    console.log('payload', JSON.stringify(payload, null, 2));
  },

  onFailure: function (error) {
    console.log('error', JSON.stringify(error, null, 2));
  },

  newPasswordRequired: function (userAttributes, requiredAttributes) {

    // console.log('userAttributes', userAttributes)
    // console.log('requiredAttributes', requiredAttributes)

    // User was signed up by an admin and must provide new
    // password and required attributes, if any, to complete
    // authentication.

    // userAttributes: object, which is the user's current profile. It will list all attributes that are associated with the user.
    // Required attributes according to schema, which don’t have any values yet, will have blank values.
    // requiredAttributes: list of attributes that must be set by the user along with new password to complete the sign-in.


    // Get these details and call
    // newPassword: password that user has given
    // attributesData: object with key as attribute name and value that the user has given.
    cognitoUser.completeNewPasswordChallenge(userPasswordNew, userAttributes, this)
  }

})
