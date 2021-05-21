import { $ } from 'zx';

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
