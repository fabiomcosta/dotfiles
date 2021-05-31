import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';

export const DIR = path.resolve(
  fileURLToPath(import.meta.url),
  '..',
  '..',
  'home'
);
export const SECRETS = path.resolve(
  fileURLToPath(import.meta.url),
  '..',
  '..',
  'secrets'
);
export const HOME = os.homedir();

export const dir = (...args) => path.join(DIR, ...args);
export const home = (...args) => path.join(HOME, ...args);
export const secrets = (...args) => path.join(SECRETS, ...args);
