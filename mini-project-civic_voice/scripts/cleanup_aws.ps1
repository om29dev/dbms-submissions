# CVI AWS Cloud Cleanup Script
# Warning: This will delete data in Cognito, DynamoDB, and S3.

$REGION = "us-east-1"
$USER_POOL_ID = "us-east-1_6wHybFEqZ"
$BUCKET = "civicvoicestorageeb20b-dev"
$TABLES = @("User-vcgcpsraobasnh6gyzgi5e5hde-dev", "UserDocument-vcgcpsraobasnh6gyzgi5e5hde-dev")

Write-Host "Starting AWS Cleanup for Region: $REGION" -ForegroundColor Yellow

# 1. Clear S3 Bucket
Write-Host "Cleaning S3 Bucket: $BUCKET..." -ForegroundColor Cyan
aws s3 rm "s3://$BUCKET" --recursive --region $REGION

# 2. Clear DynamoDB Tables
foreach ($TABLE in $TABLES) {
    Write-Host "Cleaning DynamoDB Table: $TABLE..." -ForegroundColor Cyan
    $ITEMS = aws dynamodb scan --table-name $TABLE --region $REGION --query "Items[*].[id.S]" --output text
    foreach ($ID in $ITEMS) {
        if ($ID -ne "None") {
            Write-Host "Deleting item $ID from $TABLE" -ForegroundColor Gray
            aws dynamodb delete-item --table-name $TABLE --key "{\`"id\`": {\`"S\`": \`"$ID\`"}}" --region $REGION
        }
    }
}

# 3. Clear Cognito Users
Write-Host "Cleaning Cognito User Pool: $USER_POOL_ID..." -ForegroundColor Cyan
$USERS = aws cognito-idp list-users --user-pool-id $USER_POOL_ID --region $REGION --query "Users[*].Username" --output text
foreach ($USER in $USERS) {
    if ($USER -ne "None") {
        Write-Host "Deleting user $USER from $USER_POOL_ID" -ForegroundColor Gray
        aws cognito-idp admin-delete-user --user-pool-id $USER_POOL_ID --username $USER --region $REGION
    }
}

Write-Host "Cleanup Completed!" -ForegroundColor Green
