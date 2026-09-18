(
    -- Replace previous Lonas_Max_Measured tapes only. Keep LM_TestBox and the rest of the scene.
    local doomed = for o in objects where (getUserProp o "LM_type") == "tape" collect o
    if doomed.count > 0 then delete doomed
    local orphans = for o in objects where o.parent == undefined and (matchPattern o.name pattern:"LM_*") and (classof o == SplineShape or classof o == TextPlus) collect o
    if orphans.count > 0 then delete orphans

    local boxNode = getNodeByName "LM_TestBox"
    local outTxt = ""
    if boxNode == undefined then
        "FAIL missing_LM_TestBox"
    else
    (
        local mn = boxNode.min
        local mx = boxNode.max
        LiveMeasure.roundEnabled = false
        LiveMeasure.decimals = 2
        LiveMeasure.unitsType = "cm"
        LiveMeasure.splineThickness = 0.4
        LiveMeasure.textSize = 7.0
        LiveMeasure.textOffset = 3.5
        LiveMeasure.textAlign = "center"
        LiveMeasure.renderable = true

        local tW = LiveMeasure.createTape [mn.x, mn.y, mn.z] [mx.x, mn.y, mn.z] [0, -12, 0] \
            namePrefix:"LM_W" col:(color 30 90 200)
        local tL = LiveMeasure.createTape [mx.x, mn.y, mn.z] [mx.x, mx.y, mn.z] [12, 0, 0] \
            namePrefix:"LM_L" col:(color 20 150 70)
        local tH = LiveMeasure.createTape [mx.x, mx.y, mn.z] [mx.x, mx.y, mx.z] [12, 0, 0] \
            namePrefix:"LM_H" col:(color 200 90 30)
        local tD = LiveMeasure.createTape [mn.x, mn.y, mn.z] [mx.x, mx.y, mx.z] [0, 0, 8] \
            namePrefix:"LM_DIAG" col:(color 160 50 160)

        local near = LiveMeasure.createTape [0,0,0] [49.9,0,0] [0, -8, 0] \
            namePrefix:"LM_ROUND" col:(color 180 40 40)
        setUserProp near "LM_round" 1
        setUserProp near "LM_roundStep" 1.0
        setUserProp near "LM_decimals" 0
        LiveMeasure.rebuildTape near

        LiveMeasure.applyOffset tW [0, -18, 6]
        setUserProp tL "LM_textAlign" "start"
        LiveMeasure.rebuildTape tL
        setUserProp tH "LM_textAlign" "end"
        LiveMeasure.rebuildTape tH

        local measures = LiveMeasure.listMeasures()
        local coneCount = 0
        local boxPrim = 0
        for o in objects where (classof o == Cone) do coneCount += 1
        for o in objects where (classof o == Box and o.name != "LM_TestBox") do boxPrim += 1

        local splineRend = true
        for o in objects where classof o == SplineShape do
            if o.render_renderable != true then splineRend = false
        outTxt += "Wgroup=" + ((isGroupHead tW) as string) + "\n"
        outTxt += "rebuildOk=" + ((isValidNode tW) as string) + "\n"
        outTxt += "count=" + (measures.count as string) + "\n"
        outTxt += "W=" + (getUserProp tW "LM_value") + "\n"
        outTxt += "L=" + (getUserProp tL "LM_value") + "\n"
        outTxt += "H=" + (getUserProp tH "LM_value") + "\n"
        outTxt += "DIAG=" + (getUserProp tD "LM_value") + "\n"
        outTxt += "ROUND=" + (getUserProp near "LM_value") + "\n"
        outTxt += "Woff=" + ((LiveMeasure.readOffset tW) as string) + "\n"
        outTxt += "cones=" + (coneCount as string) + " extraBoxes=" + (boxPrim as string) + "\n"
        outTxt += "splinesRenderable=" + (splineRend as string)
        outTxt
    )
)
