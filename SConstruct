import os, glob, string

ssrdir = os.environ["SSRDIR"]

nodes = ['.']
dirs = []
vs = []

while nodes:
  node = nodes.pop()
  b = os.path.basename(node)
  if node.endswith('.v'):
    vs += [node]
  if os.path.isdir(node):
    dirs += [node]
    nodes += glob.glob(node + '/*')

ssr_include = '-I ' + ssrdir + '/theories -as Ssreflect'

coqc = ssrdir + '/bin/ssrcoq -compile ${str(SOURCE)[:-2]} ' + ssr_include

env = DefaultEnvironment(ENV = os.environ)
env.Append(BUILDERS = {'Coq' : Builder(action = coqc, suffix = '.vo', src_suffix = '.v')})

for node in vs:
  vo = env.Coq(node)
  env.Clean(vo, node[:-2] + '.glob')

os.system('coqdep -I . ' + ' '.join(vs) + ' > deps')
ParseDepends('deps')
