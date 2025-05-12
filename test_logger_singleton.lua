-- Test script for HyperLogger singleton pattern
local HyperLogger = require('HyperLogger')

print("=== TESTING HYPERLOGGER SINGLETON PATTERN ===\n")

-- Phase 1: Create multiple loggers with the same namespace
print("Phase 1: Creating multiple loggers with same namespace")
local log1 = HyperLogger.new('TestLogger', 'debug')
local log2 = HyperLogger.new('TestLogger', 'info')    -- Should reuse the existing logger
local log3 = HyperLogger.new('TestLogger', 'warning') -- Should reuse and update level

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
print("Registered loggers: " .. table.concat(loggers, ", "))

-- Phase 4: Try setting a different log level
print("\nPhase 4: Changing log level")
local beforeLevel = log1:getLogLevel()
print("Before log level: " .. beforeLevel)
log1:setLogLevel('error')
local afterLevel = log1:getLogLevel()
print("After log level: " .. afterLevel)

-- Phase 5: Check if logger2 and logger3 reference the same object
print("\nPhase 5: Checking if loggers reference the same object")
print("log2 and log3 have same log level: " .. tostring(log2:getLogLevel() == log3:getLogLevel()))

print("\n=== TEST COMPLETED ===")

-- Return the test loggers for manual testing in the console
return {
    log1 = log1,
    log2 = log2,
    log3 = log3,
    mainLog = mainLog,
    windowLog = windowLog,
    fileLog = fileLog
}
