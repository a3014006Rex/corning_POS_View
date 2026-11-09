<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { getSystemInfo } from '@/api/system.js'

const info = ref(null)
const loading = ref(false)
const error = ref('')
const traceId = ref('')
let controller

async function refresh() {
  controller?.abort()
  const current = new AbortController()
  controller = current
  loading.value = true
  error.value = ''
  traceId.value = ''
  info.value = null
  try {
    const result = await getSystemInfo({ signal: current.signal })
    if (!current.signal.aborted) info.value = result
  } catch (failure) {
    if (!current.signal.aborted) {
      error.value = failure.message
      traceId.value = failure.traceId || ''
    }
  } finally {
    if (controller === current) loading.value = false
  }
}

onMounted(refresh)
onUnmounted(() => controller?.abort())
</script>

<template>
  <main class="system-page container py-5">
    <RouterLink to="/pos">← 返回用餐刷卡</RouterLink>
    <h1 class="my-4">系統狀態</h1>
    <CAlert color="warning">目前為專案骨架。API 連線成功僅表示服務可回應，尚未接入讀卡機、資料庫及正式計費。</CAlert>
    <button class="btn btn-primary mb-4" :disabled="loading" @click="refresh">{{ loading ? '檢查中…' : '重新檢查' }}</button>
    <p v-if="loading" role="status">正在連接 API…</p>
    <CAlert v-if="error" color="danger" role="alert">{{ error }}<span v-if="traceId"> 追蹤編號：{{ traceId }}</span></CAlert>
    <dl v-if="info" class="system-info">
      <dt>服務名稱</dt><dd>{{ info.name }}</dd>
      <dt>版本</dt><dd>{{ info.version }}</dd>
      <dt>API</dt><dd>已連線</dd>
      <dt>資料庫</dt><dd>{{ info.capabilities.database ? '已啟用' : '尚未串接' }}</dd>
      <dt>設備服務</dt><dd>{{ info.capabilities.deviceGateway ? '已啟用' : '尚未串接' }}</dd>
      <dt>正式交易</dt><dd>{{ info.capabilities.transactions ? '已啟用' : '尚未開放' }}</dd>
      <dt>伺服器時間</dt><dd>{{ new Date(info.serverTime).toLocaleString('zh-TW', { timeZone: 'Asia/Taipei', hour12: false }) }}</dd>
    </dl>
  </main>
</template>

<style scoped>
.system-page { max-width: 960px; }
.system-info { display: grid; grid-template-columns: 120px minmax(0, 1fr); gap: 1rem; padding: 1.5rem; border: 1px solid #c5cfd7; border-radius: 6px; background: white; }
.system-info dd { margin: 0; overflow-wrap: anywhere; }
</style>
