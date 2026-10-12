// Lets you use the deployed UI in the browser against the trade license services running on this machine,
// without building the React app.
//
//   node ui-proxy.js        then open  http://localhost:3000/upyog-ui/citizen  or  .../upyog-ui/employee
//
// - The UI itself and every API not listed in LOCAL_ROUTES are fetched from the deployed server.
// - Calls to the services in LOCAL_ROUTES go to the local stack (start-local.ps1). The deployed gateway
//   normally adds the logged-in user to RequestInfo; here this proxy does it: it resolves the authToken
//   with the real user service (connect-server.ps1 forwards it to localhost:8081) and sets RequestInfo.userInfo.
// - Role-to-API permission checks of the real gateway are NOT done here.
const http = require('http');
const https = require('https');
const { URL } = require('url');

const PORT = Number(process.env.UI_PROXY_PORT || 3000);
const SERVER = new URL(process.env.UI_PROXY_SERVER || 'https://sangamner-demo.ddns.net');
const USER_SERVICE = process.env.UI_PROXY_USER_SERVICE || 'http://localhost:8081';
// UI_PROXY_LOCAL_ONLY=true (start-local-all.ps1 is running): every API is served by this machine and nothing
// is fetched from the deployed server; a call to a service that does not run locally is answered with 502.
const LOCAL_ONLY = process.env.UI_PROXY_LOCAL_ONLY === 'true';
const LOCAL_ROUTES = {
  '/tl-services': 'http://localhost:8079',
  '/tl-calculator': 'http://localhost:8085',
  '/egov-workflow-v2': 'http://localhost:8280',
  '/billing-service': 'http://localhost:8082',
  '/collection-services': 'http://localhost:8095'
};
if (LOCAL_ONLY) Object.assign(LOCAL_ROUTES, {
  '/user-otp': 'http://localhost:8092',
  '/user': 'http://localhost:8081',
  '/egov-mdms-service': 'http://localhost:8094',
  '/localization': 'http://localhost:8096',
  '/access': 'http://localhost:8097',
  '/filestore': 'http://localhost:8083',
  '/egov-hrms': 'http://localhost:9999',
  '/egov-location': 'http://localhost:8086',
  '/property-services': 'http://localhost:8087',
  '/ws-services': 'http://localhost:8089'
});

// The receipt and the certificate are rendered by the local pdf-service (preview-pdf.ps1 -Rebuild) so that the
// SMC formats under test are the ones the browser downloads; every other PDF key still goes to the server.
const LOCAL_PDF_SERVICE = process.env.UI_PROXY_PDF_SERVICE || 'http://localhost:8098';
const LOCAL_PDF_KEYS = ['tlcertificate', 'tradelicense-receipt', 'tl-loi'];

const userCache = new Map();   // authToken -> { userInfo, expires }

function localTarget(path, url) {
  if (path.startsWith('/pdf-service/')) {
    if (LOCAL_ONLY) return LOCAL_PDF_SERVICE;
    const key = new URL(url, 'http://localhost').searchParams.get('key');
    return LOCAL_PDF_KEYS.includes(key) ? LOCAL_PDF_SERVICE : null;
  }
  const prefix = Object.keys(LOCAL_ROUTES).find(p => path === p || path.startsWith(p + '/'));
  return prefix ? LOCAL_ROUTES[prefix] : null;
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', c => chunks.push(c));
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

// the same lookup the deployed gateway does: token -> user with roles
function resolveUser(token) {
  const cached = userCache.get(token);
  if (cached && cached.expires > Date.now()) return Promise.resolve(cached.userInfo);
  return new Promise((resolve, reject) => {
    const u = new URL('/user/_details?access_token=' + encodeURIComponent(token), USER_SERVICE);
    const r = http.request(u, { method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': 0 } }, res => {
      const chunks = [];
      res.on('data', c => chunks.push(c));
      res.on('end', () => {
        const text = Buffer.concat(chunks).toString('utf8');
        if (res.statusCode !== 200) return reject(new Error('user service answered ' + res.statusCode + ': ' + text.slice(0, 200)));
        try {
          const userInfo = JSON.parse(text);
          userCache.set(token, { userInfo, expires: Date.now() + 5 * 60 * 1000 });
          resolve(userInfo);
        } catch (e) { reject(e); }
      });
    });
    r.on('error', reject);
    r.end();
  });
}

function sendError(res, status, code, message) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ ResponseInfo: null, Errors: [{ code, message }] }));
}

