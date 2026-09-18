-- Lonas_Max_Measured — CAD-style 3D dimensions for 3ds Max
-- Two-point distance tapes as renderable splines + TextPlus. No cube/cone markers.

global LiveMeasure
global Lonas_Max_Measured
global LM_nextId

fn LM_intPow n p =
(
    local r = 1
    for i = 1 to p do r *= n
    r
)

fn LM_formatNumber v d =
(
    if d < 0 then d = 0
    if d > 2 then d = 2
    local mag = LM_intPow 10 d
    local scaled = (abs v) * mag + 0.5
    local iv = scaled as integer
    local whole = iv / mag
    local frac = iv - whole * mag
    local signTxt = if v < 0 then "-" else ""
    if d == 0 then
        signTxt + (whole as string)
    else
    (
        local fs = frac as string
        while fs.count < d do fs = "0" + fs
        signTxt + (whole as string) + "." + fs
    )
)

fn LM_lookText pos alongDir faceDir upHint:undefined sideHint:undefined rotDeg:0 =
(
    local z = normalize faceDir
    if length z < 0.0001 then z = [0,0,1]
    local y = [0,0,0]
    if sideHint != undefined and (length sideHint) > 0.0001 then
    (
        y = sideHint - z * (dot sideHint z)
        if length y > 0.0001 then y = normalize y
    )
    if length y < 0.0001 then
    (
        local x0 = alongDir - z * (dot alongDir z)
        if length x0 < 0.0001 then x0 = [1,0,0] else x0 = normalize x0
        y = normalize (cross z x0)
    )
    if length y < 0.0001 then y = [0,1,0]
    if upHint != undefined and sideHint == undefined and (dot y upHint) < 0.0 then y = -y
    local x = normalize (cross y z)
    if length x < 0.0001 then x = [1,0,0]
    y = normalize (cross z x)
    z = normalize (cross x y)
    local tm = matrix3 x y z pos
    local ang = rotDeg
    if ang == undefined then ang = 0.0
    if abs ang > 0.0001 then preRotateX tm ang
    tm
)

fn LM_snapLabelAlong tp align =
(
    if tp == undefined then return undefined
    local tm = tp.transform
    local bb = nodeGetBoundingBox tp tm
    local minL = bb[1]
    local maxL = bb[2]
    local x0 = case align of
    (
        "start": minL.x
        "end": maxL.x
        default: (minL.x + maxL.x) * 0.5
    )
    local xaxis = normalize tm.row1
    local yaxis = normalize tm.row2
    tp.pos = tm.pos - xaxis * x0
    tm = tp.transform
    bb = nodeGetBoundingBox tp tm
    local yGap = 1.8
    tp.pos = tp.pos - yaxis * (bb[1].y - yGap)
    tp
)

fn LM_propF obj key defaultVal =
(
    local s = getUserProp obj key
    if s == undefined then defaultVal
    else s as float
)

fn LM_propI obj key defaultVal =
(
    local s = getUserProp obj key
    if s == undefined then defaultVal
    else s as integer
)

fn LM_propS obj key defaultVal =
(
    local s = getUserProp obj key
    if s == undefined then defaultVal
    else s as string
)

fn LM_distPointRay pt r =
(
    local d = r.dir
    if (length d) < 0.0001 then return (distance pt r.pos)
    d = normalize d
    length (cross (pt - r.pos) d)
)

fn LM_mouseInView =
(
    try
    (
        local mx = mouse.pos.x as float
        local my = mouse.pos.y as float
        local sx = gw.getWinSizeX() as float
        local sy = gw.getWinSizeY() as float
        (mx >= 0.0) and (my >= 0.0) and (mx <= sx) and (my <= sy)
    )
    catch (false)
)

