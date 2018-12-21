; gdi+ ahk tutorial 3 written by tic (Tariq Porter)
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
;
; Tutorial to take make a gui from an existing image on disk
; For the example we will use png as it can handle transparencies. The image will also be halved in size

/*
	Author: Eruyome
	Tutorial used as template to show PoE UI overlay
	Overlay images created by https://www.reddit.com/user/Musti_A, reddit post https://www.reddit.com/r/pathofexile/comments/5x9pgt/i_made_some_poe_twitch_stream_overlays_free/
*/

#SingleInstance, Force
#NoEnv
SetBatchLines, -1

; Uncomment if Gdip.ahk is not in your standard library
#Include, Gdip_All.ahk

; Start gdi+
If !pToken := Gdip_Startup()
	{
	   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	}
OnExit, Exit

global image1 := "Syndicate.png"
global image2 := "Incursion.png"
global GuiOn1 := 0
global GuiOn2 := 0
global poeWindowName = "Path of Exile ahk_class POEWindowClass"

; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption


Loop 2
{
    ; Create two layered windows (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
    Gui, %A_Index%: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    ; Show the window
 
    ; Get a handle to this window we have created in order to update it later
    hwnd%A_Index% := WinExist()
}



Loop 2
{
If (GuiON%A_Index% = 0) {
	Gosub, CheckWinActivePOE
	SetTimer, CheckWinActivePOE, 100
	GuiON%A_Index% = 1
	
	; Show the window
	Gui, %A_Index%: Show, NA
}
Else {
	SetTimer, CheckWinActivePOE, Off      
	Gui, %A_Index%: Hide	
	GuiON%A_Index% = 0
}
}


; If the image we want to work with does not exist on disk, then download it...

; Get a bitmap from the image
pBitmap1 := Gdip_CreateBitmapFromFile(image1)
pBitmap2 := Gdip_CreateBitmapFromFile(image2)
; Check to ensure we actually got a bitmap from the file, in case the file was corrupt or some other error occured
If !pBitmap1
{
	MsgBox, 48, File loading error!, Could not load the image specified
	ExitApp
}

; Check to ensure we actually got a bitmap from the file, in case the file was corrupt or some other error occured
If !pBitmap2
{
	MsgBox, 48, File loading error!, Could not load the image specified
	ExitApp
}


; Get the width and height of the bitmap we have just created from the file
; This will be the dimensions that the file is
Width := Gdip_GetImageWidth(pBitmap1), Height := Gdip_GetImageHeight(pBitmap1)

; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
hbm := CreateDIBSection(Width, Height)
hbm2 := CreateDIBSection(Width, Height)

; Get a device context compatible with the screen
hdc := CreateCompatibleDC()
hdc2 := CreateCompatibleDC()

; Select the bitmap into the device context
obm := SelectObject(hdc, hbm)
obm2 := SelectObject(hdc2, hbm2)

; Get a pointer to the graphics of the bitmap, for use with drawing functions
G1 := Gdip_GraphicsFromHDC(hdc)
G2 := Gdip_GraphicsFromHDC(hdc2)

; We do not need SmoothingMode as we did in previous examples for drawing an image
; Instead we must set InterpolationMode. This specifies how a file will be resized (the quality of the resize)
; Interpolation mode has been set to HighQualityBicubic = 7
Gdip_SetInterpolationMode(G1, 7)
Gdip_SetInterpolationMode(G2, 7)


; DrawImage will draw the bitmap we took from the file into the graphics of the bitmap we created
; The source height and width are specified, and also the destination width and height
; Gdip_DrawImage(pGraphics, pBitmap1, dx, dy, dw, dh, sx, sy, sw, sh, Matrix)
; d is for destination and s is for source. We will not talk about the matrix yet (this is for changing colours when drawing)
Gdip_DrawImage(G1, pBitmap1, 0, 0, Width, Height, 0, 0, Width, Height)


; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
; So this will position our gui at (0,0) with the Width and Height specified earlier
UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)

; Select the object back into the hdc
SelectObject(hdc, obm)

; Now the bitmap may be deleted
DeleteObject(hbm)

; Also the device context related to the bitmap may be deleted
DeleteDC(hdc)

; The graphics may now be deleted
Gdip_DeleteGraphics(G1)

; The bitmap we made from the image may be deleted
Gdip_DisposeImage(pBitmap1)


; DrawImage will draw the bitmap we took from the file into the graphics of the bitmap we created
; The source height and width are specified, and also the destination width and height
; Gdip_DrawImage(pGraphics, pBitmap1, dx, dy, dw, dh, sx, sy, sw, sh, Matrix)
; d is for destination and s is for source. We will not talk about the matrix yet (this is for changing colours when drawing)
Gdip_DrawImage(G2, pBitmap2, 0, 0, Width, Height, 0, 0, Width, Height)


; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
; So this will position our gui at (0,0) with the Width and Height specified earlier
UpdateLayeredWindow(hwnd2, hdc2, 0, 0, Width, Height)

; Select the object back into the hdc
SelectObject(hdc2, obm2)

; Now the bitmap may be deleted
DeleteObject(hbm2)

; Also the device context related to the bitmap may be deleted
DeleteDC(hdc2)

; The graphics may now be deleted

Gdip_DeleteGraphics(G2)
; The bitmap we made from the image may be deleted

Gdip_DisposeImage(pBitmap2)
Return
;#######################################################################
WinSet, Transparent, [0-255], [1]
CheckWinActivePOE:
	GuiControlGet, focused_control, focus
	
Loop 2
{
	If(WinActive(poeWindowName))
		If (GuiON%A_Index% = 0) {
			
			GuiON%A_Index% := 0
			
		}
	If(!WinActive(poeWindowName))
		If (GuiON%A_Index% = 1)
		{
			Gui, %A_Index%: Hide
			GuiON%A_Index% := 0
		}
		
}
Return


f2::
If (GuiON1 = 1) {
Gui, 1: Hide
GuiON1 := 0
}

Else{
Gui, 1: Show, NA
GuiON1 := 1
}
return

f3::
If (GuiON2 = 1) {
Gui, 2: Hide
GuiON2 := 0
}

Else{
Gui, 2: Show, NA
GuiON2 := 1
}
return


Exit:
; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp


Return
