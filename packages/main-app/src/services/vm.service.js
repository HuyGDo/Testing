const vmRepository = require('../repository/vm.repository');
const db = require('../config/database');
const fs = require('fs/promises');
const path = require('path');
const { fromHstore } = require('../utils/hstore.util');

const targetsPath = path.resolve(__dirname, '../../../infra/prometheus/targets.json');

// Helper to read Prometheus targets
async function getPrometheusTargets() {
    try {
        const data = await fs.readFile(targetsPath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        if (error.code === 'ENOENT') return []; // File doesn't exist yet
        throw error;
    }
}

// Helper to write Prometheus targets
async function writePrometheusTargets(targets) {
    await fs.writeFile(targetsPath, JSON.stringify(targets, null, 2));
}

async function regenerateTargets() {
    console.log('Generating Prometheus targets file...');
    const client = await db.getClient();
    try {
        const { rows } = await client.query(`
            SELECT t.port, t.scrape, t.labels, v.ip_address
            FROM prom_sd_static_targets t
            JOIN vm v ON t.vm_id = v.vm_id
            WHERE t.scrape = TRUE;
        `);

        const targets = rows.map(row => {
            const hstoreData = fromHstore(row.labels);
            return {
                targets: [`${row.ip_address}:${row.port}`],
                labels: hstoreData
            };
        });

        await writePrometheusTargets(targets);

        console.log(`Successfully wrote ${targets.length} targets to ${targetsPath}`);
        return { success: true, count: targets.length, path: targetsPath };
    } catch (error) {
        console.error('Error generating targets file:', error);
        throw error;
    } finally {
        client.release();
    }
}

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
                instance: newVm.name,
                ...vmData.labels
            }
        };
        await vmRepository.createVmTargetInTransaction(targetData, client);
        
        // Add to prometheus targets.json
        const targets = await getPrometheusTargets();
        targets.push({
            targets: [`${newVm.ip_address}:${targetData.port}`],
            labels: { instance: newVm.name, ...vmData.labels }
        });
        await writePrometheusTargets(targets);

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
    // Assuming 'active' status and mapping vm_id to id
    return vms.map(vm => ({
        id: vm.vm_id,
        name: vm.name,
        ip_address: vm.ip_address,
        status: 'active'
    }));
}

async function deleteVm(vmId) {
    const client = await db.getClient();
    try {
        await client.query('BEGIN');
        
        // First, get vm details to remove it from targets.json
        const vmResult = await client.query('SELECT ip_address, name FROM vm WHERE vm_id = $1', [vmId]);
        if (vmResult.rows.length === 0) throw new Error('VM not found');
        const vm = vmResult.rows[0];

        // Delete from DB
        await vmRepository.deleteVmTargetsInTransaction(vmId, client);
        await vmRepository.deleteVmInTransaction(vmId, client);

        // Remove from prometheus targets.json
        const targets = await getPrometheusTargets();
        const updatedTargets = targets.filter(t => !t.targets.includes(`${vm.ip_address}:9100`));
        await writePrometheusTargets(updatedTargets);

        await client.query('COMMIT');
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}

module.exports = {
    createVm,
    getAllVms,
    deleteVm,
    regenerateTargets
};