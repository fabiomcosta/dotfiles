import * as fs from 'fs/promises';
import { secrets } from '../../src/path.js';

const HA_ADDRESS = 'ha.fabio.pw';
const TV_ENTITY_ID = 'media_player.vizio_smartcast';
export const HDMI_PORT_ID = 'HDMI-2';

const API_URL = `https://${HA_ADDRESS}/api`;
const TV_STATE_URL = `${API_URL}/states/${TV_ENTITY_ID}`;
const TV_ON_URL = `${API_URL}/services/media_player/turn_on`;
const TV_OFF_URL = `${API_URL}/services/media_player/turn_off`;

async function genHomeAssistantToken() {
  const haTokenPath = secrets('home_assistant.token');
  return (await fs.readFile(haTokenPath, 'utf8')).trim();
}

async function runWithRetry(job, options = {}) {
  const {
    maxRetries = 5,
    delayMs = 1000,
    errorCodes = ['EAI_AGAIN'],
  } = options;
  for (let i = 1; i <= maxRetries; i++) {
    try {
      return await job();
    } catch (error) {
      if (!errorCodes.includes(error.cause?.code) || i === maxRetries) {
        // If it's a different kind of error, fail immediately
        throw error;
      }

      console.info(
        `DNS not ready. Retry ${i}/${maxRetries} in ${delayMs / 1000}s...`
      );
      // Wait for the specified delay before the loop repeats
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }
}

async function httpRequestWithJsonResponse(url, options) {
  const token = await genHomeAssistantToken();

  const response = await runWithRetry(async () => {
    return await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      ...options,
    });
  });

  if (!response.ok) {
    throw new Error(`HTTP error status: ${response.status}`);
  }

  return await response.json();
}

async function httpPost(url) {
  return await httpRequestWithJsonResponse(url, {
    method: 'POST',
    body: JSON.stringify({
      entity_id: TV_ENTITY_ID,
    }),
  });
}

async function httpGet(url) {
  return await httpRequestWithJsonResponse(url, {
    method: 'GET',
  });
}

export function log(message, level = 'info') {
  if (level === 'success') {
    console.log(`[SUCCESS] ${message}`);
  } else {
    console.log(`[INFO]    ${message}`);
  }
}

export async function tvState() {
  return await httpGet(TV_STATE_URL);
}

export async function tvOn() {
  return await httpPost(TV_ON_URL);
}

export async function tvOff() {
  return await httpPost(TV_OFF_URL);
}
