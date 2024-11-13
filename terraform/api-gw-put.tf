resource "aws_api_gateway_resource" "api-put-res" {
  parent_id   = aws_api_gateway_rest_api.test-api-tf.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
  path_part   = "putData"
}

resource "aws_api_gateway_method" "put-data-method" {
  resource_id   = aws_api_gateway_resource.api-put-res.id
  rest_api_id   = aws_api_gateway_rest_api.test-api-tf.id
  authorization = "AWS_IAM"
  http_method   = "POST"
}

resource "aws_api_gateway_integration" "api-gw-put-integration" {
  resource_id             = aws_api_gateway_resource.api-put-res.id
  rest_api_id             = aws_api_gateway_rest_api.test-api-tf.id
  type                    = "AWS"
  http_method             = aws_api_gateway_method.put-data-method.http_method
  uri                     = aws_lambda_function.lambda_github_put.invoke_arn
  integration_http_method = "POST"

  request_templates = {
    "application/json" = <<EOF
    {
      "body" : $input.json('$')
    }
    EOF
  }
}


resource "aws_api_gateway_method_response" "putdata-response_200" {
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
  resource_id = aws_api_gateway_resource.api-put-res.id
  http_method = aws_api_gateway_method.put-data-method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "putdata-response-integration" {
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
  resource_id = aws_api_gateway_resource.api-put-res.id
  http_method = aws_api_gateway_method.put-data-method.http_method
  status_code = aws_api_gateway_method_response.putdata-response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
    
    EOF
  }

  depends_on = [aws_api_gateway_integration.api-gw-put-integration]
}