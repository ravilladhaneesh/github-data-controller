resource "aws_api_gateway_deployment" "api-gw-deploy-test" {
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.test-api-res-getdata.id,
      aws_api_gateway_method.get-api.id,
      aws_api_gateway_integration.getdata-intergration.id,
      aws_api_gateway_method_response.getdata-response_200.id,
      aws_api_gateway_integration_response.getdata-response-integration.id,

      aws_api_gateway_resource.test-api-res-getUsers.id,
      aws_api_gateway_method.getUsers-api-method.id,
      aws_api_gateway_integration.getUsers-intergration.id,
      aws_api_gateway_method_response.getUsers-response_200.id,
      aws_api_gateway_integration_response.getUsers-response-integration.id,

      aws_api_gateway_resource.api-put-res.id,
      aws_api_gateway_method.put-data-method.id,
      aws_api_gateway_integration.api-gw-put-integration.id,
      aws_api_gateway_method_response.putdata-response_200.id,
      aws_api_gateway_integration_response.putdata-response-integration.id,

      aws_api_gateway_rest_api_policy.api-gw-test-resource-policy

    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "api-gw-test-stage" {
  deployment_id = aws_api_gateway_deployment.api-gw-deploy-test.id
  rest_api_id   = aws_api_gateway_rest_api.test-api-tf.id
  stage_name    = "test"
}


resource "aws_api_gateway_rest_api_policy" "api-gw-test-resource-policy" {
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${var.github_assume_role_arn}",
          "${var.local_user_arn}",
          "${var.role_arn}"
        ]
      },
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.test-api-tf.execution_arn}/test/POST/*"
    },
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.test-api-tf.execution_arn}/*"
    }
  ]
}
EOF
}