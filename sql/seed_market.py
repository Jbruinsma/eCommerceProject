import mysql.connector
import random
import uuid
from datetime import datetime, timedelta
from tqdm import tqdm
import math
import os
from dotenv import load_dotenv

# --- 1. LOAD ENVIRONMENT VARIABLES ---
# Get the directory where this script is located (the /sql folder)
script_dir = os.path.dirname(os.path.abspath(__file__))

# Construct path: Go UP one level to project root, then DOWN into 'backend', then find '.env'
# Path becomes: .../eCommerceProject/backend/.env
env_path = os.path.join(script_dir, '..', 'backend', '.env')

# Load the .env file
loaded = load_dotenv(env_path)

# Debugging: Print where we are looking if it fails
if not loaded:
    print(f"⚠️  Warning: .env file not loaded.")
    print(f"   Tried looking at: {os.path.abspath(env_path)}")

# --- 2. CONFIGURATION ---
DB_CONFIG = {
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME'),
    'port': int(os.getenv('DB_PORT', 3306))
}

# Check if variables were actually found
if not DB_CONFIG['user'] or not DB_CONFIG['database']:
    print("\n❌ Error: Database credentials are missing.")
    print("   The .env file was found, but DB_USER or DB_NAME is empty.")
    print("   Please check your .env file content.")
    exit(1)

# Batch size for inserts
BATCH_SIZE = 5000


def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)


