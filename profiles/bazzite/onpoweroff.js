#!/usr/bin/env node

import { HDMI_PORT_ID, tvOff, tvState, log as _log } from './common.js';

function log(message, type) {
  return _log(`onpoweroff - ${message}`, type);
}

async function main() {
  const state = await tvState();
  if (state.state === 'off') {
    log('tv was already off.', 'success');
    return;
  }
  if (state.attributes.source !== HDMI_PORT_ID) {
    // If the TV is not on the "Computer" HDMI source, that means we are doing
    // something else (watching movie, etc), don't turn the tv off.
    log(`tv is not on the ${HDMI_PORT_ID} source, doing nothing.`, 'success');
    return;
  }

  log('turning tv off...');
  await tvOff();
  log('tv should be off.', 'success');
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
