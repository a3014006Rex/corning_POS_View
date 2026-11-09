import { beforeEach, describe, expect, it, vi } from 'vitest'
import { useSimulationPos } from './useSimulationPos.js'

const claimId = '11111111-1111-4111-8111-111111111111'
const quoteId = '22222222-2222-4222-8222-222222222222'
const mockApi = () => ({
  scenarios: vi.fn().mockResolvedValue([{ id: 'employee-a' }]),
  swipe: vi.fn().mockResolvedValue({ eventId: 'test-event' }),
  claim: vi.fn().mockResolvedValue({ claimId, person: { name: '合成人員' } }),
  quote: vi.fn().mockResolvedValue({ quoteId }),
  commit: vi.fn().mockImplementation(async (value) => ({ ...value, transactionId: 'test-transaction', status: 'SIMULATED' })),
  find: vi.fn(),
  release: vi.fn().mockResolvedValue({ state: 'RELEASED' }),
})

beforeEach(() => sessionStorage.clear())

describe('API-based simulation workflow', () => {
  it('does not replace the current person and clears them after success', async () => {
    const api = mockApi()
    const flow = useSimulationPos(api)
    await flow.swipe('employee-a')
    await flow.swipe('employee-b')
    expect(api.swipe).toHaveBeenCalledTimes(1)
    flow.amount.value = 80
    await flow.confirm()
    expect(api.quote).toHaveBeenCalledWith(claimId, 8000)
    expect(flow.claim.value).toBeNull()
    expect(flow.amount.value).toBe('')
    expect(flow.canSwipe.value).toBe(true)
    expect(sessionStorage.getItem('tc.simulation.pending')).toBeNull()
  })

  it('persists only the original IDs and recovers a lost response through lookup', async () => {
    const api = mockApi()
    api.commit.mockRejectedValueOnce(new Error('網路回應中斷'))
    const flow = useSimulationPos(api)
    await flow.swipe('employee-a')
    await flow.confirm()
    const original = api.commit.mock.calls[0][0]
    expect(flow.phase.value).toBe('unknown')
    expect(flow.canSwipe.value).toBe(false)
    const saved = JSON.parse(sessionStorage.getItem('tc.simulation.pending'))
    expect(saved).toEqual(original)
    expect(Object.keys(saved).sort()).toEqual(['claimId', 'clientTransactionId', 'quoteId'])
    api.find.mockResolvedValue({ ...original, status: 'SIMULATED' })
    const recovered = useSimulationPos(api)
    await recovered.initialize()
    expect(api.find).toHaveBeenCalledWith(original.clientTransactionId)
    expect(api.commit).toHaveBeenCalledTimes(1)
    expect(recovered.phase.value).toBe('recorded')
  })

  it('explicit retry checks the result first and reuses the same request', async () => {
    const api = mockApi()
    api.commit.mockRejectedValueOnce(new Error('response lost'))
    api.find.mockRejectedValue(Object.assign(new Error('not found'), { code: 'TRANSACTION_NOT_FOUND' }))
    const flow = useSimulationPos(api)
    await flow.swipe('employee-a')
    await flow.confirm()
    await flow.retryOriginal()
    expect(api.commit.mock.calls[1][0]).toEqual(api.commit.mock.calls[0][0])
    expect(flow.phase.value).toBe('recorded')
  })

  it('does not submit when recovery state cannot be persisted', async () => {
    const api = mockApi()
    const storage = { getItem: () => null, setItem: () => { throw new Error('storage full') }, removeItem: () => {} }
    const flow = useSimulationPos(api, storage)
    await flow.swipe('employee-a')
    await flow.confirm()
    expect(api.commit).not.toHaveBeenCalled()
    expect(flow.error.value).toContain('storage full')
  })

  it('cancel releases the claim and removes displayed personal information', async () => {
    const api = mockApi()
    const flow = useSimulationPos(api)
    await flow.swipe('employee-a')
    await flow.cancel()
    expect(api.release).toHaveBeenCalledWith(claimId)
    expect(flow.claim.value).toBeNull()
    expect(flow.amount.value).toBe('')
  })

  it('ignores responses arriving after the page is disposed', async () => {
    const api = mockApi()
    let resolve
    api.claim.mockImplementation(() => new Promise((done) => { resolve = done }))
    const flow = useSimulationPos(api)
    const work = flow.swipe('employee-a')
    await Promise.resolve()
    flow.dispose()
    resolve({ claimId, person: { name: 'late person' } })
    await work
    expect(flow.claim.value).toBeNull()
    expect(api.release).toHaveBeenCalledWith(claimId)
  })

  it('releases an unsubmitted draft when leaving the page', async () => {
    const api = mockApi()
    const flow = useSimulationPos(api)
    await flow.swipe('employee-a')
    flow.dispose()
    expect(api.release).toHaveBeenCalledWith(claimId)
    expect(flow.claim.value).toBeNull()
    expect(flow.amount.value).toBe('')
  })

  it('keeps the recovery ID and does not release a submission in progress', async () => {
    const api = mockApi()
    let finish
    api.commit.mockImplementation(() => new Promise((resolve) => { finish = resolve }))
    const flow = useSimulationPos(api)
    await flow.swipe('employee-a')
    const work = flow.confirm()
    await vi.waitFor(() => expect(api.commit).toHaveBeenCalledTimes(1))
    const original = api.commit.mock.calls[0][0]
    flow.dispose()
    expect(api.release).not.toHaveBeenCalled()
    expect(JSON.parse(sessionStorage.getItem('tc.simulation.pending'))).toEqual(original)
    finish({ ...original, status: 'SIMULATED' })
    await work
    expect(JSON.parse(sessionStorage.getItem('tc.simulation.pending'))).toEqual(original)
  })
})
