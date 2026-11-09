import { computed, ref } from 'vue'

// 技術上限；正式業務上限與零元餐政策由 Q05/Q08 決定。
export const MAX_SAFE_TWD = Math.floor(Number.MAX_SAFE_INTEGER / 100)
export const PREVIEW_STATES = ['idle', 'reading', 'ready', 'error']

// 僅供畫面預覽，不是正式刷卡、報價或交易狀態機。
export function usePosPreview() {
  const state = ref('idle')
  const amount = ref('')
  const person = ref(null)
  const submitted = ref(false)
  const error = ref('')
  const canConfirm = computed(() => state.value === 'ready' && !submitted.value)
  const status = computed(() => {
    if (submitted.value) return `示範確認完成，金額 NT$ ${Number(amount.value).toLocaleString('zh-TW')}。未送出實際交易。`
    return {
      idle: '請感應員工卡',
      reading: '卡片讀取中，請稍候',
      ready: '請確認過卡資訊與金額',
      error: '讀卡失敗，請重新感應員工卡',
    }[state.value]
  })

  function setState(nextState) {
    state.value = PREVIEW_STATES.includes(nextState) ? nextState : 'idle'
    submitted.value = false
    error.value = ''
    amount.value = state.value === 'ready' ? 50 : ''
    person.value = state.value === 'ready' ? {
      employeeCode: 'DEMO-00128', name: '測試員工', cardCode: '••••••3456',
      identityType: '員工', swipedAt: new Date().toISOString(), meal: '午餐 · 標準餐',
    } : null
  }

  function confirm() {
    if (!canConfirm.value) return false
    const value = Number(amount.value)
    if (!Number.isSafeInteger(value) || value < 1 || value > MAX_SAFE_TWD) {
      error.value = '請輸入有效的正整數金額。'
      return false
    }
    submitted.value = true
    error.value = ''
    return true
  }

  return { state, amount, person, submitted, error, status, canConfirm, setState, confirm }
}
