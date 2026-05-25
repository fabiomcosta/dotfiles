#!/usr/bin/env node

const fs = require('fs/promises');
const path = require('path');
const util = require('util');
const { execFile } = require('child_process');

const execFileAsync = util.promisify(execFile);

const DEVICES_PATH = '/sys/bus/usb/devices/';

// --- Logging & Notification Functions ---

// 1. Terminal-only logging for Info/Success
function logMessage(message, level = 'info') {
  if (level === 'success') {
    console.log(`[SUCCESS] ${message}`);
  } else {
    console.log(`[INFO]    ${message}`);
  }
}

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
    logMessage(`Scanning ${devices.length} potential USB devices...`, 'info');

    let enabledCount = 0;

    for (const deviceId of devices) {
      const wakeupPath = path.join(DEVICES_PATH, deviceId, 'power', 'wakeup');

      try {
        const currentState = (await fs.readFile(wakeupPath, 'utf8')).trim();

        if (currentState === 'disabled') {
          // Native write (Requires the script to be run with sudo)
          await fs.writeFile(wakeupPath, 'enabled', 'utf8');

          logMessage(`Enabled wakeup for device: ${deviceId}`, 'success');
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
      logMessage(
        'Finished: All supported USB devices were already enabled.',
        'info'
      );
    } else {
      logMessage(
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
