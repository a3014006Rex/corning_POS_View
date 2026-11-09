import { afterEach, describe, expect, it, vi } from 'vitest'
import { ApiError, request } from './http.js'

afterEach(() => vi.unstubAllGlobals())

describe('API client contract', () => {
  it('extracts successful data and uses the versioned endpoint', async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response(JSON.stringify({ success: true, code: 'OK', data: { mode: 'Foundation' } })))
    vi.stubGlobal('fetch', fetchMock)
    expect(await request('/system/info')).toEqual({ mode: 'Foundation' })
    expect(fetchMock.mock.calls[0][0]).toBe('/api/v1/system/info')
  })

  it('rejects a business failure even when HTTP status is 200', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(JSON.stringify({ success: false, code: 'LIMIT_EXCEEDED', message: '超過限制', traceId: 'trace-1' }))))
    await expect(request('/quotes')).rejects.toMatchObject({ code: 'LIMIT_EXCEEDED', status: 200, traceId: 'trace-1' })
  })

  it('preserves an HTTP error and its trace ID without retrying', async () => {
    const fetchMock = vi.fn().mockResolvedValue(new Response(JSON.stringify({ success: false, code: 'UNAUTHENTICATED', message: '請登入', traceId: 'trace-2' }), { status: 401 }))
    vi.stubGlobal('fetch', fetchMock)
    await expect(request('/protected')).rejects.toMatchObject({ status: 401, traceId: 'trace-2' })
    expect(fetchMock).toHaveBeenCalledTimes(1)
  })

  it('rejects a malformed success response', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response('{}')))
    await expect(request('/system/info')).rejects.toMatchObject({ code: 'INVALID_RESPONSE' })
  })

  it('reports a network failure without pretending the operation failed on the server', async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('network disconnected')))
    await expect(request('/system/info')).rejects.toBeInstanceOf(ApiError)
  })

  it('preserves caller cancellation', async () => {
    const controller = new AbortController()
    controller.abort()
    const aborted = new DOMException('Cancelled', 'AbortError')
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(aborted))
    await expect(request('/system/info', { signal: controller.signal })).rejects.toBe(aborted)
  })

  it('preserves cancellation while reading the response body', async () => {
    const controller = new AbortController()
    const aborted = new DOMException('Cancelled', 'AbortError')
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
      json: async () => { controller.abort(); throw aborted },
    }))
    await expect(request('/system/info', { signal: controller.signal })).rejects.toBe(aborted)
  })

  it('reports timeout without retrying the request', async () => {
    const fetchMock = vi.fn().mockImplementation((_url, options) => new Promise((_resolve, reject) => {
      options.signal.addEventListener('abort', () => reject(options.signal.reason), { once: true })
    }))
    vi.stubGlobal('fetch', fetchMock)
    await expect(request('/system/info', { timeoutMs: 5 })).rejects.toMatchObject({ code: 'REQUEST_TIMEOUT' })
    expect(fetchMock).toHaveBeenCalledTimes(1)
  })
})
