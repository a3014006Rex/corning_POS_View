<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { useSimulationPos } from '@/composables/useSimulationPos.js'

const enabled = import.meta.env.DEV
const selected = ref('employee-a')
const flow = useSimulationPos()
const { scenarios, claim, amount, busy, error, phase, result, pending, canSwipe, canConfirm } = flow
onMounted(() => { if (enabled) flow.initialize() })
onUnmounted(flow.dispose)
</script>

<template>
  <main class="container py-4 lab-page">
    <div class="d-flex gap-4 mb-4"><RouterLink to="/pos">← POS 畫面</RouterLink><RouterLink to="/admin/transactions">管理後台</RouterLink></div>
    <h1 class="h3">刷卡流程驗證</h1>
    <CAlert color="warning">僅供本機開發：使用合成員工與程序記憶體，服務重啟後測試資料會消失。此流程沒有連接 RFID、舊 DB 或正式帳務，財務分攤尚未計算。</CAlert>
    <CAlert v-if="!enabled" color="secondary">正式產物停用此開發入口。</CAlert>
    <template v-else>
      <p role="status">{{ { idle: '等待模擬刷卡', ready: '請確認測試人員與金額', submitting: '正在送出測試紀錄', recorded: '測試紀錄已建立（SIMULATED）', unknown: '結果待確認：保留原交易編號查詢' }[phase] }}</p>
      <div v-if="error" class="alert alert-danger" role="alert">{{ error }}</div>
      <div class="card mb-4"><div class="card-body d-flex align-items-end gap-3 flex-wrap">
        <div><label for="scenario" class="form-label">合成測試卡</label><select id="scenario" v-model="selected" class="form-select" :disabled="!canSwipe"><option v-for="scenario in scenarios" :key="scenario.id" :value="scenario.id">{{ scenario.name }} · {{ scenario.employeeCode }}{{ scenario.enabled ? '' : '（應拒絕）' }}</option></select></div>
        <button class="btn btn-primary" :disabled="!canSwipe || !scenarios.length" @click="flow.swipe(selected)">模擬刷卡</button>
      </div></div>
      <div class="row g-4">
        <section class="col-md-6"><div class="card h-100"><div class="card-body">
          <h2 class="h5">目前領取的人員</h2>
          <dl class="person-info"><dt>工號</dt><dd>{{ claim?.person.employeeCode || '—' }}</dd><dt>姓名</dt><dd>{{ claim?.person.name || '—' }}</dd><dt>卡號</dt><dd>{{ claim?.person.cardCode || '—' }}</dd><dt>身分</dt><dd>{{ claim?.person.identityType || '—' }}</dd></dl>
        </div></div></section>
        <section class="col-md-6"><form class="card h-100" @submit.prevent="flow.confirm"><div class="card-body">
          <label for="simulation-amount" class="form-label">測試總金額（元）</label><input id="simulation-amount" v-model="amount" class="form-control form-control-lg mb-3" type="number" min="1" step="1" required :disabled="!canConfirm" />
          <p class="text-secondary">只驗證總額傳遞；公司／DL／員工自付分攤為待財務確認。</p>
          <div class="d-flex gap-3"><button type="submit" class="btn btn-primary" :disabled="!canConfirm">{{ busy ? '處理中…' : '確認並建立測試紀錄' }}</button><button class="btn btn-outline-secondary" type="button" :disabled="!canConfirm" @click="flow.cancel">取消草稿</button></div>
        </div></form></section>
      </div>
      <div v-if="pending" class="alert alert-warning mt-4">
        <p>原交易編號：<code>{{ pending.clientTransactionId }}</code></p>
        <p>尚未取得明確結果時，暫停新刷卡。請查詢原交易；重送會使用相同編號與內容。</p>
        <div class="d-flex gap-3"><button class="btn btn-outline-primary" :disabled="busy" @click="flow.lookup">查詢原交易</button><button class="btn btn-outline-secondary" :disabled="busy" @click="flow.retryOriginal">查詢後重送原請求</button></div>
      </div>
      <div v-if="result" class="alert alert-info mt-4" role="status">
        <p>測試紀錄編號：<code>{{ result.transactionId }}</code></p><p class="mb-0">NT$ {{ (result.totalAmountMinor / 100).toLocaleString('zh-TW') }} · {{ result.status }} · 目前人員資料已清除，可測下一位。</p>
      </div>
    </template>
  </main>
</template>

<style scoped>
.lab-page { max-width: 1200px; }
.person-info { display: grid; grid-template-columns: 80px 1fr; gap: 1rem; margin: 1.5rem 0 0; }
.person-info dd { margin: 0; overflow-wrap: anywhere; }
code { overflow-wrap: anywhere; }
</style>
