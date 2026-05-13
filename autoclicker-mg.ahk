myGui := Gui("+AlwaysOnTop", "Auto Clicker")
myGui.MarginX := 12
myGui.MarginY := 10
myGui.SetFont("s9", "Segoe UI")

; Click rate
myGui.AddGroupBox("w210 h95", "Click Rate")

modeInterval := myGui.AddRadio("xp+10 yp+20", "Interval")
modeInterval.OnEvent("Click", UpdateMode)
modeCPS := myGui.AddRadio("x+10 Checked", "CPS")
modeCPS.OnEvent("Click", UpdateMode)

; Interval row
hoursLabel  := myGui.AddText("x22 yp+24 w40", "Hours")
minsLabel   := myGui.AddText("x+10 w40", "Mins")
secsLabel   := myGui.AddText("x+10 w40", "Secs")
millisLabel := myGui.AddText("x+10 w50", "Millis")
hoursEdit   := myGui.AddEdit("x17 yp+18 w40 Number", "0")
minsEdit    := myGui.AddEdit("x+10 w40 Number", "0")
secsEdit    := myGui.AddEdit("x+10 w40 Number", "0")
millisEdit  := myGui.AddEdit("x+10 w50 Number", "100")
hoursLabel.Visible  := false
minsLabel.Visible   := false
secsLabel.Visible   := false
millisLabel.Visible := false
hoursEdit.Visible   := false
minsEdit.Visible    := false
secsEdit.Visible    := false
millisEdit.Visible  := false

; CPS row (hidden initially)
cpsLabel := myGui.AddText("x22 yp-20 w60", "Clicks/sec")
cpsEdit  := myGui.AddEdit("x22 yp+20 w60 Number", "100")
cpsLabel.Visible := true
cpsEdit.Visible  := true

; Click Options
myGui.AddGroupBox("x12 y+15 w210 h70", "Click Options")

myGui.AddText("xp+10 yp+22", "Mouse Button:")
leftRadio   := myGui.AddRadio("x+8 Checked", "Left")
rightRadio  := myGui.AddRadio("x+6", "Right")

myGui.AddText("x22 yp+22", "Click Type:")
singleRadio := myGui.AddRadio("x+10 Checked", "Single")
doubleRadio := myGui.AddRadio("x+6", "Double")

; Hotkey
myGui.AddGroupBox("x12 y+15 w210 h45", "Hotkey")
myGui.AddText("xp+10 yp+20 cBlue", "RShift")
holdRadio   := myGui.AddRadio("x+16 Checked", "Hold")
toggleRadio := myGui.AddRadio("x+8", "Toggle")

; Status
statusText := myGui.AddText("x13 y+18 w210 h20 cGreen", "Ready")

myGui.Show("w235")
myGui.OnEvent("Close", (*) => ExitApp())

; Mode toggle
UpdateMode(*) {
    if modeInterval.Value {
        hoursLabel.Visible  := true
        minsLabel.Visible   := true
        secsLabel.Visible   := true
        millisLabel.Visible := true
        hoursEdit.Visible   := true
        minsEdit.Visible    := true
        secsEdit.Visible    := true
        millisEdit.Visible  := true
        cpsLabel.Visible    := false
        cpsEdit.Visible     := false
    } else {
        hoursLabel.Visible  := false
        minsLabel.Visible   := false
        secsLabel.Visible   := false
        millisLabel.Visible := false
        hoursEdit.Visible   := false
        minsEdit.Visible    := false
        secsEdit.Visible    := false
        millisEdit.Visible  := false
        cpsLabel.Visible    := true
        cpsEdit.Visible     := true
    }
}

; Helpers
GetSleepMs() {
    if modeInterval.Value {
        h := Integer(hoursEdit.Value)
        m := Integer(minsEdit.Value)
        s := Integer(secsEdit.Value)
        ms := Integer(millisEdit.Value)
        total := (h * 3600000) + (m * 60000) + (s * 1000) + ms
        return Max(total, 1)
    } else {
        cps := Integer(cpsEdit.Value)
        return (cps > 0) ? Max(Round(1000 / cps), 1) : 10
    }
}

; Main logic
clicking := false

DoClick() {
    btn := leftRadio.Value ? "Left" : "Right"
    if singleRadio.Value
        Click btn
    else
        Click btn, 2
}

ClickLoop() {
    global clicking
    if clicking {
        DoClick()
        Sleep GetSleepMs()
    } else {
        SetTimer ClickLoop, 0  ; 0 removes the timer
    }
}

; I like to use RShift
; Other good keys to use are F7, =, RAlt
; The labels for stuff won't change if you change the hotkey though,
; You'll have to change those too
RShift::
{
    global clicking
    if holdRadio.Value {
        statusText.Value := "Clicking..."
        statusText.Opt("cRed")
        while GetKeyState("RShift", "P") {
            DoClick()
            Sleep GetSleepMs()
        }
        statusText.Value := "Ready"
        statusText.Opt("cGreen")
    } else {
        if clicking {
            clicking := false
            statusText.Value := "Ready"
            statusText.Opt("cGreen")
        } else {
            clicking := true
            statusText.Value := "Clicking..."
            statusText.Opt("cRed")
            SetTimer ClickLoop, 1
        }
    }
}