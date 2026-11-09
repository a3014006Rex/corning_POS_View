import { describe, expect, it } from 'vitest'
import { MAX_SAFE_TWD, usePosPreview } from './usePosPreview.js'

describe('POS preview', () => {
  it('does not allow idle, reading or error states to confirm', () => {
    const preview = usePosPreview()
    for (const state of ['idle', 'reading', 'error']) {
      preview.setState(state)
      expect(preview.confirm()).toBe(false)
      expect(preview.person.value).toBeNull()
    }
  })

  it('rejects zero, decimals and amounts that cannot safely convert to minor units', () => {
    const preview = usePosPreview()
    for (const value of ['', 0, -1, 1.5, MAX_SAFE_TWD + 1, Infinity]) {
      preview.setState('ready')
      preview.amount.value = value
      expect(preview.confirm()).toBe(false)
      expect(preview.submitted.value).toBe(false)
    }
  })

  it('locks one confirmation and clears personal information before the next person', () => {
    const preview = usePosPreview()
    preview.setState('ready')
    preview.amount.value = 80
    expect(preview.confirm()).toBe(true)
    expect(preview.confirm()).toBe(false)
    expect(preview.status.value).toContain('未送出實際交易')
    preview.setState('idle')
    expect(preview.person.value).toBeNull()
    expect(preview.amount.value).toBe('')
    expect(preview.canConfirm.value).toBe(false)
  })
})
