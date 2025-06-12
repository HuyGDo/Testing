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
import { Label, } from '@/components/ui/label';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { X } from 'lucide-react';

const METRICS = [{ id: 'cpu_util_pct', name: 'CPU Utilization (%)' }];
const HORIZONS = [1, 6, 24]; // in hours
const MAX_VMS = 6;

// Custom hook for polling
function usePredictionPolling(taskIds: Record<string, string | null>) {
  const [data, setData] = useState<Record<string, any>>({});
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<any>(null);

  useEffect(() => {
    const activeTaskIds = Object.values(taskIds).filter(Boolean);
    if (activeTaskIds.length === 0) {
      setData({});
      setIsLoading(false);
      return;
    }

    let intervalId: NodeJS.Timeout;
    let attempts = 0;
    const maxAttempts = 60; // 5 minutes polling

    const poll = async () => {
      try {
        const results = await Promise.all(
          Object.entries(taskIds).map(async ([vmId, taskId]) => {
            if (!taskId) return null;
            const statusResult = await getPredictionStatus(taskId);
            return { vmId, result: statusResult };
          })
        );

        const newData: Record<string, any> = {};
        let allCompleted = true;

        results.forEach((result) => {
          if (!result) return;
          const { vmId, result: statusResult } = result;
          
          if (statusResult.status === 'COMPLETED') {
            newData[vmId] = statusResult.result;
          } else if (statusResult.status === 'FAILED') {
            setError(`Prediction failed for VM ${vmId}`);
          } else {
            allCompleted = false;
          }
        });

        setData(newData);
        attempts++;

        if (allCompleted || attempts > maxAttempts) {
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
  }, [taskIds]);

  return { data, isLoading, error };
}

export default function DashboardPage() {
  const { data: vms } = useSWR<VM[]>('/vms', getVMs);
  const [selectedVms, setSelectedVms] = useState<string[]>([]);
  const [selectedMetric, setSelectedMetric] = useState<string>('cpu_util_pct');
  const [selectedHorizon, setSelectedHorizon] = useState<number>(1);
  const [taskIds, setTaskIds] = useState<Record<string, string | null>>({});
  const [recommendation, setRecommendation] = useState<string | null>(null);

  const { data: predictionResults, isLoading: isPredictionLoading, error: predictionError } = usePredictionPolling(taskIds);

  const { data: historicalDataMap, isLoading: isHistoricalLoading } = useSWR(
    selectedVms.length > 0 ? ['/dashboard-data', selectedVms, selectedMetric] : null,
    () => Promise.all(
      selectedVms.map(vmId => getDashboardData(vmId, selectedMetric))
    ).then(results => {
      const map: Record<string, DashboardData[]> = {};
      selectedVms.forEach((vmId, index) => {
        map[vmId] = results[index];
      });
      return map;
    })
  );

  const handleVmSelect = (vmId: string) => {
    if (selectedVms.includes(vmId)) return;
    if (selectedVms.length >= MAX_VMS) {
      alert(`You can only select up to ${MAX_VMS} VMs`);
      return;
    }
    setSelectedVms([...selectedVms, vmId]);
  };

  const handleVmRemove = (vmId: string) => {
    setSelectedVms(selectedVms.filter(id => id !== vmId));
    const newTaskIds = { ...taskIds };
    delete newTaskIds[vmId];
    setTaskIds(newTaskIds);
  };
    
  const handlePredict = async () => {
    if (selectedVms.length === 0) return;

    const newTaskIds: Record<string, string> = {};
    
    try {
      for (const vmId of selectedVms) {
        const { task_id } = await triggerPrediction({
          vm_id: vmId,
          metric: selectedMetric,
          horizon_hours: selectedHorizon,
        });
        newTaskIds[vmId] = task_id;
      }
      
      setTaskIds(newTaskIds);
    } catch (error) {
      console.error("Failed to trigger predictions", error);
    }
  };

  useEffect(() => {
    if (Object.keys(predictionResults || {}).length > 0) {
      const fetchRecommendations = async () => {
        try {
          const recommendations = await Promise.all(
            Object.entries(taskIds)
              .filter(([_, taskId]) => taskId)
              .map(([vmId, taskId]) => getRecommendation(taskId!))
          );
          
          setRecommendation(recommendations.map(r => r.recommendation).join('\n'));
        } catch (error) {
          console.error("Failed to fetch recommendations", error);
          setRecommendation("Could not fetch recommendations.");
        }
      };
      fetchRecommendations();
    } else {
      setRecommendation(null);
    }
  }, [predictionResults, taskIds]);

  // Prepare chart data for all selected VMs
  const chartData = selectedVms.flatMap(vmId => {
    const historical = (historicalDataMap?.[vmId] || []).map(d => ({
      ...d,
      type: 'historical',
      vm: vmId
    }));
    
    const predicted = (predictionResults?.[vmId] || []).map((d: any) => ({
      ...d,
      type: 'predicted',
      vm: vmId
    }));

    return [...historical, ...predicted];
  });

  const getVmName = (vmId: string) => vms?.find(vm => vm.id === vmId)?.name || vmId;

  return (
    <div className="container mx-auto py-10">
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div className="space-y-4">
          <div>
            <Label>Select VMs (max {MAX_VMS})</Label>
            <Select onValueChange={handleVmSelect}>
              <SelectTrigger>
                <SelectValue placeholder="Add a VM" />
              </SelectTrigger>
              <SelectContent>
                {vms?.filter(vm => !selectedVms.includes(vm.id)).map((vm) => (
                  <SelectItem key={vm.id} value={vm.id}>
                    {vm.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="flex flex-wrap gap-2">
            {selectedVms.map(vmId => (
              <Badge key={vmId} variant="secondary" className="flex items-center gap-1">
                {getVmName(vmId)}
                <button
                  onClick={() => handleVmRemove(vmId)}
                  className="ml-1 hover:bg-gray-200 rounded-full p-1"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            ))}
          </div>
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
              <Button
                key={h}
                variant={selectedHorizon === h ? "default" : "outline"}
                onClick={() => setSelectedHorizon(h)}
              >
                {h}h
              </Button>
            ))}
          </div>
        </div>
        <div className="flex items-end">
          <Button
            onClick={handlePredict}
            disabled={selectedVms.length === 0 || isPredictionLoading}
          >
            {isPredictionLoading ? "Predicting..." : "Predict"}
          </Button>
        </div>
      </div>

      {predictionError && <p className='text-red-500 my-4'>{predictionError}</p>}

      {recommendation && (
        <Alert className="my-4">
          <AlertTitle>Recommendation</AlertTitle>
          <AlertDescription>
            {recommendation}
          </AlertDescription>
        </Alert>
      )}

      <div style={{ width: '100%', height: 400 }}>
        {isHistoricalLoading && <p>Loading chart data...</p>}
        <ResponsiveContainer>
          <LineChart data={chartData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="timestamp" />
            <YAxis />
            <Tooltip />
            <Legend />
            {selectedVms.map((vmId, index) => (
              <>
                <Line
                  key={`${vmId}-historical`}
                  type="monotone"
                  dataKey="value"
                  data={chartData.filter(d => d.vm === vmId && d.type === 'historical')}
                  stroke="#2563eb"
                  name={`${getVmName(vmId)} - Historical`}
                  dot={false}
                />
                <Line
                  key={`${vmId}-predicted`}
                  type="monotone"
                  dataKey="value"
                  data={chartData.filter(d => d.vm === vmId && d.type === 'predicted')}
                  stroke="#f97316"
                  name={`${getVmName(vmId)} - Predicted`}
                />
              </>
            ))}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
