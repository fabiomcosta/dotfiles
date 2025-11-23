import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';

export const REPO_ROOT = path.resolve(
  fileURLToPath(import.meta.url),
  '..',
  '..'
);

export const DIR = path.join(REPO_ROOT, 'home');
export const SECRETS = path.join(REPO_ROOT, 'secrets');
export const META_HOME = path.join(SECRETS, 'meta-home');
export const HOME = os.homedir();

export const dir = (...args) => path.join(DIR, ...args);
export const secrets = (...args) => path.join(SECRETS, ...args);
export const metahome = (...args) => path.join(META_HOME, ...args);
export const home = (...args) => path.join(HOME, ...args);
