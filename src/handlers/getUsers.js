const AWS = require('aws-sdk');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const tableName = process.env.USERS_TABLE;

/**
 * Get all users
 */
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    try {
        // Scan DynamoDB table to get all users
        const params = {
            TableName: tableName
        };

        const result = await dynamodb.scan(params).promise();
        
        // Sort users by createdAt (newest first)
        const users = result.Items.sort((a, b) => {
            return new Date(b.createdAt) - new Date(a.createdAt);
        });

        console.log(`Retrieved ${users.length} users from DynamoDB`);

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
                body: users
            })
        };

    } catch (error) {
        console.error('Error getting users:', error);

        // Handle errors
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
