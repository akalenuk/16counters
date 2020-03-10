.386
.model flat, stdcall
option casemap:none
WinMain proto :DWORD, :DWORD, :DWORD, :DWORD
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\winmm.inc
include \masm32\include\masm32.inc
include \masm32\include\advapi32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comdlg32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\winmm.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comdlg32.lib

.const
; 0-15 reserved for counters

; buttons
eB0 equ 100
eBN equ 101
eBW equ 102
eBC equ 103
eBT equ 104

; checkbox
eRealtimePrint equ 110

; labels
eL03 equ 130
eL47 equ 131
eL8B equ 132
eLCF equ 133

; limits
MAX_FILE_NAME_SIZE equ 260
MAX_COUNTERS equ 16

.data 
; mandatories
ClassName db "SimpleWinClass", 0
AppName  db " ", 0
MenuName db "NoMenu", 0
ButtonClassName db "button", 0
StaticClassName db "static", 0
EditClassName db "edit", 0

; buttons
sB0 db "0", 0
sBN db "N", 0
sBW db "W", 0
sBC db "C", 0
sBT db "T", 0

; checkbox
sRealtimePrint db "realtime", 0

; labels
s03 db "0-3", 0
s47 db "4-7", 0
s8B db "8-B", 0
sCF db "C-F", 0

; layout
sEOL db 13, 10, 0
sTab db 9, 0
sZero db "0", 0

; program handler dialog
sCopyToClipboard db "Copy to clipboard?", 0

; C-style send message dialog
sCLeft  db "SendMessage((HWND)", 0
sCRight db ", WM_USER, 'I', 0);", 0

; realtime printing flag
do_realtime_print db 0

.data?
; mandatories
hInstance HINSTANCE ?
CommandLine LPSTR ?

; button handlers
hB0 HWND ?
hBN HWND ?
hBW HWND ?
hBC HWND ?
hBT HWND ?

; checkbox
hRealtimePrint HWND ?

; counter handlers
hCounterHandlers HWND 16 dup(?)
counter_values DWORD 16 dup(?)
counter_timers DWORD 16 dup(?)

; text buffers
TextBuffer db 512 dup(?)
SmallerBuffer db 16 dup(?)
LargerBuffer db 65536 dup(?)

; clipboard
ClipboardMemoryHandler DWORD ?
ClipboardMemoryAddress DWORD ?

.code
start:
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke GetCommandLine
	invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
	local wc:WNDCLASSEX
	local msg:MSG
	local hwnd:HWND
	mov wc.cbSize, SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, offset WndProc
	mov wc.cbClsExtra, NULL
	mov wc.cbWndExtra, NULL
	push hInst
	pop wc.hInstance
	mov wc.hbrBackground, COLOR_BTNFACE+1
	mov wc.lpszMenuName, offset MenuName
	mov wc.lpszClassName, offset ClassName
	invoke LoadIcon, hInstance, 500
	mov wc.hIcon, eax
	invoke LoadIcon, hInstance, 501
	mov wc.hIconSm, eax
	invoke LoadCursor, NULL, IDC_ARROW
	mov wc.hCursor, eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx, WS_EX_LEFT, addr ClassName, addr AppName, \
		WS_OVERLAPPEDWINDOW - WS_MAXIMIZEBOX, CW_USEDEFAULT, \
		CW_USEDEFAULT, 420, 160, NULL, NULL, \
		hInst, NULL
	mov hwnd, eax
	invoke ShowWindow, hwnd, SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.while TRUE
		invoke GetMessage, addr msg, NULL, 0, 0
		.break .if (!eax)
		invoke TranslateMessage, addr msg
		invoke DispatchMessage, addr msg
	.endw
	mov eax, msg.wParam
	ret
