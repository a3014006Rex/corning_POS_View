import { request } from './http.js'

const call = (path, options = {}) => request(`/development${path}`, {
  ...options,
  headers: { 'X-TC-Simulation': '1' },
})
const post = (path, body) => call(path, { method: 'POST', body })

export const simulationApi = {
  scenarios: () => call('/scenarios'),
  swipe: (scenarioId, operationId) => post('/swipes', { scenarioId, operationId }),
  claim: (eventId) => post('/claims', { eventId }),
  release: (claimId) => post(`/claims/${claimId}/release`, {}),
  quote: (claimId, totalAmountMinor) => post('/quotes', { claimId, totalAmountMinor }),
  commit: (value) => post('/transactions', value),
  find: (clientId) => call(`/transactions/by-client-id/${clientId}`),
  transactions: (options = {}) => call('/transactions', options),
}
