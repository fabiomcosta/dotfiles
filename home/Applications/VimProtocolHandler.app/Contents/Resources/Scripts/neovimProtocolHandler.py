#!/usr/bin/python3

# TODO
# * Provide helpful error if trying to open a file that is not available to the nvim instance.
#   Example: trying to open an fbsource link on a server that only contains www.
# * Support devserver
# * Support et?
# * [DONE] Support local links for projects known to be local, like wa-js
# * [DONE] detect if ssh is properly configured

'''
This script opens codehub urls on Neovim.

# How it works

As you might be aware, neovim can be used in multiple ways and we also
have local and remote projects that run on ondemand or devserver machines.

This script has been tested on macOS and currently works as described below.

## For Local projects

We try to find an nvim process that is able to open files for the provided
project (according to the project_to_path config), then if the nvim process is
running on tmux, we select its window in order to change the focus to it and
so nvim is visible on that terminalself.
We then try to focus on any of the most known terminal applications with
the help of the focus_currently_open_terminal.scpt script.

## For Remote projects

We check is ssh is configured properly, then try to find the ~/.ssh/vph_*.sock
unix sockets that are actively in use.
Once found, we try to see if there are nvim instances listening to those
sockets that can actually open the requested files.
Once those instances are found we ask them to open the file.
When then try to select the tmux window being used by ssh to connect to
the ondemand server so that the local tmux instance changes the focus
to that window.
We then try to focus on any of the most known terminal applications with
the help of the focus_currently_open_terminal.scpt script.

# Configuration

In order to open files on nvim processes running on ondemands servers,
there is still some extra setup that needs to happen, see below.

## ssh

Add this to your local ~/.ssh/config file:

  Host *.od.fbinfra.net
      ForwardAgent yes
      LocalForward /tmp/vph_%C.sock localhost:8082

## ondemand

With the previous configuration we are making sure the ssh will
forward data from the local vph_*.sock unix socket to the localhost:8082
address on our ondemand.
With this setup we need to make sure that nvim is listening to localhost:8082
so it can open files (and execute some other commands that we need).

For that, make sure you add the following line on your ondemand .bashrc:

  export NVIM_LISTEN_ADDRESS="localhost:8082"

'''

import os
import re
import sys
import glob
import shlex
import logging
import subprocess
from functools import lru_cache
from urllib.parse import urlparse, parse_qs, unquote


project_to_path = {
  'local': {
    'wa-js': '~/local/whatsapp/wajs/',
  },
  'remote': {
    'facebook-www': '~/www/',
    'facebook-admin': '~/admin/',
    'opsfiles': '~/opsfiles/',
    'fbsource': '~/fbsource/',
  }
}

supported_url_scheme = {
  'scheme': ['fb-vscode', 'vim', 'neovim'],
  'netloc': ['nuclide.core'],
  'path': ['/open-arc'],
}


dirname = os.path.dirname(__file__)
name = os.path.basename(__file__)

logpath = '/tmp/{}.log'.format(name)
logging.basicConfig(
  filename=logpath,
  level=logging.DEBUG,
  format='%(asctime)s %(levelname)s %(message)s'
)
logger = logging.getLogger(name)


def to_int(value):
  try:
    return int(value)
  except ValueError as error:
    pass
  return None


def run_proc(cmd, check=True, debug=True):
  is_shell = isinstance(cmd, str)
  if debug:
    logger.debug('running command: {}'.format(cmd if is_shell else shlex.join(cmd)))
  try:
    return subprocess.run(cmd, shell=is_shell, check=check, capture_output=True)
  except subprocess.CalledProcessError as error:
    logger.error('\n{}\nstderr: {}\nstdout: {}'.format(error, error.stderr, error.stdout))


def runs(cmd, check=True, debug=True):
  return not run_proc(cmd, check=check, debug=debug) is None


def run(cmd, check=True, debug=True):
  proc = run_proc(cmd, check=check, debug=debug)
  if proc is None:
    return
  return proc.stdout.decode('utf-8').strip()


def log_error(error, exc_info=False):
  message = str(error)
  notify('{}. See error logs at {}'.format(re.sub(r'\.+$', '', message), logpath))
  logger.error(message, exc_info=exc_info)


def log_error_and_exit(error, exc_info=False):
  log_error(error, exc_info=exc_info)
  sys.exit(1)


def notify(text, title = 'Vim Protocol Handler'):
  def quote(t):
    return t.replace('"', '\\"')
  run(['osascript', '-e', 'display notification "{}" with title "{}"'.format(quote(text), quote(title))], debug=False)