async function toLocal(req, res, target) {
  let body = await readBody(req);
  let who = '';
  const isJson = /json/i.test(req.headers['content-type'] || '');
  if (isJson && body.length) {
    let parsed = null;
    try { parsed = JSON.parse(body.toString('utf8')); } catch (e) { /* forwarded as it is */ }
    const info = parsed && (parsed.RequestInfo || parsed.requestInfo);
    if (info && info.authToken) {
      try {
        info.userInfo = await resolveUser(info.authToken);
        who = ' as ' + info.userInfo.userName + ' [' + (info.userInfo.roles || []).map(r => r.code).join(',') + ']';
        body = Buffer.from(JSON.stringify(parsed), 'utf8');
      } catch (e) {
        console.log(new Date().toISOString(), 'LOCAL ', req.method, req.url, '-> 401', e.message);
        return sendError(res, 401, 'InvalidAccessTokenException', 'ui-proxy could not resolve the auth token: ' + e.message);
      }
    }
  }
  const u = new URL(req.url, target);
  const headers = Object.assign({}, req.headers, { host: u.host, 'content-length': body.length });
  delete headers['accept-encoding'];
  const out = http.request(u, { method: req.method, headers }, r => {
    console.log(new Date().toISOString(), 'LOCAL ', req.method, req.url.split('?')[0], '->', r.statusCode + who);
    res.writeHead(r.statusCode, r.headers);
    r.pipe(res);
  });
  out.on('error', e => {
    console.log(new Date().toISOString(), 'LOCAL ', req.method, req.url, '-> 502', e.message);
    sendError(res, 502, 'LOCAL_SERVICE_DOWN', 'ui-proxy could not reach ' + target + ' (' + e.message + '). Is start-local.ps1 running?');
  });
  out.end(body);
}

function toServer(req, res) {
  const u = new URL(req.url, SERVER);
  const headers = Object.assign({}, req.headers, { host: SERVER.host });
  if (headers.origin) headers.origin = SERVER.origin;
  if (headers.referer) headers.referer = headers.referer.replace('http://localhost:' + PORT, SERVER.origin);
  const out = https.request(u, { method: req.method, headers }, r => {
    const h = Object.assign({}, r.headers);
    // keep the browser on localhost when the server redirects to itself
    if (h.location && h.location.startsWith(SERVER.origin)) h.location = h.location.slice(SERVER.origin.length) || '/';
    if (!/\.(js|css|png|jpg|svg|woff2?|ico|map|json)(\?|$)/.test(req.url)) console.log(new Date().toISOString(), 'SERVER', req.method, req.url.split('?')[0], '->', r.statusCode);
    res.writeHead(r.statusCode, h);
    r.pipe(res);
  });
  out.on('error', e => {
    console.log(new Date().toISOString(), 'SERVER', req.method, req.url, '-> 502', e.message);
    sendError(res, 502, 'SERVER_UNREACHABLE', 'ui-proxy could not reach ' + SERVER.origin + ' (' + e.message + ')');
  });
  req.pipe(out);
}

http.createServer((req, res) => {
  // mdms-v2 is not run locally; its v1 search takes and returns the same JSON as egov-mdms-service,
  // which serves the local mdms folder (tl-services itself is pointed at it the same way)
  if (LOCAL_ONLY && req.url.startsWith('/mdms-v2/v1/')) req.url = '/egov-mdms-service/v1/' + req.url.slice('/mdms-v2/v1/'.length);
  const path = req.url.split('?')[0];
  if (path === '/') { res.writeHead(302, { Location: '/upyog-ui/citizen' }); return res.end(); }
  const target = localTarget(path, req.url);
  if (target) toLocal(req, res, target).catch(e => sendError(res, 500, 'UI_PROXY_ERROR', e.message));
  else if (LOCAL_ONLY) {
    console.log(new Date().toISOString(), 'NONE  ', req.method, path, '-> 502 (no local service)');
    req.resume();
    sendError(res, 502, 'NOT_RUNNING_LOCALLY', 'No local service is configured in ui-proxy.js for ' + path);
  }
  else toServer(req, res);
}).listen(PORT, '127.0.0.1', () => {
  console.log('ui-proxy on http://localhost:' + PORT + '/upyog-ui/citizen  and  /upyog-ui/employee');
  console.log((LOCAL_ONLY ? 'local only, nothing from the server' : 'UI and other APIs from ' + SERVER.origin) + '; local: ' + Object.keys(LOCAL_ROUTES).join(', '));
});
