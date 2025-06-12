const vmRepository = require('../repository/vm.repository');
const db = require('../config/database');

async function createVm(vmData) {
    const client = await db.getClient();
    try {
        await client.query('BEGIN');

        const newVm = await vmRepository.createVmInTransaction(vmData, client);

        const targetData = {
            vm_id: newVm.vm_id,
            job_name: 'node_exporter',
            port: 9100, // Default node_exporter port
            labels: {
                instance: newVm.name
            }
        };

        await vmRepository.createVmTargetInTransaction(targetData, client);

        await client.query('COMMIT');
        return newVm;
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

async function getAllVms() {
    const vms = await vmRepository.getAllVms();
    return vms.map(vm => ({
        id: vm.vm_id,
        name: vm.name,
        ip_address: vm.ip_address,
        status: 'active' // Assuming all fetched VMs are active
    }));
}

module.exports = {
    createVm,
    getAllVms,
};
