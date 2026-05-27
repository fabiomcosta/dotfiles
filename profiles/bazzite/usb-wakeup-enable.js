#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import util from 'util';
import { execFile } from 'child_process';
import { log } from './common.js';

const execFileAsync = util.promisify(execFile);

const DEVICES_PATH = '/sys/bus/usb/devices/';

// --- Logging & Notification Functions ---

// 2. Terminal error logging AND desktop notifications
async function logAndNotifyError(message, error) {
  // Log the clean message
  console.error(`[ERROR]   ${message}`);

  // Log the full error object/stack trace to the terminal
  if (error) {
    console.error(error);
  }

  try {
    // Send the clean message to the desktop notification
    await execFileAsync('notify-send', [
      'usb-wakeup-enable.service',
      message,
      `-u`,
      'critical',
    ]);
  } catch (notifyError) {
    console.error('[CRITICAL] Could not trigger notify-send:');
    // Log the full notification error stack trace
    console.error(notifyError);
  }
}

// --- Main Script ---
async function enableUsbWakeup() {
  try {
    const devices = await fs.readdir(DEVICES_PATH);
    log(`Scanning ${devices.length} potential USB devices...`, 'info');

    let enabledCount = 0;

    for (const deviceId of devices) {
      const wakeupPath = path.join(DEVICES_PATH, deviceId, 'power', 'wakeup');

      try {
        const currentState = (await fs.readFile(wakeupPath, 'utf8')).trim();

        if (currentState === 'disabled') {
          // Native write (Requires the script to be run with sudo)
          await fs.writeFile(wakeupPath, 'enabled', 'utf8');

          log(`Enabled wakeup for device: ${deviceId}`, 'success');
          enabledCount++;
        }
      } catch (error) {
        if (error.code !== 'ENOENT') {
          await logAndNotifyError(
            `Failed to process device ${deviceId}`,
            error
          );
        }
      }
    }

    if (enabledCount === 0) {
      log('Finished: All supported USB devices were already enabled.', 'info');
    } else {
      log(
        `Finished: Enabled wakeup for ${enabledCount} USB device(s).`,
        'success'
      );
    }
  } catch (error) {
    await logAndNotifyError('Failed to read USB directory', error);
    // Rethrow so the outer .catch() can catch it and exit with code 1
    throw error;
  }
}

// Safely execute and exit
enableUsbWakeup()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
