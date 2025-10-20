import json


def format_size_dict(size_dict_str):
    if isinstance(size_dict_str, str):
        return json.loads(size_dict_str)
    return size_dict_str

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
        formatted_market_data[size][formatted_condition]["lowest_ask"] = price

    for bid_dict in bids_data:
        size = bid_dict["listing_size"]["size_value"]
        condition = bid_dict["product_condition"]
        formatted_condition = condition.capitalize()
        bid_amount = bid_dict["bid_amount"]
        formatted_market_data[size][formatted_condition]["highest_bid"] = bid_amount

    return formatted_market_data