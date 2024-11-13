
resource "aws_api_gateway_resource" "test-api-res-getdata" {
  parent_id   = aws_api_gateway_rest_api.test-api-tf.root_resource_id
  path_part   = "getData"
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
}

resource "aws_api_gateway_method" "get-api" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.test-api-res-getdata.id
  rest_api_id   = aws_api_gateway_rest_api.test-api-tf.id

  request_parameters = {
    "method.request.querystring.username" = true
  }
}

resource "aws_api_gateway_integration" "getdata-intergration" {
  rest_api_id             = aws_api_gateway_rest_api.test-api-tf.id
  resource_id             = aws_api_gateway_resource.test-api-res-getdata.id
  http_method             = aws_api_gateway_method.get-api.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda-get.invoke_arn

  request_templates = {
    "application/json" = <<EOF
    #set($inputRoot = $input.path('$'))
    {
     "username": "$input.params('username')" 
    }
  EOF
  }
}

resource "aws_api_gateway_method_response" "getdata-response_200" {
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
  resource_id = aws_api_gateway_resource.test-api-res-getdata.id
  http_method = aws_api_gateway_method.get-api.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "getdata-response-integration" {
  rest_api_id = aws_api_gateway_rest_api.test-api-tf.id
  resource_id = aws_api_gateway_resource.test-api-res-getdata.id
  http_method = aws_api_gateway_method.get-api.http_method
  status_code = aws_api_gateway_method_response.getdata-response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
    
    EOF
  }

  depends_on = [aws_api_gateway_integration.getdata-intergration]
}