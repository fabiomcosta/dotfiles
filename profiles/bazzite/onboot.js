#!/usr/bin/env node

import { tvOn } from './common.js';

async function main() {
  await tvOn();
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