WinMain endp


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	local rect:RECT
	local dWnd:HWND
	local syst:SYSTEMTIME
	local hKey:DWORD
	local Disp:DWORD
	local i:DWORD
	local x:DWORD
	local y:DWORD
	
	.if uMsg==WM_DESTROY
		invoke PostQuitMessage, NULL
	; Setting up UI
	.elseif uMsg==WM_CREATE
		invoke dwtoa, hWnd, addr SmallerBuffer
		invoke SetWindowText, hWnd, addr SmallerBuffer

		; set initial window position  
		invoke GetDesktopWindow
		mov dWnd, eax
		invoke GetWindowRect, dWnd, addr rect
		mov eax, rect.right
		sub eax, 500
		invoke SetWindowPos, hWnd, HWND_TOPMOST, eax, 45, 0, 0, SWP_NOSIZE

		; counters
		mov i, 0
		.repeat
			mov eax, i
			shr eax, 2
			mov ebx, 22
			mul ebx
			add eax, 30
			mov y, eax

			mov eax, i
			and eax, 11b
			mov ebx, 88
			mul ebx
			add eax, 42
			mov x, eax

			invoke CreateWindowEx, WS_EX_CLIENTEDGE, addr EditClassName, addr sZero, \
				WS_CHILD or WS_VISIBLE or ES_LEFT or ES_AUTOHSCROLL, \
				x, y, 84, 18, hWnd, i, hInstance, NULL
			mov esi, offset hCounterHandlers
			mov ecx, i
			mov [esi + ecx*4], eax
			inc i
		.until i==MAX_COUNTERS

		; labels
		invoke CreateWindowEx, NULL, addr StaticClassName, addr s03, \
			WS_CHILD or WS_VISIBLE, \
			15, 32, 25, 20, hWnd, eL03, hInstance, NULL
		invoke CreateWindowEx, NULL, addr StaticClassName, addr s47, \
			WS_CHILD or WS_VISIBLE, \
			15, 54, 25, 20, hWnd, eL47, hInstance, NULL
		invoke CreateWindowEx, NULL, addr StaticClassName, addr s8B, \
			WS_CHILD or WS_VISIBLE, \
			15, 76, 25, 20, hWnd, eL8B, hInstance, NULL
		invoke CreateWindowEx, NULL, addr StaticClassName, addr sCF, \
			WS_CHILD or WS_VISIBLE, \
			15, 98, 25, 20, hWnd, eLCF, hInstance, NULL

		; buttons
		invoke CreateWindowEx, NULL, addr ButtonClassName, addr sB0, \
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
			42, 6, 21, 21, hWnd, eB0, hInstance, NULL
		mov hB0, eax

		invoke CreateWindowEx, NULL, addr ButtonClassName, addr sBN, \
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
			64, 6, 21, 21, hWnd, eBN, hInstance, NULL
		mov hBN, eax

		invoke CreateWindowEx, NULL, addr ButtonClassName, addr sBW, \
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
			166, 2, 21, 21, hWnd, eBW, hInstance, NULL
		mov hBW, eax

		invoke CreateWindowEx, NULL, addr ButtonClassName, addr sBC, \
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
			188, 2, 21, 21, hWnd, eBC, hInstance, NULL
		mov hBC, eax

		invoke CreateWindowEx, NULL, addr ButtonClassName, addr sBT, \
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
			210, 6, 21, 21, hWnd, eBT, hInstance, NULL
		mov hBT, eax

		; check box
		invoke CreateWindowEx, NULL, addr ButtonClassName, addr sRealtimePrint, \
			WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX , \
			88, 6, 72, 21, hWnd, eRealtimePrint, hInstance, NULL
		mov hRealtimePrint, eax

		invoke SendMessage, hRealtimePrint, BM_SETCHECK, 1, 0
		mov do_realtime_print, 1


	; Reacting on messages
	.elseif uMsg==WM_USER
		; two kinds of interfaces
		.if wParam<MAX_COUNTERS
			mov eax, wParam
			mov i, eax   ; (..., 4, 123) - (counter, value)
		.else
			mov eax, lParam
			mov i, eax   ; (..., 'T', 4) - (command, counter)
		.endif

		; set counter
		.if wParam<16
			mov esi, offset counter_values
			mov ecx, i
			mov eax, lParam
			mov [esi + ecx*4], eax
		; returns counter value
		.elseif wParam=='R'
			mov esi, offset hCounterHandlers
			mov ecx, i
			invoke GetWindowText, [esi + ecx*4], addr TextBuffer, 512
			invoke atodw, addr TextBuffer
			ret
		; increment counter
		.elseif wParam=='I'
			mov esi, offset counter_values
			mov ecx, i
			mov eax, [esi + ecx*4]
			inc eax
			mov [esi + ecx*4], eax
		; decrement counter
		.elseif wParam=='D'
			mov esi, offset counter_values
			mov ecx, i
			mov eax, [esi + ecx*4]
			dec eax
			mov [esi + ecx*4], eax
		; nullify counter
		.elseif wParam=='0'
			mov esi, offset counter_values
			mov ecx, i
			mov eax, 0
			mov [esi + ecx*4], eax
		; start timing
		.elseif wParam=='T'
			invoke GetTickCount 
			mov esi, offset counter_timers
			mov ecx, i
			mov [esi + ecx*4], eax
			ret
		; stop timing
		.elseif wParam=='S'
			invoke GetTickCount 
			mov esi, offset counter_timers
			mov ecx, i
			sub eax, [esi + ecx*4]
			mov esi, offset counter_values
			mov [esi + ecx*4], eax
		.endif

		; update counters
		.if do_realtime_print==1
			mov esi, offset counter_values
			mov ecx, i
			invoke dwtoa, [esi + ecx*4], addr TextBuffer
			mov esi, offset hCounterHandlers
			mov ecx, i
			invoke SetWindowText, [esi + ecx*4], addr TextBuffer
		.endif

	; Reacting on button
	.elseif uMsg==WM_COMMAND
		mov eax, wParam

		; nullify counters
		.if ax==eB0
			mov i, 0
			.repeat
				mov esi, offset counter_values
				mov ecx, i
				xor eax, eax
				mov [esi + ecx*4], eax
				mov esi, offset hCounterHandlers
				mov ecx, i
				invoke SetWindowText, [esi + ecx*4], addr sZero
				inc i
			.until i==MAX_COUNTERS
			invoke dwtoa, hWnd, addr TextBuffer
			invoke SetWindowText, hWnd, addr TextBuffer

		; update counters on screen (if no realtime printing on)
		.elseif ax==eBN
			mov i, 0
			.repeat
				mov esi, offset counter_values
				mov ecx, i
				invoke dwtoa, [esi + ecx*4], addr TextBuffer
				mov esi, offset hCounterHandlers
				mov ecx, i
				invoke SetWindowText, [esi + ecx*4], addr TextBuffer
				inc i
			.until i==MAX_COUNTERS

		; copy the handler to clipboard
		.elseif ax==eBW 
			invoke dwtoa, hWnd, addr SmallerBuffer
			invoke MessageBox, 0, addr SmallerBuffer, addr sCopyToClipboard, MB_YESNO
			.if eax==IDYES
				invoke OpenClipboard, 0
				invoke EmptyClipboard
				invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_DDESHARE, 32
				mov ClipboardMemoryHandler, eax
				invoke GlobalLock, ClipboardMemoryHandler
				mov ClipboardMemoryAddress, eax
				invoke lstrcpy, ClipboardMemoryAddress, addr SmallerBuffer
				invoke GlobalUnlock, ClipboardMemoryHandler
				invoke SetClipboardData, CF_TEXT, ClipboardMemoryHandler
				invoke CloseClipboard
			.endif

		; copy the handler with C-style messaging example
		.elseif ax==eBC
			invoke lstrcpy, addr TextBuffer, addr sCLeft
			invoke dwtoa, hWnd, addr SmallerBuffer
			invoke szCatStr, addr TextBuffer, addr SmallerBuffer
			invoke szCatStr, addr TextBuffer, addr sCRight
			invoke MessageBox, 0, addr TextBuffer, addr sCopyToClipboard, MB_YESNO
			.if eax==IDYES
				invoke OpenClipboard, 0
				invoke EmptyClipboard
				invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_DDESHARE, 64
				mov ClipboardMemoryHandler, eax
				invoke GlobalLock, ClipboardMemoryHandler
				mov ClipboardMemoryAddress, eax
				invoke lstrcpy, ClipboardMemoryAddress, addr TextBuffer
				invoke GlobalUnlock, ClipboardMemoryHandler
				invoke SetClipboardData, CF_TEXT, ClipboardMemoryHandler
				invoke CloseClipboard
			.endif

		; copy counters to the clipboard
		.elseif ax==eBT
			mov LargerBuffer[0], 0
			mov i, 0
			.repeat
				; value
				mov esi, offset hCounterHandlers
				mov ecx, i
				invoke GetWindowText, [esi + ecx*4], addr TextBuffer, 512
				invoke szCatStr, addr LargerBuffer, addr TextBuffer
				; separator
				.if i == 3
					invoke szCatStr, addr LargerBuffer, addr sEOL
				.elseif i == 7
					invoke szCatStr, addr LargerBuffer, addr sEOL
				.elseif i == 11
					invoke szCatStr, addr LargerBuffer, addr sEOL
				.else
					invoke szCatStr, addr LargerBuffer, addr sTab
				.endif
				inc i
			.until i==MAX_COUNTERS

			invoke MessageBox, 0, addr LargerBuffer, addr sCopyToClipboard, MB_YESNO
			.if eax==IDYES
				invoke OpenClipboard, 0
				invoke EmptyClipboard
				invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_DDESHARE, 64
				mov ClipboardMemoryHandler, eax
				invoke GlobalLock, ClipboardMemoryHandler
				mov ClipboardMemoryAddress, eax
				invoke lstrcpy, ClipboardMemoryAddress, addr LargerBuffer
				invoke GlobalUnlock, ClipboardMemoryHandler
				invoke SetClipboardData, CF_TEXT, ClipboardMemoryHandler
				invoke CloseClipboard
			.endif

		; realtime printing on/off
		.elseif ax==eRealtimePrint
			.if do_realtime_print==1 
				mov do_realtime_print, 0
			.else
				mov do_realtime_print, 1
			.endif 
  
		.endif
	.else
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.endif
	xor eax, eax
	ret
WndProc endp
end start
