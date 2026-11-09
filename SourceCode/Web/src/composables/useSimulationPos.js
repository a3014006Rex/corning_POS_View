import { computed, ref } from 'vue'
import { simulationApi } from '@/api/simulation.js'
import { MAX_SAFE_TWD } from './usePosPreview.js'

const STORAGE_KEY = 'tc.simulation.pending'
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export function useSimulationPos(api = simulationApi, storage = sessionStorage) {
  const scenarios = ref([])
  const claim = ref(null)
  const amount = ref('')
  const busy = ref(false)
  const error = ref('')
  const phase = ref('idle')
  const result = ref(null)
  const pending = ref(null)
  let disposed = false
  try {
    const saved = JSON.parse(storage.getItem(STORAGE_KEY))
    if (saved && ['clientTransactionId', 'claimId', 'quoteId'].every((key) => UUID.test(saved[key]))) {
      pending.value = { clientTransactionId: saved.clientTransactionId, claimId: saved.claimId, quoteId: saved.quoteId }
      phase.value = 'unknown'
    }
  } catch { error.value = '無法讀取本機測試狀態，送出前會再檢查保存能力。' }

  const canSwipe = computed(() => !busy.value && !claim.value && !pending.value)
  const canConfirm = computed(() => !busy.value && Boolean(claim.value) && !pending.value)

  async function run(action) {
    if (busy.value || disposed) return
    busy.value = true
    error.value = ''
    try { await action() }
    catch (failure) {
      if (!disposed) {
        error.value = failure.message
        if (pending.value) phase.value = 'unknown'
      }
    } finally { if (!disposed) busy.value = false }
  }

  async function accept(transaction) {
    if (disposed) return
    result.value = transaction
    claim.value = null
    amount.value = ''
    phase.value = 'recorded'
    // 服務已回明確測試結果，清除本機復原狀態失敗也不能改報交易失敗。
    try {
      storage.removeItem(STORAGE_KEY)
      pending.value = null
    } catch { error.value = '測試結果已取得，但本機狀態未能清除；重新整理後請再查原編號。' }
  }

  async function lookup() {
    if (!pending.value) return
    await run(async () => accept(await api.find(pending.value.clientTransactionId)))
  }

  async function initialize() {
    await run(async () => {
      const values = await api.scenarios()
      if (!disposed) scenarios.value = values
      if (pending.value && !disposed) await accept(await api.find(pending.value.clientTransactionId))
    })
  }

  async function swipe(scenarioId) {
    if (!canSwipe.value) return
    await run(async () => {
      const receipt = await api.swipe(scenarioId, crypto.randomUUID())
      if (disposed) return
      const value = await api.claim(receipt.eventId)
      if (disposed) {
        await releaseQuietly(value.claimId)
        return
      }
      claim.value = value
      amount.value = 50
      result.value = null
      phase.value = 'ready'
    })
  }

  async function confirm() {
    if (!canConfirm.value) return
    const value = Number(amount.value)
    if (!Number.isSafeInteger(value) || value < 1 || value > MAX_SAFE_TWD) {
      error.value = '請輸入有效的正整數金額。'
      return
    }
    await run(async () => {
      const quote = await api.quote(claim.value.claimId, value * 100)
      if (disposed) return
      const original = { clientTransactionId: crypto.randomUUID(), claimId: claim.value.claimId, quoteId: quote.quoteId }
      // 保留原 ID 與請求後才送出。這裡只保存 UUID，不保存卡號、姓名或金額。
      storage.setItem(STORAGE_KEY, JSON.stringify(original))
      pending.value = original
      phase.value = 'submitting'
      await accept(await api.commit(original))
    })
  }

  async function retryOriginal() {
    if (!pending.value) return
    await run(async () => {
      const original = { ...pending.value }
      try { await accept(await api.find(original.clientTransactionId)) }
      catch (failure) {
        if (failure.code !== 'TRANSACTION_NOT_FOUND') throw failure
        if (!disposed) await accept(await api.commit(original))
      }
    })
  }

  async function cancel() {
    if (!canConfirm.value) return
    await run(async () => {
      await api.release(claim.value.claimId)
      if (disposed) return
      claim.value = null
      amount.value = ''
      phase.value = 'idle'
    })
  }

  async function releaseQuietly(claimId) {
    try { await api.release(claimId) } catch { /* 未提交的測試 Claim 仍有到期保護。 */ }
  }

  function dispose() {
    disposed = true
    // 只有尚未送出的草稿能釋放；結果不明的提交保留原 ID 供下次查單。
    if (claim.value && !pending.value) void releaseQuietly(claim.value.claimId)
    claim.value = null
    amount.value = ''
    result.value = null
  }
  return { scenarios, claim, amount, busy, error, phase, result, pending, canSwipe, canConfirm,
    initialize, swipe, confirm, cancel, lookup, retryOriginal, dispose }
}
