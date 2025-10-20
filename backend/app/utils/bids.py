import json

from app.utils.formatting import format_size_dict


def process_bids(bids_rows):
    processed_bids = []
    for bid in bids_rows:
        processed_bid = dict(bid)
        if 'listing_size' in processed_bid and isinstance(processed_bid['listing_size'], str):
            processed_bid['listing_size'] = format_size_dict(processed_bid['listing_size'])
        processed_bids.append(processed_bid)
    return processed_bids

def find_highest_bid(bids_rows):
    pass