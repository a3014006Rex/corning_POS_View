import { expect, it } from 'vitest'
import { simulationCsv } from './simulationCsv.js'

it('exports simulation labels and neutralizes formula-like names', () => {
  const csv = simulationCsv([{ transactionId: 'sample', clientTransactionId: 'client',
    person: { employeeCode: 'SYNTH001', name: '=1+1,"test"' }, recordedAt: '2026-11-08T04:00:00Z', totalAmountMinor: 8000, status: 'SIMULATED' }])
  expect(csv).toContain('狀態（僅模擬）')
  expect(csv).toContain('"\'=1+1,""test"""')
  expect(csv).toContain('"80.00"')
})
