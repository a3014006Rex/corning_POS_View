<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import TerminalSettingsDialog from '@/components/TerminalSettingsDialog.vue'
import { useTerminalStore } from '@/stores/terminal.js'
import { MAX_SAFE_TWD, PREVIEW_STATES, usePosPreview } from '@/composables/usePosPreview.js'
import '@/styles/pos.css'

const route = useRoute()
const router = useRouter()
const terminal = useTerminalStore()
const settingsDialog = ref(null)
const previewEnabled = import.meta.env.DEV
const { state, amount, person, submitted, error, status, canConfirm, setState, confirm } = usePosPreview()
const swipeTime = computed(() => person.value ? new Date(person.value.swipedAt).toLocaleString('zh-TW', {
  timeZone: 'Asia/Taipei', hour12: false,
}) : '—')

watch(() => route.query.preview, (next) => {
  const resolved = previewEnabled && PREVIEW_STATES.includes(next) ? next : 'idle'
  if (state.value !== resolved) setState(resolved)
}, { immediate: true })

function changePreview(event) {
  setState(event.target.value)
  router.replace({ query: { preview: event.target.value } })
}

function resetPreview() {
  setState('idle')
  if (previewEnabled) router.replace({ query: { preview: 'idle' } })
}
</script>

<template>
  <main class="pos-page" :data-state="state">
    <header class="pos-header">
      <div>
        <h1>用餐刷卡</h1>
        <p v-if="terminal.caption" class="terminal-caption">{{ terminal.caption }}</p>
      </div>
      <p class="pos-status" role="status" aria-live="polite">{{ status }}</p>
    </header>
    <form class="card-form" @submit.prevent="confirm">
      <dl class="details">
        <div class="field"><dt>工號</dt><dd>{{ person?.employeeCode || '—' }}</dd></div>
        <div class="field"><dt>姓名</dt><dd>{{ person?.name || '—' }}</dd></div>
        <div class="field"><dt>卡號</dt><dd>{{ person?.cardCode || '—' }}</dd></div>
        <div class="field"><dt>身分別</dt><dd>{{ person?.identityType || '—' }}</dd></div>
        <div class="field"><dt>時間</dt><dd><time :datetime="person?.swipedAt">{{ swipeTime }}</time></dd></div>
        <div class="field"><dt>餐點資訊</dt><dd>{{ person?.meal || '—' }}</dd></div>
      </dl>
      <section class="payment" aria-label="金額確認">
        <label for="amount">金額（元）</label>
        <div class="amount-wrap">
          <span class="currency" aria-hidden="true">NT$</span>
          <input id="amount" v-model="amount" type="number" inputmode="numeric" min="1" :max="MAX_SAFE_TWD" step="1" required :disabled="!canConfirm" />
        </div>
        <p v-if="error" role="alert" class="error-text">{{ error }}</p>
        <button id="submit" type="submit" :disabled="!canConfirm">{{ submitted ? '已確認' : '確認送出' }}</button>
        <button v-if="submitted" type="button" class="next-person secondary" @click="resetPreview">下一位（示範）</button>
      </section>
    </form>
    <footer class="pos-footer">
      <button type="button" class="settings-trigger" aria-haspopup="dialog" @click="settingsDialog.open()">⚙ 設定</button>
      <p class="settings-message" role="status">{{ terminal.message }}</p>
      <RouterLink to="/system">系統狀態</RouterLink>
      <RouterLink to="/admin/transactions">管理後台</RouterLink>
      <RouterLink v-if="previewEnabled" to="/development">流程驗證</RouterLink>
      <label v-if="previewEnabled" class="preview-control">
        示範狀態
        <select :value="state" @change="changePreview">
          <option v-for="item in PREVIEW_STATES" :key="item" :value="item">{{ { idle: '待刷卡', reading: '讀卡中', ready: '待確認', error: '失敗' }[item] }}</option>
        </select>
      </label>
      <p class="demo-note">示範畫面 · 未連接實際交易</p>
    </footer>
    <TerminalSettingsDialog ref="settingsDialog" />
  </main>
</template>
