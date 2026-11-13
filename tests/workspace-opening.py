import pathlib,tempfile,subprocess,importlib.machinery,importlib.util,unittest.mock as mock,time,json
loader=importlib.machinery.SourceFileLoader('w',str(pathlib.Path(__file__).resolve().parents[1]/'bin/work'));spec=importlib.util.spec_from_loader('w',loader);m=importlib.util.module_from_spec(spec);loader.exec_module(m)
original=m.run
def run(*args,**kw):
 if args[1] in ('attach-session','switch-client'):return
 return original(*args,**kw)
m.run=run
with tempfile.TemporaryDirectory() as tmp:
 x=dict(name='Opening audit',path=tmp,group='Tests');name=m.session(x);state=m.workspace_state(name)
 def editor():
  for _ in range(80):
   for file in state.glob('editor-*.json'):
    data=json.loads(file.read_text())
    if subprocess.run(['nvim','--server',data['socket'],'--remote-expr','1'],capture_output=True).returncode==0:return data
   time.sleep(.1)
  raise AssertionError('No live editor')
 try:
  m.open_project(x,'code');data=editor()
  assert len(m.tmux_output('list-panes','-t',name,'-F','#{pane_id}').splitlines())==1
  file=pathlib.Path(tmp)/'sample.txt';file.write_text('sample\n')
  expression="luaeval(\"(function() vim.cmd.edit(_A); vim.cmd.vsplit(); vim.cmd.tabnew(); return vim.fn.getpid() end)()\", '"+str(file)+"')"
  pid=m.tmux_rpc(data['socket'],expression);m.open_project(x,'code');assert m.tmux_rpc(data['socket'],'getpid()')==pid
  m.run('tmux','new-window','-t',name,'-n','Shell','-c',tmp)
  with mock.patch('builtins.input',return_value='y'):m.stop_project(x)
  m.open_project(x,'code');restored=editor();time.sleep(.5)
  assert len(m.tmux_output('list-windows','-t',name,'-F','#{window_id}').splitlines())==2
  assert int(m.tmux_rpc(restored['socket'],'tabpagenr("$")'))==2
  assert m.tmux_output('display-message','-p','-t',name,'#{window_name}')=='Shell'
  print('PASS first opening, no sidebar, live resume, stopped window/editor restoration and focused window')
 finally:subprocess.run(['tmux','kill-session','-t',name],capture_output=True)
