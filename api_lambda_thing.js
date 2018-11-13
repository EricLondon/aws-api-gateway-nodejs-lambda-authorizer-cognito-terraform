'use strict';

const AWS_REGION_STRING = process.env.AWS_REGION || 'us-east-1'
const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID
const S3_BUCKET = process.env.S3_BUCKET

const AWS = require('aws-sdk')
AWS.config.update({
  region: AWS_REGION_STRING
});
const s3 = new AWS.S3()

exports.handler = (event, context, callback) => {
  return main(event).then(function (result) {
    callback(null, result);
  }).catch(function (error) {
    callback(error);
  });
};

const main = async (event) => {
  // debug
  console.log('event', JSON.stringify(event, null, 2))

  let resourceType = event.requestContext.stage
  let resourceId = event.pathParameters.proxy
  let authorizer = event.requestContext.authorizer
  let httpMethod = event.httpMethod.toUpperCase()

  // debug
  console.log('S3_BUCKET', S3_BUCKET)
  console.log('resourceType', JSON.stringify(resourceType, null, 2))
  console.log('resourceId', JSON.stringify(resourceId, null, 2))
  console.log('authorizer', JSON.stringify(authorizer, null, 2))
  console.log('httpMethod', JSON.stringify(httpMethod, null, 2))

  try {

    switch (httpMethod) {
      case 'GET':
        let fileContexts = await fetchS3File(S3_BUCKET, `${resourceType}/${resourceId}.json`)
        return {
          statusCode: 200,
          headers: {},
          body: fileContexts
        }
        break

      default:
        return {
          statusCode: 501,
          headers: {},
          body: {
            message: "Not Implemented"
          }
        }
    }

  } catch (error) {
    console.log('error', JSON.stringify(error, null, 2))

    return {
      statusCode: error.statusCode,
      headers: {},
      body: {
        message: error.message
      }
    }
  }

}

const fetchS3File = async (bucket, key) => {
  // debug
  console.log('fetchS3File')
  console.log('bucket', bucket)
  console.log('key', key)

  let params = {
    Bucket: bucket,
    Key: key
  }
  let response = await s3.getObject(params).promise()
  console.log('response', JSON.stringify(response, null, 2))
  return response.Body.toString('utf-8')
}
