project('record', 'vala', version: '0.1')

dependencies = [
    dependency('glib-2.0'),
    dependency('gio-2.0'),
    dependency('gstreamer-1.0')
]

# Define executable
executable('record', 'recorder.vala',
           dependencies: dependencies,
           install: true)
