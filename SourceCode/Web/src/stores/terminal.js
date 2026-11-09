import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { loadTerminalSettings, saveTerminalSettings } from '@/utils/terminalSettings.js'

export const useTerminalStore = defineStore('terminal', () => {
  const initial = loadTerminalSettings()
  const settings = ref(initial.settings)
  const message = ref(initial.error)
  const caption = computed(() => [settings.value.laneName, settings.value.postCode].filter(Boolean).join(' · '))

  function save(value) {
    // 儲存失敗時保留目前設定，讓表單明確提示，避免假裝已持久保存。
    settings.value = saveTerminalSettings(value)
    message.value = '設定已儲存'
  }

  return { settings, message, caption, save }
})
