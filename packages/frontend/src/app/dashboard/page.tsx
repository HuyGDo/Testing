"use client";

import { useState, useEffect } from 'react';
import useSWR from 'swr';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { getVMs, VM, triggerPrediction, getPredictionStatus, getDashboardData, DashboardData, getRecommendation } from '@/api';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';

const METRICS = [{ id: 'cpu_util_pct', name: 'CPU Utilization (%)' }];
const HORIZONS = [1, 6, 24]; // in hours

// Custom hook for polling
function usePredictionPolling(taskId: string | null) {
  const [data, setData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<any>(null);

  useEffect(() => {
    if (!taskId) {
        setData(null)
        setIsLoading(false)
        return
    };

    let intervalId: NodeJS.Timeout;
    let attempts = 0;
    const maxAttempts = 60; // 5 minutes polling
    const poll = async () => {
        try {
            const statusResult = await getPredictionStatus(taskId);
            attempts++;
            if (statusResult.status === 'COMPLETED') {
                setData(statusResult.result);
                setIsLoading(false);
                clearInterval(intervalId);
            } else if (statusResult.status === 'FAILED') {
                setError('Prediction failed.');
                setIsLoading(false);
                clearInterval(intervalId);
            } else if (attempts > maxAttempts) {
                setError('Prediction timed out.');
                setIsLoading(false);
                clearInterval(intervalId);
            }
        } catch (err) {
            setError(err);
            setIsLoading(false);
            clearInterval(intervalId);
      }
    };

    setIsLoading(true);
    setError(null);
    intervalId = setInterval(poll, 5000); // Poll every 5 seconds

    return () => clearInterval(intervalId);
  }, [taskId]);

  return { data, isLoading, error };
}

export default function DashboardPage() {
  const { data: vms } = useSWR<VM[]>('/vms', getVMs);
  const [selectedVm, setSelectedVm] = useState<string>('');
  const [selectedMetric, setSelectedMetric] = useState<string>('cpu_util_pct');
  const [selectedHorizon, setSelectedHorizon] = useState<number>(1);
  const [taskId, setTaskId] = useState<string | null>(null);
  const [recommendation, setRecommendation] = useState<string | null>(null);

  const { data: predictionResult, isLoading: isPredictionLoading, error: predictionError } = usePredictionPolling(taskId);

  const { data: historicalData, isLoading: isHistoricalLoading } = useSWR(
    selectedVm ? ['/dashboard-data', selectedVm, selectedMetric] : null,
    () => getDashboardData(selectedVm, selectedMetric)
  );
    
  const handlePredict = async () => {
    if (!selectedVm) return;
    setTaskId(null)
    const { task_id } = await triggerPrediction({
      vm_id: selectedVm,
      metric: selectedMetric,
      horizon_hours: selectedHorizon,
    });
    setTaskId(task_id);
  };

  useEffect(() => {
    if (predictionResult) {
        const fetchRecommendation = async () => {
            try {
                if (taskId) {
                    const rec = await getRecommendation(taskId);
                    setRecommendation(rec.recommendation);
                }
            } catch (error) {
                console.error("Failed to fetch recommendation", error);
                setRecommendation("Could not fetch recommendation.");
            }
        };
        fetchRecommendation();
    } else {
        setRecommendation(null);
    }
  }, [predictionResult, taskId]);

  const chartData = (historicalData || []).map(d => ({ ...d, type: 'historical' }))
  .concat((predictionResult || []).map((d: any) => ({ ...d, type: 'predicted' })));


  return (
    <div className="container mx-auto py-10">
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div>
          <Label>Select VM</Label>
          <Select onValueChange={setSelectedVm} value={selectedVm}>
            <SelectTrigger>
              <SelectValue placeholder="Select a VM" />
            </SelectTrigger>
            <SelectContent>
              {vms?.map((vm) => (
                <SelectItem key={vm.id} value={vm.id}>
                  {vm.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div>
          <Label>Select Metric</Label>
          <Select onValueChange={setSelectedMetric} value={selectedMetric} disabled>
            <SelectTrigger>
              <SelectValue placeholder="Select a metric" />
            </SelectTrigger>
            <SelectContent>
              {METRICS.map((metric) => (
                <SelectItem key={metric.id} value={metric.id}>
                  {metric.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div>
            <Label>Prediction Horizon (Hours)</Label>
            <div className="flex gap-2 mt-2">
                {HORIZONS.map(h => (
                    <Button key={h} variant={selectedHorizon === h ? "default" : "outline"} onClick={() => setSelectedHorizon(h)}>{h}h</Button>
                ))}
            </div>
        </div>
        <div className="flex items-end">
            <Button onClick={handlePredict} disabled={!selectedVm || isPredictionLoading}>
                {isPredictionLoading ? "Predicting..." : "Predict"}
            </Button>
        </div>
      </div>
      {(predictionError) && <p className='text-red-500 my-4'>{predictionError}</p>}

      {recommendation && (
        <Alert className="my-4">
            <AlertTitle>Recommendation</AlertTitle>
            <AlertDescription>
                {recommendation}
            </AlertDescription>
        </Alert>
      )}

      <div style={{ width: '100%', height: 400 }}>
        {(isHistoricalLoading) && <p>Loading chart data...</p>}
        <ResponsiveContainer>
          <LineChart data={chartData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="timestamp" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="value" stroke="#8884d8" name="Historical" dot={false} />
            <Line type="monotone" dataKey="value" data={chartData.filter(d => d.type === 'predicted')} stroke="#82ca9d" name="Predicted" />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
