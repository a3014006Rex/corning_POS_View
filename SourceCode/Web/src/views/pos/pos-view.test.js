import { afterEach, describe, expect, it } from 'vitest'
import { createApp, nextTick } from 'vue'
import { createPinia } from 'pinia'
import { createMemoryHistory, createRouter } from 'vue-router'
import PosView from './pos-view.vue'

let app
let container
afterEach(() => {
  app?.unmount()
  container?.remove()
})

describe('POS view', () => {
  it('confirms the demo once and clears the previous person on next', async () => {
    const router = createRouter({ history: createMemoryHistory(), routes: [
      { path: '/pos', component: PosView },
      { path: '/system', component: { template: '<div />' } },
      { path: '/admin/transactions', component: { template: '<div />' } },
      { path: '/development', component: { template: '<div />' } },
    ] })
    await router.push('/pos?preview=ready')
    await router.isReady()
    container = document.createElement('div')
    document.body.appendChild(container)
    app = createApp(PosView).use(createPinia()).use(router)
    app.mount(container)
    const amount = container.querySelector('#amount')
    expect(amount.disabled).toBe(false)
    amount.value = '80'
    amount.dispatchEvent(new Event('input', { bubbles: true }))
    await nextTick()
    container.querySelector('.card-form').dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }))
    await nextTick()
    expect(container.querySelector('#submit').disabled).toBe(true)
    expect(container.querySelector('.pos-status').textContent).toContain('未送出實際交易')
    container.querySelector('.next-person').click()
    await nextTick()
    expect(container.textContent).not.toContain('DEMO-00128')
    expect(amount.value).toBe('')
    expect(container.querySelector('#submit').disabled).toBe(true)
    const select = container.querySelector('.preview-control select')
    select.value = 'ready'
    select.dispatchEvent(new Event('change', { bubbles: true }))
    await nextTick()
    expect(amount.disabled).toBe(false)
    expect(container.textContent).toContain('DEMO-00128')
  })
})
