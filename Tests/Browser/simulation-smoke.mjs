// Requires local Development API + Vite. Uses Node 24 built-ins and an isolated headless Chrome.
// Creates synthetic SIMULATED records only. Never connects to RFID or a database.
import { spawn } from 'node:child_process'
import { existsSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'

const base = process.env.TC_WEB_URL || 'http://127.0.0.1:5180'
const output = mkdtempSync(join(tmpdir(), 'tc-pos-browser-'))
const profile = join(output, 'profile')
mkdirSync(profile)
const chrome = spawn(process.env.TC_CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe', [
  '--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
  '--remote-debugging-port=0', `--user-data-dir=${profile}`, 'about:blank',
], { windowsHide: true })
let socket
let send
try {
  const endpoint = await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('Chrome startup timeout')), 15000)
    chrome.stderr.on('data', (chunk) => {
      const match = chunk.toString().match(/DevTools listening on (ws:\/\/[^\s]+)/)
      if (match) { clearTimeout(timer); resolve(match[1]) }
    })
    chrome.once('error', (failure) => { clearTimeout(timer); reject(failure) })
  })
  const port = new URL(endpoint).port
  const target = await (await fetch(`http://127.0.0.1:${port}/json/new?about:blank`, { method: 'PUT' })).json()
  socket = new WebSocket(target.webSocketDebuggerUrl)
  await new Promise((resolve, reject) => { socket.onopen = resolve; socket.onerror = reject })
  let sequence = 0
  const pending = new Map()
  const exceptions = []
  socket.onmessage = (event) => {
    const message = JSON.parse(event.data)
    const request = pending.get(message.id)
    if (request) {
      clearTimeout(request.timer)
      pending.delete(message.id)
      if (message.error) request.reject(new Error(JSON.stringify(message.error)))
      else request.resolve(message.result)
    }
    if (message.method === 'Runtime.exceptionThrown') exceptions.push(message.params.exceptionDetails.text)
  }
  send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = ++sequence
    const timer = setTimeout(() => { pending.delete(id); reject(new Error(`${method} timeout`)) }, 15000)
    pending.set(id, { resolve, reject, timer })
    socket.send(JSON.stringify({ id, method, params }))
  })
  async function evaluate(expression) {
    const value = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true })
    if (value.exceptionDetails) throw new Error(JSON.stringify(value.exceptionDetails))
    return value.result.value
  }
  async function waitFor(expression) {
    for (let attempt = 0; attempt < 60; attempt++) {
      if (await evaluate(expression)) return
      await new Promise((resolve) => setTimeout(resolve, 150))
    }
    throw new Error(`Condition not met: ${expression}`)
  }
  async function screenshot(name) {
    const value = await send('Page.captureScreenshot', { format: 'png' })
    writeFileSync(join(output, `${name}.png`), Buffer.from(value.data, 'base64'))
  }
  await send('Page.enable')
  await send('Runtime.enable')
  await send('Emulation.setDeviceMetricsOverride', { width: 1280, height: 900, deviceScaleFactor: 1, mobile: false })
  await send('Page.navigate', { url: `${base}/#/development` })
  await waitFor("document.querySelectorAll('#scenario option').length === 4")
  await evaluate("[...document.querySelectorAll('button')].find(button => button.textContent === '模擬刷卡').click()")
  await waitFor("document.querySelector('dd')?.textContent === 'SYNTH00000001'")
  await screenshot('flow-ready')
  await evaluate("(() => { const input = document.querySelector('#simulation-amount'); input.value = '80'; input.dispatchEvent(new Event('input', { bubbles: true })); document.querySelector('form').requestSubmit() })()")
  await waitFor("document.querySelector('.alert-info')?.textContent.includes('SIMULATED')")
  if (!await evaluate("[...document.querySelectorAll('dd')].every(value => value.textContent === '—') && document.querySelector('#simulation-amount').value === ''")) {
    throw new Error('Current person or amount was not cleared')
  }
  await screenshot('flow-recorded')
  await send('Page.navigate', { url: `${base}/#/admin/transactions` })
  await waitFor("document.querySelectorAll('tbody tr').length >= 1")
  await send('Browser.setDownloadBehavior', { behavior: 'allow', downloadPath: output })
  await evaluate("[...document.querySelectorAll('button')].find(button => button.textContent === '匯出測試 CSV').click()")
  const csvPath = join(output, 'simulation-transactions.csv')
  for (let attempt = 0; attempt < 30 && !existsSync(csvPath); attempt++) {
    await new Promise((resolve) => setTimeout(resolve, 100))
  }
  const csv = readFileSync(csvPath, 'utf8')
  if (!csv.includes('SIMULATED') || !csv.includes('80.00')) throw new Error('Downloaded CSV content invalid')
  await screenshot('admin')
  await send('Page.navigate', { url: `${base}/#/development` })
  await waitFor("document.querySelectorAll('#scenario option').length === 4")
  await evaluate("(() => { const select = document.querySelector('#scenario'); select.value = 'revoked'; select.dispatchEvent(new Event('change', { bubbles: true })); [...document.querySelectorAll('button')].find(button => button.textContent === '模擬刷卡').click() })()")
  await waitFor("document.querySelector('.alert-danger')?.textContent.includes('撤銷')")
  await send('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 1, mobile: true })
  await screenshot('mobile')
  const sizes = await evaluate('({ viewport: innerWidth, content: document.documentElement.scrollWidth })')
  if (sizes.content > sizes.viewport) throw new Error(`Horizontal overflow: ${JSON.stringify(sizes)}`)
  if (exceptions.length) throw new Error(`Uncaught browser exceptions: ${exceptions.join('; ')}`)
  console.log('PASS: swipe -> claim -> NT$80 confirmation -> SIMULATED -> clear person -> admin -> CSV -> revoked card rejection')
  console.log('PASS: viewport 390 has no horizontal overflow; uncaught browser exceptions: 0')
  console.log(`Screenshots and CSV: ${output}`)
} finally {
  if (socket?.readyState === WebSocket.OPEN && send) {
    try { await send('Browser.close') } catch { /* Chrome may close the socket before replying. */ }
  }
  socket?.close()
  if (chrome.exitCode === null) chrome.kill()
}
