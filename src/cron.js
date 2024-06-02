import { $ } from 'zx';
import { fileURLToPath } from 'url';
import path from 'path';
import { OK, hl } from './log.mjs';

// Every 30mins
// const cronScheduleExpression = '*/30 * * * *';
const cronScheduleExpression = '* * * * *';
const cronRootScriptPath = path.resolve(
  fileURLToPath(import.meta.url),
  '..',
  'cron_root_script.sh'
);

export async function setupCron() {
  // https://stackoverflow.com/questions/4880290/how-do-i-create-a-crontab-through-a-script
  const cronLine = `${cronScheduleExpression} ${cronRootScriptPath} >/tmp/cron_personal_stdout.log 2>/tmp/cron_personal_stderr.log`;
  const cronTabs = await $`crontab -l`;
  if (!cronTabs.stdout.includes(cronLine)) {
    await $`sh -c "(crontab -l 2>/dev/null || true; echo ${cronLine}) | crontab -"`;
    OK`${hl('cron')} installed.`;
  } else {
    OK`${hl('cron')} was already installed.`;
  }
}
