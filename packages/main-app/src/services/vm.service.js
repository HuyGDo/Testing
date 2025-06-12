// packages/main-app/src/services/vm.service.js

const vmRepository = require('../repository/vm.repository');
const db = require('../config/database');
const fs = require('fs/promises');
const path = require('path');
const { fromHstore } = require('../utils/hstore.util'); // Assumes you have this utility
const { Console } = require('console');

const targetsPath = path.resolve(__dirname, '../../../infra/prometheus/targets.json');

/**
 * Generates the targets.json file by joining vm and prom_sd_static_targets.
 * This is the single source of truth for creating the Prometheus configuration.
 */
async function syncPrometheusTargets() {
    console.log('Generating Prometheus targets file from database...');
    const client = await db.getClient();
    try {
        // This query correctly joins the tables to get all necessary info
        // for active scrape targets.
        const { rows } = await client.query(`
            SELECT t.port, t.labels AS target_labels, v.name, v.vm_id, v.ip_address
            FROM prom_sd_static_targets t
            JOIN vm v ON t.vm_id = v.vm_id
            WHERE t.scrape = TRUE;
        `);

        // Map the database rows to the structure Prometheus expects.
        const targets = rows.map(row => {
            const hstoreData = fromHstore(row.target_labels);
            return {
                targets: [`${row.ip_address}:${row.port}`],
                labels: {
                    instance: row.name, // Use the VM name as the instance label
                    vm_id: row.vm_id.toString(),
                    ...hstoreData
                }
            };
        });

        await fs.writeFile(targetsPath, JSON.stringify(targets, null, 2));

        console.log(`Successfully wrote ${targets.length} targets to ${targetsPath}`);
        return { success: true, count: targets.length, path: targetsPath };
    } catch (error) {
        console.log('Error generating Prometheus targets file:', error);
        throw error;
    } finally {
        client.release();
    }
}

/**
 * Creates a VM and its associated scrape target in a single transaction.
 * Afterwards, it triggers a full sync to update the targets.json file.
 * @param {object} vmData - Contains 'name', 'ip_address', and optional 'labels'.
 */
async function createVm(vmData) {
    const client = await db.getClient();
    try {
        await client.query('BEGIN');

        // Step 1: Create the VM entry
        const newVm = await vmRepository.createVmInTransaction(vmData, client);

        // Step 2: Create the associated Prometheus scrape configuration
        const targetData = {
            vm_id: newVm.vm_id,
            job_name: 'node_exporter',
            port: 9100, // Default port
            scrape: true,
            labels: { instance: newVm.name, ...vmData.labels }
        };
        await vmRepository.createVmTargetInTransaction(targetData, client);

        await client.query('COMMIT');
        console.log(`Database transaction for new VM ${newVm.name} committed.`);
        
        // Step 3: Regenerate the targets.json file to reflect the new addition
        await syncPrometheusTargets();

        return newVm;
    } catch (error) {
        await client.query('ROLLBACK');
        console.log(`Error creating VM, transaction rolled back: ${error.message}`);
        throw error;
    } finally {
        client.release();
    }
}

/**
 * Deletes a VM and its scrape target in a transaction, then updates targets.json.
 * @param {string} vmId - The UUID of the VM to delete.
 */
async function deleteVm(vmId) {
    const client = await db.getClient();
    try {
        await client.query('BEGIN');

        // The repository should handle deleting from both tables
        const deletedVm = await vmRepository.deleteVmAndTargetInTransaction(vmId, client);
        if (!deletedVm) throw new Error('VM not found');
        
        await client.query('COMMIT');
        console.log(`Database transaction for deleting VM ${vmId} committed.`);

        // Regenerate the targets file to remove the deleted VM
        await syncPrometheusTargets();
        
        return { message: `VM ${deletedVm.name} deleted successfully.` };
    } catch (error) {
        await client.query('ROLLBACK');
        console.log(`Error deleting VM ${vmId}, transaction rolled back: ${error.message}`);
        throw error;
    } finally {
        client.release();
    }
}

async function getAllVms() {
    return await vmRepository.getAllVms();
}

module.exports = {
    createVm,
    getAllVms,
    deleteVm,
    syncPrometheusTargets,
};