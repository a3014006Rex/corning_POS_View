const cell = (value) => {
  let text = String(value ?? '')
  if (/^[\s]*[=+@-]/.test(text)) text = `'${text}`
  return `"${text.replaceAll('"', '""')}"`
}

export function simulationCsv(rows) {
  const lines = [['測試交易編號', '原交易編號', '員編', '姓名', '時間', '金額（元）', '狀態（僅模擬）'],
    ...rows.map((row) => [row.transactionId, row.clientTransactionId, row.person.employeeCode,
      row.person.name, row.recordedAt, (row.totalAmountMinor / 100).toFixed(2), row.status])]
  return '\uFEFF' + lines.map((line) => line.map(cell).join(',')).join('\r\n')
}
