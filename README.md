# "The Valut": an E-Commerce Project

Built for CSCI 300, Fall 2025.

A full-stack e-commerce platform built with **FastAPI** (Python) and **Vue 3** (JavaScript). This application supports user authentication, product listings, a bidding system, portfolio management, and order processing.

It is configured for **Local Network Development**, allowing you to run the server on your laptop and access the full application (frontend and backend) from any device on your Wi-Fi network (like your phone).

## Tech Stack

* **Backend:** Python 3.10+, FastAPI, SQLAlchemy (Async), MySQL (aiomysql)
* **Frontend:** Vue 3, Vite, Pinia (State Management), Tailwind CSS (implied/if used)
* **Database:** MySQL

## Quick Start Guide

### 1. Database Setup
Ensure you have a local MySQL server running and create a database (e.g., `ecommerce_db`).

### 2. Backend Setup
Navigate to the `backend/` folder:
```bash
cd backend
python -m venv .venv
# Activate Virtual Env (Windows)
.venv\Scripts\activate
# Activate Virtual Env (Mac/Linux)
source .venv/bin/activate

pip install -r requirements.txt