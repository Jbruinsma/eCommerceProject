# E-Commerce Backend (FastAPI)

This is the REST API service powered by **FastAPI** and **SQLAlchemy (Async)**. It handles data persistence, user authentication, and transaction processing.

## Configuration
The application uses `python-dotenv` to manage settings.

1.  Create a `.env` file in this directory.
2.  Add your database credentials:
    ```ini
    DATABASE_URL=mysql+aiomysql://user:password@localhost/your_db_name
    SECRET_KEY=your_super_secret_key
    ```

## API Endpoints
The application (`app/main.py`) exposes the following modules:

* **Auth (`/auth`)**: Login and JWT token generation.
* **Users (`/users`)**: User profile management and registration.
* **Products (`/products`)**: Product catalog and inventory.
* **Listings (`/listings`)**: Marketplace listings created by users.
* **Bids (`/bids`)**: Auction and bidding system logic.
* **Orders (`/orders`)**: Order processing and history.
* **Portfolio (`/portfolio`)**: User asset tracking.
* **Admin (`/admin`)**: Administrative dashboard data.
* **Search (`/search`)**: Product search functionality.
* **Fees (`/fees`)**: Transaction fee calculations.

## 📡 Networking
The server is configured in `main.py` to allow Cross-Origin (CORS) requests from any origin (`allow_origins=["*"]`). This enables the frontend to communicate with the backend even when accessed via a different IP address on the local network.