<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { simulationApi } from '@/api/simulation.js'
import { simulationCsv } from '@/utils/simulationCsv.js'

const enabled = import.meta.env.DEV
const rows = ref([])
const loading = ref(false)
const error = ref('')
let controller

async function refresh() {
  controller?.abort()
  const current = new AbortController()
  controller = current
  loading.value = true
  error.value = ''
  try {
    const result = await simulationApi.transactions({ signal: current.signal })
    if (!current.signal.aborted) rows.value = result
  } catch (failure) { if (!current.signal.aborted) error.value = failure.message }
  finally { if (controller === current) loading.value = false }
}

function download() {
  const url = URL.createObjectURL(new Blob([simulationCsv(rows.value)], { type: 'text/csv;charset=utf-8' }))
  const link = document.createElement('a')
  link.href = url
  link.download = 'simulation-transactions.csv'
  link.click()
  setTimeout(() => URL.revokeObjectURL(url), 1000)
}

onMounted(() => { if (enabled) refresh() })
onUnmounted(() => controller?.abort())
</script>

<template>
  <h1 class="h3">測試交易紀錄</h1>
  <CAlert color="warning">本頁只有合成資料與 SIMULATED 測試紀錄。服務重啟會清除記憶體資料；匯出不是正式財務報表，補助分攤尚未計算。</CAlert>
  <CAlert v-if="!enabled" color="secondary">正式資料與帳號授權尚未接入。</CAlert>
  <template v-else>
    <div class="d-flex gap-3 mb-4 flex-wrap"><RouterLink class="btn btn-primary" to="/development">開啟刷卡流程驗證</RouterLink><button class="btn btn-outline-primary" :disabled="loading" @click="refresh">{{ loading ? '載入中…' : '重新整理' }}</button><button class="btn btn-outline-secondary" :disabled="loading || !rows.length" @click="download">匯出測試 CSV</button></div>
    <div v-if="error" class="alert alert-danger" role="alert">{{ error }}</div>
    <p v-if="!loading && !rows.length && !error" role="status">尚無測試紀錄。可先到刷卡流程驗證建立一筆。</p>
    <div v-if="rows.length" class="table-responsive bg-white border rounded"><table class="table table-hover mb-0"><thead><tr><th>員編</th><th>姓名</th><th>金額</th><th>時間</th><th>狀態</th><th>測試交易編號</th></tr></thead><tbody><tr v-for="row in rows" :key="row.transactionId"><td>{{ row.person.employeeCode }}</td><td>{{ row.person.name }}</td><td>NT$ {{ (row.totalAmountMinor / 100).toFixed(2) }}</td><td>{{ new Date(row.recordedAt).toLocaleString('zh-TW', { timeZone: 'Asia/Taipei', hour12: false }) }}</td><td>{{ row.status }}</td><td><code>{{ row.transactionId }}</code></td></tr></tbody></table></div>
  </template>
</template>
