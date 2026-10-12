// Local stand-in for egov-user, for running trade license flows without egov-enc-service.
//
// The real egov-user encrypts names and mobile numbers through egov-enc-service, which only works
// with the master password of the environment that owns the database. This stub avoids that:
// it never touches the database. Create/update echo the user back with the uuid of the logged-in
// user (RequestInfo.userInfo), and search returns a minimal user for each requested uuid.
//
//   node user-stub.js          (listens on http://localhost:8091)
const http = require('http');
const PORT = process.env.USER_STUB_PORT || 8091;
// existing citizen that becomes the owner of applications created by an employee
const COUNTER_CITIZEN_UUID = process.env.STUB_CITIZEN_UUID || '57a3e9c0-fc9e-480c-bf12-2d6a964d134c';
const COUNTER_CITIZEN_ID = Number(process.env.STUB_CITIZEN_ID || 17253);
const DATE_FIELDS =['dob', 'pwdExpiryDate', 'createdDate', 'lastModifiedDate'];

// egov-user returns audit dates as "dd-MM-yyyy HH:mm:ss"; callers parse createdDate unconditionally
function now() {
  const d = new Date(), p = n => String(n).padStart(2, '0');
  return `${p(d.getDate())}-${p(d.getMonth() + 1)}-${d.getFullYear()} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`;
}

function requestInfoOf(body) {
  return body.RequestInfo || body.requestInfo || {};
}

function minimalUser(uuid, info) {
  const u = info.userInfo || {};
  const same = u.uuid === uuid;
  return {
    id: same && u.id ? u.id : 1,
    uuid,
    userName: same && u.userName ? u.userName : uuid,
    name: same && u.name ? u.name : 'STUB USER',
    mobileNumber: same && u.mobileNumber ? u.mobileNumber : '9999999999',
    type: 'CITIZEN',
    active: true,
    createdDate: now(),
    lastModifiedDate: now(),
    tenantId: u.tenantId || 'pg',
    // any user other than the caller is treated as a citizen; the workflow service checks these
    // roles when an application is assigned back to its owner (SENDBACKTOCITIZEN)
    roles: same && u.roles ? u.roles : [{ code: 'CITIZEN', name: 'Citizen', tenantId: 'pg' }]
  };
}

function handle(path, body) {
  const info = requestInfoOf(body);
  const loggedIn = info.userInfo || {};
  if (/_createnovalidate|_updatenovalidate/.test(path)) {
    const user = Object.assign({}, body.user || body.User || {});
    DATE_FIELDS.forEach(f => delete user[f]);
    // a citizen applies for themselves; an employee at the counter applies for a citizen
    const selfService = loggedIn.type === 'CITIZEN';
    if (!user.uuid) user.uuid = selfService ? loggedIn.uuid : COUNTER_CITIZEN_UUID;
    if (!user.id) user.id = selfService ? (loggedIn.id || 1) : COUNTER_CITIZEN_ID;
    user.createdDate = now();
    user.lastModifiedDate = now();
    return { responseInfo: {}, user: [user] };
  }
  if (/_search/.test(path)) {
    const uuids = body.uuid && body.uuid.length ? body.uuid : (loggedIn.uuid ? [loggedIn.uuid] : []);
    return { responseInfo: {}, user: uuids.map(id => minimalUser(id, info)) };
  }
  return null;
}

http.createServer((req, res) => {
  let raw = '';
  req.on('data', c => (raw += c));
  req.on('end', () => {
    let body = {};
    try { body = raw ? JSON.parse(raw) : {}; } catch (e) { /* keep empty */ }
    const out = handle(req.url, body);
    console.log(new Date().toISOString(), req.method, req.url, out ? 'OK' : '404');
    res.writeHead(out ? 200 : 404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(out || { Errors: [{ code: 'STUB_NOT_FOUND', message: req.url }] }));
  });
}).listen(PORT, '127.0.0.1', () => console.log('user stub listening on ' + PORT));
