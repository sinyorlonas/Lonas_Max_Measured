-- Lonas_Max_Measured installer. In 3ds Max: Scripting > Run Script... > this file.
(
    local src = getFilenamePath (getThisScriptFilename())
    local scripts = getDir #userScripts
    local dest = scripts + "\\Lonas_Max_Measured\\"
    local startupDir = scripts + "\\startup\\"
    local macroDir = getDir #userMacros

    fn lmCopy fromPath toPath =
    (
        if doesFileExist toPath then deleteFile toPath
        makeDir (getFilenamePath toPath)
        if not (copyFile fromPath toPath) then
            throw ("Copy failed:\n" + fromPath + "\n-> " + toPath)
    )

    if not doesFileExist (src + "Lonas_Max_Measured.ms") then
    (
        messageBox "Run this script from the unzipped Lonas_Max_Measured folder."
    )
    else
    (
        makeDir dest
        makeDir startupDir
        makeDir macroDir
        lmCopy (src + "Lonas_Max_Measured.ms") (dest + "Lonas_Max_Measured.ms")
        lmCopy (src + "Lonas_Max_Measured_ui.ms") (dest + "Lonas_Max_Measured_ui.ms")
        lmCopy (src + "Lonas_Max_Measured_startup.ms") (dest + "Lonas_Max_Measured_startup.ms")
        lmCopy (src + "Lonas_Max_Measured_startup.ms") (startupDir + "Lonas_Max_Measured_startup.ms")
        lmCopy (src + "macroscripts\\Lonas_Max_Measured-Open.mcr") (macroDir + "\\Lonas_Max_Measured-Open.mcr")
        fileIn (dest + "Lonas_Max_Measured.ms")
        fileIn (dest + "Lonas_Max_Measured_ui.ms")
        try (macros.load (macroDir + "\\Lonas_Max_Measured-Open.mcr")) catch ()
        LM_openUI()
        messageBox ("Lonas_Max_Measured installed.\n\nCustomize UI > Toolbars > category Lonas_Max_Measured > drag Lonas_Max_Measured to a toolbar.\n\nFiles:\n" + dest)
    )
)
