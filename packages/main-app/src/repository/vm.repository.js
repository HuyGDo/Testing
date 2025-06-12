const db = require('../config/database');

/**
 * Converts a JavaScript object to a PostgreSQL hstore string format.
 * Example: { "a": "1", "b": "2" } -> '"a"=>"1","b"=>"2"'
 * @param {object} obj The object to convert.
 * @returns {string} The hstore-formatted string.
 */
function toHstore(obj) {
  if (!obj || typeof obj !== 'object' || Array.isArray(obj)) {
    return '';
  }
  return Object.entries(obj)
    .map(([key, value]) => {
      // Escape quotes and backslashes in keys and values
      const escapedKey = String(key).replace(/"/g, '""').replace(/\\/g, '\\\\');
      const escapedValue = String(value).replace(/"/g, '""').replace(/\\/g, '\\\\');
      return `"${escapedKey}"=>"${escapedValue}"`;
    })
    .join(',');
}

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

module.exports = {
    createVm,
    createVmInTransaction,
    createVmTargetInTransaction,
    getAllVms
};
