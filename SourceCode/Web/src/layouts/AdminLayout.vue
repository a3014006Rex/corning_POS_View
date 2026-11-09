<template>
  <div class="admin-layout">
    <header class="bg-white border-bottom p-3"><div class="container d-flex align-items-center justify-content-between gap-3 flex-wrap"><RouterLink to="/admin/transactions" class="h5 mb-0 text-decoration-none">康寧餐卡管理後台</RouterLink><nav class="d-flex gap-4"><RouterLink to="/pos">POS</RouterLink><RouterLink to="/system">系統狀態</RouterLink></nav></div></header>
    <main class="container py-4"><p class="text-secondary">前期開發驗證 · 正式帳號、權限與舊 DB 尚未接入</p><RouterView /></main>
  </div>
</template>

<style scoped>
.admin-layout { min-height: 100svh; }
</style>
