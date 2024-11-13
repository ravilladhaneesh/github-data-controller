resource "aws_iam_role" "lambda-get-role" {
  name               = "lambda-role-for-get-function"
  assume_role_policy = <<EOF
    {
        
        "Statement" : [
            {
                "Effect": "Allow",
                "Principal" : {
                    "Service" : "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}



resource "aws_iam_policy" "cloudwatch-policy" {
  name   = "tf-lamda-s3-trigger"
  policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:GetObject"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:PutLogEvents",
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream"
                ],
                "Resource": "*"
            }
        ]
    }
    EOF

}


resource "aws_iam_role_policy_attachment" "lambda-get-role-attachment" {
  role       = aws_iam_role.lambda-get-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


resource "aws_iam_role_policy_attachment" "cloudwatch-policy-attachment" {

  role       = aws_iam_role.lambda-get-role.name
  policy_arn = aws_iam_policy.cloudwatch-policy.arn
}

// api gw permission for getData lambda
resource "aws_lambda_permission" "apigw_lambda_getData" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-get.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.test-api-tf.id}/*/${aws_api_gateway_method.get-api.http_method}${aws_api_gateway_resource.test-api-res-getdata.path}"
}

// api gw permission for getUsers lambda
resource "aws_lambda_permission" "apigw_lambda_getUsers" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-getUsers.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.test-api-tf.id}/*/${aws_api_gateway_method.getUsers-api-method.http_method}${aws_api_gateway_resource.test-api-res-getUsers.path}"
}

// api gw permission for putData lambda
resource "aws_lambda_permission" "apigw_lambda_putData" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_github_put.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.test-api-tf.id}/*/${aws_api_gateway_method.put-data-method.http_method}${aws_api_gateway_resource.api-put-res.path}"
}