"use client";

import { useState, useEffect, useRef } from 'react';
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

export default function DashboardPage() {
  const { data: vms } = useSWR<VM[]>('/vms', getVMs);
  const [selectedVms, setSelectedVms] = useState<string[]>([]);
  const [selectedMetric, setSelectedMetric] = useState<string>('cpu_util_pct');
  const [selectedHorizon, setSelectedHorizon] = useState<number>(1);
  const [taskIds, setTaskIds] = useState<Record<string, string | null>>({});
  
  // State for prediction results and loading status
  const [predictionResults, setPredictionResults] = useState<Record<string, any>>({});
  const [isPredictionLoading, setIsPredictionLoading] = useState(false);
  const [recommendation, setRecommendation] = useState<string | null>(null);

  // Use a ref to keep track of active EventSource connections
  const eventSources = useRef<Record<string, EventSource>>({});

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

  // Effect to handle SSE connections
  useEffect(() => {
    // Close any connections for deselected VMs
    Object.keys(eventSources.current).forEach(vmId => {
      if (!selectedVms.includes(vmId)) {
        eventSources.current[vmId].close();
        delete eventSources.current[vmId];
      }
    });

    // Create new connections for selected VMs
    selectedVms.forEach(vmId => {
      if (!eventSources.current[vmId]) {
        const url = process.env.NEXT_PUBLIC_API_URL ? `${process.env.NEXT_PUBLIC_API_URL}/predict/events/${vmId}` : `http://localhost:3000/api/predict/events/${vmId}`;
        const eventSource = new EventSource(url);

        eventSource.onmessage = async (event) => {
          const data = JSON.parse(event.data);
          if (data.event === 'prediction_ready' && data.task_id) {
            // Fetch the completed prediction result
            const result = await getPredictionStatus(data.task_id);
            if (result.status === 'COMPLETED') {
              setPredictionResults(prev => ({...prev, [vmId]: result.result}));
              // Fetch recommendation for this specific task
              const rec = await getRecommendation(data.task_id);
              setRecommendation(prev => `${prev || ''}\nVM ${getVmName(vmId)}: ${rec.recommendation}`);
            }
            // Once we get the update, we can assume the process for this VM is done
            setIsPredictionLoading(false); 
          }
        };

        eventSource.onerror = (err) => {
          console.error('EventSource failed:', err);
          eventSource.close();
          delete eventSources.current[vmId];
        };
        
        eventSources.current[vmId] = eventSource;
      }
    });

    // Cleanup on component unmount
    return () => {
      Object.values(eventSources.current).forEach(es => es.close());
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedVms]);

  const handleVmSelect = (vmId: string) => {
    if (selectedVms.includes(vmId)) return;
    if (selectedVms.length >= 6) {
      alert(`You can only select up to 6 VMs`);
      return;
    }
    setSelectedVms([...selectedVms, vmId]);
  };

  const handleVmRemove = (vmId: string) => {
    setSelectedVms(selectedVms.filter(id => id !== vmId));
    // Also clear prediction results and task for the removed VM
    setPredictionResults(prev => {
      const next = {...prev};
      delete next[vmId];
      return next;
    });
    setTaskIds(prev => {
        const next = {...prev};
        delete next[vmId];
        return next;
    })
  };

  const handlePredict = async () => {
    if (selectedVms.length === 0) return;

    setIsPredictionLoading(true);
    setPredictionResults({}); // Clear old results
    setRecommendation(null);  // Clear old recommendations
    
    const newTasks: Record<string, string | null> = {};
    try {
      for (const vmId of selectedVms) {
        const { task_id } = await triggerPrediction({
          vm_id: vmId,
          metric: selectedMetric,
          horizon_hours: selectedHorizon,
        });
        newTasks[vmId] = task_id;
      }
      setTaskIds(newTasks);
    } catch (error) {
      console.error("Failed to trigger predictions", error);
      setIsPredictionLoading(false);
    }
  };

  const getVmName = (vmId: string) => vms?.find(vm => vm.id === vmId)?.name || vmId;

  const chartData = selectedVms.flatMap(vmId => {
    const historical = (historicalDataMap?.[vmId] || []).map(d => ({
      ...d,
      timestamp: new Date(d.timestamp).toLocaleString(), // Format date for chart
      type: 'historical',
      vm: vmId
    }));

    const predictedData = predictionResults[vmId];
    // The prediction result from Redis is now an array of numbers, not objects with timestamps.
    // We need to generate future timestamps.
    const lastHistoricalPoint = historical[historical.length - 1];
    const predicted = Array.isArray(predictedData) && lastHistoricalPoint ? predictedData.map((value, index) => {
        const nextTimestamp = new Date(new Date(lastHistoricalPoint.timestamp).getTime() + (index + 1) * 60000);
        return {
            timestamp: nextTimestamp.toLocaleString(),
            value: value,
            type: 'predicted',
            vm: vmId,
        };
    }) : [];
    
    return [...historical, ...predicted];
  });

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
