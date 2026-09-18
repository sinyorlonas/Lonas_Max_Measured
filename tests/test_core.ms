-- Lonas_Max_Measured core tests. fileIn this file from 3ds Max.

(
    global LM_TEST_RESULTS = #()

    fn lmAssertEq name got expected =
    (
        local ok = false
        if (classof got) == float and (classof expected) == float then
            ok = (abs (got - expected) < 0.001)
        else
            ok = (got == expected)
        if ok then
            append LM_TEST_RESULTS ("PASS " + name)
        else
            append LM_TEST_RESULTS ("FAIL " + name + " got=" + (got as string) + " expected=" + (expected as string))
    )

    fn lmAssertTrue name cond =
    (
        if cond then
            append LM_TEST_RESULTS ("PASS " + name)
        else
            append LM_TEST_RESULTS ("FAIL " + name)
    )

    try (fileIn @"B:\3DSMAX\PLUGINS\Lonas_Max_Measured\Lonas_Max_Measured.ms") catch ()

    lmAssertTrue "struct_exists" (LiveMeasure != undefined)

    if LiveMeasure != undefined then
    (
        LiveMeasure.unitsType = "cm"
        LiveMeasure.decimals = 2
        lmAssertEq "format_100cm" (LiveMeasure.formatValue 100.0) "100.00 cm"
        lmAssertEq "distance_x" (LiveMeasure.distanceBetween [0,0,0] [100,0,0]) 100.0
        lmAssertEq "distance_xyz" (LiveMeasure.distanceBetween [0,0,0] [30,40,0]) 50.0

        LiveMeasure.roundEnabled = true
        LiveMeasure.roundStep = 1.0
        LiveMeasure.decimals = 0
        lmAssertEq "round_49_9_to_50" (LiveMeasure.roundValue 49.9) 50.0
        lmAssertEq "format_rounded_49_9" (LiveMeasure.formatValue 49.9) "50 cm"
        LiveMeasure.roundEnabled = false
        LiveMeasure.decimals = 2
        lmAssertEq "format_unrounded_49_9" (LiveMeasure.formatValue 49.9) "49.90 cm"

        local p1 = [0,0,0]
        local p2 = [100,0,0]
        local offsetV = [0,-10,0]
        local ctr = LiveMeasure.textWorldPos p1 p2 offsetV "center" 3.0
        local st = LiveMeasure.textWorldPos p1 p2 offsetV "start" 3.0
        local en = LiveMeasure.textWorldPos p1 p2 offsetV "end" 3.0
        lmAssertTrue "text_center_mid_x" (abs (ctr.x - 50.0) < 0.01)
        lmAssertTrue "text_start_near_p1" (st.x < ctr.x)
        lmAssertTrue "text_end_near_p2" (en.x > ctr.x)
        local ctr0 = LiveMeasure.textWorldPos p1 p2 offsetV "center" 0.0
        local ctr6 = LiveMeasure.textWorldPos p1 p2 offsetV "center" 6.0
        lmAssertTrue "text_gap_moves_off_line" ((distance ctr0 ctr6) > 5.9)

        LiveMeasure.textSize = 80.0
        LiveMeasure.lineGap = 8.0
        local ov = LiveMeasure.defaultOffsetVec [0,0,0] [100,0,0] viewN:[0,0,1]
        lmAssertTrue "linegap_ignores_textsize" (abs ((length ov) - 8.0) < 0.01)
        lmAssertTrue "offset_top_x_in_xy" (abs ov.z < 0.01)
        local ovF = LiveMeasure.defaultOffsetVec [0,0,0] [100,0,0] viewN:[0,-1,0]
        lmAssertTrue "offset_front_x_in_xz" (abs ovF.y < 0.01)
        lmAssertTrue "facing_front_is_neg_y" ((distance (LiveMeasure.facingFor "front") [0,-1,0]) < 0.001)
        lmAssertTrue "facing_top_is_pos_z" ((distance (LiveMeasure.facingFor "top") [0,0,1]) < 0.001)
        local tmTop = LM_lookText [0,0,0] [1,0,0] [0,0,1] upHint:[0,1,0]
        lmAssertTrue "text_top_faces_up" (abs (tmTop.row3.z) > 0.9)
        local tmFront = LM_lookText [0,0,0] [1,0,0] [0,-1,0] upHint:[0,0,1]
        lmAssertTrue "text_front_faces_camera" (abs (tmFront.row3.y) > 0.9)
        local tm0 = LM_lookText [0,0,0] [1,0,0] [0,-1,0] rotDeg:0
        local tm90 = LM_lookText [0,0,0] [1,0,0] [0,-1,0] rotDeg:90
        lmAssertTrue "text_rot_keeps_along" ((distance tm0.row1 tm90.row1) < 0.05)
        lmAssertTrue "text_rot_90_tilts" ((distance tm0.row3 tm90.row3) > 0.5)
        lmAssertTrue "text_rot_90_can_face_up" (abs (tm90.row3.z) > 0.9)
        lmAssertEq "orient_h" (LiveMeasure.rotFromOrient "horizontal" false) 0.0
        lmAssertEq "orient_v" (LiveMeasure.rotFromOrient "vertical" false) 90.0
        lmAssertEq "orient_h_mirror" (LiveMeasure.rotFromOrient "horizontal" true) 180.0
        lmAssertEq "orient_v_mirror" (LiveMeasure.rotFromOrient "vertical" true) 270.0
        local bx = Box name:"LM_SnapBox" width:100 length:50 height:30 pos:[50,25,15]
        local corner = bx.min
        local hit = LM_snapToCorner (corner + [2.5, 2.0, 1.5]) r:12.0
        lmAssertTrue "snap_hits_box_corner" ((distance hit corner) < 0.05)
        local eye = corner + [80, 90, 140]
        local miss = [corner.x + 45, corner.y + 40, 0]
        local rMiss = ray eye (normalize (corner - eye))
        local hitRay = LM_snapToCorner miss r:5.0 viewRay:rMiss
        lmAssertTrue "snap_ray_hits_corner" ((distance hitRay corner) < 0.05)
        local ln = SplineShape name:"LM_SnapSpline"
        addNewSpline ln
        addKnot ln 1 #corner #line [0,0,0]
        addKnot ln 1 #corner #line [20,0,0]
        updateShape ln
        ln.transform = transMatrix [200, 30, 12]
        local knotW = [200, 30, 12]
        local hitKnot = LM_snapToCorner (knotW + [3, 2, 1]) r:12.0
        lmAssertTrue "snap_spline_knot_world" ((distance hitKnot knotW) < 0.05)
        delete ln
        delete bx
        LiveMeasure.textSize = 8.0

        local arr = LiveMeasure.arrowBarbs [0,0,0] [0,-8,0] 2.0 0.35
        lmAssertTrue "arrow_tip_at_pick" (distance arr[2] [0,0,0] < 0.001)
        lmAssertTrue "arrow_has_two_barbs" (arr.count == 3)

        lmAssertEq "ruler_marks_100_by_10" (LiveMeasure.rulerMarkCount 100.0 10.0) 11

        local alongX = [1,0,0]
        LiveMeasure.arrowSize = 2.0
        LiveMeasure.arrowWidth = 0.4
        LiveMeasure.pickArrowSize = 1.5
        local stArrow = LiveMeasure.tapeStrokes [0,0,0] [100,0,0] [0,-10,0] alongX style:"arrow"
        LiveMeasure.pickArrowSize = 0.0
        local stNoPick = LiveMeasure.tapeStrokes [0,0,0] [100,0,0] [0,-10,0] alongX style:"arrow"
        LiveMeasure.pickArrowSize = 1.5
        local stLine = LiveMeasure.tapeStrokes [0,0,0] [100,0,0] [0,-10,0] alongX style:"line"
        local stRuler = LiveMeasure.tapeStrokes [0,0,0] [100,0,0] [0,-10,0] alongX style:"ruler"
        local dimHeads = 0
        local pickHeads = 0
        for s in stArrow where s.count == 3 do
        (
            if (distance s[2] [0,-10,0]) < 0.001 then dimHeads += 1
            if (distance s[2] [0,0,0]) < 0.001 then pickHeads += 1
        )
        local pickWhenOff = 0
        for s in stNoPick where s.count == 3 do
            if (distance s[2] [0,0,0]) < 0.001 then pickWhenOff += 1
        lmAssertTrue "style_arrow_has_heads" (dimHeads >= 1)
        lmAssertTrue "style_arrow_marks_pick" (pickHeads >= 1)
        lmAssertTrue "style_arrow_pick_can_hide" (pickWhenOff == 0)
        lmAssertTrue "style_line_no_heads" (stLine.count == 5)
        lmAssertTrue "style_ruler_has_ticks" (stRuler.count >= 14)

        local g = LiveMeasure.createTape [0,0,0] [100,0,0] [0,-10,0] namePrefix:"LM_SelfTest" textOrient:"vertical"
        local gName = if g != undefined then g.name else ""
        lmAssertTrue "tape_is_group" (g != undefined and (isGroupHead g))
        lmAssertTrue "tape_has_line" (g != undefined and LiveMeasure.findLineChild g != undefined)
        lmAssertTrue "tape_has_text" (g != undefined and LiveMeasure.findTextChild g != undefined)
        if g != undefined then
        (
            local tpFace = LiveMeasure.findTextChild g
            lmAssertTrue "tape_text_rot_90_faces_up" (abs (tpFace.transform.row3.z) > 0.85)
        )
        if g != undefined then
        (
            local tp0 = LiveMeasure.findTextChild g
            local tm0 = tp0.transform
            local bb0 = nodeGetBoundingBox tp0 tm0
            local localCx = (bb0[1].x + bb0[2].x) * 0.5
            local worldC = tm0.pos + (normalize tm0.row1) * localCx
            lmAssertTrue "text_visual_center" (abs (worldC.x - 50.0) < 1.5)

            local tpSpan = LiveMeasure.findTextChild g
            local bbA = nodeGetBoundingBox tpSpan tpSpan.transform
            local spanA = bbA[2].x - bbA[1].x
            LiveMeasure.applyAppearance g (color 32 96 176) 0.8 24.0 "center" 1.0 false 1.0
            local tpGrow = LiveMeasure.findTextChild g
            local bbB = nodeGetBoundingBox tpGrow tpGrow.transform
            local spanB = bbB[2].x - bbB[1].x
            lmAssertTrue "text_mesh_grows_with_size" (spanB > spanA * 2.0)

            local hid = g
            LiveMeasure.rebuildTape g
            lmAssertTrue "rebuild_keeps_head" (isValidNode hid)
            select g
            lmAssertTrue "group_select_is_multi" (selection.count > 1)
            local fromSel = LiveMeasure.tapeFromSelection()
            lmAssertTrue "group_sel_finds_tape" (fromSel == g)
            LiveMeasure.applyAppearance g (color 32 96 176) 0.8 20.0 "center" 1.0 false 1.0
            local tp = LiveMeasure.findTextChild g
            local ss = LiveMeasure.findLineChild g
            lmAssertTrue "group_text_size_applied" (tp != undefined and (abs (tp.size - 20.0) < 0.01))
            local thGot = if ss != undefined then (try ss.render_thickness catch -1) else -1
            lmAssertTrue "group_thickness_applied" (abs (thGot - 0.8) < 0.01)
            local tm1 = tp.transform
            local bb1 = nodeGetBoundingBox tp tm1
            local localCx2 = (bb1[1].x + bb1[2].x) * 0.5
            local worldC2 = tm1.pos + (normalize tm1.row1) * localCx2
            lmAssertTrue "text_center_after_resize" (abs (worldC2.x - 50.0) < 2.0)
            LiveMeasure.applyAppearance g (color 32 96 176) 0.8 20.0 "center" 6.0 false 1.0
            local tpGap = LiveMeasure.findTextChild g
            local lineY = -10.0
            lmAssertTrue "text_pushed_from_line" (tpGap != undefined and (abs (tpGap.pos.y - lineY)) > 4.0)
            LiveMeasure.applyAppearance g (color 32 96 176) 0.8 20.0 "center" 6.0 false 1.0 tThk:1.25
            local tpEx = LiveMeasure.findTextChild g
            lmAssertTrue "group_text_extrude_applied" (tpEx != undefined and (abs (tpEx.extrudeamount - 1.25) < 0.01))
            LiveMeasure.deleteTape g
        )
        lmAssertTrue "tape_deleted" (gName != "" and (getNodeByName gName) == undefined)
    )

    local outTxt = ""
    for r in LM_TEST_RESULTS do outTxt += r + "\n"
    outTxt
)
