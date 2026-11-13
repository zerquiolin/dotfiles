"""Send the configured Ghostty CSI actions through Neovim's terminal decoder."""
import os
from pathlib import Path
import pty
import select
import subprocess
import time

root = Path(__file__).resolve().parents[1]
expected = {
    'super+semicolon': '<F13>',
    'super+alt+j': '<F14>',
    'super+j': '<F15>',
    'super+slash': '<F16>',
    'super+s': '<F17>',
    'super+q': '<F18>',
}
actions = {}
for line in (root / 'config/ghostty/config').read_text().splitlines():
    if line.startswith('keybind = '):
        trigger, action = line.removeprefix('keybind = ').split('=', 1)
        actions[trigger] = action
assert actions.get('super+v') == 'paste_from_clipboard', 'Cmd-V must retain native clipboard paste'
assert actions.get('performable:super+c') == 'copy_to_clipboard', 'Cmd-C must copy terminal selections and pass through otherwise'
sequences = []
for trigger in expected:
    action = actions[trigger]
    assert action.startswith('csi:'), f'{trigger} must use a direct CSI action'
    sequences.append(b'\x1b[' + action.removeprefix('csi:').encode('ascii'))

(root / '.state').mkdir(exist_ok=True)
result = root / '.state/terminal-keys.txt'
master, slave = pty.openpty()
script = root / '.state/read-terminal-keys.lua'
script.write_text(f'''local keys = {{}}
for i=1,{len(expected)} do keys[i]=vim.fn.keytrans(vim.fn.getcharstr()) end
vim.fn.writefile(keys, vim.env.DOTFILES_KEY_RESULT)
vim.cmd('qa!')
''')
env = dict(os.environ, TERM='xterm-256color', DOTFILES_KEY_RESULT=str(result))
proc = subprocess.Popen(['nvim','--clean','-n','-i','NONE','-c',f'lua dofile("{script}")'], stdin=slave, stdout=slave, stderr=slave, env=env)
os.close(slave)
try:
    deadline = time.monotonic() + 2
    while time.monotonic() < deadline:
        if select.select([master], [], [], 0.05)[0]:
            os.read(master, 65536)
    os.write(master, b''.join(sequences))
    deadline = time.monotonic() + 10
    while proc.poll() is None and time.monotonic() < deadline:
        if select.select([master], [], [], 0.1)[0]:
            try:
                os.read(master, 65536)
            except OSError:
                break
    proc.wait(timeout=2)
    keys = result.read_text().splitlines()
    assert keys == list(expected.values()), keys
    print('PASS configured Ghostty CSI actions decode as F13/F14/F15/F16/F17/F18 in Neovim; Cmd-V keeps native paste')
finally:
    if proc.poll() is None:
        proc.kill()
        proc.wait()
    os.close(master)
