# "The Valut": an E-Commerce Project

Built for CSCI 300, Fall 2025.

A full-stack e-commerce application built with **FastAPI** (Python) and **Vue 3** (JavaScript).

This project is configured for **Local Network Development**, meaning you can run the server on your laptop and access the full application from any device on your Wi-Fi (like your phone) without manual IP configuration.

## Project Structure

* **`backend/`**: The REST API handling database connections, authentication, and business logic.
* **`frontend/`**: The Vue 3 User Interface.

## Quick Start (Run Everything)

You need to run the backend and frontend simultaneously in two separate terminal windows.

### Prerequisites
* **MySQL Server** running locally.
* **Node.js** (v20+) and **Python** (v3.10+) installed.

### Step 1: Start the Backend
1.  Navigate to the backend folder: `cd backend`
2.  Create/Activate virtual environment:
    * **Win:** `python -m venv .venv` then `.venv\Scripts\activate`
    * **Mac/Linux:** `python3 -m venv .venv` then `source .venv/bin/activate`
3.  Install dependencies: `pip install -r requirements.txt`
4.  Start the server (Accessible on Wi-Fi):
    ```bash
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ```

### Step 2: Start the Frontend
1.  Navigate to the frontend folder: `cd frontend`
2.  Install dependencies: `npm install`
3.  Start the dev server:
    ```bash
    npm run dev
    ```

## How to Access on Mobile
1.  Look at the **Frontend Terminal** output. It will show a "Network" URL, e.g., `http://192.168.1.15:5173`.
2.  Enter that URL in your phone's browser.
3.  The app automatically detects your IP and connects to the backend API smoothly.