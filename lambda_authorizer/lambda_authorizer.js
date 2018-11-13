'use strict';

// constants
const AWS_REGION_STRING = process.env.AWS_REGION || 'us-east-1'
const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID
const COGNITO_USER_POOL = process.env.COGNITO_USER_POOL
const COGNITO_URI = `https://cognito-idp.${AWS_REGION_STRING}.amazonaws.com/${COGNITO_USER_POOL}`
// const DEBUG_ENABLED = process.env.DEBUG_ENABLED.toUpperCase() == 'TRUE'
const DEBUG_ENABLED = true

const AWS = require('aws-sdk');
AWS.config.update({
  region: AWS_REGION_STRING
});
const s3 = new AWS.S3();

const jwt = require('jsonwebtoken')

exports.handler = function (event, context, callback) {
  return main(event, context).then(function (result) {
    callback(null, result);
  }).catch(function (error) {
    callback(error);
  });
}

const main = async (event, context) => {

  if (DEBUG_ENABLED) {
    console.log('event: ', JSON.stringify(event, null, 2))
    console.log('context: ', JSON.stringify(context, null, 2))
  }

  const methodArnSegments = event.methodArn.split('/')
  const apiStage = methodArnSegments[1]
  const apiVerb = methodArnSegments[2].toUpperCase()
  const apiResource = methodArnSegments[3]

  if (DEBUG_ENABLED) {
    console.log('methodArnSegments: ', JSON.stringify(methodArnSegments, null, 2))
    console.log('apiStage: ', apiStage)
    console.log('apiVerb: ', apiVerb)
    console.log('apiResource: ', apiResource)
  }

  let principalId = `user|${new Date().getTime()}`

  try {
    let jwtEncoded = event.authorizationToken
    if (DEBUG_ENABLED) console.log('jwtEncoded: ', JSON.stringify(jwtEncoded, null, 2))

    let jwtDecoded = jwt.decode(jwtEncoded)
    if (DEBUG_ENABLED) console.log('jwtDecoded: ', JSON.stringify(jwtDecoded, null, 2))

    // TODO: determine unique identififer
    // jwtDecoded.sub, jwtDecoded.username, jwtDecoded.cognito:username, etc
    let userId = jwtDecoded.sub
    if (DEBUG_ENABLED) console.log('userId: ', userId)
    principalId = `user|${userId}`

    // ensure cognito pool uri source
    if (jwtDecoded.iss != COGNITO_URI) {
      if (DEBUG_ENABLED) console.log("FAILUE: COGNITO_URI does not match JWT")
      return denyResponse(event.methodArn, principalId)
    }

    // ensure expiration of jwt token
    let expirationDate = new Date(jwtDecoded.exp * 1000)
    if (expirationDate < new Date()) {
      if (DEBUG_ENABLED) console.log("FAILURE: JWT EXPIRED")
      return denyResponse(event.methodArn, principalId)
    }

    // define policy metadata
    let metadata = {
      'sub': jwtDecoded.sub,
      'email': jwtDecoded.email,
      'cognito:username': jwtDecoded['cognito:username'],
      'custom:acl_stuff': jwtDecoded['custom:acl_stuff'],
      'custom:acl_thing': jwtDecoded['custom:acl_thing']
    }
    if (DEBUG_ENABLED) console.log('metadata: ', JSON.stringify(metadata, null, 2))

    // TODO: deny access based on verb/action?

    // get user acl
    let userAcl = getUserAcl(jwtDecoded)

    // get policy statements
    let policyStmnts = policyStatements(methodArnSegments, userAcl)
    if (DEBUG_ENABLED) console.log('policyStmnts: ', JSON.stringify(policyStmnts, null, 2))

    let response = authorizerResponse(principalId, metadata, policyStmnts)
    if (DEBUG_ENABLED) console.log('response: ', JSON.stringify(response, null, 2))

    return response

  } catch (error) {
    if (DEBUG_ENABLED) console.log('error: ', JSON.stringify(error, null, 2))
  }

  return denyResponse(event.methodArn, principalId)
}

const getUserAcl = function(jwtDecoded) {
  let acl = {}
  let aclKeys = Object.keys(jwtDecoded).filter(key => key.match(/^custom:acl_/i))
  aclKeys.forEach(key => {
    let resource = key.replace(/^custom:acl_/i, '')
    let ids = jwtDecoded[key].split(',')
    acl[resource] = ids
  })
  return acl
}

const policyStatements = function (methodArnSegments, userAcl) {
  let statements = []

  Object.keys(userAcl).forEach(resource => {
    userAcl[resource].forEach(id => {
      let resourceArn = [
        methodArnSegments[0],
        resource,
        '*',
        id
      ].join('/')

      let policy = {
        Action: 'execute-api:Invoke',
        Effect: 'Allow',
        Resource: resourceArn
      }

      statements.push(policy)
    })
  })

  // conditionally add deny statement based on requested resource
  if (!userAcl[methodArnSegments[1]].includes(methodArnSegments[3])) {
    let policy = {
      Action: 'execute-api:Invoke',
      Effect: 'Deny',
      Resource: methodArnSegments.join('/')
    }
    statements.push(policy)
  }

  return statements
}

const authorizerResponse = function (principalId, metadata, policyStmnts) {
  return {
    "principalId": principalId,
    "policyDocument": {
      "Version": "2012-10-17",
      "Statement": policyStmnts
    },
    "context": metadata
  }
}

const denyResponse = function(resourceArn, principalId) {
  return {
    "principalId": principalId,
    "policyDocument": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "execute-api:Invoke",
          "Effect": "Deny",
          "Resource": resourceArn
        }
      ]
    }
  }
}
