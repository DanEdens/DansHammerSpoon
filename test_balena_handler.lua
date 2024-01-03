
function retest_balena(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-3) == ".py" then
            doReload = true
        end
    end
    if doReload then
        local command = "python3 /Users/d.edens/lab/regressiontestkit/balena_handler.py"
        local output, status, type, rc = hs.execute(command, true)
        if status then
            hs.alert.show("Script executed: " .. output)
        else
            hs.alert.show("Error executing script")
        end
        hs.logger.default:info(output) -- Write the output to the Hammerspoon log
        doReload = false
    end
end

myBalenaWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/lab/regressiontestkit/", retest_balena):start()