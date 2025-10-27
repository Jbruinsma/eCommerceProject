import json


def format_size_dict(size_dict_str):
    if isinstance(size_dict_str, str):
        return json.loads(size_dict_str)
    return size_dict_str


def make_json_safe(data_input):
    """
    Converts a list of product dictionaries (or a JSON string representing it)
    into a JSON-serializable format.

    - Parses the 'sizes' JSON string into a list of objects.
    - Converts datetime.date objects to ISO format strings ('YYYY-MM-DD').
    - Converts Decimal objects to floats.
    """
    if isinstance(data_input, str):
        try:
            product_list = json.loads(data_input)
        except json.JSONDecodeError:
            print("Error: Input string is not valid JSON.")
            return []  # Return an empty list on failure
    elif isinstance(data_input, list):
        product_list = data_input
    else:
        print("Error: Invalid input type. Expected a list or a JSON string.")
        return []

    processed_list = []
    for product in product_list:
        # Now 'product' is guaranteed to be a dictionary
        processed_product = product.copy()

        # 1. Parse the 'sizes' string into a list
        if 'sizes' in processed_product and isinstance(processed_product['sizes'], str):
            try:
                processed_product['sizes'] = json.loads(processed_product['sizes'])
            except json.JSONDecodeError:
                print(f"Warning: Could not decode sizes for product_id {processed_product.get('product_id')}")
                processed_product['sizes'] = []

        # 2. Convert datetime.date to string
        if 'release_date' in processed_product and isinstance(processed_product['release_date'], datetime.date):
            processed_product['release_date'] = processed_product['release_date'].isoformat()

        # 3. Convert Decimal to float
        if 'retail_price' in processed_product and isinstance(processed_product['retail_price'], Decimal):
            processed_product['retail_price'] = float(processed_product['retail_price'])

        processed_list.append(processed_product)

    return processed_list

def format_lowest_ask(lowest_ask_dict):
    formatted_size_dict = format_size_dict(lowest_ask_dict.size_details)
    return {
        "listingId": lowest_ask_dict.listing_id,
        "sizeId": formatted_size_dict["size_id"],
        "sizeValue": formatted_size_dict["size_value"],
        "condition": lowest_ask_dict.item_condition,
        "price": lowest_ask_dict.price,
        "status": lowest_ask_dict.status,
        "created_at": lowest_ask_dict.created_at,
    }

def format_market_data(product_sizes, lowest_ask_info, bids_data):
    formatted_market_data = {}

    for size_dict in product_sizes:
        size = size_dict["size_value"]

        default_data = {
            "lowest_ask": None,
            "highest_bid": None
        }

        formatted_market_data[size] = {
            "New": default_data.copy(),
            "Used": default_data.copy(),
            "Worn": default_data.copy()
        }

    for lowest_ask_dict in lowest_ask_info:
        size_details = format_size_dict(lowest_ask_dict["size_details"])
        size = size_details["size_value"]
        condition = lowest_ask_dict["item_condition"]
        formatted_condition = condition.capitalize()
        price = lowest_ask_dict["price"]
        formatted_market_data[size][formatted_condition]["lowest_ask"] = {
            "price": price,
            "listingId": lowest_ask_dict["listing_id"]
        }

    for bid_dict in bids_data:
        size = bid_dict["listing_size"]["size_value"]
        condition = bid_dict["product_condition"]
        formatted_condition = condition.capitalize()
        bid_amount = bid_dict["bid_amount"]
        formatted_market_data[size][formatted_condition]["highest_bid"] = bid_amount

    return formatted_market_data