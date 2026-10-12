// Generates the SMC trade license receipt, certificate and letter of intimation (LOI) configs for pdf-service.
//   node build-pdf-configs.js <configs/pdf-service dir> <preview dir>
// Rules imposed by pdf-service's template step (it strips every backslash and then repairs the JSON):
//   - no double quotes or line breaks inside any text
//   - no text that starts with "[" or "{" or ends with "]"
const fs = require('fs');
const path = require('path');
const outDir = process.argv[2];
const previewDir = process.argv[3];

const FONT = 'Cambay';
// The council seal is embedded in the format config, so the PDF does not depend on any hosted image.
const LOGO = 'data:image/png;base64,' + fs.readFileSync(path.join(__dirname, 'smc-logo.png')).toString('base64');

// ---------- small layout helpers ----------------------------------------------------------------------------
const mr = (text, extra) => Object.assign({ text, font: FONT }, extra || {});
const en = (text, extra) => Object.assign({ text, font: FONT, fontSize: 7.5, color: '#444444' }, extra || {});
// Marathi label with the English one under it
const bi = (m, e, extra) => Object.assign({ stack: [mr(m, { bold: true }), en(e)] }, extra || {});
const val = (text, extra) => Object.assign({ text, font: FONT }, extra || {});
const cell = (node, extra) => Object.assign({}, node, extra || {});

// ---------- functions evaluated by pdf-service (data-config type "function") ---------------------------------
// The value arrives as "type"; a missing value arrives as the single character N (first letter of NA).
const blankIfMissing = "return (type === 'N' || type === null || type === undefined) ? '' : type;";
const money = "var n = Number(type); return isNaN(n) ? '' : n.toFixed(2);";
const financialYear = "var d = new Date(Number(type) + 19800000); if (isNaN(d)) return ''; var y = d.getUTCMonth() >= 3 ? d.getUTCFullYear() : d.getUTCFullYear() - 1; return y + '-' + (y + 1);";
// The validity dates are stored as the financial year's boundaries in UTC (31 March 23:59:59 UTC), so they
// must be printed in UTC; in Indian time the end date would show as 1 April.
const utcDate = "var d = new Date(Number(type)); if (isNaN(d)) return ''; function p(n){ return (n < 10 ? '0' : '') + n; } return p(d.getUTCDate()) + '/' + p(d.getUTCMonth() + 1) + '/' + d.getUTCFullYear();";
const printedOn ="var d = new Date(Date.now() + 19800000); function p(n){ return (n < 10 ? '0' : '') + n; } return p(d.getUTCDate()) + '/' + p(d.getUTCMonth() + 1) + '/' + d.getUTCFullYear() + ' ' + p(d.getUTCHours()) + ':' + p(d.getUTCMinutes());";

const wordsEn = [
  "var n = Math.round(Number(type)); if (isNaN(n)) return '';",
  "var a = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];",
  "var b = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];",
  "function two(x){ return x < 20 ? a[x] : b[Math.floor(x / 10)] + (x % 10 ? ' ' + a[x % 10] : ''); }",
  "function part(x, name){ return x ? two(x) + ' ' + name + ' ' : ''; }",
  "if (n === 0) return 'Zero Rupees Only';",
  "var s = part(Math.floor(n / 10000000), 'Crore') + part(Math.floor(n / 100000) % 100, 'Lakh') + part(Math.floor(n / 1000) % 100, 'Thousand') + part(Math.floor(n / 100) % 10, 'Hundred') + two(n % 100);",
  "return s.replace(/\\s+/g, ' ').trim() + ' Rupees Only';"
].join(' ');

const mrNumbers = ['', 'एक', 'दोन', 'तीन', 'चार', 'पाच', 'सहा', 'सात', 'आठ', 'नऊ', 'दहा', 'अकरा', 'बारा', 'तेरा', 'चौदा', 'पंधरा', 'सोळा', 'सतरा', 'अठरा', 'एकोणीस',
  'वीस', 'एकवीस', 'बावीस', 'तेवीस', 'चोवीस', 'पंचवीस', 'सव्वीस', 'सत्तावीस', 'अठ्ठावीस', 'एकोणतीस',
  'तीस', 'एकतीस', 'बत्तीस', 'तेहेतीस', 'चौतीस', 'पस्तीस', 'छत्तीस', 'सदतीस', 'अडतीस', 'एकोणचाळीस',
  'चाळीस', 'एक्केचाळीस', 'बेचाळीस', 'त्रेचाळीस', 'चव्वेचाळीस', 'पंचेचाळीस', 'सेहेचाळीस', 'सत्तेचाळीस', 'अठ्ठेचाळीस', 'एकोणपन्नास',
  'पन्नास', 'एक्कावन्न', 'बावन्न', 'त्रेपन्न', 'चोपन्न', 'पंचावन्न', 'छप्पन्न', 'सत्तावन्न', 'अठ्ठावन्न', 'एकोणसाठ',
  'साठ', 'एकसष्ठ', 'बासष्ठ', 'त्रेसष्ठ', 'चौसष्ठ', 'पासष्ठ', 'सहासष्ठ', 'सदुसष्ठ', 'अडुसष्ठ', 'एकोणसत्तर',
  'सत्तर', 'एक्काहत्तर', 'बाहत्तर', 'त्र्याहत्तर', 'चौऱ्याहत्तर', 'पंच्याहत्तर', 'शहात्तर', 'सत्याहत्तर', 'अठ्ठ्याहत्तर', 'एकोणऐंशी',
  'ऐंशी', 'एक्क्याऐंशी', 'ब्याऐंशी', 'त्र्याऐंशी', 'चौऱ्याऐंशी', 'पंच्याऐंशी', 'शहाऐंशी', 'सत्त्याऐंशी', 'अठ्ठ्याऐंशी', 'एकोणनव्वद',
  'नव्वद', 'एक्क्याण्णव', 'ब्याण्णव', 'त्र्याण्णव', 'चौऱ्याण्णव', 'पंच्याण्णव', 'शहाण्णव', 'सत्त्याण्णव', 'अठ्ठ्याण्णव', 'नव्व्याण्णव'];