fn LM_snapToCorner p r:20.0 viewRay:undefined maxRayDist:3.0 pixelR:36 =
(
    if p == undefined then return p
    local rayUse = viewRay
    if rayUse == undefined and (LM_mouseInView()) then
    (
        try (rayUse = mapScreenToWorldRay mouse.pos) catch ()
    )
    local usePix = (LM_mouseInView()) and (pixelR > 0.0)
    local mpos = mouse.pos
    local bestPixPt = undefined
    local bestPix = pixelR
    local bestRayPt = undefined
    local bestRay = maxRayDist
    local bestW = p
    local bestWd = r
    for obj in objects where isValidNode obj and (not obj.isHidden) and (not obj.isFrozen) do
    (
        if (getUserProp obj "LM_type") == "tape" then ()
        else if isGroupHead obj then ()
        else
        (
            local pts = #()
            try
            (
                if (classof obj) == Point then append pts obj.pos
                else if (superClassof obj) == GeometryClass then
                (
                    local msh = snapshotAsMesh obj
                    for i = 1 to msh.numverts do append pts (getVert msh i)
                )
                else if (superClassof obj) == Shape then
                (
                    local nsp = numSplines obj
                    for si = 1 to nsp do
                    (
                        local nk = numKnots obj si
                        for k = 1 to nk do append pts (getKnotPoint obj si k)
                    )
                )
            )
            catch ()
            for wp in pts do
            (
                if usePix then
                (
                    try
                    (
                        local sp = gw.wTransPoint wp
                        local pix = distance [sp.x, sp.y, 0] [mpos.x, mpos.y, 0]
                        if pix <= bestPix then
                        (
                            bestPix = pix
                            bestPixPt = wp
                        )
                    )
                    catch ()
                )
                if rayUse != undefined then
                (
                    local t = dot (wp - rayUse.pos) (normalize rayUse.dir)
                    local dr = LM_distPointRay wp rayUse
                    if t > 0.001 and dr <= bestRay then
                    (
                        bestRay = dr
                        bestRayPt = wp
                    )
                )
                local dw = distance wp p
                if dw < bestWd then
                (
                    bestWd = dw
                    bestW = wp
                )
            )
        )
    )
    if bestPixPt != undefined then bestPixPt
    else if bestRayPt != undefined then bestRayPt
    else bestW
)

fn LM_pushMagnetSnap =
(
    local st = #(
        snapMode.active,
        snapMode.type,
        snapMode.snapRadius,
        snapMode.getOSnapItemActive 4 1,
        snapMode.getOSnapItemActive 4 2,
        snapMode.getOSnapItemActive 1 1,
        snapMode.getOSnapItemActive 1 2,
        snapMode.getOSnapItemActive 1 3,
        snapMode.getOSnapItemActive 1 4,
        snapMode.getOSnapItemActive 1 5,
        snapMode.getOSnapItemActive 7 1,
        snapMode.getOSnapItemActive 7 2,
        snapMode.getOSnapItemActive 7 3,
        snapMode.getOSnapItemActive 7 4,
        snapMode.getOSnapItemActive 7 5,
        snapMode.getOSnapItemActive 7 6
    )
    snapMode.active = true
    snapMode.type = #3D
    snapMode.snapRadius = 60
    snapMode.setOSnapItemActive 4 1 false
    snapMode.setOSnapItemActive 4 2 false
    snapMode.setOSnapItemActive 1 1 true
    snapMode.setOSnapItemActive 1 2 true
    snapMode.setOSnapItemActive 1 3 false
    snapMode.setOSnapItemActive 1 4 true
    snapMode.setOSnapItemActive 1 5 false
    snapMode.setOSnapItemActive 7 1 true
    snapMode.setOSnapItemActive 7 2 true
    snapMode.setOSnapItemActive 7 3 false
    snapMode.setOSnapItemActive 7 4 true
    snapMode.setOSnapItemActive 7 5 false
    snapMode.setOSnapItemActive 7 6 false
    st
)

