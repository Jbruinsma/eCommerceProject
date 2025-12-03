// Helper functions for API calls used across the frontend.
// Provides `fetchFromAPI`, `postToAPI`, and `deleteFromAPI`.

// LOGIC UPDATE: Determine the API Base URL dynamically
// 1. If VITE_API_BASE_URL is set in .env, use that (Production/Overrides).
// 2. Otherwise, use the current hostname (localhost or Wi-Fi IP) + Port 8000.
let API_BASE = ''

if (import.meta.env && import.meta.env.VITE_API_BASE_URL) {
  API_BASE = import.meta.env.VITE_API_BASE_URL
} else {
  // Get the host (e.g., "localhost" or "192.168.1.15")
  const hostname = window.location.hostname
  // Construct the backend URL assuming standard http and port 8000
  API_BASE = `http://${hostname}:8000`
}

function buildUrl(endpoint, params) {
  const base = endpoint.startsWith('http') ? endpoint : `${API_BASE}${endpoint}`
  if (!params) return base
  const usp = new URLSearchParams()
  Object.entries(params).forEach(([k, v]) => {
    if (v === undefined || v === null) return
    if (Array.isArray(v)) v.forEach((item) => usp.append(k, item))
    else usp.append(k, String(v))
  })
  const suffix = usp.toString()
  return suffix ? `${base}${base.includes('?') ? '&' : '?'}${suffix}` : base
}

function getAuthHeader() {
  try {
    const token = localStorage.getItem('token')
    return token ? { Authorization: `Bearer ${token}` } : {}
  } catch {
    return {}
  }
}

async function parseResponseBody(res) {
  const contentType = res.headers.get('content-type') || ''
  if (!contentType || res.status === 204) return null // 204 No Content
  if (contentType.includes('application/json')) return res.json()
  return res.text()
}

function makeTimeoutController(timeout, externalSignal) {
  if (externalSignal) return { signal: externalSignal, cancel: () => {} }
  if (!timeout) return { signal: undefined, cancel: () => {} }
  const controller = new AbortController()
  const id = setTimeout(() => controller.abort(), timeout)
  return { signal: controller.signal, cancel: () => clearTimeout(id) }
}

function isApiErrorPayload(data) {
  if (!data || typeof data !== 'object') return false
  if (data.error) return true
  if (data.success === false) return true
  if (typeof data.status === 'string' && data.status.toLowerCase() === 'error') return true
  return false
}

async function callAPI(url, options) {
  const { timeout = 10000, signal: externalSignal, ...fetchOptions } = options
  const { signal, cancel } = makeTimeoutController(timeout, externalSignal)

  try {
    const res = await fetch(url, { ...fetchOptions, signal })
    const data = await parseResponseBody(res)

    if (isApiErrorPayload(data)) {
      const message = (data && (data.message || data.detail)) || res.statusText || 'Request failed'
      const err = new Error(message)
      err.status = res.status
      err.data = data
      throw err
    }

    if (!res.ok) {
      let message = res.statusText || 'Request failed'
      if (data) {
        if (data.message) message = data.message
        else if (data.detail) {
          if (Array.isArray(data.detail)) {
            try {
              message = data.detail
                .map((d) => {
                  const loc = Array.isArray(d.loc) ? d.loc.join('.') : d.loc || ''
                  return loc ? `${loc}: ${d.msg}` : d.msg
                })
                .join('; ')
            } catch (e) {
              message = JSON.stringify(data.detail)
            }
          } else {
            message = String(data.detail)
          }
        } else {
          try {
            message = JSON.stringify(data)
          } catch (e) {
            /* ignore */
          }
        }
      }
      const err = new Error(message)
      err.status = res.status
      err.data = data
      throw err
    }

    return data
  } catch (err) {
    if (err.name === 'AbortError') {
      const e = new Error('Request timed out')
      e.status = 0
      throw e
    }
    throw err
  } finally {
    cancel()
  }
}

async function fetchFromAPI(endpoint, options = {}) {
  const { params, headers = {}, ...restOptions } = options
  const url = buildUrl(endpoint, params)
  const authHeader = getAuthHeader()

  return callAPI(url, {
    method: 'GET',
    headers: {
      Accept: 'application/json',
      ...authHeader,
      ...headers,
    },
    ...restOptions,
  })
}

async function postToAPI(endpoint, body = {}, options = {}) {
  const { headers = {}, ...restOptions } = options
  const url = buildUrl(endpoint)
  const authHeader = getAuthHeader()

  const finalHeaders = {
    Accept: 'application/json',
    ...authHeader,
    ...headers,
  }

  const specifiedContentType = headers['Content-Type'] || headers['content-type']
  const contentType = specifiedContentType || 'application/json'

  let payload
  if (contentType.includes('application/json')) {
    payload = JSON.stringify(body)
    if (!specifiedContentType) finalHeaders['Content-Type'] = 'application/json'
  } else {
    payload = body
    if (payload instanceof FormData && finalHeaders['Content-Type']) {
      delete finalHeaders['Content-Type']
    }
  }

  return callAPI(url, {
    method: 'POST',
    headers: finalHeaders,
    body: payload,
    ...restOptions,
  })
}

async function deleteFromAPI(endpoint, options = {}) {
  const { headers = {}, ...restOptions } = options
  const url = buildUrl(endpoint)
  const authHeader = getAuthHeader()

  return callAPI(url, {
    method: 'DELETE',
    headers: {
      Accept: 'application/json',
      ...authHeader,
      ...headers,
    },
    ...restOptions,
  })
}

export { fetchFromAPI, postToAPI, deleteFromAPI }