const wordsMr = [
  "var n = Math.round(Number(type)); if (isNaN(n)) return '';",
  "var w = " + JSON.stringify(mrNumbers).replace(/"/g, "'") + ";",
  "function part(x, name){ return x ? w[x] + ' ' + name + ' ' : ''; }",
  "if (n === 0) return 'शून्य रुपये मात्र';",
  "var h = Math.floor(n / 100) % 10; var rest = n % 100;",
  "var hundred = h ? (h === 1 && rest === 0 && n < 1000 ? 'शंभर' : w[h] + 'शे') + ' ' : '';",
  "var s = part(Math.floor(n / 10000000), 'कोटी') + part(Math.floor(n / 100000) % 100, 'लाख') + part(Math.floor(n / 1000) % 100, 'हजार') + hundred + w[rest];",
  "return s.replace(/\\s+/g, ' ').trim() + ' रुपये मात्र';"
].join(' ');

// Values that must print in both languages whatever language the user works in. The server has no Marathi
// localization, and a localization lookup gives one language only, so the names are carried in the config.
const quote = s => "'" + String(s).replace(/['"\\]/g, '') + "'";
const mapLiteral = obj => '{' + Object.keys(obj).map(k => quote(k) + ': ' + quote(obj[k])).join(', ') + '}';

const paymentModes = {
  CASH: 'रोख / Cash', CHEQUE: 'धनादेश / Cheque', DD: 'डिमांड ड्राफ्ट / DD', CARD: 'कार्ड / Card', ONLINE: 'ऑनलाईन / Online',
  NEFT: 'एनईएफटी / NEFT', RTGS: 'आरटीजीएस / RTGS', OFFLINE_NEFT: 'एनईएफटी / NEFT', OFFLINE_RTGS: 'आरटीजीएस / RTGS', POSTAL_ORDER: 'पोस्टल ऑर्डर / Postal Order'
};
const paymentMode = "var m = " + mapLiteral(paymentModes) + "; return m[type] || type;";

const taxHeads = {
  TL_TAX: 'व्यवसाय परवाना शुल्क / Trade License Fee', TL_RENEWAL_TAX: 'परवाना नूतनीकरण शुल्क / License Renewal Fee',
  TL_ADHOC_PENALTY: 'दंड / Penalty', TL_TIME_PENALTY: 'विलंब दंड / Late Penalty', TL_RENEWAL_PENALTY: 'विलंब दंड / Late Penalty',
  TL_ADHOC_REBATE: 'सूट / Rebate', TL_TIME_REBATE: 'सूट / Rebate', TL_RENEWAL_REBATE: 'सूट / Rebate',
  TL_ROUNDOFF: 'पूर्णांक फरक / Round Off', TL_ADVANCE_ADJUSTED: 'आगाऊ रक्कम समायोजन / Advance Adjusted',
  // cleanliness certificate, health NOC, advertisement permission
  TL_CLEAN_CERT_FEE: 'स्वच्छता प्रमाणपत्र शुल्क / Cleanliness Certificate Fee', TL_NOC_FEE: 'ना हरकत प्रमाणपत्र शुल्क / Health NOC Fee',
  TL_NOC_PUBLICITY_FEE: 'वृत्तपत्र प्रसिद्धी शुल्क / Paper Publicity Charge', TL_ADV_CHARGE: 'जाहिरात शुल्क / Advertisement Charge',
  TL_ADV_PERMISSION_FEE: 'परवानगी शुल्क / Permission Fee'
};
// receives the bill's account lines and returns the rows of the fee table
const feeLines = "var m = " + mapLiteral(taxHeads) + "; if (!type || typeof type !== 'object') return []; var rows = []; for (var i = 0; i < type.length; i++) { var a = type[i] || {}; var n = Number(a.adjustedAmount != null ? a.adjustedAmount : a.amount); rows.push({ accountCode: a.taxHeadCode || '', particulars: m[a.taxHeadCode] || a.taxHeadCode || '', itemAmount: isNaN(n) ? '' : n.toFixed(2) }); } return rows;";

// business type names: English from the MDMS master, Marathi from the SMC localization file
const mdmsTradeTypes = process.env.TRADE_TYPE_MDMS || path.join(__dirname, '..', '..', '..', '..', '..', '..', 'mdms', 'data', 'pg', 'TradeLicense', 'TradeType.json');
const mrTradeTypes = process.env.TRADE_TYPE_MR || path.join(__dirname, '..', 'localization_rainmaker-tl_mr_IN.json');
const tradeNamesEn = {}, tradeNamesMr = {};
const localeKey = code => 'TRADELICENSE_TRADETYPE_' + code.toUpperCase().replace(/[.:\-\s\/]/g, '_');
const mrByKey = {};
JSON.parse(fs.readFileSync(mrTradeTypes, 'utf8')).messages.forEach(m => { mrByKey[m.code.replace(/-/g, '_')] = m.message; });
JSON.parse(fs.readFileSync(mdmsTradeTypes, 'utf8')).TradeType.forEach(t => {
  tradeNamesEn[t.code] = t.name;
  tradeNamesMr[t.code] = mrByKey[localeKey(t.code)] || t.name;
});
const tradeTypeEn = "var m = " + mapLiteral(tradeNamesEn) + "; return m[type] || type;";
const tradeTypeMr = "var m = " + mapLiteral(tradeNamesMr) + "; return m[type] || type;";

// The SMC form stores the owner's address in additionalDetails.residentialAddress (permanentAddress stays empty).
// An owner without any address prints an empty line to be filled in, not NA.
const ownerRows = "if (!type || typeof type !== 'object') return []; var rows = []; for (var i = 0; i < type.length; i++) { var o = type[i] || {}; rows.push({ name: o.name || '', ownerAddress: o.permanentAddress || (o.additionalDetails || {}).residentialAddress || o.correspondenceAddress || '' }); } return rows;";

const fn = (variable, pathExpr, body) => ({ variable, value: { path: pathExpr }, type: 'function', format: body });
const direct = (variable, pathExpr, extra) => Object.assign({ variable, value: { path: pathExpr } }, extra || {});
const date = (variable, pathExpr) => ({ variable, value: { path: pathExpr }, type: 'date', format: 'DD/MM/YYYY' });

const tableLayout = {
  hLineWidth: 'THIN', vLineWidth: 'THIN'   // placeholders, replaced by plain numbers below
};
const bordered = { defaultBorder: true };

// =============================================================================================================
// RECEIPT  (key: tradelicense-receipt, request body: { Payments: [ ... ] })
// =============================================================================================================
const receiptData = {
  key: 'tradelicense-receipt',
  DataConfigs: {
    serviceName: 'rainmaker-common',
    version: '1.0.0',
    baseKeyPath: '$.Payments.*',
    entityIdPath: '$.id',
    isCommonTableBorderRequired: true,
    mappings: [{
      topic: 'common-pg-receipt',
      mappings: [{
        direct: [
          direct('tenantid', '$.tenantId'),
          direct('receiptNo', '$.paymentDetails[0].receiptNumber'),
          date('receiptDate', '$.paymentDetails[0].receiptDate'),
          fn('financialYear', '$.paymentDetails[0].bill.billDetails[0].fromPeriod', financialYear),
          direct('payerName', '$.payerName'),
          direct('paidBy', '$.paidBy'),
          direct('consumerID', '$.paymentDetails[0].bill.consumerCode'),
          fn('items', '$.paymentDetails[0].bill.billDetails[0].billAccountDetails', feeLines),

          fn('totalAmount', '$.totalAmountPaid', money),
          fn('amountWordsMr', '$.totalAmountPaid', wordsMr),
          fn('amountWordsEn', '$.totalAmountPaid', wordsEn),
          fn('paymentMode', '$.paymentMode', paymentMode),
          fn('instrumentNo', '$.instrumentNumber', blankIfMissing),
          date('instrumentDate', '$.instrumentDate'),
          fn('bankName', '$.ifscCode', blankIfMissing),
          direct('transactionNo', '$.transactionNumber'),
          fn('printedOn', '$.tenantId', printedOn)
        ],
        externalAPI: [{
          path: 'http://tl-services:8080/tl-services/v1/_search',
          queryParam: 'tenantId=$.tenantId,applicationNumber=$.paymentDetails[0].bill.consumerCode',
          apiRequest: null,
          responseMapping: [
            { variable: 'applicationDate', value: '$.Licenses[0].applicationDate', type: 'date', format: 'DD/MM/YYYY' },
            { variable: 'tradeName', value: '$.Licenses[0].tradeName' }
          ]
        }],
        qrcodeConfig: [{
          variable: 'qrCode',
          value: 'citizen/withoutAuth/egov-common/download-receipt?status=success&consumerCode={{consumerID}}&tenantId={{tenantid}}&receiptNumber={{receiptNo}}&businessService=TL&smsLink=true'
        }]
      }]
    }]
  }
};

const receiptFormat = {
  key: 'tradelicense-receipt',
  config: {
    pageSize: 'A4',
    pageMargins: [30, 30, 30, 40],
    defaultStyle: { font: FONT, fontSize: 9.5 },
    footer: "function(currentPage, pageCount) { return { text: 'Page ' + currentPage + ' of ' + pageCount, alignment: 'right', margin: [0, 10, 30, 0], fontSize: 8 }; }",
    content: [
      {
        font: FONT,
        table: {
          widths: ['*'],
          body: [[{
            stack: [
              // ---- heading
              {
                columns: [
                  { image: LOGO, width: 58, height: 58 },
                  {
                    width: '*', alignment: 'center',
                    stack: [
                      mr('संगमनेर नगरपरिषद', { bold: true, fontSize: 15 }),
                      en('Sangamner Municipal Council', { fontSize: 9 }),
                      mr('नमुना क्रमांक ५४   /   Form No. 54', { fontSize: 9.5 }),
                      mr('(नियम क्रमांक ७५, ८७, ४७६ पहा)   /   (See Rules 75, 87, 476)', { fontSize: 8.5 }),
                      mr('पावती   /   RECEIPT', { bold: true, fontSize: 12, margin: [0, 2, 0, 0] })
                    ]
                  },
                  { width: 46, text: '' }
                ]
              },
              { margin: [0, 4, 0, 4], text: [mr('आर्थिक वर्ष / Financial Year : ', { bold: true }), val('{{financialYear}}')] },

              // ---- receipt number row
              {
                table: {
                  widths: ['32%', '36%', '32%'],
                  body: [
                    [bi('पावती क्रमांक', 'Receipt No.', { alignment: 'center' }), bi('लेखा विभाग', 'Accounts Department', { alignment: 'center' }), bi('पावती दिनांक', 'Receipt Date', { alignment: 'center' })],
                    [val('{{receiptNo}}', { alignment: 'center', bold: true }), bi('संकिर्ण पावती', 'Miscellaneous Receipt', { alignment: 'center' }), val('{{receiptDate}}', { alignment: 'center' })]
                  ]
                }
              },

              // ---- received from
              {
                margin: [0, 6, 0, 6],
                table: {
                  widths: [110, '*'],
                  body: [
                    [bi('कडून मिळाले', 'Received from'), val(':  {{payerName}}')],
                    [bi('विवरण', 'Description'), {
                      stack: [
                        mr(':  व्यवसाय परवाना शुल्काचा भरणा - {{tradeName}}'),
                        en('   Payment of Trade License fee - {{tradeName}}.  Paid by: {{paidBy}}.  Transaction No.: {{transactionNo}}')
                      ]
                    }]
                  ]
                },
                layout: 'noBorders'
              },

              // ---- fee lines
              {
                table: {
                  headerRows: 1,
                  widths: ['24%', '14%', '17%', '*', '15%'],
                  body: [
                    [bi('अर्ज क्रमांक', 'Application No.', { alignment: 'center' }), bi('अर्जाची तारीख', 'Application Date', { alignment: 'center' }), bi('लेखा संहिता', 'Account Code', { alignment: 'center' }), bi('तपशील', 'Particulars', { alignment: 'center' }), bi('वसूल रक्कम', 'Amount (Rs.)', { alignment: 'center' })],
                    '{{#items}}[{"text":"{{consumerID}}","font":"' + FONT + '"},{"text":"{{applicationDate}}","alignment":"center","font":"' + FONT + '"},{"text":"{{accountCode}}","font":"' + FONT + '"},{"text":"{{particulars}}","font":"' + FONT + '"},{"text":"{{itemAmount}}","alignment":"right","font":"' + FONT + '"}]{{/items}}',
                    [cell(bi('एकूण रक्कम', 'Total Amount', { alignment: 'right' }), { colSpan: 4 }), {}, {}, {}, val('{{totalAmount}}', { alignment: 'right', bold: true })]
                  ]
                }
              },

              // ---- amount in words
              {
                margin: [0, 6, 0, 6],
                stack: [
                  { text: [mr('रुपये अक्षरी : ', { bold: true }), val('{{amountWordsMr}}')] },
                  { text: [en('Amount in words : '), en('{{amountWordsEn}}')] }
                ]
              },

              // ---- how it was paid
              {
                table: {
                  widths: ['18%', '20%', '18%', '*', '15%'],
                  body: [
                    [bi('वसूली प्रकार', 'Payment Mode', { alignment: 'center' }), bi('इन्स्ट्रुमेन्ट नंबर', 'Instrument No.', { alignment: 'center' }), bi('इन्स्ट्रुमेन्ट दिनांक', 'Instrument Date', { alignment: 'center' }), bi('बँकेचे नाव', 'Bank Name', { alignment: 'center' }), bi('रक्कम', 'Amount (Rs.)', { alignment: 'center' })],
                    [val('{{paymentMode}}', { alignment: 'center' }), val('{{instrumentNo}}', { alignment: 'center' }), val('{{instrumentDate}}', { alignment: 'center' }), val('{{bankName}}', { alignment: 'center' }), val('{{totalAmount}}', { alignment: 'right' })]
                  ]
                }
              },

              // ---- QR and signature
              {
                margin: [0, 14, 0, 4],
                columns: [
                  { image: '{{qrCode}}', width: 70, height: 70 },
                  { width: '*', text: '' },
                  {
                    width: 200, alignment: 'center',
                    stack: [
                      { text: ' ', margin: [0, 22, 0, 0] },
                      mr('प्राप्तकर्त्याची स्वाक्षरी', { bold: true }),
                      en("Receiver's Signature"),
                      { margin: [0, 6, 0, 0], text: [mr('मुद्रण दिनांक / Printed on : ', { fontSize: 8.5 }), val('{{printedOn}}', { fontSize: 8.5 })] }
                    ]
                  }
                ]
              }
            ],
            margin: [8, 8, 8, 8]
          }]]
        }
      }
    ],
    styles: {}
  }
};

// =============================================================================================================
// CERTIFICATE  (key: tlcertificate, request body: { Licenses: [ ... ] })
// =============================================================================================================
const certData = {
  key: 'tlcertificate',
  DataConfigs: {
    serviceName: 'rainmaker-common',
    version: '1.0.0',
    baseKeyPath: '$.Licenses.*',
    entityIdPath: '$.id',
    isCommonTableBorderRequired: true,
    mappings: [{
      topic: 'pdfgen-create',
      mappings: [{
        direct: [
          direct('tradeLicenseNo', '$.licenseNumber'),
          direct('applicationNo', '$.applicationNumber'),
          direct('financialYear', '$.financialYear'),
          direct('tradeName', '$.tradeName'),
          direct('ownerName', '$.tradeLicenseDetail.owners[0].name'),
          fn('tradeTypeMr', '$.tradeLicenseDetail.tradeUnits[0].tradeType', tradeTypeMr),
          fn('tradeTypeEn', '$.tradeLicenseDetail.tradeUnits[0].tradeType', tradeTypeEn),
          date('licenseIssueDate', '$.issuedDate'),
          fn('validFrom', '$.validFrom', utcDate),
          fn('validTo', '$.validTo', utcDate),
          direct('locality', '$.tradeLicenseDetail.address.locality.name'),
          fn('addressLine', '$.tradeLicenseDetail.address.addressLine1', blankIfMissing),
          fn('buildingNo', '$.tradeLicenseDetail.address.doorNo', blankIfMissing),
          fn('pincode', '$.tradeLicenseDetail.address.pincode', blankIfMissing),
          fn('area', '$.tradeLicenseDetail.operationalArea', blankIfMissing),
          fn('employees', '$.tradeLicenseDetail.noOfEmployees', blankIfMissing),
          fn('owners', '$.tradeLicenseDetail.owners', ownerRows)
        ],
        externalAPI: [{
          path: 'http://collection-services:8080/collection-services/payments/TL/_search',
          queryParam: 'tenantId=$.tenantId,consumerCodes=$.applicationNumber',
          apiRequest: null,
          responseMapping: [
            { variable: 'receiptNo', value: '$.Payments[0].paymentDetails[0].receiptNumber' },
            { variable: 'receiptDate', value: '$.Payments[0].paymentDetails[0].receiptDate', type: 'date', format: 'DD/MM/YYYY' },
            { variable: 'feeAmount', value: '$.Payments[0].totalAmountPaid' }
          ]
        }],
        qrcodeConfig: [{
          variable: 'qrCode',
          value: 'Sangamner Municipal Council - Trade License No: {{tradeLicenseNo}}, Application No: {{applicationNo}}, Trade: {{tradeName}}, Valid till: {{validTo}}'
        }]
      }]
    }]
  }
};

const b = text => val(text, { bold: true });
const certFormat = {
  key: 'tlcertificate',
  config: {
    pageSize: 'A4',
    pageMargins: [40, 22, 40, 20],
    defaultStyle: { font: FONT, fontSize: 10 },
    content: [
      // ---- heading
      {
        font: FONT,
        columns: [
          { image: LOGO, width: 62, height: 62 },
          {
            width: '*', alignment: 'center',
            stack: [
              mr('संगमनेर नगरपरिषद, संगमनेर', { bold: true, fontSize: 17 }),
              en('Sangamner Municipal Council, Sangamner', { fontSize: 10 }),
              mr('नमुना   /   Form', { bold: true, fontSize: 12, margin: [0, 4, 0, 0] }),
              mr('उपविधी ३ व ६ पहा   /   See Bye-laws 3 and 6', { fontSize: 10 })
            ]
          },
          {
            width: 150,
            stack: [
              mr('(आरोग्य विभाग)', { bold: true }),
              en('(Health Department)'),
              mr('व्यवसाय परवाना नं.', { bold: true, margin: [0, 3, 0, 0] }),
              en('Trade License No.'),
              val('{{tradeLicenseNo}}', { bold: true, fontSize: 11 }),
              { margin: [0, 3, 0, 0], text: [mr('दिनांक / Date : ', { bold: true }), val('{{licenseIssueDate}}')] }
            ]
          }
        ]
      },
      { canvas: [{ type: 'line', x1: 0, y1: 4, x2: 515, y2: 4, lineWidth: 0.8 }], margin: [0, 0, 0, 6] },

      // ---- the license text, Marathi
      {
        font: FONT, alignment: 'justify', lineHeight: 1.15,
        text: [
          b('{{tradeTypeMr}}'), mr(' साठी म्हणून जागेचा वापर करण्यासाठी वार्षिक लायसन्स. संगमनेर नगरपरिषद, श्री./श्रीमती '), b('{{ownerName}}'), mr(' ('), b('{{tradeName}}'),
          mr(') व खाली नांवे दिलेले त्यांचे नोकर व एजंट यांना रुपये '), b('{{feeAmount}}/-'),
          mr(' आगाऊ फी दिल्यावर, उपविधीत विनिर्दिष्ट केलेल्या व मागील बाजूस मुद्रित केलेल्या शर्तींच्या व निर्बंधांच्या अधीन, '), b('{{validTo}}'),
          mr(' रोजी संपणाऱ्या वर्षासाठी संगमनेर (नगराचे नांव) मधील '), b('{{locality}}'), mr(' (रस्त्याचे - मार्गाचे नांव) वरील इमारत / पत्ता '), b('{{buildingNo}} {{addressLine}}'),
          mr(' मध्ये '), b('{{tradeTypeMr}}'), mr(' साठी म्हणून '), b('{{area}}'), mr(' चौ. फूट जागेचा वापर करण्यासाठी याद्वारे लायसन्स देण्यात येत आहे. त्या जागेत कामावर नेमण्यात येणाऱ्या व्यक्तींची संख्या '),
          b('{{employees}}'), mr(' पेक्षा अधिक असणार नाही.')
        ]
      },
      { font: FONT, alignment: 'justify', margin: [0, 4, 0, 0], text: 'उपविधीच्या प्रती अवलोकनार्थ नगरपरिषद कार्यालयात ठेवण्यात आलेल्या असून त्या कार्यालयातून खरेदी करता येतील.' },

      // ---- the same in English
      {
        font: FONT, fontSize: 8, color: '#333333', margin: [0, 4, 0, 0],
        text: [
          'Annual license to use premises for ', { text: '{{tradeTypeEn}}', bold: true }, '. Sangamner Municipal Council hereby grants this license to Shri/Smt. ', { text: '{{ownerName}}', bold: true },
          ' (', { text: '{{tradeName}}', bold: true }, ') and to the servants and agents named below, on payment of an advance fee of Rs. ', { text: '{{feeAmount}}/-', bold: true },
          ', subject to the conditions and restrictions specified in the bye-laws and printed overleaf, for the year ending on ', { text: '{{validTo}}', bold: true },
          ', to use ', { text: '{{area}}', bold: true }, ' sq. ft. of premises at ', { text: '{{buildingNo}} {{addressLine}}, {{locality}}', bold: true },
          ', Sangamner, for ', { text: '{{tradeTypeEn}}', bold: true }, '. The number of persons employed at the premises shall not exceed ', { text: '{{employees}}', bold: true },
          '. Copies of the bye-laws are kept at the Municipal Council office for inspection and can be purchased there.'
        ]
      },

      // ---- servants and agents
      { font: FONT, alignment: 'center', margin: [0, 7, 0, 3], stack: [mr('नोकर व अभिकर्ते यांची नांवे', { bold: true, fontSize: 12 }), en('Names of servants and agents')] },
      {
        font: FONT,
        table: {
          widths: [95, '*'],
          body: [
            '{{#owners}}[{"stack":[{"text":"नांव","bold":true,"font":"' + FONT + '"},{"text":"Name","fontSize":7.5,"color":"#444444","font":"' + FONT + '"}]},{"text":"{{name}}","font":"' + FONT + '"}],[{"stack":[{"text":"पत्ता","bold":true,"font":"' + FONT + '"},{"text":"Address","fontSize":7.5,"color":"#444444","font":"' + FONT + '"}]},{"text":"{{ownerAddress}}","font":"' + FONT + '"}]{{/owners}}'
          ]
        }
      },

      // ---- fee received and renewal
      {
        font: FONT, margin: [0, 8, 0, 0], lineHeight: 1.15,
        text: [
          mr('व त्याप्रमाणे '), b('{{validFrom}}'), mr(' ते '), b('{{validTo}}'), mr(' या वर्षासाठी पावती क्रमांक '), b('{{receiptNo}}'), mr(' दिनांक '), b('{{receiptDate}}'),
          mr(' अन्वये रुपये '), b('{{feeAmount}}/-'), mr(' मिळाले.')
        ]
      },
      { font: FONT, text: [mr('नूतनीकरणाचा अर्ज दिनांक '), b('{{validTo}}'), mr(' पूर्वी करण्यात येईल.')] },
      {
        font: FONT, fontSize: 8, color: '#333333', margin: [0, 2, 0, 0],
        text: [
          'Accordingly, Rs. ', { text: '{{feeAmount}}/-', bold: true }, ' has been received for the year ', { text: '{{validFrom}}', bold: true }, ' to ', { text: '{{validTo}}', bold: true },
          ' vide receipt no. ', { text: '{{receiptNo}}', bold: true }, ' dated ', { text: '{{receiptDate}}', bold: true }, '. The application for renewal shall be made before ', { text: '{{validTo}}', bold: true }, '.'
        ]
      },

      // ---- QR and signature
      {
        font: FONT, margin: [0, 4, 0, 0],
        columns: [
          { image: '{{qrCode}}', width: 56, height: 56 },
          { width: '*', text: '' },
          {
            width: 220, alignment: 'center',
            stack: [
              { text: ' ', margin: [0, 8, 0, 0] },
              mr('मुख्याधिकारी', { bold: true, fontSize: 12 }),
              en('Chief Officer'),
              mr('संगमनेर नगरपरिषद, संगमनेर'),
              en('Sangamner Municipal Council, Sangamner')
            ]
          }
        ]
      },

      // ---- renewals
      { font: FONT, alignment: 'center', margin: [0, 6, 0, 3], stack: [mr('लायसन्सचे नूतनीकरण', { bold: true, fontSize: 12 }), en('Renewal of License')] },
      {
        font: FONT,
        table: {
          headerRows: 1,
          widths: [30, 62, '*', 120, 70, 85],
          body: [
            [bi('अ.नं.', 'Sr. No.', { alignment: 'center' }), bi('वर्ष', 'Year', { alignment: 'center' }), bi('नूतनीकरण वर्ष', 'Renewal Period', { alignment: 'center' }), bi('पावती नं. व तारीख', 'Receipt No. and Date', { alignment: 'center' }), bi('भरलेली रक्कम', 'Amount Paid (Rs.)', { alignment: 'center' }), bi('मुख्याधिकारी', 'Chief Officer', { alignment: 'center' })],
            [val('१', { alignment: 'center' }), val('{{financialYear}}', { alignment: 'center' }), val('{{validFrom}} - {{validTo}}', { alignment: 'center' }), { stack: [val('{{receiptNo}}', { alignment: 'center' }), val('{{receiptDate}}', { alignment: 'center' })] }, val('{{feeAmount}}/-', { alignment: 'right' }), val(' ')],
            [val(' ', { margin: [0, 2, 0, 2] }), val(' '), val(' '), val(' '), val(' '), val(' ')],
            [val(' ', { margin: [0, 2, 0, 2] }), val(' '), val(' '), val(' '), val(' '), val(' ')]
          ]
        }
      }
    ],
    styles: {}
  }
};

// =============================================================================================================
// LETTER OF INTIMATION  (key: tl-loi, request body: { Licenses: [ { ...license, loi: { charges, totalAmount } } ] })
// Printed while a payment is due: the fee after approval (PENDINGPAYMENT) or the paper publicity charge of a
// health NOC (PUBLICITYPAYMENTPENDING). loi.charges are the account lines of the bill (billAccountDetails) and
// loi.totalAmount its total; the caller fetches the bill, as the payment screen does.
// =============================================================================================================
// Days the LOI stays valid. Not given by the council yet: null prints a line to be filled in by hand.
const LOI_VALIDITY_DAYS = null;

const loiServices = {
  TL_NEW: 'Permanent Trade License (New)', TTL_NEW: 'Temporary Trade License', TL_RENEW: 'Renewal of Trade License',
  TTL_RENEW: 'Renewal of Temporary Trade License', CLEAN_CERT: 'Cleanliness Certificate',
  HEALTH_NOC: 'No Objection Certificate (Health License)', ADV_PERM: 'Advertisement / Hoarding / Flex / Flags Permission'
};
const loiService = "var m = " + mapLiteral(loiServices) + "; return m[type] || 'Trade License';";
const loiStage = "return type === 'PUBLICITYPAYMENTPENDING' ? 'that the paper publicity charge mentioned below is to be paid before the notice inviting objections is published.' : 'that approval is given by the officer duly authorized by Sangamner Municipal Council.';";
// before payment a bill line holds the charge in amount (adjustedAmount is what has been paid); lines of Rs. 0 are left
// out, and an empty list still gives one blank row, since pdfmake refuses a table row without cells
const loiCharges = "var m = " + mapLiteral(taxHeads) + "; if (!type || typeof type !== 'object') return []; var rows = []; for (var i = 0; i < type.length; i++) { var a = type[i] || {}; var n = Number(a.amount); if (isNaN(n) || n === 0) continue; rows.push({ srNo: rows.length + 1, description: m[a.taxHeadCode] || a.taxHeadCode || '', chargeAmount: n.toFixed(2) }); } if (!rows.length) rows.push({ srNo: '', description: '', chargeAmount: '' }); return rows;";
// the applicant's own address; for a firm without one, the address of the premises
const loiAddress = "if (!type || typeof type !== 'object') return ''; var o = (type.owners || [])[0] || {}; var own = o.permanentAddress || (o.additionalDetails || {}).residentialAddress || o.correspondenceAddress; if (own) return own; var a = type.address || {}; var parts = [a.doorNo, a.addressLine1, (a.locality || {}).name, a.pincode]; var out = []; for (var i = 0; i < parts.length; i++) { if (parts[i]) out.push(parts[i]); } return out.join(', ');";
const today = "var d = new Date(Date.now() + 19800000); function p(n){ return (n < 10 ? '0' : '') + n; } return p(d.getUTCDate()) + '/' + p(d.getUTCMonth() + 1) + '/' + d.getUTCFullYear();";
const loiValidity = "return " + (LOI_VALIDITY_DAYS === null ? "'__________'" : "'" + LOI_VALIDITY_DAYS + "'") + ";";

const loiData = {
  key: 'tl-loi',
  DataConfigs: {
    serviceName: 'rainmaker-common',
    version: '1.0.0',
    baseKeyPath: '$.Licenses.*',
    entityIdPath: '$.id',
    isCommonTableBorderRequired: true,
    mappings: [{
      topic: 'pdfgen-create',
      mappings: [{
        direct: [
          direct('applicationNo', '$.applicationNumber'),
          date('applicationDate', '$.applicationDate'),
          fn('loiDate', '$.tenantId', today),
          direct('applicantName', '$.tradeLicenseDetail.owners[0].name'),
          fn('applicantAddress', '$.tradeLicenseDetail', loiAddress),
          fn('serviceName', '$.workflowCode', loiService),
          fn('stageText', '$.status', loiStage),
          fn('charges', '$.loi.charges', loiCharges),
          fn('totalAmount', '$.loi.totalAmount', money),
          fn('amountWordsEn', '$.loi.totalAmount', wordsEn),
          fn('validityDays', '$.tenantId', loiValidity)
        ]
      }]
    }]
  }
};

const loiFormat = {
  key: 'tl-loi',
  config: {
    pageSize: 'A4',
    pageMargins: [40, 36, 40, 40],
    defaultStyle: { font: FONT, fontSize: 10.5 },
    content: [
      {
        font: FONT,
        table: {
          widths: [78, '*'],
          body: [
            // ---- heading: council seal and name
            [
              { image: LOGO, width: 64, height: 64, alignment: 'center', margin: [0, 4, 0, 4] },
              {
                alignment: 'center', margin: [0, 14, 0, 0],
                stack: [
                  mr('संगमनेर नगरपरिषद', { bold: true, fontSize: 16 }),
                  val('Sangamner Municipal Council', { bold: true, fontSize: 13 })
                ]
              }
            ],
            // ---- the letter
            [{
              colSpan: 2, margin: [8, 6, 8, 8],
              stack: [
                mr('Letter of Intimation / सूचना पत्र', { bold: true, fontSize: 12.5, alignment: 'center' }),
                { alignment: 'right', margin: [0, 6, 0, 0], text: [mr('Date / दिनांक : ', { bold: true }), val('{{loiDate}}')] },
                { alignment: 'right', text: [mr('No. / क्रमांक : ', { bold: true }), val('LOI/{{applicationNo}}')] },

                val('To,', { bold: true, margin: [0, 8, 0, 0] }),
                val('{{applicantName}}', { bold: true }),
                val('{{applicantAddress}}'),

                {
                  margin: [50, 14, 0, 0],
                  table: {
                    widths: [62, '*'],
                    body: [
                      [val('Subject'), { text: [val(':  Letter of Intimation for '), val('{{serviceName}}', { bold: true })] }],
                      [val('Reference'), { text: [val(':  Application No. '), val('{{applicationNo}}', { bold: true }), val(' and Application Date '), val('{{applicationDate}}', { bold: true })] }]
                    ]
                  },
                  layout: 'noBorders'
                },

                val('Sir / Madam,', { margin: [0, 16, 0, 0] }),
                {
                  margin: [0, 10, 0, 0], alignment: 'justify', lineHeight: 1.2, leadingIndent: 28,
                  text: [val('This is with reference to your above application for '), val('{{serviceName}}', { bold: true }), val(' {{stageText}}')]
                },
                val('You have to pay the charges mentioned below (if applicable).', { margin: [28, 12, 0, 6] }),

                {
                  table: {
                    headerRows: 1,
                    widths: [40, '*', 110],
                    body: [
                      [val('Sr. No.', { bold: true, alignment: 'center' }), val('Charge Description', { bold: true }), val('Amount (Rs.)', { bold: true, alignment: 'right' })],
                      '{{#charges}}[{"text":"{{srNo}}","alignment":"center","font":"' + FONT + '"},{"text":"{{description}}","font":"' + FONT + '"},{"text":"{{chargeAmount}}","alignment":"right","font":"' + FONT + '"}]{{/charges}}',
                      [cell(val('Total', { bold: true, alignment: 'right' }), { colSpan: 2 }), {}, val('{{totalAmount}}', { bold: true, alignment: 'right' })]
                    ]
                  }
                },
                { margin: [0, 4, 0, 0], text: [val('Amount in words : '), val('{{amountWordsEn}}')] },
                { margin: [0, 8, 0, 0], text: [val('LOI Validity Period (in days) - '), val('{{validityDays}}', { bold: true })] },

                {
                  margin: [0, 44, 0, 0], alignment: 'right',
                  stack: [val('Signing Authority', { bold: true }), val('Sangamner Municipal Council', { margin: [0, 4, 0, 0] })]
                }
              ]
            }, {}]
          ]
        }
      }
    ],
    styles: {}
  }
};

// ---------- write ---------------------------------------------------------------------------------------------
function check(name, obj) {
  const text = JSON.stringify(obj);
  // the template step removes backslashes, so nothing in the layout may need one
  const stripped = text.replace(/\\"/g, '"');
  if (/\\/.test(stripped)) throw new Error(name + ': a text needs a backslash (line break, tab or backslash), which pdf-service would corrupt');
}
check('receipt format', receiptFormat);
check('certificate format', certFormat);
check('LOI format', loiFormat);

function write(dir, sub, name, obj) {
  fs.mkdirSync(path.join(dir, sub), { recursive: true });
  fs.writeFileSync(path.join(dir, sub, name + '.json'), JSON.stringify(obj, null, 2) + '\n', 'utf8');
}
write(outDir, 'data-config', 'tradelicense-receipt', receiptData);
write(outDir, 'format-config', 'tradelicense-receipt', receiptFormat);
write(outDir, 'data-config', 'tlcertificate', certData);
write(outDir, 'format-config', 'tlcertificate', certFormat);
write(outDir, 'data-config', 'tl-loi', loiData);
write(outDir, 'format-config', 'tl-loi', loiFormat);

// preview copies: the in-cluster service addresses replaced by the local stack's
if (previewDir) {
  const local = obj => JSON.parse(JSON.stringify(obj)
    .replace('http://tl-services:8080/', 'http://localhost:8079/')
    .replace('http://collection-services:8080/', 'http://localhost:8095/'));
  write(previewDir, 'data-config', 'tradelicense-receipt', local(receiptData));
  write(previewDir, 'format-config', 'tradelicense-receipt', receiptFormat);
  write(previewDir, 'data-config', 'tlcertificate', local(certData));
  write(previewDir, 'format-config', 'tlcertificate', certFormat);
  write(previewDir, 'data-config', 'tl-loi', loiData);
  write(previewDir, 'format-config', 'tl-loi', loiFormat);
}
console.log('written 6 config files to ' + outDir + (previewDir ? ' and preview copies to ' + previewDir : ''));
