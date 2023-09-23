#NoEnv
SetBatchLines -1
SendMode Input
SetWorkingDir %A_ScriptDir%

Menu, Tray, NoIcon ; Hide the script's icon from the system tray

#SingleInstance, Force ; Ensure only one instance of the script is running

Random, clickDelay, 30, 60 ; Generate a random delay between 40ms and 60ms

F1::
    toggle := !toggle
    SetTimer, ToolTipOff, 1000
return

ToolTipOff:
    SetTimer, ToolTipOff, Off
    ToolTip
return

#if toggle
~$LButton::
    prevDelay := 0 ; Initialize the previous delay variable
    consecutiveFastClicks := 0 ; Initialize the consecutive fast clicks counter
    clickCounter := 0 ; Initialize the click counter
    startTime := A_TickCount ; Get the initial tick count

    While (toggle && GetKeyState("LButton", "P"))
    {
        SendInput, {LButton down} ; Simulate mouse button down

        Random, holdDuration, 30, 45 ; Generate a random hold duration between 30ms and 45ms
        Sleep, holdDuration

        SendInput, {LButton up} ; Simulate mouse button up

        clickCounter := clickCounter + 1

        elapsed := A_TickCount - startTime ; Calculate the elapsed time in milliseconds
        clicksPerSecond := clickCounter / (elapsed / 1000) ; Calculate the average clicks per second

        Random, movementChance, 1, 100 ; Chance of mouse movement

        if (clicksPerSecond > 15 || RandomClickDelay())
        {
            Random, delay, 25, 35 ; Generate a random delay between 30ms and 40ms

            if (movementChance <= 20)
            {
                ; Add mouse movement before click
                RandomMouseMovement()
            }

            Sleep, delay

            if (movementChance <= 20)
            {
                ; Add mouse movement after click
                RandomMouseMovement()
            }
        }
        else if (Mod(clickCounter, 3) = 0)
        {
            ; Guaranteed click faster than 50ms every third click if clicks per second is below 15
            Random, delay, 10, 35
            Sleep, delay
        }
        else if (Mod(clickCounter, 5) = 0)
        {
            ; 40% chance for clicks slower than 70ms every fifth click
            Random, delay, 10, 70
            if (delay > 40)
                Random, delay, 30, 60 ; Default random delay between 40ms and 60ms
            Sleep, delay
        }
        else
        {
            Sleep, 60 ; Default delay of 60ms
        }

        prevDelay := delay ; Store the current delay as the previous delay

        if (delay < 55)
            consecutiveFastClicks := consecutiveFastClicks + 1
        else
            consecutiveFastClicks := 0
    }

    prevDelay := 0 ; Reset the previous delay variable when the loop ends
    consecutiveFastClicks := 0 ; Reset the consecutive fast clicks counter when the loop ends
    clickCounter := 0 ; Reset the click counter when the loop ends
return
#if

RandomClickDelay()
{
    Random, delay, 1, 3 ; Generate a random number between 1 and 3

    if (delay = 1)
    {
        ; 50% chance for clicks faster than 45ms
        Random, delay, 10, 45
        if (delay <= 50)
        {
            ; 25% chance for clicks faster than 30ms
            Random, delay, 10, 30
        }
        else
        {
            ; Default random delay between 40ms and 60
            Random, delay, 30, 60
        }
    }
    else if (delay = 2 && Mod(clickCounter, 3) = 0)
    {
        ; 60% chance for clicks faster than 40ms every third click
        Random, delay, 10, 60
        if (delay <= 60)
        {
            ; Click faster than 40ms
            Random, delay, 1, 40
        }
        else
        {
            ; Default random delay between 40ms and 60ms
            Random, delay, 40, 60
        }
    }
    else
    {
        ; Default random delay between 40ms and 60ms
        Random, delay, 30, 60
    }

    return delay
}

RandomMouseMovement()
{
{
    MouseGetPos, startX, startY ; Get the starting position of the mouse

    Random, offsetX, -1, 1 ; Generate a random offset for the X coordinate within -3 and 3 pixels
    Random, offsetY, -1, 1 ; Generate a random offset for the Y coordinate within -3 and 3 pixels

    targetX := startX + offsetX ; Calculate the new X position
    targetY := startY + offsetY ; Calculate the new Y position

    duration := 500 ; Set the duration of the mouse movement in milliseconds (increased to 500ms)

    DllCall("mouse_event", uint, 0x0001, int, targetX - startX, int, targetY - startY, uint, 0, int, 0, UInt, duration) ; Smoothly move the mouse to the new position
}

}
