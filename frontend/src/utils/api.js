// Helper functions for API calls used across the frontend.
// Provides `fetchFromAPI` for GET-like requests and `postToAPI` for POST requests.
// - Uses import.meta.env.VITE_API_BASE_URL as the API base (falls back to empty string)
// - Automatically attaches `Authorization: Bearer <token>` if `localStorage.token` exists
// - Provides a configurable timeout using AbortController
// - Normalizes errors into thrown objects: { message, status, data }

const API_BASE = typeof import.meta !== 'undefined' && import.meta.env && import.meta.env.VITE_API_BASE_URL
  ? import.meta.env.VITE_API_BASE_URL
  : '';

function buildUrl(endpoint, params) {
  const base = endpoint.startsWith('http') ? endpoint : `${API_BASE}${endpoint}`;
  if (!params) return base;
  const usp = new URLSearchParams();
  Object.entries(params).forEach(([k, v]) => {
    if (v === undefined || v === null) return;
    if (Array.isArray(v)) v.forEach(item => usp.append(k, item));
    else usp.append(k, String(v));
  });
  const suffix = usp.toString();
  return suffix ? `${base}${base.includes('?') ? '&' : '?'}${suffix}` : base;
}

function getAuthHeader() {
  try {
    const token = localStorage.getItem('token');
    return token ? { Authorization: `Bearer ${token}` } : {};
  } catch (e) {
    return {};
  }
}

async function parseResponseBody(res) {
  const contentType = res.headers.get('content-type') || '';
  if (!contentType) return null;
  if (contentType.includes('application/json')) return res.json();
  // fallback to text for other content types
  return res.text();
}

function makeTimeoutController(timeout, externalSignal) {
  if (externalSignal) return { signal: externalSignal, cancel: () => {} };
  if (!timeout) return { signal: undefined, cancel: () => {} };
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), timeout);
  return { signal: controller.signal, cancel: () => clearTimeout(id) };
}

async function fetchFromAPI(endpoint, options = {}) {
  // options: { params, headers, timeout(ms), signal }
  const { params, headers = {}, timeout = 10000, signal: externalSignal } = options;
  const url = buildUrl(endpoint, params);
  const authHeader = getAuthHeader();
  const { signal, cancel } = makeTimeoutController(timeout, externalSignal);

  try {
    const res = await fetch(url, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
        ...authHeader,
        ...headers,
      },
      signal,
    });

    const data = await parseResponseBody(res);
    if (!res.ok) {
      const message = (data && data.message) || res.statusText || 'Request failed';
      const err = new Error(message);
      err.status = res.status;
      err.data = data;
      throw err;
    }

    return data;
  } catch (err) {
    if (err.name === 'AbortError') {
      const e = new Error('Request timed out');
      e.status = 0;
      throw e;
    }
    throw err;
  } finally {
    cancel();
  }
}

async function postToAPI(endpoint, body = {}, options = {}) {
  // options: { headers, timeout(ms), signal }
  const { headers = {}, timeout = 10000, signal: externalSignal } = options;
  const url = endpoint.startsWith('http') ? endpoint : `${API_BASE}${endpoint}`;
  const authHeader = getAuthHeader();
  const { signal, cancel } = makeTimeoutController(timeout, externalSignal);

  // Build final headers object so we can conditionally add/remove Content-Type
  const finalHeaders = {
    Accept: 'application/json',
    ...authHeader,
    ...headers,
  };

  // Determine content-type preference (if caller provided one)
  const specifiedContentType = headers['Content-Type'] || headers['content-type'];
  const contentType = specifiedContentType || 'application/json';

  let payload;
  if (contentType.includes('application/json')) {
    payload = JSON.stringify(body);
    // only set Content-Type header if caller didn't already
    if (!specifiedContentType) finalHeaders['Content-Type'] = 'application/json';
  } else {
    // allow callers to pass a FormData instance or pre-serialized body
    payload = body;
    // If payload is FormData, the browser will set the correct Content-Type boundary; remove it if present
    if (payload instanceof FormData && finalHeaders['Content-Type']) {
      delete finalHeaders['Content-Type'];
    }
  }

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: finalHeaders,
      body: payload,
      signal,
    });

    const data = await parseResponseBody(res);
    if (!res.ok) {
      const message = (data && data.message) || res.statusText || 'Request failed';
      const err = new Error(message);
      err.status = res.status;
      err.data = data;
      throw err;
    }

    return data;
  } catch (err) {
    if (err.name === 'AbortError') {
      const e = new Error('Request timed out');
      e.status = 0;
      throw e;
    }
    throw err;
  } finally {
    cancel();
  }
}

export { fetchFromAPI, postToAPI };

// Usage examples:
// import { fetchFromAPI, postToAPI } from '@/utils/api';
// fetchFromAPI('/products', { params: { page: 1, limit: 20 } })
//   .then(data => console.log(data))
//   .catch(err => console.error(err));
// postToAPI('/login', { email, password })
//   .then(data => console.log(data))
//   .catch(err => console.error(err));
