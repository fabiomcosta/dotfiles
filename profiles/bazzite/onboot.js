#!/usr/bin/env node

import { tvOn, tvState, log as _log } from './common.js';

function log(message, type) {
  return _log(`onboot - ${message}`, type);
}

async function main() {
  const state = await tvState();
  if (state.state === 'on') {
    log('tv was already on.', 'success');
    return;
  }

  log('turning tv on...');
  await tvOn();
  log('tv should be on.', 'success');
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
