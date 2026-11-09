import { request } from './http.js'

export const getSystemInfo = (options = {}) => request('/system/info', options)
