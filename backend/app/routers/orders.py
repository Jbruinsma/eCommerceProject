from fastapi import APIRouter, Depends
from ..pydantic_models.error_message import ErrorMessage

from ..db import get_session
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ..pydantic_models.new_order import NewOrder

router = APIRouter(prefix="/orders", tags=["orders"])

@router.post("/{listing_id}")
async def fulfil_order(listing_id: int, new_order_summary: NewOrder, session: AsyncSession = Depends(get_session)):
    if not listing_id:
        return ErrorMessage(message="Listing ID is required", error="MissingListingID")

    if listing_id != new_order_summary.listing_id:
        return ErrorMessage(message="Listing ID does not match shipping info listing ID", error="ListingIDMismatch")

    address = new_order_summary.shipping_info

    statement = text("CALL retrieveSpecificActiveListing(:input_listing_id);")
    result = await session.execute(statement, {"input_listing_id": int(listing_id)})
    row = result.mappings().first()

    if not row:
        return ErrorMessage(message="Listing not found", error="ListingNotFound")

    listing_summary = dict(row)

    buyer_id = new_order_summary.buyer_id
    seller_id = listing_summary['user_id']

    if buyer_id == seller_id:
        return ErrorMessage(message="Buyer and seller cannot be the same", error="BuyerAndSellerCannotBeSame")

    listing_ask_price = listing_summary['price']

    if new_order_summary.purchase_price != listing_ask_price:
        return ErrorMessage(message="Purchase price does not match listing ask price", error="PurchasePriceMismatch")

    statement = text("CALL addAddress(:input_user_id, :input_name, :input_address_line1, :input_address_line2, :input_city, :input_state, :input_zip_code, :input_country);")
    await session.execute(statement, {
        "input_user_id": new_order_summary.buyer_id,
        "input_name": address.name,
        "input_address_line1": address.address_line_1,
        "input_address_line2": address.address_line_2,
        "input_city": address.city,
        "input_state": address.state,
        "input_zip_code": address.zip_code,
        "input_country": address.country,
    })
    await session.commit()

    statement = text("CALL newOrder(:input_buyer_id, :input_listing_id, :input_transaction_fee, :input_payment_method)")
    result = await session.execute(statement, {
        "input_buyer_id": new_order_summary.buyer_id,
        "input_listing_id": new_order_summary.listing_id,
        "input_transaction_fee": new_order_summary.transaction_fee,
        "input_payment_method": new_order_summary.payment_method,
    })
    await session.commit()

    new_order = result.mappings().first()
    if not new_order:
        return ErrorMessage(message="Order could not be fulfilled", error="OrderFulfillmentFailed")

    return dict(new_order)

@router.get("/{user_uuid}")
async def orders(user_uuid: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    statement = text("CALL retrieveAllOrdersByUserId(:input_user_id);")
    result = await session.execute(statement, {"input_user_id": user_uuid})
    rows = result.mappings().all()

    if not rows:
        return ErrorMessage(message="No orders found", error="NoOrdersFound")

    return list(rows)

@router.get("/{user_uuid}/{order_id}")
async def order_details(user_uuid: str, order_id: str, session: AsyncSession = Depends(get_session)):
    if not user_uuid:
        return ErrorMessage(message="User UUID is required", error="MissingUserUUID")

    if not order_id:
        return ErrorMessage(message="Order ID is required", error="MissingOrderID")

    statement = text("CALL retrieveOrderById(:input_order_id);")
    result = await session.execute(statement, {"input_order_id": order_id})
    order_row = result.mappings().first()

    print(order_row)

    # {
    #     'order_id': '3a400dad-af76-11f0-9011-96302f5b3d1f',
    #     'buyer_id': '23d25655-af53-11f0-9011-96302f5b3d1f',
    #     'seller_id': '963987dc-af53-11f0-9011-96302f5b3d1f',
    #     'order_status': 'pending'
    #     'buyer_transaction_fee': Decimal('4.50'),
    #     'buyer_final_price': Decimal('304.50'),
    #     'seller_transaction_fee': Decimal('18.00'),
    #     'seller_final_payout': Decimal('282.00'),
    #     'product_id': 1,
    #     'size_id': 13,
    #     'size': '10',
    #     'brand_id': 12,
    #     'brand_name': 'Nike',
    #     'product_name': 'Dunk Low "Panda"',
    #     'product_sku': 'DD1391-100',
    #     'product_colorway': 'White/Black-White',
    #     'product_image_url': 'https://images.stockx.com/images/Nike-Dunk-Low-Retro-White-Black-2021-Product.jpg',
    #     'product_retail_price': Decimal('110.00'),
    #     'address_name': 'Justino B',
    #     'address_line_1': '123 Main St',
    #     'address_line_2': 'Apt 4B',
    #     'city': 'Springfield',
    #     'state': 'IL',
    #     'zip_code': '62701',
    #     'country': 'USA',
    #     'created_at': datetime.datetime(2025, 10, 22, 14, 37, 56),
    #     'updated_at': datetime.datetime(2025, 10, 22, 14, 37, 56)
    # }

    role = None
    if user_uuid == order_row['buyer_id']: role = 'buyer'
    elif user_uuid == order_row['seller_id']: role = 'seller'

    core_payload = {
        "role": role,
        "orderId": order_row.order_id,
        "orderStatus": order_row.order_status,
        "createdAt": order_row.created_at,
        "lastUpdatedAt": order_row.updated_at,
        "productDetails": {
            "productId": order_row.product_id,
            "sizeId": order_row.size_id,
            "sizeValue": order_row.size,
            "brandId": order_row.brand_id,
            "brandName": order_row.brand_name,
            "productName": order_row.product_name,
            "productSku": order_row.product_sku,
            "productColorway": order_row.product_colorway,
            "productImageUrl": order_row.product_image_url,
            "productRetailPrice": order_row.product_retail_price,
        }
    }

    if role == 'buyer':
        core_payload['buyerDetails'] = {
            "address":{
                "nameOnAddress": order_row.address_name,
                "addressLine1": order_row.address_line_1,
                "addressLine2": order_row.address_line_2,
                "city": order_row.city,
                "state": order_row.state,
                "zipCode": order_row.zip_code,
                "country": order_row.country,
            },
            "transactionFee": order_row.buyer_transaction_fee,
            "finalPrice": order_row.buyer_final_price
        }

    if role == 'seller':
        core_payload['sellerDetails'] = {
            "transactionFee": order_row.seller_transaction_fee,
            "finalPayout": order_row.seller_final_payout
        }

    return core_payload