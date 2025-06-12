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
      const escape = (str) => String(str).replace(/\\/g, '\\\\').replace(/"/g, '\\"');
      return `"${escape(key)}"=>"${escape(value)}"`;
    })
    .join(',');
}


module.exports = {
    fromHstore,
    toHstore
} 