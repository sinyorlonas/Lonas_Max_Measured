(
    local boxNode = getNodeByName "LM_TestBox"
    local outTxt = ""
    if boxNode == undefined then
        "FAIL missing_LM_TestBox"
    else
    (
        local ext = LiveMeasure.bboxExtents boxNode
        outTxt += "sx=" + (ext[1] as string) + " sy=" + (ext[2] as string) + " sz=" + (ext[3] as string) + "\n"
        outTxt += (if (abs (ext[1] - 100.0) < 0.001) then "PASS bbox_width\n" else "FAIL bbox_width\n")
        outTxt += (if (abs (ext[2] - 50.0) < 0.001) then "PASS bbox_length\n" else "FAIL bbox_length\n")
        outTxt += (if (abs (ext[3] - 30.0) < 0.001) then "PASS bbox_height\n" else "FAIL bbox_height\n")
        LiveMeasure.unitsType = "cm"
        LiveMeasure.decimals = 2
        LiveMeasure.textSize = 8.0
        LiveMeasure.splineThickness = 0.45
        LiveMeasure.endMarker = "arrow"
        local created = LiveMeasure.createBBox boxNode style:"minimal"
        local measureList = LiveMeasure.listMeasures()
        outTxt += "created=" + (created.count as string) + "\n"
        outTxt += "formatX=" + (LiveMeasure.formatValue ext[1]) + "\n"
        outTxt += "formatY=" + (LiveMeasure.formatValue ext[2]) + "\n"
        outTxt += "formatZ=" + (LiveMeasure.formatValue ext[3]) + "\n"
        outTxt += "measures=" + (measureList.count as string)
        outTxt
    )
)
