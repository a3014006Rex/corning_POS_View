'use strict';
// Static demo only: no reader or transaction API is connected.
const form = document.getElementById('card-form');
const amount = document.getElementById('amount');
const submit = document.getElementById('submit');
const status = document.getElementById('status');
const ready = document.body.dataset.state === 'ready';
let submitted = false;
if (ready) {
  // Capture once so this remains the swipe time, not a live clock.
  const now = new Date();
  const pad = value => String(value).padStart(2, '0');
  const time = document.getElementById('swipe-time');
  time.dateTime = now.toISOString();
  time.textContent = `${now.getFullYear()}/${pad(now.getMonth() + 1)}/${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
}
form.addEventListener('submit', event => {
  event.preventDefault();
  if (!ready || submitted || !form.reportValidity()) return;
  const value = Number(amount.value);
  if (!Number.isFinite(value) || value <= 0) return;
  submitted = true;
  amount.disabled = true;
  submit.disabled = true;
  submit.textContent = '已確認';
  status.textContent = `示範確認完成，金額 NT$ ${value.toLocaleString('zh-TW', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}。未送出實際交易。`;
});


// These settings configure the demo terminal only; saving never calls the URL.
const settingsKey = 'pos-terminal-settings';
const dialog = document.getElementById('settings-dialog');
const settingsForm = document.getElementById('settings-form');
const laneName = document.getElementById('lane-name');
const postCode = document.getElementById('post-code');
const apiUrl = document.getElementById('api-url');
const settingsError = document.getElementById('settings-error');
const settingsMessage = document.getElementById('settings-message');
let settings = { laneName: '', postCode: '', apiUrl: '' };
try {
  const saved = JSON.parse(localStorage.getItem(settingsKey));
  if (saved && typeof saved === 'object') {
    for (const key of Object.keys(settings)) {
      if (typeof saved[key] === 'string') settings[key] = saved[key];
    }
  }
} catch {
  settingsMessage.textContent = '無法讀取本機設定';
}
function showTerminalCaption() {
  const caption = document.getElementById('terminal-caption');
  caption.textContent = [settings.laneName, settings.postCode].filter(Boolean).join(' · ');
  caption.hidden = !caption.textContent;
}
showTerminalCaption();
document.getElementById('open-settings').addEventListener('click', () => {
  laneName.value = settings.laneName;
  postCode.value = settings.postCode;
  apiUrl.value = settings.apiUrl;
  apiUrl.setCustomValidity('');
  settingsError.textContent = '';
  dialog.showModal();
});
document.getElementById('cancel-settings').addEventListener('click', () => dialog.close());
apiUrl.addEventListener('input', () => apiUrl.setCustomValidity(''));
settingsForm.addEventListener('submit', event => {
  event.preventDefault();
  const next = { laneName: laneName.value.trim(), postCode: postCode.value.trim(), apiUrl: apiUrl.value.trim() };
  if (next.apiUrl) {
    try {
      const url = new URL(next.apiUrl);
      if (!['http:', 'https:'].includes(url.protocol) || !url.hostname) throw new Error('Invalid URL');
    } catch {
      apiUrl.setCustomValidity('請輸入完整的 http:// 或 https:// API URL');
    }
  }
  if (!settingsForm.reportValidity()) return;
  try {
    localStorage.setItem(settingsKey, JSON.stringify(next));
  } catch {
    settingsError.textContent = '無法儲存設定，請確認瀏覽器允許本機儲存後重試。';
    return;
  }
  settings = next;
  showTerminalCaption();
  dialog.close();
  settingsMessage.textContent = '設定已儲存';
});
