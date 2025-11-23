import mysql.connector
import random
import uuid
from datetime import datetime, timedelta
from tqdm import tqdm
import math
import os
from dotenv import load_dotenv

# --- 1. LOAD ENVIRONMENT VARIABLES ---
script_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(script_dir, '..', 'backend', '.env')
loaded = load_dotenv(env_path)

if not loaded:
    print(f"⚠️  Warning: .env file not loaded from {env_path}")

# --- 2. CONFIGURATION ---
DB_CONFIG = {
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME'),
    'port': int(os.getenv('DB_PORT', 3306))
}

if not DB_CONFIG['user'] or not DB_CONFIG['database']:
    print("\n❌ Error: Database credentials are missing.")
    exit(1)

BATCH_SIZE = 5000


def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)


def fetch_existing_data(cursor):
    print("⏳ Fetching existing data (Users, Products, Fees)...")

    cursor.execute("SELECT uuid FROM users")
    user_ids = [row[0] for row in cursor.fetchall()]

    # Fetch Product Sizes + Release Date
    cursor.execute("""
                   SELECT ps.product_id, ps.size_id, p.retail_price, p.brand_id, p.name, p.release_date
                   FROM products_sizes ps
                            JOIN products p ON ps.product_id = p.product_id
                   """)
    product_sizes = cursor.fetchall()

    cursor.execute("SELECT id, seller_fee_percentage, buyer_fee_percentage FROM fee_structures LIMIT 1")
    fee_data = cursor.fetchone()

    print(f"✅ Loaded {len(user_ids)} users and {len(product_sizes)} product variations.")
    return user_ids, product_sizes, fee_data


def calculate_hype_score(brand_id, product_name):
    """
    Returns a multiplier (1.0 to 10.0) representing demand/volume.
    """
    score = 1.0

    # Brand Multipliers (Based on IDs in your dummy_data.sql)
    # Nike(12), Jordan(8), Supreme(19), Off-White(13), Balenciaga(3), BAPE(4)
    hype_brands = {
        8: 3.0,  # Jordan
        12: 1.5,  # Nike (General)
        13: 4.0,  # Off-White
        19: 3.5,  # Supreme
        3: 2.0,  # Balenciaga
        4: 2.0,  # BAPE
        9: 2.5,  # Kith
        7: 2.0,  # Fear of God
        18: 2.5,  # Stussy
    }

    if brand_id in hype_brands:
        score = hype_brands[brand_id]

    # Keyword Multipliers (The "Grail" Factor)
    name_lower = product_name.lower()
    if 'travis scott' in name_lower: score *= 3.0
    if 'off-white' in name_lower: score *= 2.5
    if 'kobe' in name_lower: score *= 2.5
    if 'dunk' in name_lower: score *= 1.5
    if 'box logo' in name_lower: score *= 2.0
    if 'lost & found' in name_lower: score *= 2.0
    if 'black cat' in name_lower: score *= 2.0
    if 'yeezy' in name_lower: score *= 2.0

    # Random "Viral" Factor (Some random items just blow up)
    if random.random() < 0.05:  # 5% chance
        score *= 3.0

    return score


