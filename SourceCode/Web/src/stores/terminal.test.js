import { beforeEach, describe, expect, it, vi } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { useTerminalStore } from './terminal.js'
import { TERMINAL_SETTINGS_KEY } from '@/utils/terminalSettings.js'

beforeEach(() => {
  localStorage.clear()
  setActivePinia(createPinia())
})

describe('terminal settings', () => {
  it('reads original prototype settings without trusting its API URL', () => {
    localStorage.setItem(TERMINAL_SETTINGS_KEY, JSON.stringify({ laneName: '第一餐道', postCode: 'POS01', apiUrl: 'https://unused.example/api' }))
    const store = useTerminalStore()
    expect(store.caption).toBe('第一餐道 · POS01')
    expect(store.settings).not.toHaveProperty('apiUrl')
  })

  it('recovers from corrupt local storage', () => {
    localStorage.setItem(TERMINAL_SETTINGS_KEY, '{corrupt')
    const store = useTerminalStore()
    expect(store.caption).toBe('')
    expect(store.message).toContain('無法讀取')
  })

  it('persists display settings without storing personal information', () => {
    const store = useTerminalStore()
    store.save({ laneName: ' 第一餐道 ', postCode: 'POS01', employeeCode: 'not-persisted' })
    expect(JSON.parse(localStorage.getItem(TERMINAL_SETTINGS_KEY))).toEqual({ laneName: '第一餐道', postCode: 'POS01' })
  })

  it('keeps the previous settings when persistence fails', () => {
    const store = useTerminalStore()
    vi.spyOn(Storage.prototype, 'setItem').mockImplementation(() => { throw new DOMException('Full', 'QuotaExceededError') })
    expect(() => store.save({ laneName: '新餐道' })).toThrow()
    expect(store.caption).toBe('')
    expect(store.message).not.toBe('設定已儲存')
  })
})
