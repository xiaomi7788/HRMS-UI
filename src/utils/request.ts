import axios, {
  type AxiosInstance,
  type AxiosRequestConfig,
  type AxiosResponse,
  type InternalAxiosRequestConfig,
} from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'

// 响应数据结构（根据实际后端返回格式调整）
export interface ApiResponse<T = unknown> {
  code: number
  message: string
  data: T
}

// 创建 axios 实例
const service: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json;charset=utf-8',
  },
})

// ---- 请求拦截器 ----
service.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    // 自动携带 token
    const token = localStorage.getItem('hrm_token')
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  },
)

// ---- 响应拦截器 ----
service.interceptors.response.use(
  (response: AxiosResponse<ApiResponse>) => {
    const { code, message, data } = response.data

    // 业务逻辑成功
    if (code === 200 || code === 0) {
      return data as unknown as AxiosResponse
    }

    // token 过期或未登录
    if (code === 401) {
      ElMessageBox.confirm('登录已过期，请重新登录', '提示', {
        confirmButtonText: '重新登录',
        cancelButtonText: '取消',
        type: 'warning',
      }).then(() => {
        localStorage.removeItem('hrm_token')
        window.location.href = '/login'
      })
      return Promise.reject(new Error(message || '未授权'))
    }

    // 其他业务错误
    ElMessage.error(message || '请求失败')
    return Promise.reject(new Error(message || '请求失败'))
  },
  (error) => {
    // HTTP 错误状态码处理
    const status = error.response?.status
    const messageMap: Record<number, string> = {
      400: '请求参数错误',
      401: '未授权，请登录',
      403: '拒绝访问',
      404: '请求资源不存在',
      500: '服务器内部错误',
      502: '网关错误',
      503: '服务暂不可用',
    }
    const msg = messageMap[status] || error.message || '网络异常，请稍后再试'
    ElMessage.error(msg)
    return Promise.reject(error)
  },
)

// ---- 封装通用请求方法 ----
const request = {
  get<T = unknown>(url: string, params?: object, config?: AxiosRequestConfig): Promise<T> {
    return service.get(url, { params, ...config }) as Promise<T>
  },
  post<T = unknown>(url: string, data?: object, config?: AxiosRequestConfig): Promise<T> {
    return service.post(url, data, config) as Promise<T>
  },
  put<T = unknown>(url: string, data?: object, config?: AxiosRequestConfig): Promise<T> {
    return service.put(url, data, config) as Promise<T>
  },
  delete<T = unknown>(url: string, params?: object, config?: AxiosRequestConfig): Promise<T> {
    return service.delete(url, { params, ...config }) as Promise<T>
  },
  upload<T = unknown>(url: string, formData: FormData, config?: AxiosRequestConfig): Promise<T> {
    return service.post(url, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      ...config,
    }) as Promise<T>
  },
}

export default request
export { service as axiosInstance }
