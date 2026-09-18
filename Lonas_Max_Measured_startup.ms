-- Auto-load Lonas_Max_Measured on 3ds Max startup.
(
    local root = (getDir #userScripts) + "\\Lonas_Max_Measured\\"
    if doesFileExist (root + "Lonas_Max_Measured.ms") then fileIn (root + "Lonas_Max_Measured.ms")
    if doesFileExist (root + "Lonas_Max_Measured_ui.ms") then fileIn (root + "Lonas_Max_Measured_ui.ms")
)
