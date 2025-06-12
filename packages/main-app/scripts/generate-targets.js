const { Pool } = require('pg');
const fs = require('fs/promises');
const path = require('path');

require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

const pool = new Pool({
    user: process.env.PGUSER || 'huygdo',
    host: process.env.PGHOST || 'localhost',
    database: process.env.PGDATABASE || 'metrics',
    password: process.env.PGPASSWORD || '',
    port: process.env.PGPORT || 5432,
});

/**
 * Converts a PostgreSQL hstore string to a JavaScript object.
 * This is a robust replacement for the node-hstore library's parse function.
 * @param {string} hstoreString The hstore-formatted string from the database.
 * @returns {object} The parsed JavaScript object.
 */
function fromHstore(hstoreString) {
  if (!hstoreString || typeof hstoreString !== 'string') {
    return {};
  }
  const result = {};
  const regex = /"([^"\\]*(?:\\.[^"\\]*)*)"=>"([^"\\]*(?:\\.[^"\\]*)*)"/g;
  let match;
  while ((match = regex.exec(hstoreString)) !== null) {
      const key = match[1].replace(/\\"/g, '"').replace(/\\\\/g, '\\');
      const value = match[2].replace(/\\"/g, '"').replace(/\\\\/g, '\\');
      result[key] = value;
  }
  return result;
}

async function generateTargets() {
    console.log('Generating Prometheus targets file...');
    const client = await pool.connect();
    try {
        const { rows } = await client.query(`
            SELECT t.port, t.scrape, t.labels, v.ip_address
            FROM prom_sd_static_targets t
            JOIN vm v ON t.vm_id = v.vm_id
            WHERE t.scrape = TRUE;
        `);

        const targets = rows.map(row => {
            // Use our robust fromHstore function instead of the buggy library
            const hstoreData = fromHstore(row.labels);
            return {
                targets: [`${row.ip_address}:${row.port}`],
                labels: hstoreData
            };
        });

        const targetsJsonPath = path.resolve(__dirname, '../../../packages/infra/prometheus/targets.json');
        await fs.writeFile(targetsJsonPath, JSON.stringify(targets, null, 2));

        console.log(`Successfully wrote ${targets.length} targets to ${targetsJsonPath}`);
    } catch (error) {
        console.error('Error generating targets file:', error);
    } finally {
        client.release();
        await pool.end();
    }
}

generateTargets(); 