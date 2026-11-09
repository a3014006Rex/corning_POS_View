<script setup>
import { reactive, ref } from 'vue'
import { useTerminalStore } from '@/stores/terminal.js'
import { getApiBaseUrl } from '@/api/http.js'

const terminal = useTerminalStore()
const dialog = ref(null)
const draft = reactive({ laneName: '', postCode: '' })
const error = ref('')

function open() {
  Object.assign(draft, terminal.settings)
  error.value = ''
  dialog.value.showModal()
}

function save() {
  try {
    terminal.save(draft)
    dialog.value.close()
  } catch {
    error.value = '無法儲存設定，請確認瀏覽器允許本機儲存後重試。'
  }
}

defineExpose({ open })
</script>

<template>
  <dialog ref="dialog" class="terminal-dialog" aria-labelledby="settings-title">
    <form @submit.prevent="save">
      <h2 id="settings-title">系統設定</h2>
      <label for="lane-name">餐道名稱</label>
      <input id="lane-name" v-model="draft.laneName" maxlength="60" autocomplete="off" placeholder="例如：第一餐道" />
      <label for="post-code">POS 代號</label>
      <input id="post-code" v-model="draft.postCode" maxlength="60" autocomplete="off" placeholder="例如：POS01" />
      <label for="api-url">API 路徑</label>
      <input id="api-url" :value="getApiBaseUrl()" readonly aria-describedby="settings-note" />
      <p id="settings-note">API 路徑由部署設定管理。本機餐道設定僅供顯示，尚未綁定讀卡機。</p>
      <p v-if="error" role="alert" class="error-text">{{ error }}</p>
      <div class="dialog-actions">
        <button type="button" class="secondary" @click="dialog.close()">取消</button>
        <button type="submit">儲存設定</button>
      </div>
    </form>
  </dialog>
</template>
