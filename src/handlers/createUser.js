const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const tableName = process.env.USERS_TABLE;

/**
 * Create a new user
 */
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    try {
        // Parse request body
        const body = JSON.parse(event.body || '{}');
        
        // Validate required fields
        if (!body.name || typeof body.name !== 'string' || body.name.trim() === '') {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
                },
                body: JSON.stringify({
                    statusCode: 400,
                    message: 'Name is required and must be a non-empty string'
                })
            };
        }

        // Create user object
        const user = {
            id: uuidv4(),
            name: body.name.trim(),
            createdAt: new Date().toISOString()
        };

        // Save to DynamoDB
        const params = {
            TableName: tableName,
            Item: user,
            ConditionExpression: 'attribute_not_exists(id)'
        };

        await dynamodb.put(params).promise();

        console.log('User created successfully:', user);

        // Return success response
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
            },
            body: JSON.stringify({
                statusCode: 200,
                body: user
            })
        };

    } catch (error) {
        console.error('Error creating user:', error);

        // Handle DynamoDB conditional check failed error
        if (error.code === 'ConditionalCheckFailedException') {
            return {
                statusCode: 409,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
                },
                body: JSON.stringify({
                    statusCode: 409,
                    message: 'User with this ID already exists'
                })
            };
        }

        // Handle other errors
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
            },
            body: JSON.stringify({
                statusCode: 500,
                message: 'Internal server error',
                error: error.message
            })
        };
    }
};
