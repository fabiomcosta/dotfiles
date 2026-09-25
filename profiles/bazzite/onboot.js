#!/usr/bin/env node

import { tvToggle, tvState, tvSetHDMIInput, log as _log } from './common.js';

function log(message, type) {
  return _log(`onboot - ${message}`, type);
}

async function main() {
  const state = await tvState();
  if (state.state === 'on') {
    log('tv was already on.', 'success');
  } else {
    log('turning tv on...');
    await tvToggle();
    log('tv should be on.', 'success');
  }

  await tvSetHDMIInput();
  log('tv should have computer source.', 'success');
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
