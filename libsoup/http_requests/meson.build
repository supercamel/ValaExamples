project('vget', 'vala', version: '0.1')

dependencies = [
    dependency('glib-2.0'),
    dependency('libsoup-3.0')
]

# Define executable
executable('vget', 'main.vala',
           dependencies: dependencies,
           install: true)
