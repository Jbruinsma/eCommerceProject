# E-Commerce Frontend (Vue 3 + Vite)

A modern Single Page Application (SPA) built with **Vue 3**, **Vite**, and **Pinia**.

## Key Features

### Zero-Config Wi-Fi Access
This project uses a smart API client (`src/utils/api.js`) that automatically determines the backend URL.
* **Localhost:** If you visit `localhost:5173`, it calls `localhost:8000`.
* **Wi-Fi:** If you visit `192.168.x.x:5173`, it calls `192.168.x.x:8000`.

This means you don't need to hardcode IP addresses in your `.env` file to test on mobile devices.

## Development Commands

| Command | Description |
| :--- | :--- |
| `npm install` | Installs all dependencies listed in `package.json`. |
| `npm run dev` | Starts the development server. Accessible on your local IP (`host: true`). |
| `npm run build` | Compiles and minifies the app for production. |
| `npm run lint` | Runs ESLint to check for code quality issues. |

## Project Setup
* **State Management:** Pinia (with persistence).
* **Routing:** Vue Router.