import { $, nothrow } from 'zx';

export async function commandExists(commandName) {
  try {
    $.verbose = false;
    await $`hash ${commandName} 2> /dev/null`;
    return true;
  } catch (error) {
    if (error.exitCode == null) {
      throw error;
    }
    return false;
  } finally {
    $.verbose = true;
  }
}

export async function $swallow(...args) {
  return await nothrow($(...args));
}

export async function $silent(...args) {
  try {
    $.verbose = false;
    return await $(...args);
  } finally {
    $.verbose = true;
  }
}
