macroScript LonasMaxMeasuredOpen
category:"Lonas_Max_Measured"
internalCategory:"Lonas_Max_Measured"
buttonText:"Lonas_Max_Measured"
tooltip:"Lonas_Max_Measured CAD dimensions"
(
    on execute do
    (
        local root = (getDir #userScripts) + "\\Lonas_Max_Measured\\"
        if not doesFileExist (root + "Lonas_Max_Measured.ms") then
        (
            messageBox ("Lonas_Max_Measured is not installed.\nCopy the plugin folder to:\n" + root)
            return false
        )
        fileIn (root + "Lonas_Max_Measured.ms")
        fileIn (root + "Lonas_Max_Measured_ui.ms")
        LM_openUI()
    )
)
