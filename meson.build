project(
  'fixdep',
  'c',
  version: '1.0.0',
  license: 'GPL-2.0-only',
  meson_version: '>=0.59.0',
)

cc = meson.get_compiler('c')

fixdep_src = files('fixdep/fixdep.c')

fixdep_exe = executable(
  'fixdep',
  fixdep_src,
  install: true,
  install_dir: get_option('bindir'),
)
