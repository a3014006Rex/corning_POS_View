export const TERMINAL_SETTINGS_KEY = 'pos-terminal-settings'

export function normalizeTerminalSettings(value) {
  return {
    laneName: typeof value?.laneName === 'string' ? value.laneName.trim().slice(0, 60) : '',
    postCode: typeof value?.postCode === 'string' ? value.postCode.trim().slice(0, 60) : '',
  }
}

export function loadTerminalSettings() {
  try {
    return {
      settings: normalizeTerminalSettings(JSON.parse(localStorage.getItem(TERMINAL_SETTINGS_KEY))),
      error: '',
    }
  } catch {
    return { settings: normalizeTerminalSettings(null), error: '無法讀取本機設定，請重新設定。' }
  }
}

export function saveTerminalSettings(value) {
  const settings = normalizeTerminalSettings(value)
  localStorage.setItem(TERMINAL_SETTINGS_KEY, JSON.stringify(settings))
  return settings
}
