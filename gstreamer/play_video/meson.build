project('player', 'vala', version: '0.1')

dependencies = [
    dependency('glib-2.0'),
    dependency('gio-2.0'),
    dependency('gtk+-3.0'),
    dependency('gstreamer-1.0')
]

# Define executable
executable('player', 'player.vala',
           dependencies: dependencies,
           install: true)
