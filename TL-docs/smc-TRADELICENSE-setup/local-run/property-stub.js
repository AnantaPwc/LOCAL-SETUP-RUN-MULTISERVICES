// Local stand-ins for property-services (port 8087) and ws-services (port 8089).
//
// tl-services calls them when a permanent license is submitted (APPLY):
//   - property-services: does the propertyId exist?            -> always "yes", echoing the id asked for
//   - ws-services: which water connections belong to it?       -> always "none"
// The property tax dues themselves are still read from the real billing-service.
// The real services are not used because, like egov-user, they need egov-enc-service.
//
//   node property-stub.js
const http = require('http');
const url = require('url');

function serve(port, name, respond) {
  http.createServer((req, res) => {
    req.on('data', () => {});
    req.on('end', () => {
      const out = respond(url.parse(req.url, true));
      console.log(new Date().toISOString(), name, req.method, req.url, out ? 'OK' : '404');
      res.writeHead(out ? 200 : 404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(out || { Errors: [{ code: 'STUB_NOT_FOUND', message: req.url }] }));
    });
  }).listen(port, '127.0.0.1', () => console.log(name + ' stub listening on ' + port));
}

serve(process.env.PROPERTY_STUB_PORT || 8087, 'property-services', u => {
  if (!/\/property\/_search/.test(u.pathname)) return null;
  const ids = String(u.query.propertyIds || '').split(',').filter(Boolean);
  return {
    ResponseInfo: {},
    Properties: ids.map(id => ({
      propertyId: id,
      tenantId: u.query.tenantId,
      status: 'ACTIVE',
      owners: [{ name: 'STUB PROPERTY OWNER', status: 'ACTIVE' }]
    }))
  };
});

serve(process.env.WS_STUB_PORT || 8089, 'ws-services', u => {
  if (!/\/wc\/_search/.test(u.pathname)) return null;
  return { ResponseInfo: {}, WaterConnection: [] };
});