def generate_market_data():
    conn = get_db_connection()
    cursor = conn.cursor()

    user_ids, product_sizes, fee_data = fetch_existing_data(cursor)

    if not user_ids:
        print("❌ No users found! Run the SQL script to create users first.")
        return

    fee_id, seller_fee_pct, buyer_fee_pct = fee_data
    seller_fee_pct = float(seller_fee_pct)
    buyer_fee_pct = float(buyer_fee_pct)

    # Buffers
    orders_buffer = []
    listings_buffer = []
    transactions_buffer = []
    addresses_buffer = []
    portfolio_buffer = []
    bids_buffer = []

    user_balance_deltas = {}

    # Start of "The Site" history
    SITE_START_DATE = datetime.now() - timedelta(days=730)

    print("🚀 Starting Realistic Market Simulation...")

    for prod_data in tqdm(product_sizes, desc="Processing Market"):
        p_id, s_id, retail, b_id, p_name, release_date = prod_data
        retail = float(retail) if retail else 150.00

        # 1. Determine Timeline
        item_start_date = SITE_START_DATE
        if release_date:
            if isinstance(release_date, str):
                release_date = datetime.strptime(release_date, '%Y-%m-%d')
            if not isinstance(release_date, datetime):
                release_date = datetime.combine(release_date, datetime.min.time())

            if release_date > item_start_date:
                item_start_date = release_date

        # Skip future items
        if item_start_date > datetime.now():
            continue

        days_available = (datetime.now() - item_start_date).days
        if days_available < 1: days_available = 1

        # 2. Determine Volume based on Hype
        hype_mult = calculate_hype_score(b_id, p_name)

        # Base volume: 2 to 12 sales per year
        base_sales = random.randint(2, 12) * (days_available / 365.0)

        # Apply Hype Multiplier
        target_sales = int(base_sales * hype_mult)

        # Floor and Ceiling
        if target_sales < 1: target_sales = 1  # At least 1 sale if it's been out
        if target_sales > 600: target_sales = 600  # Cap to prevent explosion

        # If item is very new (<30 days), scale down strictly but allow high freq
        if days_available < 30:
            target_sales = int(target_sales * (days_available / 30.0))
            if target_sales < 1: target_sales = 1

        # Iterate Conditions
        for condition in ['new', 'used', 'worn']:
            # Condition rarity: New is most common, Worn is least
            if condition == 'new':
                condition_sales = int(target_sales * 0.7)
            elif condition == 'used':
                condition_sales = int(target_sales * 0.25)
            else:
                condition_sales = int(target_sales * 0.05)

            if condition_sales == 0 and random.random() < 0.3:
                condition_sales = 1

            # --- Price Logic ---
            base_price_mult = 0.8 + (random.random() * 0.6)  # Base volatility
            if hype_mult > 2.0:
                base_price_mult = 1.5 + (random.random() * 2.0)  # Hype creates premium

            if condition == 'used': base_price_mult *= 0.7
            if condition == 'worn': base_price_mult *= 0.4

            last_sale_price = round(retail * base_price_mult, 2)

            # --- Generate Sales ---
            sale_dates = []
            for _ in range(condition_sales):
                # Linear Growth Distribution (Square Root)
                # 0.0 = Start Date, 1.0 = Today
                normalized_time = math.sqrt(random.random())

                days_offset = int(normalized_time * days_available)
                sale_date = item_start_date + timedelta(days=days_offset)

                # Add random time
                sale_date = sale_date.replace(
                    hour=random.randint(8, 22),  # Sales mostly during day
                    minute=random.randint(0, 59),
                    second=random.randint(0, 59)
                )

                if sale_date > datetime.now(): sale_date = datetime.now()
                sale_dates.append(sale_date)

            sale_dates.sort()

            for current_date in sale_dates:
                buyer = random.choice(user_ids)
                seller = random.choice(user_ids)
                while seller == buyer: seller = random.choice(user_ids)

                # Price Walk (Brownian Motion)
                # Hype items have more volatility (0.08 vs 0.03)
                volatility = 0.08 if hype_mult > 2 else 0.03
                change_pct = 1.0 + ((random.random() - 0.5) * 2 * volatility)

                sale_price = round(last_sale_price * change_pct, 2)
                if sale_price < 10: sale_price = 10  # Minimum price

                # Calc Fees
                seller_fee = round(sale_price * seller_fee_pct, 2)
                seller_payout = sale_price - seller_fee
                buyer_fee = round(sale_price * buyer_fee_pct, 2)
                buyer_final = sale_price + buyer_fee

                order_id = str(uuid.uuid4())

                orders_buffer.append((
                    order_id, buyer, seller, p_id, s_id, condition, sale_price,
                    buyer_fee, fee_id, buyer_final, seller_fee, fee_id, seller_payout,
                    'completed', current_date, current_date
                ))

                # Only add addresses for ~30% of orders to save DB space/time,
                # or 100% if you need them for the frontend.
                # Assuming you need them for order details:
                addresses_buffer.append((
                    buyer, order_id, 'shipping', 'Dummy Buyer', '123 Street',
                    'City', 'ST', '00000', 'USA'
                ))

                # Listings (Historical Sold)
                listings_buffer.append((
                    seller, p_id, s_id, 'sale', sale_price, fee_id, condition,
                    'sold', current_date, current_date
                ))

                # Transactions
                transactions_buffer.append((
                    buyer, order_id, -buyer_final, 'completed', 'account_balance',
                    'purchase_funds', current_date
                ))
                user_balance_deltas[buyer] = user_balance_deltas.get(buyer, 0.0) - buyer_final

                payout_date = current_date + timedelta(days=1)
                transactions_buffer.append((
                    seller, order_id, seller_payout, 'completed', 'account_balance',
                    'sale_proceeds', payout_date
                ))
                user_balance_deltas[seller] = user_balance_deltas.get(seller, 0.0) + seller_payout

                # Only ~20% of buyers keep it in "Portfolio" (Active collection)
                if random.random() < 0.2:
                    portfolio_buffer.append((
                        str(uuid.uuid4()), buyer, p_id, s_id, current_date.date(), sale_price, condition
                    ))

                last_sale_price = sale_price

            # --- Active Market (Bids/Asks) ---
            # More active listings for hype items
            num_listings = random.randint(1, 3)
            if hype_mult > 3: num_listings = random.randint(5, 12)

            for _ in range(num_listings):
                # Ask
                ask_price = round(last_sale_price * (1.0 + random.random() * 0.15), 2)
                listings_buffer.append((
                    random.choice(user_ids), p_id, s_id, 'sale', ask_price, fee_id, condition,
                    'active', datetime.now(), datetime.now()
                ))

                # Bid
                bid_price = round(last_sale_price * (1.0 - random.random() * 0.15), 2)
                bid_fee = round(bid_price * buyer_fee_pct, 2)
                bids_buffer.append((
                    str(uuid.uuid4()), random.choice(user_ids), p_id, s_id, condition, bid_price,
                    bid_fee, fee_id, bid_price + bid_fee, 'active', 'account_balance',
                    datetime.now(), datetime.now()
                ))

    # --- 4. EXECUTE ---
    def flush_buffer(sql, data, name):
        if not data: return
        print(f"   Writing {len(data)} {name}...")
        for i in range(0, len(data), BATCH_SIZE):
            cursor.executemany(sql, data[i:i + BATCH_SIZE])
        conn.commit()

    print("\n💾 Flushing buffers to database...")

    flush_buffer("""
                 INSERT INTO orders (order_id, buyer_id, seller_id, product_id, size_id, product_condition,
                                     sale_price, buyer_transaction_fee, buyer_fee_structure_id, buyer_final_price,
                                     seller_transaction_fee, seller_fee_structure_id, seller_final_payout,
                                     order_status, created_at, updated_at)
                 VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                 """, orders_buffer, "Orders")

    flush_buffer("""
                 INSERT INTO addresses (user_id, order_id, purpose, name, address_line_1, city, state, zip_code,
                                        country)
                 VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                 """, addresses_buffer, "Addresses")

    flush_buffer("""
                 INSERT INTO listings (user_id, product_id, size_id, listing_type, price, fee_structure_id,
                                       item_condition, status, created_at, updated_at)
                 VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                 """, listings_buffer, "Listings")

    flush_buffer("""
                 INSERT INTO transactions (user_id, order_id, amount, transaction_status, payment_origin,
                                           payment_purpose, created_at)
                 VALUES (%s, %s, %s, %s, %s, %s, %s)
                 """, transactions_buffer, "Transactions")

    flush_buffer("""
                 INSERT INTO portfolio_items (portfolio_item_id, user_id, product_id, size_id, acquisition_date,
                                              acquisition_price, item_condition)
                 VALUES (%s, %s, %s, %s, %s, %s, %s)
                 """, portfolio_buffer, "Portfolio Items")

    flush_buffer("""
                 INSERT INTO bids (bid_id, user_id, product_id, size_id, product_condition, bid_amount, transaction_fee,
                                   fee_structure_id, total_bid_amount, bid_status, payment_origin, created_at,
                                   updated_at)
                 VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                 """, bids_buffer, "Bids")

    print("\n💰 Updating User Balances...")
    balance_updates = [(amt, uid) for uid, amt in user_balance_deltas.items()]
    cursor.executemany("""
                       UPDATE account_balance
                       SET balance = balance + %s
                       WHERE user_id = %s
                       """, balance_updates)
    conn.commit()

    cursor.close()
    conn.close()
    print("\n✅ Market Seeding Complete!")


if __name__ == "__main__":
    generate_market_data()