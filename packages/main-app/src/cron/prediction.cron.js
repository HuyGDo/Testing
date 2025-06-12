const cron = require('node-cron');
const VmService = require('../services/vm.service');
const PredictionService = require('../services/prediction.service');

/**
 * A helper function to fetch all VMs and trigger predictions for a given set of horizons.
 * This avoids code duplication between the cron jobs.
 * @param {number[]} horizons - An array of prediction horizons in minutes (e.g., [60, 360]).
 * @param {string} jobName - A descriptive name for the cron job for logging purposes.
 */
const runPredictionTasks = async (horizons, jobName) => {
  console.log(`[Cron: ${jobName}] Starting scheduled prediction job for horizons: ${horizons.join(', ')} min.`);
  
  try {
    const vms = await VmService.getAllVms();
    if (!vms || vms.length === 0) {
      console.log(`[Cron: ${jobName}] No VMs found. Skipping prediction tasks.`);
      return;
    }

    console.log(`[Cron: ${jobName}] Found ${vms.length} VMs to process.`);

    // For now, we'll use a default metric for all VMs.
    const metric_name = 'cpu_util_pct';

    // Iterate over each VM and each specified horizon to start a prediction task.
    for (const vm of vms) {
      for (const horizon_min of horizons) {
        console.log(`[Cron: ${jobName}] Starting prediction for VM: ${vm.vm_id}, Horizon: ${horizon_min} min`);
        try {
          // Asynchronously start the prediction, don't wait for it to finish.
          PredictionService.startPrediction(vm.vm_id, metric_name, horizon_min);
        } catch (error) {
          console.log(`[Cron: ${jobName}] Failed to queue prediction for VM ${vm.vm_id}, Horizon ${horizon_min}:`, error);
        }
      }
    }
  } catch (error) {
    console.log(`[Cron: ${jobName}] An unexpected error occurred in the main job loop:`, error);
  }
};

// ==============================================================================
//                          CRON JOB DEFINITIONS
// ==============================================================================

// --- Job 1: Short-Term Predictions ---
// Runs every 15 minutes to generate forecasts for the next 1 and 6 hours.
// Cron Expression: '*/15 * * * *'
cron.schedule('*/15 * * * *', () => {
  const horizonsToRun = [60, 360]; // 1-hour and 6-hour horizons
  runPredictionTasks(horizonsToRun, 'Short-Term');
});

// --- Job 2: Long-Term Predictions ---
// Runs at the beginning of every hour to generate forecasts for the next 24 hours.
// Cron Expression: '0 * * * *'
cron.schedule('0 * * * *', () => {
  const horizonsToRun = [1440]; // 24-hour horizon
  runPredictionTasks(horizonsToRun, 'Long-Term');
});

console.log('Cron jobs for scheduled predictions have been initialized with separate schedules for short-term and long-term horizons.');