def fetch_existing_data(cursor):
    """Loads necessary IDs into memory to avoid DB lookups during generation."""
    print("⏳ Fetching existing data (Users, Products, Fees)...")

    # 1. Fetch Users
    cursor.execute("SELECT uuid FROM users")
    user_ids = [row[0] for row in cursor.fetchall()]

    # 2. Fetch Product Sizes AND Release Date
    # Returns: (product_id, size_id, retail_price, brand_id, name, release_date)
    cursor.execute("""
                   SELECT ps.product_id, ps.size_id, p.retail_price, p.brand_id, p.name, p.release_date
                   FROM products_sizes ps
                            JOIN products p ON ps.product_id = p.product_id
                   """)
    product_sizes = cursor.fetchall()

    # 3. Fetch Fee Structure
    cursor.execute("SELECT id, seller_fee_percentage, buyer_fee_percentage FROM fee_structures LIMIT 1")
    fee_data = cursor.fetchone()

    print(f"✅ Loaded {len(user_ids)} users and {len(product_sizes)} product variations.")
    return user_ids, product_sizes, fee_data


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

    # Storage for bulk inserts
    orders_buffer = []
    listings_buffer = []
    transactions_buffer = []
    addresses_buffer = []
    portfolio_buffer = []
    bids_buffer = []

    user_balance_deltas = {}

    # Market Start Date (The "founding" of your fake site)
    SITE_START_DATE = datetime.now() - timedelta(days=730)  # 2 years ago

    print("🚀 Starting Data Generation with Growth Simulation...")

    for prod_data in tqdm(product_sizes, desc="Processing Products"):
        p_id, s_id, retail, b_id, p_name, release_date = prod_data
        retail = float(retail) if retail else 150.00

        # Determine when this specific item could have started selling
        # It can't sell before the site existed, and it can't sell before it was released.
        item_start_date = SITE_START_DATE
        if release_date:
            # release_date might be a date object or string depending on connector
            if isinstance(release_date, str):
                release_date = datetime.strptime(release_date, '%Y-%m-%d')
            # Convert date to datetime
            if isinstance(release_date, datetime):
                pass
            else:
                release_date = datetime.combine(release_date, datetime.min.time())

            if release_date > item_start_date:
                item_start_date = release_date

        # If item released in the future (relative to now), skip sales
        if item_start_date > datetime.now():
            continue

        # Calculate the window of availability in days
        availability_window = (datetime.now() - item_start_date).days
        if availability_window < 1:
            availability_window = 1

        # Iterate Conditions
        for condition in ['new', 'used', 'worn']:

            # --- 1. PRICE LOGIC ---
            base_mult = 0.8 + (random.random() * 1.0)  # 0.8 - 1.8

            # Hype Logic
            if b_id in [13, 19, 3, 6, 7, 8]:
                base_mult = 1.2 + (random.random() * 1.8)

            hype_keywords = ['Travis Scott', 'The Ten', 'Lost & Found', 'Shattered Backboard', 'SB Dunk High', 'Kobe',
                             'Off-White']
            if any(k in p_name for k in hype_keywords):
                base_mult = 2.5 + (random.random() * 4.5)

            if condition == 'used':
                base_mult *= (0.5 + random.random() * 0.3)
            elif condition == 'worn':
                base_mult *= (0.2 + random.random() * 0.3)

            initial_price = round(retail * base_mult, 2)
            last_sale_price = initial_price

            # --- 2. GENERATE PAST SALES (Growth Curve) ---
            # Scale number of sales by how long the item has been out?
            # Optional: give newer items fewer sales? Let's keep it simple: 15-30 sales per item
            num_sales = random.randint(15, 30)

            # If the item is BRAND new (e.g. released last week), reduce sales count reasonably
            if availability_window < 30:
                num_sales = random.randint(1, 5)

            # Generate Dates with Linear Growth Bias
            sale_dates = []
            for _ in range(num_sales):
                # SQRT(Random) biases the result towards 1.0 (The end of the timeline)
                # This creates a "Linear Growth" curve for volume.
                normalized_time = math.sqrt(random.random())

                days_offset = int(normalized_time * availability_window)
                sale_date = item_start_date + timedelta(days=days_offset)

                # Add a random time of day
                sale_date = sale_date.replace(
                    hour=random.randint(0, 23),
                    minute=random.randint(0, 59),
                    second=random.randint(0, 59)
                )

                if sale_date > datetime.now():
                    sale_date = datetime.now()

                sale_dates.append(sale_date)

            # Sort dates chronologically so the price walk makes sense
            sale_dates.sort()

            for current_date in sale_dates:
                # Random Users
                buyer = random.choice(user_ids)
                seller = random.choice(user_ids)
                while seller == buyer:
                    seller = random.choice(user_ids)

                # Random Walk Price
                price_walk = 0.95 + (random.random() * 0.1)
                sale_price = round(last_sale_price * price_walk, 2)

                # Fees
                seller_fee = round(sale_price * seller_fee_pct, 2)
                seller_payout = sale_price - seller_fee
                buyer_fee = round(sale_price * buyer_fee_pct, 2)
                buyer_final = sale_price + buyer_fee

                order_id = str(uuid.uuid4())

                # BUFFERING
                orders_buffer.append((
                    order_id, buyer, seller, p_id, s_id, condition, sale_price,
                    buyer_fee, fee_id, buyer_final, seller_fee, fee_id, seller_payout,
                    'completed', current_date, current_date
                ))

                addresses_buffer.append((
                    buyer, order_id, 'shipping', 'Dummy User', '123 Market St',
                    'Fakeville', 'CA', '90210', 'USA'
                ))

                listings_buffer.append((
                    seller, p_id, s_id, 'sale', sale_price, fee_id, condition,
                    'sold', current_date, current_date
                ))

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

                portfolio_buffer.append((
                    str(uuid.uuid4()), buyer, p_id, s_id, current_date.date(), sale_price, condition
                ))

                last_sale_price = sale_price

            # --- 3. ACTIVE MARKET (Bids/Asks) ---
            # These are always "Recent", so we distribute them in the last 30 days
            for _ in range(random.randint(3, 5)):
                ask_seller = random.choice(user_ids)
                ask_price = round(last_sale_price * (1.02 + random.random() * 0.13), 2)
                ask_date = datetime.now() - timedelta(days=random.randint(0, 30))

                listings_buffer.append((
                    ask_seller, p_id, s_id, 'sale', ask_price, fee_id, condition,
                    'active', ask_date, ask_date
                ))

            for _ in range(random.randint(3, 5)):
                bid_buyer = random.choice(user_ids)
                bid_amount = round(last_sale_price * (0.85 + random.random() * 0.13), 2)
                bid_fee = round(bid_amount * buyer_fee_pct, 2)
                bid_total = bid_amount + bid_fee
                bid_date = datetime.now() - timedelta(days=random.randint(0, 30))

                bids_buffer.append((
                    str(uuid.uuid4()), bid_buyer, p_id, s_id, condition, bid_amount,
                    bid_fee, fee_id, bid_total, 'active', 'account_balance',
                    bid_date, bid_date
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