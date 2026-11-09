const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || '/api/v1').replace(/\/+$/, '')

export class ApiError extends Error {
  constructor(message, { status = 0, code = 'REQUEST_FAILED', traceId = '', details = [] } = {}) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.code = code
    this.traceId = traceId
    this.details = details
  }
}

export const getApiBaseUrl = () => API_BASE_URL

// 不自動重送。未來交易重試必須由用例保留原 ClientTransactionId 並先查單。
export async function request(path, { method = 'GET', body, signal, timeoutMs = 10000, headers = {} } = {}) {
  if (!path.startsWith('/') || path.startsWith('//') || path.includes('..')) {
    throw new TypeError('API wrapper 必須使用以 / 開頭的相對端點。')
  }
  const timeoutSignal = AbortSignal.timeout(timeoutMs)
  const requestSignal = signal ? AbortSignal.any([signal, timeoutSignal]) : timeoutSignal
  let response
  try {
    response = await fetch(`${API_BASE_URL}${path}`, {
      method,
      headers: {
        Accept: 'application/json',
        ...(body === undefined ? {} : { 'Content-Type': 'application/json' }),
        ...headers,
      },
      credentials: 'same-origin',
      body: body === undefined ? undefined : JSON.stringify(body),
      signal: requestSignal,
    })
  } catch (error) {
    if (signal?.aborted) throw error
    if (timeoutSignal.aborted) {
      throw new ApiError('連線逾時，請稍後查詢服務狀態。', { code: 'REQUEST_TIMEOUT' })
    }
    throw new ApiError('無法連接 API，請確認服務已啟動。', { code: 'NETWORK_ERROR' })
  }

  let payload
  try {
    payload = await response.json()
  } catch (error) {
    if (signal?.aborted) throw error
    if (timeoutSignal.aborted) {
      throw new ApiError('連線逾時，請稍後查詢服務狀態。', { code: 'REQUEST_TIMEOUT' })
    }
    throw new ApiError('API 回應格式不正確。', {
      status: response.status,
      code: 'INVALID_RESPONSE',
      traceId: response.headers.get('X-Trace-Id') || '',
    })
  }
  if (!response.ok || payload?.success === false) {
    throw new ApiError(payload?.message || `請求失敗（HTTP ${response.status}）。`, {
      status: response.status,
      code: payload?.code || 'HTTP_ERROR',
      traceId: payload?.traceId || response.headers.get('X-Trace-Id') || '',
      details: payload?.details || [],
    })
  }
  if (payload?.success !== true || payload.code !== 'OK' || !Object.hasOwn(payload, 'data')) {
    throw new ApiError('API 回應缺少必要欄位。', { status: response.status, code: 'INVALID_RESPONSE' })
  }
  return payload.data
}