def focus_currently_open_terminal():
  run(['osascript', '{}/focus_currently_open_terminal.scpt'.format(dirname)])


# Parses the output of an lsof command with the `-F pfn` format option
def parse_lsof_pfn(lsof_output):
  processes = {}

  if not lsof_output:
    return processes

  lsof_lines = lsof_output.split('\n')
  pid = None
  field_name = None

  for line in lsof_lines:
    field_key = line[0]
    field_value = line[1:]
    if field_key == 'p':
      pid = field_value
      processes[pid] = {'pid': pid}
      continue
    if field_key == 'f':
      # "16", "6" and others is not easy to understandable, renaming it to
      # something more descriptive
      if not to_int(field_value) is None:
        field_name = 'unix_socket_path'
      continue
    if field_key == 'n':
      processes[pid][field_name] = field_value
      continue

  return processes


# Temporary placeholder for a function that will smartly detect if the User
# uses tmux.
lru_cache(maxsize=None)
def is_tmux_user():
  return True


def tmux_select_window_by_tty(tty):
  if not is_tmux_user():
    return

  # ex: %19
  tmux_pane_id = run("tmux list-panes -a -F '#{pane_tty} #{pane_id}' | grep "+ tty +" | awk '{print $2}'")
  run('tmux select-window -t {}'.format(tmux_pane_id))


def focus_tmux_window_with_ssh(socket):
  if not is_tmux_user():
    return

  # getting hostname from the server running the nvim instance that is listening to socket
  # not sure why it goes to stderr, but it is what it is.
  # ex: 34120.od.fbinfra.net
  hostname = run_proc(['nvim', '--server', socket, '--remote-expr', 'hostname()']).stderr.decode('utf-8').strip()

  # getting the tty for the local ssh command that connects to the hostname running nvim
  tty = run("ps -o tty= -o command= | grep ssh | grep "+ hostname +" | grep -v grep | awk '{print $1}'")
  tmux_select_window_by_tty(tty)


def parse_and_validate_url(url):
  validation = supported_url_scheme

  parsed_url = urlparse(url)
  parsed_qs = parse_qs(parsed_url.query)

  if parsed_url.scheme not in validation['scheme']:
    log_error_and_exit('scheme (protocol) not supported on {}. Supported schemes: {}'.format(url, validation['scheme']))

  if parsed_url.netloc not in validation['netloc']:
    log_error_and_exit('application (domain) not supported on {}. Supported applications: {}'.format(url, validation['netloc']))

  if parsed_url.path not in validation['path']:
    log_error_and_exit('command (path) not supported on {}. Supported commands: {}'.format(url, validation['path']))

  if not 'project' in parsed_qs:
    log_error_and_exit('No "project" query param found on {}.'.format(url))

  if not 'path' in parsed_qs:
    log_error_and_exit('No "path" query param found on {}.'.format(url))

  return parsed_url, parsed_qs


def get_supported_project_paths(project_name):

  if not project_name in project_to_path['local'] and not project_name in project_to_path['remote']:
    log_error_and_exit('Project {} not supported.\nSupported local projects: {}\nSupported remote projects: {}'.format(project_name, project_to_path['local'].keys(), project_to_path['remote'].keys()))

  project = {}

  if project_name in project_to_path['local']:
    project['local'] = project_to_path['local'][project_name]

  if project_name in project_to_path['remote']:
    project['remote'] = project_to_path['remote'][project_name]

  return project


# vph == vim protocol handler
def get_all_open_vph_sockets():
  # Even when this lsof call returns values it for some reason returns a
  # non-zero status. So using check=False.
  return parse_lsof_pfn(run('lsof -anP -F pfn /tmp/vph_*.sock'), check=False))


# TODO this could easily become an async loop
def get_socket_for_project(project_path):
  vph_sockets = get_all_open_vph_sockets()

  for pid, socket in vph_sockets.items():
    socket = socket['unix_socket_path']

    server_has_project_path = run_proc(['nvim', '--server', socket, '--remote-expr', 'isdirectory(expand("{}"))'.format(project_path)])

    if server_has_project_path is None:
      continue

    # The isdirectory function returns 1 or 0.
    # There is no need to convert it to bool, but we are doing it for clarity.
    if not bool(to_int(server_has_project_path.stderr.decode('utf-8').strip())):
      continue

    return socket


