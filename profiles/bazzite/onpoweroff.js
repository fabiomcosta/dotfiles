#!/usr/bin/env node

import { tvToggle, tvState, log as _log } from './common.js';

function log(message, type) {
  return _log(`onpoweroff - ${message}`, type);
}

async function main() {
  const state = await tvState();
  if (state.state === 'off') {
    log('tv was already off.', 'success');
    return;
  }

  log('turning tv off...');
  await tvToggle();
  log('tv should be off.', 'success');
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
