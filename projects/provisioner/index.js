import fs from 'fs';
import path from 'path';
import { NodeSSH } from'node-ssh';
import arp from '@network-utils/arp-lookup';
import dotenv from 'dotenv';
dotenv.config();

const HOSTS = [{
  hostname: process.env.HOST_HOSTNAME,
  mac: process.env.HOST_MAC,
  ssh: {
    username: process.env.HOST_SSH_USERNAME,
    password: process.env.HOST_SSH_PASSWORD
  }
}];

async function hostConfigToConnectConfig({ mac, ssh: { username, password } }) {
  return {
    host: await arp.toIP(mac),
    username,
    password,
    tryKeyboard: true,
  };
}

async function main() {
  const ssh = new NodeSSH();
  await ssh.connect(await hostConfigToConnectConfig(HOSTS[0]));
  const result = await ssh.execCommand('hostname');
}

main()
  .then(process.exit)
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