fn LM_popMagnetSnap st =
(
    if st == undefined then return false
    snapMode.active = st[1]
    snapMode.type = st[2]
    snapMode.snapRadius = st[3]
    snapMode.setOSnapItemActive 4 1 st[4]
    snapMode.setOSnapItemActive 4 2 st[5]
    snapMode.setOSnapItemActive 1 1 st[6]
    snapMode.setOSnapItemActive 1 2 st[7]
    snapMode.setOSnapItemActive 1 3 st[8]
    snapMode.setOSnapItemActive 1 4 st[9]
    snapMode.setOSnapItemActive 1 5 st[10]
    snapMode.setOSnapItemActive 7 1 st[11]
    snapMode.setOSnapItemActive 7 2 st[12]
    snapMode.setOSnapItemActive 7 3 st[13]
    snapMode.setOSnapItemActive 7 4 st[14]
    snapMode.setOSnapItemActive 7 5 st[15]
    snapMode.setOSnapItemActive 7 6 st[16]
    true
)

struct LiveMeasureDef
(
    unitsType = "cm",
    decimals = 2,
    lineColor = (color 32 96 176),
    splineThickness = 0.12,
    textSize = 8.0,
    textThickness = 0.15,
    textOffset = 2.5,
    textAlign = "center",
    lineGap = 8.0,
    tickSize = 1.2,
    arrowSize = 2.4,
    arrowWidth = 0.35,
    pickArrowSize = 0.0,
    lineStyle = "arrow",
    textRot = 0.0,
    textOrient = "horizontal",
    textMirror = false,
    rulerStep = 10.0,
    renderable = true,
    roundEnabled = false,
    roundStep = 1.0,

    fn rotFromOrient orient mirrorOn =
    (
        local a = 0.0
        if orient == "vertical" then a = 90.0
        if mirrorOn == true then a += 180.0
        a
    ),

    fn toDisplay v =
    (
        case unitsType of
        (
            "mm": v * 10.0
            "cm": v
            "m": v / 100.0
            "ft": v / 30.48
            "in": v / 2.54
            default: v
        )
    ),

    fn unitSuffix =
    (
        case unitsType of
        (
            "mm": "mm"
            "cm": "cm"
            "m": "m"
            "ft": "ft"
            "in": "in"
            default: "cm"
        )
    ),

    fn roundValue v =
    (
        if roundEnabled != true then return v
        local step = roundStep
        if step == undefined or step <= 0.0 then step = 1.0
        local q = v / step
        (floor (q + 0.5)) * step
    ),

    fn formatValue v =
    (
        local dv = this.roundValue (this.toDisplay v)
        local d = decimals
        if roundEnabled == true and roundStep >= 1.0 then d = 0
        (LM_formatNumber dv d) + " " + this.unitSuffix()
    ),

    fn distanceBetween a b = (distance a b),

    fn rulerMarkCount len step =
    (
        if step == undefined or step <= 0.0 then step = 10.0
        if len < 0.0 then len = 0.0
        ((floor ((len / step) + 0.001)) as integer) + 1
    ),

    fn facingFor planeName =
    (
        case planeName of
        (
            "top": [0,0,1]
            "bottom": [0,0,-1]
            "front": [0,-1,0]
            "back": [0,1,0]
            "left": [-1,0,0]
            "right": [1,0,0]
            default:
            (
                try (normalize ((inverse (viewport.getTM())).row3)) catch ([0,0,1])
            )
        )
    ),

    fn upFor planeName =
    (
        case planeName of
        (
            "top": [0,1,0]
            "bottom": [0,-1,0]
            "front": [0,0,1]
            "back": [0,0,1]
            "left": [0,0,1]
            "right": [0,0,1]
            default:
            (
                try (normalize ((inverse (viewport.getTM())).row2)) catch ([0,1,0])
            )
        )
    ),

    fn viewNameFromViewport =
    (
        try
        (
            case (viewport.getType()) of
            (
                #view_top: "top"
                #view_bottom: "bottom"
                #view_front: "front"
                #view_back: "back"
                #view_left: "left"
                #view_right: "right"
                default: "persp"
            )
        )
        catch ("persp")
    ),

    fn resolveView planeName:undefined =
    (
        local n = planeName
        if n == undefined then n = "auto"
        if n == undefined or n == "auto" then n = this.viewNameFromViewport()
        #(this.facingFor n, this.upFor n, n)
    ),

    fn readFacing grp =
    (
        local v = [LM_propF grp "LM_fx" 0, LM_propF grp "LM_fy" 0, LM_propF grp "LM_fz" 1]
        if length v < 0.0001 then [0,0,1] else normalize v
    ),

    fn readUp grp =
    (
        local v = [LM_propF grp "LM_ux" 0, LM_propF grp "LM_uy" 1, LM_propF grp "LM_uz" 0]
        if length v < 0.0001 then [0,1,0] else normalize v
    ),

    fn defaultOffsetVec p1 p2 viewN:undefined =
    (
        local along = normalize (p2 - p1)
        local nrmZ = viewN
        if nrmZ == undefined then nrmZ = [0,0,1]
        if length nrmZ < 0.0001 then nrmZ = [0,0,1] else nrmZ = normalize nrmZ
        local alongP = along - nrmZ * (dot along nrmZ)
        if length alongP > 0.0001 then alongP = normalize alongP
        local nrm = normalize (cross alongP nrmZ)
        if length nrm < 0.0001 then nrm = [0,1,0]
        nrm * lineGap
    ),

    fn arrowBarbs tip towardBack size width sideHint:undefined =
    (
        local d = towardBack - tip
        if length d < 0.0001 then d = [0,-1,0] else d = normalize d
        local side = [0,0,0]
        if sideHint != undefined then
        (
            local h = normalize sideHint
            side = h - d * (dot h d)
            if length side > 0.0001 then side = normalize side
        )
        if length side < 0.0001 then side = normalize (cross d [0,0,1])
        if length side < 0.0001 then side = normalize (cross d [0,1,0])
        if size < 0.01 then size = 0.01
        local wMul = width
        if wMul == undefined or wMul < 0.05 then wMul = 0.35
        local back = tip + d * size
        local w = size * wMul
        #(back + side * w, tip, back - side * w)
    ),

    fn arrowStroke tip towardBack size sideHint:undefined =
    (
        this.arrowBarbs tip towardBack size arrowWidth sideHint:sideHint
    ),

    fn textWorldPos p1 p2 offsetV align textLift =
    (
        local p1o = p1 + offsetV
        local p2o = p2 + offsetV
        local t = 0.5
        case align of
        (
            "start": t = 0.0
            "end": t = 1.0
            default: t = 0.5
        )
        local along = p2o - p1o
        local liftDir = offsetV
        if length liftDir < 0.0001 then liftDir = [0,0,1] else liftDir = normalize liftDir
        p1o + along * t + liftDir * textLift
    ),

    fn bboxExtents node =
    (
        local mn = node.min
        local mx = node.max
        #(mx.x - mn.x, mx.y - mn.y, mx.z - mn.z, mn, mx)
    ),

    fn makeMat col nm =
    (
        local m = StandardMaterial name:nm
        m.diffuse = col
        m.ambient = col
        m.selfIllumAmount = 100
        m.specularLevel = 0
        m.twoSided = true
        m
    ),

    fn ensureRootLayer =
    (
        local lyr = LayerManager.getLayerFromName "Measures"
        if lyr == undefined then lyr = LayerManager.newLayerFromName "Measures"
        lyr
    ),

    fn addToLayer obj =
    (
        local lyr = this.ensureRootLayer()
        lyr.addNode obj
        lyr
    ),

    fn applySpline ss col mat th =
    (
        ss.wirecolor = col
        ss.material = mat
        ss.steps = 0
        ss.optimize = false
        ss.render_renderable = renderable
        ss.render_displayRenderMesh = true
        ss.render_rectangular = false
        ss.render_aspect_locked = false
        try (ss.render_thickness = th) catch ()
        try (ss.render_sides = 8) catch ()
        try (ss.thickness = th) catch ()
        try (ss.sides = 8) catch ()
        try (ss.renderable = renderable) catch ()
        ss
    ),

    fn fillCadSpline ss strokes =
    (
        resetShape ss
        for stroke in strokes do
        (
            addNewSpline ss
            local si = numSplines ss
            for p in stroke do addKnot ss si #corner #line p
            if stroke.count >= 3 and (distance stroke[1] stroke[stroke.count]) < 0.001 then close ss si
        )
        updateShape ss
        ss
    ),

    fn makeCadSpline strokes nm col mat th =
    (
        local ss = splineShape name:nm
        this.fillCadSpline ss strokes
        this.applySpline ss col mat th
        ss
    ),

    fn makeLabel txt pos alongDir faceDir nm col mat tSize tThk tAlign upHint:undefined sideHint:undefined rotDeg:0 =
    (
        local tp = TextPlus name:nm
        tp.generateGeometry = true
        try (tp.extrude = true) catch ()
        tp.size = tSize
        tp.extrudeamount = tThk
        tp.tracking = 0
        tp.leading = 0
        tp.alignment = case tAlign of
        (
            "start": 1
            "end": 3
            default: 2
        )
        tp.ResetString()
        tp.AppendString txt
        tp.size = tSize
        tp.extrudeamount = tThk
        try (tp.generateGeometry = true) catch ()
        tp.transform = LM_lookText pos alongDir faceDir upHint:upHint sideHint:sideHint rotDeg:rotDeg
        LM_snapLabelAlong tp tAlign
        tp.wirecolor = col
        tp.material = mat
        try (tp.renderable = renderable) catch ()
        tp
    ),

    fn nextTag prefix =
    (
        if LM_nextId == undefined then LM_nextId = 0
        local tag = ""
        do
        (
            LM_nextId += 1
            tag = prefix + "_" + (formattedPrint LM_nextId format:"03d")
        ) while (getNodeByName tag != undefined)
        tag
    ),

    fn storeTape grp p1 p2 offsetV col th tSize tAlign tLift extraNote style:"arrow" textRot:0 textOrient:"horizontal" textMirror:false =
    (
        setUserProp grp "LM_type" "tape"
        setUserProp grp "LM_p1x" p1.x
        setUserProp grp "LM_p1y" p1.y
        setUserProp grp "LM_p1z" p1.z
        setUserProp grp "LM_p2x" p2.x
        setUserProp grp "LM_p2y" p2.y
        setUserProp grp "LM_p2z" p2.z
        setUserProp grp "LM_ox" offsetV.x
        setUserProp grp "LM_oy" offsetV.y
        setUserProp grp "LM_oz" offsetV.z
        setUserProp grp "LM_cr" col.r
        setUserProp grp "LM_cg" col.g
        setUserProp grp "LM_cb" col.b
        setUserProp grp "LM_th" th
        setUserProp grp "LM_textSize" tSize
        setUserProp grp "LM_textThk" textThickness
        setUserProp grp "LM_textAlign" tAlign
        setUserProp grp "LM_textLift" tLift
        setUserProp grp "LM_note" extraNote
        setUserProp grp "LM_style" style
        setUserProp grp "LM_arrowSize" arrowSize
        setUserProp grp "LM_arrowWidth" arrowWidth
        setUserProp grp "LM_pickArrow" pickArrowSize
        setUserProp grp "LM_rulerStep" rulerStep
        setUserProp grp "LM_round" (if roundEnabled then 1 else 0)
        setUserProp grp "LM_roundStep" roundStep
        setUserProp grp "LM_decimals" decimals
        setUserProp grp "LM_units" unitsType
        setUserProp grp "LM_textRot" textRot
        setUserProp grp "LM_textOrient" textOrient
        setUserProp grp "LM_textMirror" (if textMirror == true then 1 else 0)
        local len = distance p1 p2
        setUserProp grp "LM_raw" len
        setUserProp grp "LM_value" (this.formatValue len)
    ),

    fn readP1 grp = [LM_propF grp "LM_p1x" 0, LM_propF grp "LM_p1y" 0, LM_propF grp "LM_p1z" 0],
    fn readP2 grp = [LM_propF grp "LM_p2x" 100, LM_propF grp "LM_p2y" 0, LM_propF grp "LM_p2z" 0],
    fn readOffset grp = [LM_propF grp "LM_ox" 0, LM_propF grp "LM_oy" -10, LM_propF grp "LM_oz" 0],
    fn readColor grp = (color (LM_propF grp "LM_cr" 32) (LM_propF grp "LM_cg" 96) (LM_propF grp "LM_cb" 176)),

    fn findTape selNode =
    (
        if selNode == undefined then return undefined
        local n = selNode
        local hops = 0
        while n != undefined and hops < 8 do
        (
            if (getUserProp n "LM_type") == "tape" then return n
            if n.parent == undefined then exit
            n = n.parent
            hops += 1
        )
        undefined
    ),

    fn tapeFromSelection =
    (
        if selection.count == 0 then return undefined
        for s in selection do
        (
            local t = this.findTape s
            if t != undefined then return t
        )
        undefined
    ),

    fn findLineChild grp =
    (
        for c in grp.children where classof c == SplineShape do return c
        undefined
    ),

    fn findTextChild grp =
    (
        for c in grp.children where classof c == TextPlus do return c
        undefined
    ),

    fn tapeStrokes p1 p2 offsetUse along style:"arrow" =
    (
        local p1o = p1 + offsetUse
        local p2o = p2 + offsetUse
        local tick = normalize offsetUse
        local overshoot = tickSize * 0.25
        local e1b = p1o + tick * overshoot
        local e2b = p2o + tick * overshoot
        local strokes = #(#(p1, e1b), #(p2, e2b), #(p1o, p2o))
        case style of
        (
            "line":
            (
                local tickLen = tickSize
                append strokes #(p1o - along * tickLen, p1o + along * tickLen)
                append strokes #(p2o - along * tickLen, p2o + along * tickLen)
            )
            "ruler":
            (
                local step = rulerStep
                if step <= 0.0 then step = 10.0
                local len = distance p1o p2o
                local n = (floor ((len / step) + 0.001)) as integer
                local shortH = tickSize * 0.4
                local longH = tickSize * 0.9
                for i = 0 to n do
                (
                    local t = i * step
                    if t > len then t = len
                    local pt = p1o + along * t
                    local h = shortH
                    if i == 0 or i == n or (mod i 5) == 0 then h = longH
                    append strokes #(pt - tick * (h * 0.2), pt + tick * h)
                )
                if abs ((n as float) * step - len) > 0.05 then
                    append strokes #(p2o - tick * (longH * 0.2), p2o + tick * longH)
            )
            default:
            (
                local dimSz = arrowSize
                local maxSz = (distance p1o p2o) * 0.18
                if maxSz > 0.2 and dimSz > maxSz then dimSz = maxSz
                local dimW = arrowWidth
                append strokes (this.arrowBarbs p1o p2o dimSz dimW sideHint:tick)
                append strokes (this.arrowBarbs p2o p1o dimSz dimW sideHint:tick)
                if pickArrowSize > 0.01 then
                (
                    append strokes (this.arrowBarbs p1 p1o pickArrowSize dimW sideHint:along)
                    append strokes (this.arrowBarbs p2 p2o pickArrowSize dimW sideHint:along)
                )
            )
        )
        strokes
    ),

    fn buildTapeNodes p1 p2 offsetV tag col mat th tSize tAlign tLift extraNote style:"arrow" rotDeg:0 =
    (
        local len = distance p1 p2
        if len < 0.0001 then return #()
        local along = normalize (p2 - p1)
        local offsetUse = offsetV
        if length offsetUse < 0.0001 then offsetUse = this.defaultOffsetVec p1 p2
        local tick = normalize offsetUse
        local strokes = this.tapeStrokes p1 p2 offsetUse along style:style
        local nodes = #()
        append nodes (this.makeCadSpline strokes (tag + "_line") col mat th)
        local labelPos = this.textWorldPos p1 p2 offsetUse tAlign tLift
        local labelTxt = this.formatValue len
        if extraNote != "" then labelTxt = labelTxt + "\n" + extraNote
        append nodes (this.makeLabel labelTxt labelPos along tick (tag + "_txt") col mat tSize textThickness tAlign sideHint:offsetUse rotDeg:rotDeg)
        nodes
    ),

    fn createTape p1 p2 offsetVec namePrefix:"LM_Tape" extraNote:"" col:undefined thickness:undefined tSize:undefined tAlign:undefined tLift:undefined style:undefined textRot:undefined textOrient:undefined textMirror:undefined =
    (
        local useCol = if col == undefined then lineColor else col
        local useTh = if thickness == undefined then splineThickness else thickness
        local useSize = if tSize == undefined then textSize else tSize
        local useAlign = if tAlign == undefined then textAlign else tAlign
        local useLift = if tLift == undefined then textOffset else tLift
        local useStyle = if style == undefined then lineStyle else style
        local useOrient = if textOrient == undefined then this.textOrient else textOrient
        local useMir = if textMirror == undefined then this.textMirror else textMirror
        local useRot = if textRot == undefined then (this.rotFromOrient useOrient useMir) else textRot
        local tag = this.nextTag namePrefix
        local mat = this.makeMat useCol (tag + "_mat")
        local nodes = this.buildTapeNodes p1 p2 offsetVec tag useCol mat useTh useSize useAlign useLift extraNote style:useStyle rotDeg:useRot
        if nodes.count == 0 then return undefined
        for n in nodes do this.addToLayer n
        local grp = group nodes name:tag
        try (setGroupOpen grp false) catch ()
        try (grp.box = false) catch ()
        try (grp.cross = false) catch ()
        try (grp.axistripod = false) catch ()
        try (grp.centermarker = false) catch ()
        try (grp.renderable = false) catch ()
        this.storeTape grp p1 p2 offsetVec useCol useTh useSize useAlign useLift extraNote style:useStyle textRot:useRot textOrient:useOrient textMirror:useMir
        this.addToLayer grp
        grp
    ),

    fn rebuildTape grp =
    (
        if grp == undefined then return undefined
        local p1 = this.readP1 grp
        local p2 = this.readP2 grp
        local offsetV = this.readOffset grp
        local col = this.readColor grp
        local th = LM_propF grp "LM_th" splineThickness
        local tSize = LM_propF grp "LM_textSize" textSize
        local tThk = LM_propF grp "LM_textThk" textThickness
        local tAlign = LM_propS grp "LM_textAlign" textAlign
        local tLift = LM_propF grp "LM_textLift" textOffset
        local extraNote = LM_propS grp "LM_note" ""
        local style = LM_propS grp "LM_style" "arrow"
        local wasClosed = false
        try (wasClosed = (isGroupHead grp) and (not (isOpenGroupHead grp))) catch ()
        if wasClosed then try (setGroupOpen grp true) catch ()
        local savedRound = roundEnabled
        local savedStep = roundStep
        local savedDec = decimals
        local savedUnits = unitsType
        local savedArr = arrowSize
        local savedArrW = arrowWidth
        local savedPick = pickArrowSize
        roundEnabled = ((LM_propI grp "LM_round" 0) == 1)
        roundStep = LM_propF grp "LM_roundStep" 1.0
        decimals = LM_propI grp "LM_decimals" 2
        unitsType = LM_propS grp "LM_units" "cm"
        arrowSize = LM_propF grp "LM_arrowSize" arrowSize
        arrowWidth = LM_propF grp "LM_arrowWidth" arrowWidth
        pickArrowSize = LM_propF grp "LM_pickArrow" pickArrowSize
        local ori = LM_propS grp "LM_textOrient" ""
        local mir = ((LM_propI grp "LM_textMirror" 0) == 1)
        local tRot = if ori == "vertical" or ori == "horizontal" then this.rotFromOrient ori mir else LM_propF grp "LM_textRot" 0
        local along = normalize (p2 - p1)
        local offsetUse = offsetV
        if length offsetUse < 0.0001 then offsetUse = this.defaultOffsetVec p1 p2
        local tick = normalize offsetUse
        local strokes = this.tapeStrokes p1 p2 offsetUse along style:style
        local tag = grp.name
        local ss = this.findLineChild grp
        local tp = this.findTextChild grp
        local mat = if ss != undefined then ss.material else undefined
        if mat == undefined and tp != undefined then mat = tp.material
        if mat == undefined then mat = this.makeMat col (tag + "_mat")
        else
        (
            try (mat.diffuse = col) catch ()
            try (mat.ambient = col) catch ()
        )
        if ss == undefined then
        (
            ss = this.makeCadSpline strokes (tag + "_line") col mat th
            ss.parent = grp
            this.addToLayer ss
        )
        else
        (
            this.fillCadSpline ss strokes
            this.applySpline ss col mat th
        )
        local labelPos = this.textWorldPos p1 p2 offsetUse tAlign tLift
        local labelTxt = this.formatValue (distance p1 p2)
        if extraNote != "" then labelTxt = labelTxt + "\n" + extraNote
        local txtName = tag + "_txt"
        if tp != undefined then
        (
            txtName = tp.name
            delete tp
            tp = undefined
        )
        tp = this.makeLabel labelTxt labelPos along tick txtName col mat tSize tThk tAlign sideHint:offsetUse rotDeg:tRot
        tp.parent = grp
        this.addToLayer tp
        setUserProp grp "LM_value" (this.formatValue (distance p1 p2))
        setUserProp grp "LM_raw" (distance p1 p2)
        roundEnabled = savedRound
        roundStep = savedStep
        decimals = savedDec
        unitsType = savedUnits
        arrowSize = savedArr
        arrowWidth = savedArrW
        pickArrowSize = savedPick
        if wasClosed then try (setGroupOpen grp false) catch ()
        grp
    ),

    fn deleteTape grp =
    (
        if grp == undefined then return false
        local n = this.findTape grp
        if n == undefined then n = grp
        delete n
        true
    ),

    fn applyOffset grp offsetV =
    (
        if grp == undefined then return undefined
        setUserProp grp "LM_ox" offsetV.x
        setUserProp grp "LM_oy" offsetV.y
        setUserProp grp "LM_oz" offsetV.z
        this.rebuildTape grp
    ),

    fn applyAppearance grp col th tSize tAlign tLift roundOn roundSt tThk:undefined =
    (
        if grp == undefined then return undefined
        setUserProp grp "LM_cr" col.r
        setUserProp grp "LM_cg" col.g
        setUserProp grp "LM_cb" col.b
        setUserProp grp "LM_th" th
        setUserProp grp "LM_textSize" tSize
        setUserProp grp "LM_textAlign" tAlign
        setUserProp grp "LM_textLift" tLift
        setUserProp grp "LM_round" (if roundOn then 1 else 0)
        setUserProp grp "LM_roundStep" roundSt
        if tThk != undefined then setUserProp grp "LM_textThk" tThk
        this.rebuildTape grp
    ),

    fn createBBox node style:"minimal" =
    (
        if node == undefined then return undefined
        local ext = this.bboxExtents node
        local sx = ext[1]
        local sy = ext[2]
        local sz = ext[3]
        local mn = ext[4]
        local mx = ext[5]
        local gap = lineGap
        local tag = "LM_" + node.name
        local created = #()
        append created (this.createTape [mn.x, mn.y, mn.z] [mx.x, mn.y, mn.z] [0, -gap, 0] namePrefix:(tag + "_X"))
        append created (this.createTape [mx.x, mn.y, mn.z] [mx.x, mx.y, mn.z] [gap, 0, 0] namePrefix:(tag + "_Y"))
        append created (this.createTape [mx.x, mx.y, mn.z] [mx.x, mx.y, mx.z] [gap, 0, 0] namePrefix:(tag + "_Z"))
        created
    ),

    fn listMeasures =
    (
        for o in objects where isValidNode o and (getUserProp o "LM_type") == "tape" collect o
    ),

    fn csvText =
    (
        local rows = "Label,Value\n"
        for o in this.listMeasures() do
        (
            local lab = o.name
            local val = getUserProp o "LM_value"
            if val == undefined then val = ""
            rows += lab + "," + val + "\n"
        )
        rows
    )
)

LiveMeasure = LiveMeasureDef()
Lonas_Max_Measured = LiveMeasure
true
