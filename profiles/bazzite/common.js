import * as fs from 'fs/promises';
import { secrets } from '../../src/path.js';

const HA_ADDRESS = 'ha.fabio.pw';
const TV_ID = 'vizio_smartcast';
const FIRETV_ID = 'living_room_fire_tv_cube';

const MP_TV_ID = `media_player.${TV_ID}`;
const REMOTE_FIRETV_ID = `remote.${FIRETV_ID}`;

const API_URL = `https://${HA_ADDRESS}/api`;

const HA_UPDATE_ENTITY = `${API_URL}/services/homeassistant/update_entity`;

const TV_STATE_URL = `${API_URL}/states/${MP_TV_ID}`;
const TV_TOGGLE_URL = `${API_URL}/services/media_player/toggle`;
const REMOTE_SEND_COMMAND_URL = `${API_URL}/services/remote/send_command`;

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

async function httpGet(url) {
  return await httpRequestWithJsonResponse(url, {
    method: 'GET',
  });
}

async function httpPost(url, extraBody = {}) {
  return await httpRequestWithJsonResponse(url, {
    method: 'POST',
    body: JSON.stringify(extraBody),
  });
}

async function httpPostForTv(url, extraBody = {}) {
  return await httpPost(url, { entity_id: MP_TV_ID, ...extraBody });
}

async function httpPostForFireTvRemote(url, extraBody = {}) {
  return await httpPost(url, { entity_id: REMOTE_FIRETV_ID, ...extraBody });
}

export function log(message, level = 'info') {
  if (level === 'success') {
    console.log(`[SUCCESS] ${message}`);
  } else {
    console.log(`[INFO]    ${message}`);
  }
}

export async function haEntityUpdate() {
  return await httpPostForTv(HA_UPDATE_ENTITY);
}

export async function tvState() {
  // Force the entity to be updated before we read its state.
  // It can take ~5s for HA to update the state of an entity, this helps
  // mitigate that.
  await haEntityUpdate();
  return await httpGet(TV_STATE_URL);
}

export async function tvToggle() {
  return await httpPostForTv(TV_TOGGLE_URL);
}

export async function tvSetHDMIInput() {
  return await httpPostForFireTvRemote(REMOTE_SEND_COMMAND_URL, {
    // This sequence of commands will select the first HDMI input.
    // There are 2 extra 'ENTER's on this list which seem to improve
    // reliability of the input selection.
    command: ['HOME', 'MENU', 'UP', 'ENTER', 'ENTER', 'ENTER', 'ENTER'],
    delay_secs: 2,
  });
}
