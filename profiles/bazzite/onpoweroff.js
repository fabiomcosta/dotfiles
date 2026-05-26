#!/usr/bin/env node

import { tvOff } from './common.js';

async function main() {
  // TODO first check if the TV is actually on HDMI-2 before turning it off.
  // This is so that we don't accidentaly turn it off in case the computer
  // is going to sleep or off while we are watching other things.
  await tvOff();
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
