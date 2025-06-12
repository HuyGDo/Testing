const cron = require('node-cron');
const VmService = require('../services/vm.service');
const PredictionService = require('../services/prediction.service');

// This cron job runs every 5 minutes
cron.schedule('*/5 * * * *', async () => {
  console.log('Running scheduled prediction job...');
  try {
    const vms = await VmService.getAllVms();
    if (!vms || vms.length === 0) {
      console.log('No VMs found to run scheduled predictions.');
      return;
    }

    // For now, we'll use a default metric and horizon for all VMs.
    // This could be made more configurable in the future.
    const metric_name = 'cpu_util_pct';
    const horizon_min = 60;

    for (const vm of vms) {
      console.log(`Starting prediction for VM: ${vm.vm_id}`);
      try {
        await PredictionService.startPrediction(vm.vm_id, metric_name, horizon_min);
      } catch (error) {
        console.error(`Failed to start prediction for VM ${vm.vm_id}:`, error);
      }
    }
  } catch (error) {
    console.error('Error in scheduled prediction job:', error);
  }
});

console.log('Cron job for scheduled predictions has been initialized.'); 