#!/usr/bin/env python

import json
import os
from http import HTTPStatus
from typing import Any

import boto3
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import (
    APIGatewayHttpResolver,
    Response,
    content_types,
)
from aws_lambda_powertools.event_handler.exceptions import (
    BadRequestError,
    NotFoundError,
)
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()
tracer = Tracer()
app = APIGatewayHttpResolver()
dynamodb = boto3.client("dynamodb")


@app.delete("/items/<item_id>")
@tracer.capture_method
def delete_item(item_id: str) -> Response:
    """Delete an item from the DynamoDB table by item ID.

    Args:
        item_id (str): The ID of the item to be deleted.

    Returns:
        Response: A JSON response indicating whether the item was successfully deleted.
    """
    logger.info("Deleting item with id: %s", item_id)
    dynamodb.delete_item(
        TableName=os.environ["DYNAMODB_TABLE_NAME"],
        Key={
            "id": {"S": item_id},
        },
    )
    return Response(
        status_code=HTTPStatus.OK.value,                # 200
        content_type=content_types.APPLICATION_JSON,    # application/json
        body=json.dumps({"message": f"Deleted item {item_id}"}),
    )


@app.get("/items/<item_id>")
@tracer.capture_method
def get_item(item_id: str) -> Response:
    """Retrieve a specific item from the DynamoDB table by item ID.

    Args:
        item_id (str): The ID of the item to be retrieved.

    Returns:
        Response: A JSON response containing the item data if found,
        otherwise a 404 Not Found response.
    """
    logger.info("Fetching item with id: %s", item_id)
    result = dynamodb.get_item(
        TableName=os.environ["DYNAMODB_TABLE_NAME"],
        Key={
            "id": {"S": item_id},
        },
    )
    item = result.get("Item")
    if not item:
        raise NotFoundError(f"Item {item_id} not found")
    else:
        response_body = {
            "id": item["id"]["S"],
            "name": item["name"]["S"],
            "price": float(item["price"]["N"]),
        }
        return Response(
            status_code=HTTPStatus.OK.value,              # 200
            content_type=content_types.APPLICATION_JSON,  # application/json
            body=json.dumps(response_body),
        )


@app.get("/items")
@tracer.capture_method
def get_all_items() -> Response:
    """Retrieve all items from the DynamoDB table.

    Returns:
        Response: A JSON response containing a list of all items in the table.
    """
    logger.info("Fetching all items")
    result = dynamodb.scan(TableName=os.environ["DYNAMODB_TABLE_NAME"])
    items = result.get("Items", [])
    response_body = [
        {
            "id": i["id"]["S"],
            "name": i["name"]["S"],
            "price": float(i["price"]["N"]),
        }
        for i in items
    ]
    return Response(
        status_code=HTTPStatus.OK.value,                # 200
        content_type=content_types.APPLICATION_JSON,    # application/json
        body=json.dumps(response_body),
    )


@app.put("/items")
@tracer.capture_method
def put_item() -> Response:
    """Add or update an item in the DynamoDB table.

    The request body must contain 'id', 'name', and 'price' fields.
    If any of these fields are missing, a 400 Bad Request response is returned.

    Returns:
        Response: A JSON response with a success message, or a 400 Bad Request.
    """
    body = app.current_event.json_body
    if any((k not in body) for k in ("id", "name", "price")):
        raise BadRequestError("Missing required fields: id, name, price")
    else:
        logger.info("Putting a new or updated item with id: %s", body["id"])
        dynamodb.put_item(
            TableName=os.environ["DYNAMODB_TABLE_NAME"],
            Item={
                "id": {"S": body["id"]},
                "name": {"S": body["name"]},
                "price": {"N": str(body["price"])},
            },
        )
        return Response(
            status_code=HTTPStatus.OK.value,                # 200
            content_type=content_types.APPLICATION_JSON,    # application/json
            body=json.dumps({"message": f"Put item {body['id']}"}),
        )


@logger.inject_lambda_context(
    correlation_id_path=correlation_paths.API_GATEWAY_HTTP, log_event=True
)
@tracer.capture_lambda_handler
def lambda_handler(event: dict[str, Any], context: LambdaContext) -> dict[str, Any]:
    """AWS Lambda function handler.

    This function uses APIGatewayHttpResolver to handle incoming API Gateway events
    and route requests to the appropriate endpoints.

    Args:
        event (dict[str, Any]): The event data passed by AWS Lambda.
        context (LambdaContext): The runtime information provided by AWS Lambda.

    Returns:
        dict[str, Any]: A dictionary representing the API Gateway response.
    """
    logger.info("Event received")
    return app.resolve(event, context)
