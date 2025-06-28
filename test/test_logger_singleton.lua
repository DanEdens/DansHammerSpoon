-- Test script for HyperLogger singleton pattern
local HyperLogger = require('HyperLogger')

print("=== TESTING HYPERLOGGER SINGLETON PATTERN ===\n")

-- Phase 1: Create multiple loggers with the same namespace
print("Phase 1: Creating multiple loggers with same namespace")
local log1 = HyperLogger.new('TestLogger', 'debug')
print("Created first logger with 'debug' level")
local log2 = HyperLogger.new('TestLogger', 'info')    -- Should reuse the existing logger
print("Attempted to create second logger with 'info' level (should reuse first)")
local log3 = HyperLogger.new('TestLogger', 'warning') -- Should reuse and update level
print("Attempted to create third logger with 'warning' level (should reuse and update)")

-- Log some messages with each logger
print("\nLogging from multiple instances of the same logger:")
log1:d('Debug message from log1')
log2:i('Info message from log2')
log3:w('Warning message from log3')

-- Phase 2: Create loggers with different namespaces
print("\nPhase 2: Creating loggers with different namespaces")
local mainLog = HyperLogger.new('Main', 'info')
local windowLog = HyperLogger.new('WindowMana', 'debug')
local fileLog = HyperLogger.new('FileManager', 'info')

-- Log some messages
print("\nLogging from different namespaces:")
mainLog:i('Info message from Main')
windowLog:d('Debug message from WindowMana')
fileLog:i('Info message from FileManager')

-- Phase 3: Get list of all registered loggers
print("\nPhase 3: Getting list of registered loggers")
local loggers = HyperLogger.getLoggers()
print("Number of registered loggers: " .. #loggers)
print("Registered loggers: " .. table.concat(loggers, ", "))

-- Phase 4: Test log level consistency
print("\nPhase 4: Testing log level consistency")
print("Current log level for TestLogger: " .. log1:getLogLevel())
print("Changing log level to 'error'...")
log1:setLogLevel('error')
print("New log level: " .. log1:getLogLevel())
print("Log level for log2 reference: " .. log2:getLogLevel())
print("Log level for log3 reference: " .. log3:getLogLevel())

-- Phase 5: Check if logger2 and logger3 reference the same object
print("\nPhase 5: Checking identity")
local isSameLevel = log2:getLogLevel() == log3:getLogLevel()
print("log2 and log3 have same log level: " .. tostring(isSameLevel))

-- Try to create another logger with the same namespace but different level
print("\nPhase 6: Creating another logger with same namespace but different level")
local log4 = HyperLogger.new('TestLogger', 'debug')
print("log4 level: " .. log4:getLogLevel())
print("log1 level: " .. log1:getLogLevel())
print("Are they the same? " .. tostring(log4:getLogLevel() == log1:getLogLevel()))

print("\n=== TEST COMPLETED ===")

-- Return the test loggers for manual testing in the console
return {
    log1 = log1,
    log2 = log2,
    log3 = log3,
    log4 = log4,
    mainLog = mainLog,
    windowLog = windowLog,
    fileLog = fileLog
}
