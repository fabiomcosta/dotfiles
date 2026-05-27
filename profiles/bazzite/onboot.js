#!/usr/bin/env node

import { tvOn, log } from './common.js';

async function main() {
  log('onboot - turning tv on...');
  await tvOn();
  log('onboot - tv should be on.');
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
