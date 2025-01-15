#!/usr/bin/env python

import json
import os
from decimal import Decimal
from functools import cache
from typing import Any

import boto3
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler.api_gateway import (
    APIGatewayHttpResolver,
    Response,
)
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()
tracer = Tracer()
app = APIGatewayHttpResolver()


@cache
def _instantiate_dynamodb_table() -> Any:
    """Instantiate a DynamoDB table resource.

    Returns:
        Any: DynamoDB Table resource.

    """
    table_name = os.environ.get("DYNAMODB_TABLE_NAME", "http-crud-tutorial-items")
    return boto3.resource("dynamodb").Table(table_name)


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
    table = _instantiate_dynamodb_table()
    table.delete_item(Key={"id": item_id})
    return Response(
        status_code=200,
        content_type="application/json",
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
    table = _instantiate_dynamodb_table()
    result = table.get_item(Key={"id": item_id})
    item = result.get("Item")
    if not item:
        return Response(
            status_code=404,
            content_type="application/json",
            body=json.dumps({"message": f"Item {item_id} not found"}),
        )
    else:
        response_body = {
            "id": item["id"],
            "name": item["name"],
            "price": float(item["price"]),
        }
        return Response(
            status_code=200,
            content_type="application/json",
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
    table = _instantiate_dynamodb_table()
    result = table.scan()
    items = result.get("Items", [])
    response_body = [
        {"id": item["id"], "name": item["name"], "price": float(item["price"])}
        for item in items
    ]
    return Response(
        status_code=200, content_type="application/json", body=json.dumps(response_body)
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
    if [k for k in ("id", "name", "price") if k not in body]:
        logger.warning(
            "Request body is missing one or more required fields: id, name, price"
        )
        return Response(
            status_code=400,
            content_type="application/json",
            body=json.dumps({"message": "Missing required fields: id, name, price"}),
        )
    else:
        logger.info("Putting a new or updated item with id: %s", body["id"])
        table = _instantiate_dynamodb_table()
        table.put_item(
            Item={
                "id": body["id"],
                "name": body["name"],
                "price": Decimal(str(body["price"])),
            }
        )
        return Response(
            status_code=200,
            content_type="application/json",
            body=json.dumps({"message": f"Put item {body['id']}"}),
        )


@logger.inject_lambda_context(log_event=True)
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