def attempt_to_open_file_remotely(socket, file):
  if not runs(['nvim', '--server', socket, '--remote-send', ':e {line} {path}<CR>'.format(**file)]):
    log_error("Could not open file remotely. Make sure to define the NVIM_LISTEN_ADDRESS='localhost:8082' env variable before running a neovim instance on your server.")

  return True


def get_currently_open_nvim_processes():
  # Get the socket paths that nvim is using to listen to commands
  # With the cwd from each of these processes we can smartly detect the right
  # nvim instance to send the commands to.
  '''
    Example output of this command:

      p4902
      fcwd
      n/Users/fabs/Dev/own/dotfiles
      f16
      n/var/folders/gc/ljcry8fs5cd7qc7h2c25d9gc0000gn/T/nvimkhqK1z/0
      p36781
      fcwd
      n/Users/fabs/local/whatsapp/wajs/web
      f16
      n/var/folders/gc/ljcry8fs5cd7qc7h2c25d9gc0000gn/T/nvimjI8WjN/0
  '''
  return parse_lsof_pfn(run('lsof -anP -F pfn -d 16 -d cwd -c nvim'))


def attempt_to_open_file_locally(file):
  processes = get_currently_open_nvim_processes()
  project_path = os.path.realpath(os.path.expanduser(file['project_path']))
  file_path = os.path.realpath(os.path.expanduser(file['path']))

  nvim_process = next(v for k, v in processes.items() if v['cwd'].startswith(project_path))

  if nvim_process is None:
    log_error("Could not find a nvim process running on your project's folder: {}".format(project_path))

  logger.info('Found nvim process {} running on {}'.format(nvim_process, project_path))

  nvim_tty = run(['ps', '-o', 'tty=', nvim_process['pid']])

  socket_path = nvim_process['unix_socket_path']

  if runs(['nvim', '--server', socket_path, '--remote-send', ':e {line} {path}<CR>'.format(**file)]):
    # TODO idealy this would happen outside this function
    tmux_select_window_by_tty(nvim_tty)
    return True

  log_error("Could not open file locally. Make sure you have a nvim instance running locally on your project's folder.")
  return False


def main(url):
  # assuming nvim and tmux (optional) were installed via homebrew
  os.environ['PATH'] += ':/usr/local/bin/'

  logger.info('Handling url {}'.format(url))

  parsed_url, parsed_qs = parse_and_validate_url(url)

  project_paths = get_supported_project_paths(parsed_qs['project'][0])
  relative_file_path = unquote(parsed_qs['path'][0])
  line = '+{}'.format(parsed_qs['line'][0]) if 'line' in parsed_qs else ''

  logger.info('Trying to open {} on {}...'.format(relative_file_path, project_paths))

  # We'll prefer trying to open the file on a remove server over locally
  # As if there is a server open that is capable of opening this file, it's
  # very likely that the user wants to use the server, instead of trying
  # to open it locally.
  if 'remote' in project_paths:
    project_path = project_paths['remote']
    file_path = os.path.normpath(os.path.join(project_paths['remote'], relative_file_path))
    file = {'project_path': project_path, 'path': file_path, 'line': line}

    if not runs("ssh -G '*.od.fbinfra.net' | grep -i LocalForward | grep '/tmp/vph_*'"):
      log_error_and_exit('ssh is not properly configured. See wiki for instructions.')

    logger.info('Trying to open file remotely...')

    socket = get_socket_for_project(file['project_path'])
    if socket is None:
      log_error_and_exit('Could not find remove nvim instance that can open files for project {project_path}.\nMake sure to connect to an ondemand using ssh and open nvim at {project_path}.'.format(**file))

    if attempt_to_open_file_remotely(socket, file):
      logger.info('Successfully opened file remotely.')
      notify('Opened {} on your remote editor.'.format(file['path']))
      focus_tmux_window_with_ssh(socket)
      focus_currently_open_terminal()
      return sys.exit(0)

  if 'local' in project_paths:
    project_path = project_paths['local']
    file_path = os.path.normpath(os.path.join(project_path, relative_file_path))
    file = {'project_path': project_path, 'path': file_path, 'line': line}

    logger.info('Trying to open file locally...')
    if attempt_to_open_file_locally(file):
      logger.info('Successfully opened file locally.')
      notify('Opened {} on your local editor.'.format(file['path']))
      focus_currently_open_terminal()


if __name__ == '__main__':
  if len(sys.argv) < 2:
    log_error_and_exit('expects 1 argument')

  if sys.platform != 'darwin':
    log_error_and_exit('This script has only be tested on macOS.')

  try:
    main(sys.argv[1])
  except Exception as error:
    log_error_and_exit(error, exc_info=True)
