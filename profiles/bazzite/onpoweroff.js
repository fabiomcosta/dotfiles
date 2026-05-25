#!/usr/bin/env node

const TOKEN =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmOTljNjE4Mzk4NjU0MmUwYWI0OTIwNTc2ZmIwZTY0MyIsImlhdCI6MTc3OTU3NjcyNCwiZXhwIjoyMDk0OTM2NzI0fQ.TE5yDlyXMaoMKvHipKLtVQPW_EHfgTfe2o3VV0elbGg';
const HA_ADDRESS = 'ha.fabio.pw';
const TV_ENTITY_ID = 'media_player.vizio_smartcast';
const HDMI_PORT_ID = 'HDMI-2';

const API_URL = `https://${HA_ADDRESS}/api`;
const TV_STATE_URL = `${API_URL}/states/${TV_ENTITY_ID}`;
const TV_ON_URL = `${API_URL}/services/media_player/turn_on`;
const TV_OFF_URL = `${API_URL}/services/media_player/turn_off`;

async function httpRequestWithJsonResponse(url, options) {
  try {
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${TOKEN}`,
        'Content-Type': 'application/json',
      },
      ...options,
    });

    if (!response.ok) {
      throw response;
      throw new Error(`HTTP error status: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Error fetching data:');
    console.error(error);
  }
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

async funcURLtion main() {
  // TODO first check if the TV is actually on HDMI-2 before turning it off.
  // This is so that we don't accidentaly turn it off in case the computer
  // is going to sleep or off while we are watching other things.
  await httpPost(TV_OFF_URL);
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
