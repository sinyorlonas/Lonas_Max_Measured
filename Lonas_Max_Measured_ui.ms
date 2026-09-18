-- Lonas_Max_Measured UI — one settings panel: selected tape if any, otherwise next new measure.

global LM_Floater
global LM_tapeMode = "distance"
global LM_updatingUI = false
global LM_lang = "en"
global LM_VERSION = "0.7"

fn LM_langFile =
(
    (getDir #userScripts) + "\\Lonas_Max_Measured\\language.txt"
)

fn LM_loadLang =
(
    local f = LM_langFile()
    if doesFileExist f then
    (
        local s = openFile f
        if s != undefined then
        (
            local v = trimRight (readLine s)
            close s
            if v == "tr" then LM_lang = "tr" else LM_lang = "en"
        )
    )
    LM_lang
)

fn LM_saveLang =
(
    local dir = (getDir #userScripts) + "\\Lonas_Max_Measured\\"
    makeDir dir
    local s = createFile (dir + "language.txt")
    if s != undefined then
    (
        format "%" LM_lang to:s
        close s
    )
)

fn LM_t key =
(
    if LM_lang == "tr" then
    (
        case key of
        (
            #floater: "Lonas_Max_Measured"
            #rollMain: "Ölçü"
            #rollSettings: "Ayarlar"
            #rollCSV: "Tüm ölçüler"
            #rollAbout: "Yardım / Hakkında"
            #help: "2 nokta + köşe magnet. Yazı: Yatay / Dikey + Ayna."
            #btnTape: "2 Nokta Mesafe"
            #btnBBox: "Sınır Kutusu (3 eksen)"
            #tapeMode: "Seçimden sonra:"
            #tapeDistance: "Mesafe (gerçek 3D)"
            #tapeDimension: "Ölçü (eksen hizalı)"
            #pick1: "Vertex snap: 1. köşe"
            #pick2: "Vertex snap: 2. köşe"
            #pickObj: "Lonas_Max_Measured: nesne seç"
            #selNew: "Yeni ölçü"
            #lineX: "Çizgi X:"
            #lineY: "Y:"
            #lineZ: "Z:"
            #th: "Çizgi kalınlığı:"
            #ts: "Yazı boyu:"
            #txtThk: "Yazı kalınlığı:"
            #lift: "Yazı-çizgi aralığı:"
            #align: "Yazı yeri:"
            #alignC: "Orta"
            #alignS: "Baş (yan)"
            #alignE: "Son (yan)"
            #orient: "Yazı yönü:"
            #orientH: "Yatay"
            #orientV: "Dikey"
            #mirror: "Yazıyı ayna çevir"
            #style: "Çizgi stili:"
            #styleA: "Ok"
            #styleL: "Çizgi"
            #styleR: "Cetvel (10 cm)"
            #arrSz: "Ok boyu:"
            #arrW: "Ok genişliği:"
            #pickArr: "Nokta oku:"
            #color: "Renk:"
            #units: "Birim:"
            #dec: "Ondalık:"
            #round: "Yuvarla (49.9 -> 50)"
            #step: "Yuvarlama adımı:"
            #render: "Renderda görünsün"
            #apply: "Uygula"
            #delTape: "Ölçüyü sil"
            #refresh: "Yenile"
            #delSel: "Seçileni sil"
            #export: "CSV aktar"
            #csvCap: "Ölçüleri aktar"
            #colLabel: "Ad"
            #colValue: "Değer"
            #lang: "Dil:"
            #aboutTitle: ("Lonas_Max_Measured " + LM_VERSION)
            #aboutBody: ("Lonas_Max_Measured — 3ds Max 2025 CAD 2 nokta ölçü eklentisi.\r\n\r\n• Köşe magnet snap — köşenin yakınına tıkla, vertex'e kilitlenir\r\n• Yazı: Yatay / Dikey + Ayna (ters okumak için)\r\n• Çizgi XYZ ofset, kalınlık, renk — bakış düzlemi çizgiyi kaydırmaz\r\n• Ok / Çizgi / Cetvel stilleri, ok boyu ve genişliği\r\n• Birimler, yuvarlama, renderable spline + TextPlus\r\n• Sınırsız ölçü, CSV dışa aktarma\r\n• Grubu silince çizgi ve yazı birlikte gider\r\n\r\nKurulum: Scripting > Run Script > Install.ms")
            default: (key as string)
        )
    )
    else
    (
        case key of
        (
            #floater: "Lonas_Max_Measured"
            #rollMain: "Measure"
            #rollSettings: "Settings"
            #rollCSV: "All measures"
            #rollAbout: "Help / About"
            #help: "2 point + vertex magnet. Text: Horizontal / Vertical + Mirror."
            #btnTape: "2-Point Distance"
            #btnBBox: "Bounding Box (3 axes)"
            #tapeMode: "After pick:"
            #tapeDistance: "Distance (true 3D)"
            #tapeDimension: "Dimension (axis aligned)"
            #pick1: "Vertex snap: 1st corner"
            #pick2: "Vertex snap: 2nd corner"
            #pickObj: "Lonas_Max_Measured: pick object"
            #selNew: "New measure"
            #lineX: "Line X:"
            #lineY: "Y:"
            #lineZ: "Z:"
            #th: "Line thickness:"
            #ts: "Text size:"
            #txtThk: "Text extrude:"
            #lift: "Text from line:"
            #align: "Text place:"
            #alignC: "Center"
            #alignS: "Start (side)"
            #alignE: "End (side)"
            #orient: "Text dir:"
            #orientH: "Horizontal"
            #orientV: "Vertical"
            #mirror: "Mirror text"
            #style: "Line style:"
            #styleA: "Arrow"
            #styleL: "Line"
            #styleR: "Ruler (10 cm)"
            #arrSz: "Arrow size:"
            #arrW: "Arrow width:"
            #pickArr: "Point arrow:"
            #color: "Color:"
            #units: "Units:"
            #dec: "Decimals:"
            #round: "Round value (49.9 -> 50)"
            #step: "Round step:"
            #render: "Renderable in render"
            #apply: "Apply"
            #delTape: "Delete tape"
            #refresh: "Refresh"
            #delSel: "Delete selected"
            #export: "Export CSV"
            #csvCap: "Export measurements"
            #colLabel: "Label"
            #colValue: "Value"
            #lang: "Language:"
            #aboutTitle: ("Lonas_Max_Measured " + LM_VERSION)
            #aboutBody: ("Lonas_Max_Measured — CAD 2-point measuring plugin for 3ds Max 2025.\r\n\r\n• Vertex magnet snap — click near a corner to lock to the point\r\n• Text: Horizontal / Vertical + Mirror (when it must read flipped)\r\n• Line XYZ offset, thickness, color — view plane does not move the line\r\n• Arrow / Line / Ruler styles, arrow size and width\r\n• Units, rounding, renderable splines + TextPlus\r\n• Unlimited measures, CSV export\r\n• Delete the group to remove spline and text together\r\n\r\nInstall: Scripting > Run Script > Install.ms")
            default: (key as string)
        )
    )
)

fn LM_styleFromIndex i =
(
    case i of
    (
        2: "line"
        3: "ruler"
        default: "arrow"
    )
)

fn LM_indexFromStyle s =
(
    case s of
    (
        "line": 2
        "ruler": 3
        default: 1
    )
)

fn LM_alignFromIndex i =
(
    case i of
    (
        2: "start"
        3: "end"
        default: "center"
    )
)

fn LM_indexFromAlign s =
(
    case s of
    (
        "start": 2
        "end": 3
        default: 1
    )
)

fn LM_orientFromIndex i =
(
    if i == 2 then "vertical" else "horizontal"
)

fn LM_indexFromOrient s =
(
    if s == "vertical" then 2 else 1
)

rollout LM_rollMain "Measure"
(
    label lblHelp "2 point + vertex magnet. Text: Horizontal / Vertical + Mirror." align:#left
    button btnTape "2-Point Distance" width:260 height:32
    button btnBBox "Bounding Box (3 axes)" width:260 height:24
    dropdownlist ddlTapeMode "After pick:" items:#("Distance (true 3D)", "Dimension (axis aligned)") selection:1 width:260

    on ddlTapeMode selected i do
        LM_tapeMode = if i == 2 then "dimension" else "distance"

    fn pickTape =
    (
        local st = LM_pushMagnetSnap()
        local p1 = pickPoint prompt:(LM_t #pick1) snap:#3D
        if p1 == undefined or p1 == #escape then
        (
            LM_popMagnetSnap st
            return false
        )
        p1 = LM_snapToCorner p1
        local p2 = pickPoint prompt:(LM_t #pick2) snap:#3D rubberBand:p1
        LM_popMagnetSnap st
        if p2 == undefined or p2 == #escape then return false
        p2 = LM_snapToCorner p2
        if LM_tapeMode == "dimension" then
        (
            local d = p2 - p1
            local ax = abs d.x
            local ay = abs d.y
            local az = abs d.z
            if ax >= ay and ax >= az then p2 = [p2.x, p1.y, p1.z]
            else if ay >= ax and ay >= az then p2 = [p1.x, p2.y, p1.z]
            else p2 = [p1.x, p1.y, p2.z]
        )
        local defaultOff = LiveMeasure.defaultOffsetVec p1 p2
        local grp = LiveMeasure.createTape p1 p2 defaultOff
        if grp != undefined then select grp
        completeRedraw()
        try (LM_rollSettings.loadFromSel()) catch ()
        true
    )

    on btnTape pressed do pickTape()
    on btnBBox pressed do
    (
        local obj = undefined
        if selection.count == 1 then obj = selection[1]
        else obj = pickObject prompt:(LM_t #pickObj)
        if obj != undefined then
        (
            LiveMeasure.createBBox obj
            completeRedraw()
            try (LM_rollSettings.loadFromSel()) catch ()
        )
    )
)

rollout LM_rollSettings "Settings"
(
    label lblSel "New measure" align:#left
    spinner spnOX "Line X:" range:[-100000, 100000, 0] type:#worldunits scale:0.1 fieldWidth:55 across:3
    spinner spnOY "Y:" range:[-100000, 100000, 0] type:#worldunits scale:0.1 fieldWidth:55
    spinner spnOZ "Z:" range:[-100000, 100000, 0] type:#worldunits scale:0.1 fieldWidth:55
    spinner spnTh "Line thickness:" range:[0.02, 50, 0.12] type:#worldunits scale:0.02 fieldWidth:50
    spinner spnTs "Text size:" range:[0.1, 500, 8] type:#worldunits scale:0.1 fieldWidth:50
    spinner spnTxtThk "Text extrude:" range:[0.0, 50, 0.15] type:#worldunits scale:0.02 fieldWidth:50
    spinner spnLift "Text from line:" range:[-200, 200, 2.5] type:#worldunits scale:0.1 fieldWidth:50
    dropdownlist ddlAlign "Text place:" items:#("Center", "Start (side)", "End (side)") selection:1 width:160
    dropdownlist ddlOrient "Text dir:" items:#("Horizontal", "Vertical") selection:1 width:160
    checkbox chkMirror "Mirror text" checked:false
    dropdownlist ddlStyle "Line style:" items:#("Arrow", "Line", "Ruler (10 cm)") selection:1 width:160
    spinner spnArrSz "Arrow size:" range:[0.1, 80, 2.4] type:#worldunits scale:0.05 fieldWidth:50
    spinner spnArrW "Arrow width:" range:[0.1, 1.5, 0.35] type:#float scale:0.02 fieldWidth:50
    spinner spnPickArr "Point arrow:" range:[0.0, 80, 0] type:#worldunits scale:0.05 fieldWidth:50
    colorpicker cpCol "Color:" color:(color 32 96 176) modal:false
    dropdownlist ddlUnits "Units:" items:#("mm", "cm", "m", "ft", "in") selection:2 width:160
    spinner spnDec "Decimals:" range:[0, 2, 2] type:#integer fieldWidth:50
    checkbox chkRound "Round value (49.9 -> 50)" checked:false
    spinner spnStep "Round step:" range:[0.01, 100, 1] type:#float scale:0.1 fieldWidth:50
    checkbox chkRender "Renderable in render" checked:true
    button btnApply "Apply" width:128 height:26 across:2
    button btnDelTape "Delete tape" width:128 height:26

    fn currentTape = (LiveMeasure.tapeFromSelection())

    fn pushDefaults =
    (
        LiveMeasure.splineThickness = spnTh.value
        LiveMeasure.textSize = spnTs.value
        LiveMeasure.textThickness = spnTxtThk.value
        LiveMeasure.textOffset = spnLift.value
        LiveMeasure.textAlign = LM_alignFromIndex ddlAlign.selection
        LiveMeasure.lineStyle = LM_styleFromIndex ddlStyle.selection
        LiveMeasure.textOrient = LM_orientFromIndex ddlOrient.selection
        LiveMeasure.textMirror = chkMirror.checked
        LiveMeasure.textRot = LiveMeasure.rotFromOrient LiveMeasure.textOrient LiveMeasure.textMirror
        LiveMeasure.arrowSize = spnArrSz.value
        LiveMeasure.arrowWidth = spnArrW.value
        LiveMeasure.pickArrowSize = spnPickArr.value
        LiveMeasure.lineColor = cpCol.color
        LiveMeasure.unitsType = ddlUnits.selected
        LiveMeasure.decimals = spnDec.value as integer
        LiveMeasure.roundEnabled = chkRound.checked
        LiveMeasure.roundStep = spnStep.value
        LiveMeasure.renderable = chkRender.checked
    )

    fn loadDefaults =
    (
        spnOX.value = 0
        spnOY.value = 0
        spnOZ.value = 0
        spnTh.value = LiveMeasure.splineThickness
        spnTs.value = LiveMeasure.textSize
        spnTxtThk.value = LiveMeasure.textThickness
        spnLift.value = LiveMeasure.textOffset
        ddlAlign.selection = LM_indexFromAlign LiveMeasure.textAlign
        ddlOrient.selection = LM_indexFromOrient LiveMeasure.textOrient
        chkMirror.checked = (LiveMeasure.textMirror == true)
        ddlStyle.selection = LM_indexFromStyle LiveMeasure.lineStyle
        spnArrSz.value = LiveMeasure.arrowSize
        spnArrW.value = LiveMeasure.arrowWidth
        spnPickArr.value = LiveMeasure.pickArrowSize
        cpCol.color = LiveMeasure.lineColor
        local ui = findItem #("mm", "cm", "m", "ft", "in") LiveMeasure.unitsType
        if ui == 0 then ui = 2
        ddlUnits.selection = ui
        spnDec.value = LiveMeasure.decimals
        chkRound.checked = (LiveMeasure.roundEnabled == true)
        spnStep.value = LiveMeasure.roundStep
        chkRender.checked = (LiveMeasure.renderable == true)
    )

    fn loadFromSel =
    (
        LM_updatingUI = true
        local grp = currentTape()
        if grp == undefined then
        (
            lblSel.text = LM_t #selNew
            loadDefaults()
            LM_updatingUI = false
            return false
        )
        lblSel.text = grp.name + "  =  " + (LM_propS grp "LM_value" "")
        local ov = LiveMeasure.readOffset grp
        spnOX.value = ov.x
        spnOY.value = ov.y
        spnOZ.value = ov.z
        spnTh.value = LM_propF grp "LM_th" LiveMeasure.splineThickness
        spnTs.value = LM_propF grp "LM_textSize" LiveMeasure.textSize
        spnTxtThk.value = LM_propF grp "LM_textThk" LiveMeasure.textThickness
        spnLift.value = LM_propF grp "LM_textLift" LiveMeasure.textOffset
        ddlAlign.selection = LM_indexFromAlign (LM_propS grp "LM_textAlign" LiveMeasure.textAlign)
        ddlOrient.selection = LM_indexFromOrient (LM_propS grp "LM_textOrient" LiveMeasure.textOrient)
        chkMirror.checked = ((LM_propI grp "LM_textMirror" 0) == 1)
        ddlStyle.selection = LM_indexFromStyle (LM_propS grp "LM_style" LiveMeasure.lineStyle)
        spnArrSz.value = LM_propF grp "LM_arrowSize" LiveMeasure.arrowSize
        spnArrW.value = LM_propF grp "LM_arrowWidth" LiveMeasure.arrowWidth
        spnPickArr.value = LM_propF grp "LM_pickArrow" LiveMeasure.pickArrowSize
        cpCol.color = LiveMeasure.readColor grp
        local ut = LM_propS grp "LM_units" LiveMeasure.unitsType
        local ui = findItem #("mm", "cm", "m", "ft", "in") ut
        if ui == 0 then ui = 2
        ddlUnits.selection = ui
        spnDec.value = LM_propI grp "LM_decimals" LiveMeasure.decimals
        chkRound.checked = ((LM_propI grp "LM_round" 0) == 1)
        spnStep.value = LM_propF grp "LM_roundStep" LiveMeasure.roundStep
        chkRender.checked = (LiveMeasure.renderable == true)
        LM_updatingUI = false
        true
    )

    fn applyNow =
    (
        if LM_updatingUI then return false
        pushDefaults()
        local grp = currentTape()
        if grp == undefined then return true
        setUserProp grp "LM_ox" spnOX.value
        setUserProp grp "LM_oy" spnOY.value
        setUserProp grp "LM_oz" spnOZ.value
        setUserProp grp "LM_style" (LM_styleFromIndex ddlStyle.selection)
        local ori = LM_orientFromIndex ddlOrient.selection
        local mir = chkMirror.checked
        setUserProp grp "LM_textOrient" ori
        setUserProp grp "LM_textMirror" (if mir then 1 else 0)
        setUserProp grp "LM_textRot" (LiveMeasure.rotFromOrient ori mir)
        setUserProp grp "LM_arrowSize" spnArrSz.value
        setUserProp grp "LM_arrowWidth" spnArrW.value
        setUserProp grp "LM_pickArrow" spnPickArr.value
        setUserProp grp "LM_units" ddlUnits.selected
        setUserProp grp "LM_decimals" (spnDec.value as integer)
        LiveMeasure.applyAppearance grp cpCol.color spnTh.value spnTs.value (LM_alignFromIndex ddlAlign.selection) spnLift.value chkRound.checked spnStep.value tThk:spnTxtThk.value
        select grp
        completeRedraw()
        loadFromSel()
        true
    )

    on spnOX changed v do applyNow()
    on spnOY changed v do applyNow()
    on spnOZ changed v do applyNow()
    on spnTh changed v do applyNow()
    on spnTs changed v do applyNow()
    on spnTxtThk changed v do applyNow()
    on spnLift changed v do applyNow()
    on ddlAlign selected i do applyNow()
    on ddlOrient selected i do applyNow()
    on chkMirror changed s do applyNow()
    on ddlStyle selected i do applyNow()
    on spnArrSz changed v do applyNow()
    on spnArrW changed v do applyNow()
    on spnPickArr changed v do applyNow()
    on cpCol changed c do applyNow()
    on ddlUnits selected i do applyNow()
    on spnDec changed v do applyNow()
    on chkRound changed s do applyNow()
    on spnStep changed v do applyNow()
    on chkRender changed s do applyNow()
    on btnApply pressed do applyNow()
    on btnDelTape pressed do
    (
        local grp = currentTape()
        if grp != undefined then
        (
            LiveMeasure.deleteTape grp
            clearSelection()
            completeRedraw()
            loadFromSel()
        )
    )
    on LM_rollSettings open do loadFromSel()
)

rollout LM_rollCSV "All measures"
(
    dotNetControl lv "System.Windows.Forms.ListView" height:130
    button btnRefresh "Refresh" width:80 across:3
    button btnDelete "Delete selected" width:90
    button btnExport "Export CSV" width:80

    fn fillList =
    (
        lv.Clear()
        lv.View = (dotNetClass "System.Windows.Forms.View").Details
        lv.FullRowSelect = true
        lv.Columns.Add (LM_t #colLabel) 150
        lv.Columns.Add (LM_t #colValue) 80
        for o in LiveMeasure.listMeasures() do
        (
            local item = dotNetObject "System.Windows.Forms.ListViewItem" o.name
            local val = getUserProp o "LM_value"
            if val == undefined then val = ""
            item.SubItems.Add val
            lv.Items.Add item
        )
    )

    on LM_rollCSV open do
    (
        lv.GridLines = true
        fillList()
    )
    on btnRefresh pressed do fillList()
    on btnDelete pressed do
    (
        if lv.SelectedItems.Count > 0 then
        (
            local nm = lv.SelectedItems.Item[0].Text
            local obj = getNodeByName nm
            if obj != undefined then LiveMeasure.deleteTape obj
            fillList()
            try (LM_rollSettings.loadFromSel()) catch ()
        )
    )
    on btnExport pressed do
    (
        local f = getSaveFileName caption:(LM_t #csvCap) types:"CSV (*.csv)|*.csv|"
        if f != undefined then
        (
            local s = createFile f
            if s != undefined then
            (
                format "%" (LiveMeasure.csvText()) to:s
                close s
            )
        )
    )
)

rollout LM_rollAbout "Help / About"
(
    dropdownlist ddlLang "Language:" items:#("English", "Türkçe") selection:1 width:200
    label lblA "Lonas_Max_Measured 0.7" align:#left
    dotNetControl txtAbout "System.Windows.Forms.TextBox" width:268 height:168

    fn applyAboutText =
    (
        lblA.text = LM_t #aboutTitle
        try
        (
            txtAbout.Multiline = true
            txtAbout.ReadOnly = true
            txtAbout.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Vertical
            txtAbout.WordWrap = true
            txtAbout.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
            txtAbout.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 40 40 40
            txtAbout.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 230 230 230
            txtAbout.Text = LM_t #aboutBody
        )
        catch ()
        local li = if LM_lang == "tr" then 2 else 1
        if ddlLang.selection != li then ddlLang.selection = li
    )

    on ddlLang selected i do
    (
        LM_lang = if i == 2 then "tr" else "en"
        LM_saveLang()
        LM_applyLang()
    )
    on LM_rollAbout open do applyAboutText()
)

fn LM_applyLang =
(
    local iTape = 1
    local iAlign = 1
    local iOrient = 1
    local iStyle = 1
    try (iTape = LM_rollMain.ddlTapeMode.selection) catch ()
    try (iAlign = LM_rollSettings.ddlAlign.selection) catch ()
    try (iOrient = LM_rollSettings.ddlOrient.selection) catch ()
    try (iStyle = LM_rollSettings.ddlStyle.selection) catch ()
    try (LM_Floater.title = LM_t #floater) catch ()
    try (LM_rollMain.title = LM_t #rollMain) catch ()
    try (LM_rollSettings.title = LM_t #rollSettings) catch ()
    try (LM_rollCSV.title = LM_t #rollCSV) catch ()
    try (LM_rollAbout.title = LM_t #rollAbout) catch ()
    try (LM_rollMain.lblHelp.text = LM_t #help) catch ()
    try (LM_rollMain.btnTape.text = LM_t #btnTape) catch ()
    try (LM_rollMain.btnBBox.text = LM_t #btnBBox) catch ()
    try (LM_rollMain.ddlTapeMode.caption = LM_t #tapeMode) catch ()
    try (LM_rollMain.ddlTapeMode.items = #(LM_t #tapeDistance, LM_t #tapeDimension)) catch ()
    try (LM_rollMain.ddlTapeMode.selection = iTape) catch ()
    try (LM_rollSettings.spnOX.caption = LM_t #lineX) catch ()
    try (LM_rollSettings.spnOY.caption = LM_t #lineY) catch ()
    try (LM_rollSettings.spnOZ.caption = LM_t #lineZ) catch ()
    try (LM_rollSettings.spnTh.caption = LM_t #th) catch ()
    try (LM_rollSettings.spnTs.caption = LM_t #ts) catch ()
    try (LM_rollSettings.spnTxtThk.caption = LM_t #txtThk) catch ()
    try (LM_rollSettings.spnLift.caption = LM_t #lift) catch ()
    try (LM_rollSettings.ddlAlign.caption = LM_t #align) catch ()
    try (LM_rollSettings.ddlAlign.items = #(LM_t #alignC, LM_t #alignS, LM_t #alignE)) catch ()
    try (LM_rollSettings.ddlAlign.selection = iAlign) catch ()
    try (LM_rollSettings.ddlOrient.caption = LM_t #orient) catch ()
    try (LM_rollSettings.ddlOrient.items = #(LM_t #orientH, LM_t #orientV)) catch ()
    try (LM_rollSettings.ddlOrient.selection = iOrient) catch ()
    try (LM_rollSettings.chkMirror.caption = LM_t #mirror) catch ()
    try (LM_rollSettings.ddlStyle.caption = LM_t #style) catch ()
    try (LM_rollSettings.ddlStyle.items = #(LM_t #styleA, LM_t #styleL, LM_t #styleR)) catch ()
    try (LM_rollSettings.ddlStyle.selection = iStyle) catch ()
    try (LM_rollSettings.spnArrSz.caption = LM_t #arrSz) catch ()
    try (LM_rollSettings.spnArrW.caption = LM_t #arrW) catch ()
    try (LM_rollSettings.spnPickArr.caption = LM_t #pickArr) catch ()
    try (LM_rollSettings.cpCol.caption = LM_t #color) catch ()
    try (LM_rollSettings.ddlUnits.caption = LM_t #units) catch ()
    try (LM_rollSettings.spnDec.caption = LM_t #dec) catch ()
    try (LM_rollSettings.chkRound.caption = LM_t #round) catch ()
    try (LM_rollSettings.spnStep.caption = LM_t #step) catch ()
    try (LM_rollSettings.chkRender.caption = LM_t #render) catch ()
    try (LM_rollSettings.btnApply.text = LM_t #apply) catch ()
    try (LM_rollSettings.btnDelTape.text = LM_t #delTape) catch ()
    try (LM_rollCSV.btnRefresh.text = LM_t #refresh) catch ()
    try (LM_rollCSV.btnDelete.text = LM_t #delSel) catch ()
    try (LM_rollCSV.btnExport.text = LM_t #export) catch ()
    try (LM_rollCSV.fillList()) catch ()
    try (LM_rollAbout.ddlLang.caption = LM_t #lang) catch ()
    try (LM_rollAbout.applyAboutText()) catch ()
    try (LM_rollSettings.loadFromSel()) catch ()
)

fn LM_onSelChanged =
(
    try (LM_rollSettings.loadFromSel()) catch ()
)

fn LM_openUI =
(
    LM_loadLang()
    if LM_Floater != undefined then
    (
        try (closeRolloutFloater LM_Floater) catch ()
        LM_Floater = undefined
    )
    try (callbacks.removeScripts id:#LiveMeasureSel) catch ()
    callbacks.addScript #selectionSetChanged "LM_onSelChanged()" id:#LiveMeasureSel
    LM_Floater = newRolloutFloater (LM_t #floater) 300 1080
    addRollout LM_rollMain LM_Floater
    addRollout LM_rollSettings LM_Floater
    addRollout LM_rollCSV LM_Floater
    addRollout LM_rollAbout LM_Floater rolledUp:false
    LM_applyLang()
)

true
