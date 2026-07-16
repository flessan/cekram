#!/usr/bin/env node
// CekRAM CLI Entrypoint for Node.js (`npx cekram` or `node bin/cekram.js`)

const { getMetrics, purgeMemory } = require('../lib/monitor');
const { getString } = require('../lib/i18n');

const args = process.argv.slice(2);
let lang = 'id';
let threshold = 80;
let interval = 5;
let oneshot = false;
let purgeNow = false;

for (let i = 0; i < args.length; i++) {
    if (args[i] === '--lang' || args[i] === '-l') {
        lang = args[i + 1] || 'id';
        i++;
    } else if (args[i].startsWith('--lang=')) {
        lang = args[i].split('=')[1];
    } else if (args[i] === '--threshold' || args[i] === '-t') {
        threshold = parseInt(args[i + 1] || '80', 10);
        i++;
    } else if (args[i].startsWith('--threshold=')) {
        threshold = parseInt(args[i].split('=')[1], 10);
    } else if (args[i] === '--interval' || args[i] === '-i') {
        interval = parseInt(args[i + 1] || '5', 10);
        i++;
    } else if (args[i] === '--oneshot' || args[i] === '--once' || args[i] === '-o') {
        oneshot = true;
    } else if (args[i] === '--purge-now') {
        purgeNow = true;
    } else if (args[i] === '--help' || args[i] === '-h') {
        console.log("==================================================");
        console.log("CekRAM - Universal RAM Monitor (Node.js Edition)");
        console.log("==================================================");
        console.log("Usage: node cekram.js [options]");
        console.log("Options:");
        console.log("  --lang, -l [id|en]      Language selection (default: id)");
        console.log("  --threshold, -t [NUM]   RAM usage threshold (default: 80)");
        console.log("  --interval, -i [SEC]    Refresh interval in seconds (default: 5)");
        console.log("  --oneshot, --once, -o   Run once and exit without looping");
        console.log("  --purge-now             Trigger purge immediately and exit");
        console.log("  --help, -h              Show help message");
        console.log("==================================================");
        process.exit(0);
    }
}

if (purgeNow) {
    console.log(getString('alert', lang));
    const res = purgeMemory();
    console.log(`  [+] ${res.detail}`);
    process.exit(0);
}

function render() {
    console.clear();
    console.log("==================================================");
    console.log(`        ${getString('title', lang)}`);
    console.log("==================================================");

    const metrics = getMetrics();
    console.log(`  ${getString('total', lang)} : ${metrics.totalMB} MB`);
    console.log(`  ${getString('used', lang)} : ${metrics.usedMB} MB`);
    console.log(`  ${getString('free', lang)} : ${metrics.freeMB} MB`);
    console.log(`  ${getString('percent', lang)} : [${metrics.percent} %]`);
    console.log("--------------------------------------------------");

    if (metrics.percent > threshold) {
        console.log(`  ${getString('alert', lang)}`);
        const res = purgeMemory();
        console.log(`  ${getString('done', lang)}`);
    } else {
        console.log(`  ${getString('status', lang)} : ${getString('safe', lang)}`);
    }
    console.log("--------------------------------------------------");

    if (oneshot) {
        process.exit(0);
    } else {
        console.log(`  ${getString('stop', lang)}`);
    }
}

render();
if (!oneshot) {
    setInterval(render, interval * 1000);
}
