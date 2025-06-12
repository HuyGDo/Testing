import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api',
});

export default api;

export interface VM {
    id: string;
    name:string;
    ip_address: string;
    status: string;
}

export const getVMs = async (): Promise<VM[]> => {
    const response = await api.get('/vms');
    return response.data;
};

export const addVM = async (vm: Omit<VM, 'id' | 'status'>): Promise<VM> => {
    const response = await api.post('/vms', vm);
    return response.data;
};

export const deleteVM = async (id: string): Promise<void> => {
    await api.delete(`/vms/${id}`);
};

export interface PredictionRequest {
    vm_id: string;
    metric: string;
    horizon_hours: number;
}

export interface PredictionTask {
    task_id: string;
}

export interface PredictionStatus {
    status: 'PENDING' | 'COMPLETED' | 'FAILED';
    result?: any[];
}

export interface DashboardData {
    timestamp: string;
    value: number;
}

export const triggerPrediction = async (data: PredictionRequest): Promise<PredictionTask> => {
    const response = await api.post('/predict', data);
    return response.data;
};

export const getPredictionStatus = async (taskId: string): Promise<PredictionStatus> => {
    const response = await api.get(`/predict/status/${taskId}`);
    return response.data;
};

export const getDashboardData = async (vmId: string, metric: string): Promise<DashboardData[]> => {
    const response = await api.get('/dashboard-data', { params: { vm_id: vmId, metric } });
    return response.data;
};

export interface Recommendation {
    recommendation: string;
}

export const getRecommendation = async (taskId: string): Promise<Recommendation> => {
    const response = await api.get('/recommendations', { params: { task_id: taskId } });
    return response.data;
};
