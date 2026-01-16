function parseYmd(ymd) {
  // ymd: YYYY-MM-DD
  const [y,m,d] = ymd.split('-').map(Number);
  return new Date(Date.UTC(y, m-1, d));
}

function daysInclusive(startYmd, endYmd) {
  const a = parseYmd(startYmd);
  const b = parseYmd(endYmd);
  const diffMs = b.getTime() - a.getTime();
  const diffDays = Math.floor(diffMs / (24*3600*1000));
  return diffDays + 1; // inclusive
}

module.exports = { daysInclusive };
