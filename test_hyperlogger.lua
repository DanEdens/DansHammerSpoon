local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('TestLogger', 'debug')

log:i('This is a test info message from test_hyperlogger.lua')
log:d('This is a test debug message')
log:w('This is a test warning message')
log:e('This is a test error message')

-- Test with manual file and line specification
log:i('This message has a custom file path and line number', '/Users/d.edens/.hammerspoon/hotkeys.lua', 42)
