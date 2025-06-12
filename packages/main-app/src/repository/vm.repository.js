const db = require('../config/database');
const { toHstore } = require('../utils/hstore.util');

async function createVm(vm) {
    const { name, ip_address, labels } = vm;
    const query = `
        INSERT INTO vm (name, ip_address, labels)
        VALUES ($1, $2, $3)
        RETURNING *;
    `;
    const { rows } = await db.query(query, [name, ip_address, toHstore(labels)]);
    return rows[0];
}

async function createVmInTransaction(vm, client) {
    const { name, ip_address, labels } = vm;
    const query = `
        INSERT INTO vm (name, ip_address, labels)
        VALUES ($1, $2, $3)
        RETURNING *;
    `;
    const { rows } = await client.query(query, [name, ip_address, toHstore(labels)]);
    return rows[0];
}


async function createVmTargetInTransaction(target, client) {
    const { vm_id, job_name, port, labels } = target;
    const query = `
        INSERT INTO prom_sd_static_targets (vm_id, job_name, port, labels)
        VALUES ($1, $2, $3, $4)
        RETURNING *;
    `;
    const { rows } = await client.query(query, [vm_id, job_name, port, toHstore(labels)]);
    return rows[0];
}

async function getAllVms() {
    const { rows } = await db.query('SELECT * FROM vm ORDER BY created_at DESC');
    return rows;
}

async function deleteVmInTransaction(vmId, client) {
    const query = 'DELETE FROM vm WHERE vm_id = $1';
    await client.query(query, [vmId]);
}

async function deleteVmTargetsInTransaction(vmId, client) {
    const query = 'DELETE FROM prom_sd_static_targets WHERE vm_id = $1';
    await client.query(query, [vmId]);
}

module.exports = {
    createVm,
    createVmInTransaction,
    createVmTargetInTransaction,
    getAllVms,
    deleteVmInTransaction,
    deleteVmTargetsInTransaction
};
