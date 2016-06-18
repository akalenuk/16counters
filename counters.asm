.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
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
eE0 equ 7
eE1 equ 5
eE2 equ 6
eE3 equ 7
eE4 equ 5
eE5 equ 6
eE6 equ 7
eE7 equ 8
eE8 equ 9
eE9 equ 10
eE10 equ 11
eS0 equ 12
eS5 equ 13
eB equ 14
eB0 equ 15
eB1 equ 16
eB2 equ 17
eB3 equ 18
eB4 equ 19
eEmemo equ 20
eButton equ 21
eB5 equ 22
MAXSIZE equ 260
MEMSIZE equ 65536

.data 
ClassName db "SimpleWinClass",0
AppName  db " ",0
MenuName db "NoMenu",0
ButtonClassName db "button",0
StaticClassName db "static",0
EditClassName db "edit",0
sProgramWindowHandler db "Program window handler: ",0
sCopyToClipboard db "Copy to clipboard?",0
sProfileResults db "Shpion report:",0
sNone db 0
sEOL db 13,10,0
sSp db 9,0
sDash db "-",0
sTotal db "T:",0
s0 db " 0:",0
s1 db " 1:",0
s2 db " 2:",0
s3 db " 3:",0
s4 db " 4:",0
s5 db " 5:",0
s6 db " 6:",0
s7 db " 7:",0
s8 db " 8:",0
s9 db " 9:",0
s10 db "10: ",0
s100 db "100",0
sA db "0",0
sB db "%",0
sB0 db "0",0
sB1 db "N",0
sB2 db "W",0
sB3 db "F",0
sB4 db "Realtime print",0
sB5 db "C",0

cT DWORD 0
T0 DWORD 0
T1 DWORD 0
T2 DWORD 0
T3 DWORD 0
T4 DWORD 0
T5 DWORD 0
T6 DWORD 0
T7 DWORD 0
T8 DWORD 0
T9 DWORD 0
T10 DWORD 0
cA DWORD 0
A0 DWORD 0
A1 DWORD 0
A2 DWORD 0
A3 DWORD 0
A4 DWORD 0
A5 DWORD 0
A6 DWORD 0
A7 DWORD 0
A8 DWORD 0
A9 DWORD 0
A10 DWORD 0
q100 QWORD 100.0

ofn OPENFILENAME <>

FilterString	db "Shpion reports",0,"*.shr",0	
				db "All Files",0,"*.*",0,0
sLog db ".shr",0
Button_count DWORD 0

sWarning	db "--- Nothing's wrong ---",0
sJustBox	db "It's just a messagebox.",0

sCLeft	db "SendMessage((HWND)",0
sCRight	db ",WM_USER,,);",0

.data?
chE HWND ?
hE0 HWND ?
hE1 HWND ?
hE2 HWND ?
hE3 HWND ?
hE4 HWND ?
hE5 HWND ?
hE6 HWND ?
hE7 HWND ?
hE8 HWND ?
hE9 HWND ?
hE10 HWND ?
hB HWND ?
hButton HWND ?
hB0 HWND ?
hB1 HWND ?
hB2 HWND ?
hB3 HWND ?
hB4 HWND ?
hB5 HWND ?
hS0 HWND ?
hS5 HWND ?
hEmemo HWND ?
hInstance HINSTANCE ?
CommandLine LPSTR ?
buffer db 512 dup(?)
buf1 db 16 dup(?)
sHWND db 16 dup(?)
text db 65536 dup(?)
hand DWORD ?
addre DWORD ?
float QWORD ?
hFile HANDLE ?
hMemory HANDLE ?
pMemory DWORD ?
SizeReadWrite DWORD ?
rtflag db ?
fqTemp QWORD ?


.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax


WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	mov wc.cbSize,SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, OFFSET WndProc
	mov wc.cbClsExtra,NULL
	mov wc.cbWndExtra,NULL
	push hInst
	pop wc.hInstance
	mov wc.hbrBackground,COLOR_BTNFACE+1
	mov wc.lpszMenuName,OFFSET MenuName
	mov wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,hInstance,500
	mov wc.hIcon,eax
	invoke LoadIcon,hInstance,501
	mov wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,WS_EX_LEFT, ADDR ClassName, ADDR AppName,\
		WS_OVERLAPPEDWINDOW - WS_MAXIMIZEBOX,CW_USEDEFAULT,\
		CW_USEDEFAULT,206,220,NULL,NULL,\
		hInst,NULL
	mov hwnd,eax
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	.WHILE TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.ENDW
	mov eax,msg.wParam
	ret
WinMain endp


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL rect:RECT
	LOCAL dWnd:HWND
	LOCAL syst:SYSTEMTIME      
	LOCAL hKey:DWORD
	LOCAL Disp:DWORD
	.IF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	; Setting up UI
	.ELSEIF uMsg==WM_CREATE
		invoke dwtoa, hWnd, ADDR sHWND
		invoke SetWindowText,hWnd, ADDR sHWND

		; write window handler to clipboard
		invoke OpenClipboard,0
		invoke EmptyClipboard
		invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_DDESHARE,32
		mov hand,eax
		invoke GlobalLock,hand
		mov addre,eax
		invoke lstrcpy,addre, ADDR sHWND
		invoke GlobalUnlock,hand
		invoke SetClipboardData,CF_TEXT,hand
		invoke CloseClipboard

		; set initial window position  
		invoke GetDesktopWindow
		mov dWnd,eax
		invoke GetWindowRect,dWnd, ADDR rect
		mov eax,rect.right
		sub eax,224
		invoke SetWindowPos, hWnd, HWND_TOPMOST, eax, 45, 0, 0, SWP_NOSIZE ; 3 

		invoke CreateWindowEx,NULL, ADDR StaticClassName, ADDR sTotal,\
			WS_CHILD or WS_VISIBLE,\
			0, 1, 15, 20, hWnd, eS0, hInstance, NULL
		mov hS0,eax 

		invoke CreateWindowEx,NULL, ADDR StaticClassName, ADDR s5+1,\
			WS_CHILD or WS_VISIBLE,\
			7, 82, 15, 20, hWnd, eS5, hInstance, NULL
		mov hS5,eax 

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sNone,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or ES_MULTILINE or\
			ES_AUTOHSCROLL,\
			102, 0, 47, 179, hWnd, eEmemo, hInstance, NULL
		mov hEmemo,eax 

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			14, 0, 88, 18, hWnd, eE0, hInstance, NULL
		mov hE0,eax 

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			22, 17, 80, 18, hWnd, eE1, hInstance, NULL
		mov hE1,eax 

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			22, 33, 80, 18, hWnd, eE2, hInstance, NULL
		mov hE2,eax 

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			22, 49, 80, 18, hWnd, eE3, hInstance, NULL
		mov hE3,eax 

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			22, 65, 80, 18, hWnd, eE4, hInstance, NULL
		mov hE4,eax 

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			22, 81, 80, 18, hWnd, eE5, hInstance, NULL
		mov hE5,eax 

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			22, 97, 80, 18, hWnd, eE6, hInstance, NULL
		mov hE6,eax

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
		22, 113, 80, 18, hWnd, eE7, hInstance, NULL
		mov hE7,eax

		invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			22, 129, 80, 18, hWnd, eE8, hInstance, NULL
		mov hE8,eax

		invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
			WS_CHILD or WS_VISIBLE or ES_LEFT or\
			ES_AUTOHSCROLL,\
			22, 145, 80, 18, hWnd, eE9, hInstance, NULL
		mov hE9,eax

		invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sB0,\
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
			0, 19, 21, 21, hWnd, eB0, hInstance, NULL
		mov hB0,eax

		invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sB,\
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
			0,40,21,21,hWnd,eB,hInstance,NULL
		mov hB,eax

		invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sB1,\
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
			0,61,21,21,hWnd,eB1,hInstance,NULL
		mov hB1,eax

		invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sB2,\
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
			0,101,21,21,hWnd,eB2,hInstance,NULL
		mov hB2,eax

		invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sB3,\
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
			0,143,21,21,hWnd,eB3,hInstance,NULL
		mov hB3,eax

		invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sB5,\
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
			0,122,21,21,hWnd,eB5,hInstance,NULL
		mov hB5,eax

		invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sB4,\
			WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX ,\
			0,167,115,21,hWnd,eB4,hInstance,NULL
		mov hB4,eax
		
		invoke SendMessage,hB4,BM_SETCHECK,1,0
		mov rtflag, 1

		; button button
		invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR ButtonClassName,\
			WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
			115,167,84,21,hWnd,eButton,hInstance,NULL
		mov hButton,eax

	; Reacting on messages
	.ELSEIF uMsg==WM_USER
		.if wParam=='B';66
			mov eax, Button_count
			sub Button_count, eax
			ret
		.endif
		.if wParam=='S';83
			invoke MessageBox,0, ADDR sJustBox, ADDR sWarning,0
			ret
		.endif
		.if wParam=='Q';81
			invoke timeBeginPeriod,lParam
			ret
		.endif
		.if rtflag==1
			.IF wParam==0
				.IF lParam==0
					mov A0,0
					invoke dwtoa,A0, ADDR buffer
					invoke SetWindowText,hE0, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T0,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T0
					add A0,eax
					invoke dwtoa,A0, ADDR buffer
					invoke SetWindowText,hE0, ADDR buffer
				.ELSEIF lParam==3
					inc A0
					invoke dwtoa,A0, ADDR buffer
					invoke SetWindowText,hE0, ADDR buffer
				.ENDIF
			.ELSEIF wParam==1
				.IF lParam==0
					mov A1,0
					invoke dwtoa,A1, ADDR buffer
					invoke SetWindowText,hE1, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T1,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T1
					add A1,eax
					invoke dwtoa,A1, ADDR buffer
					invoke SetWindowText,hE1, ADDR buffer
				.ELSEIF lParam==3
					inc A1
					invoke dwtoa,A1, ADDR buffer
					invoke SetWindowText,hE1, ADDR buffer
				.ENDIF
			.ELSEIF wParam==2
				.IF lParam==0
					mov A2,0
					invoke dwtoa,A2, ADDR buffer
					invoke SetWindowText,hE2, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T2,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T2
					add A2,eax
					invoke dwtoa,A2, ADDR buffer
					invoke SetWindowText,hE2, ADDR buffer
				.ELSEIF lParam==3
					inc A2
					invoke dwtoa,A2, ADDR buffer
					invoke SetWindowText,hE2, ADDR buffer
				.ENDIF
			.ELSEIF wParam==3
				.IF lParam==0
					mov A3,0
					invoke dwtoa,A3, ADDR buffer
					invoke SetWindowText,hE3, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T3,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T3
					add A3,eax
					invoke dwtoa,A3, ADDR buffer
					invoke SetWindowText,hE3, ADDR buffer
				.ELSEIF lParam==3
					inc A3
					invoke dwtoa,A3, ADDR buffer
					invoke SetWindowText,hE3, ADDR buffer
				.ENDIF
			.ELSEIF wParam==4
				.IF lParam==0
					mov A4,0
					invoke dwtoa,A4, ADDR buffer
					invoke SetWindowText,hE4, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T4,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T4
					add A4,eax
					invoke dwtoa,A4, ADDR buffer
					invoke SetWindowText,hE4, ADDR buffer
				.ELSEIF lParam==3
					inc A4
					invoke dwtoa,A4, ADDR buffer
					invoke SetWindowText,hE4, ADDR buffer
				.ENDIF
			.ELSEIF wParam==5
				.IF lParam==0
					mov A5,0
					invoke dwtoa,A5, ADDR buffer
					invoke SetWindowText,hE5, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T5,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T5
					add A5,eax
					invoke dwtoa,A5, ADDR buffer
					invoke SetWindowText,hE5, ADDR buffer
				.ELSEIF lParam==3
					inc A5
					invoke dwtoa,A5, ADDR buffer
					invoke SetWindowText,hE5, ADDR buffer
				.ENDIF
			.ELSEIF wParam==6
				.IF lParam==0
					mov A6,0
					invoke dwtoa,A6, ADDR buffer
					invoke SetWindowText,hE6, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T6,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T6
					add A6,eax
					invoke dwtoa,A6, ADDR buffer
					invoke SetWindowText,hE6, ADDR buffer
				.ELSEIF lParam==3
					inc A6
					invoke dwtoa,A6, ADDR buffer
					invoke SetWindowText,hE6, ADDR buffer
				.ENDIF
			.ELSEIF wParam==7
				.IF lParam==0
					mov A7,0
					invoke dwtoa,A7, ADDR buffer
					invoke SetWindowText,hE7, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T7,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T7
					add A7,eax
					invoke dwtoa,A7, ADDR buffer
					invoke SetWindowText,hE7, ADDR buffer
				.ELSEIF lParam==3
					inc A7
					invoke dwtoa,A7, ADDR buffer
					invoke SetWindowText,hE7, ADDR buffer
				.ENDIF
			.ELSEIF wParam==8
				.IF lParam==0
					mov A8,0
					invoke dwtoa,A8, ADDR buffer
					invoke SetWindowText,hE8, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T8,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T8
					add A8,eax
					invoke dwtoa,A8, ADDR buffer
					invoke SetWindowText,hE8, ADDR buffer
				.ELSEIF lParam==3
					inc A8
					invoke dwtoa,A8, ADDR buffer
					invoke SetWindowText,hE8, ADDR buffer
				.ENDIF
			.ELSEIF wParam==9
				.IF lParam==0
					mov A9,0
					invoke dwtoa,A9, ADDR buffer
					invoke SetWindowText,hE9, ADDR buffer
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T9,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T9
					add A9,eax
					invoke dwtoa,A9, ADDR buffer
					invoke SetWindowText,hE9, ADDR buffer
				.ELSEIF lParam==3
					inc A9
					invoke dwtoa,A9, ADDR buffer
					invoke SetWindowText,hE9, ADDR buffer
				.ENDIF
			.ENDIF
		.else
			.IF wParam==0
				.IF lParam==0
					mov A0,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T0,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T0
					add A0,eax
				.ELSEIF lParam==3
					inc A0
				.ENDIF
			.ELSEIF wParam==1
				.IF lParam==0
					mov A1,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T1,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T1
					add A1,eax
				.ELSEIF lParam==3
					inc A1
				.ENDIF
			.ELSEIF wParam==2
				.IF lParam==0
					mov A2,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T2,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T2
					add A2,eax
				.ELSEIF lParam==3
					inc A2
				.ENDIF
			.ELSEIF wParam==3
				.IF lParam==0
					mov A3,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T3,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T3
					add A3,eax
				.ELSEIF lParam==3
					inc A3
				.ENDIF
			.ELSEIF wParam==4
				.IF lParam==0
					mov A4,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T4,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T4
					add A4,eax
				.ELSEIF lParam==3
					inc A4
				.ENDIF
			.ELSEIF wParam==5
				.IF lParam==0
					mov A5,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T5,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T5
					add A5,eax
				.ELSEIF lParam==3
					inc A5
				.ENDIF
			.ELSEIF wParam==6
				.IF lParam==0
					mov A6,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T6,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T6
					add A6,eax
				.ELSEIF lParam==3
					inc A6
				.ENDIF
			.ELSEIF wParam==7
				.IF lParam==0
					mov A7,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T7,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T7
					add A7,eax
				.ELSEIF lParam==3
					inc A7
				.ENDIF
			.ELSEIF wParam==8
				.IF lParam==0
					mov A8,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T8,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T8
					add A8,eax
				.ELSEIF lParam==3
					inc A8
				.ENDIF
			.ELSEIF wParam==9
				.IF lParam==0
					mov A9,0
				.ELSEIF lParam==1
					invoke GetTickCount 
					mov T9,eax
				.ELSEIF lParam==2
					invoke GetTickCount 
					sub eax,T9
					add A9,eax
				.ELSEIF lParam==3
					inc A9
				.ENDIF
			.ENDIF	    
		.endif

		.if rtflag==1
			.if wParam==10
				mov eax,lParam
				mov A0,eax
				invoke dwtoa,A0, ADDR buffer
				invoke SetWindowText,hE0, ADDR buffer
			.elseif wParam==11
				mov eax,lParam
				mov A1,eax
				invoke dwtoa,A1, ADDR buffer
				invoke SetWindowText,hE1, ADDR buffer
			.elseif wParam==12
				mov eax,lParam
				mov A2,eax
				invoke dwtoa,A2, ADDR buffer
				invoke SetWindowText,hE2, ADDR buffer
			.elseif wParam==13
				mov eax,lParam
				mov A3,eax
				invoke dwtoa,A3, ADDR buffer
				invoke SetWindowText,hE3, ADDR buffer
			.elseif wParam==14
				mov eax,lParam
				mov A4,eax
				invoke dwtoa,A4, ADDR buffer
				invoke SetWindowText,hE4, ADDR buffer
			.elseif wParam==15
				mov eax,lParam
				mov A5,eax
				invoke dwtoa,A5, ADDR buffer
				invoke SetWindowText,hE5, ADDR buffer
			.elseif wParam==16
				mov eax,lParam
				mov A6,eax
				invoke dwtoa,A6, ADDR buffer
				invoke SetWindowText,hE6, ADDR buffer
			.elseif wParam==17
				mov eax,lParam
				mov A7,eax
				invoke dwtoa,A7, ADDR buffer
				invoke SetWindowText,hE7, ADDR buffer
			.elseif wParam==18
				mov eax,lParam
				mov A8,eax
				invoke dwtoa,A8, ADDR buffer
				invoke SetWindowText,hE8, ADDR buffer
			.elseif wParam==19
				mov eax,lParam
				mov A9,eax
				invoke dwtoa,A9, ADDR buffer
				invoke SetWindowText,hE9, ADDR buffer
			.endif
		.else
			.if wParam==10
				mov eax,lParam
				mov A0,eax
			.elseif wParam==11
				mov eax,lParam
				mov A1,eax
			.elseif wParam==12
				mov eax,lParam
				mov A2,eax
			.elseif wParam==13
				mov eax,lParam
				mov A3,eax
			.elseif wParam==14
				mov eax,lParam
				mov A4,eax
			.elseif wParam==15
				mov eax,lParam
				mov A5,eax
			.elseif wParam==16
				mov eax,lParam
				mov A6,eax
			.elseif wParam==17
				mov eax,lParam
				mov A7,eax
			.elseif wParam==18
				mov eax,lParam
				mov A8,eax
			.elseif wParam==19
				mov eax,lParam
				mov A9,eax
			.endif
		.endif
	.ELSEIF uMsg==WM_SIZE
		invoke GetClientRect,hWnd, ADDR rect
		mov eax,rect.right
		sub eax,102
		invoke MoveWindow, hEmemo, 102 , 0, eax, 167, TRUE
	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam	  
		.IF ax==eB
			.IF A0==0
				mov eax,A1
				add eax,A2
				add eax,A3
				add eax,A4
				add eax,A5
				add eax,A6
				add eax,A7
				add eax,A8
				add eax,A9
				mov A0,eax
			.ENDIF
			invoke SetWindowText,hE0, ADDR s100
			  
			FINIT
			FILD A1
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE1, ADDR buffer

			FINIT
			FILD A2
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE2, ADDR buffer

			FINIT
			FILD A3
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE3, ADDR buffer

			FINIT
			FILD A4
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE4, ADDR buffer

			FINIT
			FILD A5
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE5, ADDR buffer

			FINIT
			FILD A6
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE6, ADDR buffer

			FINIT
			FILD A7
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE7, ADDR buffer

			FINIT
			FILD A8
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE8, ADDR buffer

			FINIT
			FILD A9
			FLD q100
			FMUL
			FILD A0
			FDIV
			FST float
			invoke FloatToStr2,float, ADDR buffer
			.if buffer[1]!='?'
				mov buffer[7],0
			.else
				mov buffer[0],'0'
				mov buffer[1],0
			.endif
			invoke SetWindowText,hE9, ADDR buffer
						
		.ELSEIF ax==eB0
			mov A0,0
			mov A1,0
			mov A2,0
			mov A3,0
			mov A4,0
			mov A5,0
			mov A6,0
			mov A7,0
			mov A8,0
			mov A9,0
			mov A10,0
			invoke SetWindowText,hE0, ADDR sA
			invoke SetWindowText,hE1, ADDR sA
			invoke SetWindowText,hE2, ADDR sA
			invoke SetWindowText,hE3, ADDR sA
			invoke SetWindowText,hE4, ADDR sA
			invoke SetWindowText,hE5, ADDR sA
			invoke SetWindowText,hE6, ADDR sA
			invoke SetWindowText,hE7, ADDR sA
			invoke SetWindowText,hE8, ADDR sA
			invoke SetWindowText,hE9, ADDR sA
			invoke dwtoa, hWnd, ADDR buffer
			invoke SetWindowText,hWnd, ADDR buffer
		.ELSEIF ax==eB1
			invoke dwtoa,A0,addr buffer
			invoke SetWindowText,hE0, ADDR buffer
			invoke dwtoa,A1,addr buffer
			invoke SetWindowText,hE1, ADDR buffer
			invoke dwtoa,A2,addr buffer
			invoke SetWindowText,hE2, ADDR buffer
			invoke dwtoa,A3,addr buffer
			invoke SetWindowText,hE3, ADDR buffer
			invoke dwtoa,A4,addr buffer
			invoke SetWindowText,hE4, ADDR buffer
			invoke dwtoa,A5,addr buffer
			invoke SetWindowText,hE5, ADDR buffer
			invoke dwtoa,A6,addr buffer
			invoke SetWindowText,hE6, ADDR buffer
			invoke dwtoa,A7,addr buffer
			invoke SetWindowText,hE7, ADDR buffer
			invoke dwtoa,A8,addr buffer
			invoke SetWindowText,hE8, ADDR buffer
			invoke dwtoa,A9,addr buffer
			invoke SetWindowText,hE9, ADDR buffer
		.ELSEIF ax==eB2 
			invoke lstrcpy, ADDR buffer, ADDR sProgramWindowHandler
			invoke dwtoa,hWnd,addr buf1
			invoke szCatStr, ADDR buffer, ADDR buf1
			invoke MessageBox,0, ADDR buffer, ADDR sCopyToClipboard,MB_YESNO
			.IF eax==IDYES
				invoke OpenClipboard,0
				invoke EmptyClipboard
				invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_DDESHARE,32
				mov hand,eax
				invoke GlobalLock,hand
				mov addre,eax
				invoke lstrcpy,addre, ADDR buf1
				invoke GlobalUnlock,hand
				invoke SetClipboardData,CF_TEXT,hand
				invoke CloseClipboard
			.ENDIF	
		.ELSEIF ax==eB3
			mov text[0],0
			invoke GetSystemTime,addr syst
			xor eax,eax
			mov ax,syst.wDay
			invoke dwtoa,eax,addr buffer
			invoke szCatStr,addr text, addr buffer
			invoke szCatStr,addr text, addr sDash
			xor eax,eax
			mov ax,syst.wMonth
			invoke dwtoa,eax,addr buffer
			invoke szCatStr,addr text, addr buffer
			invoke szCatStr,addr text, addr sDash
			xor eax,eax
			mov ax,syst.wYear
			invoke dwtoa,eax,addr buffer
			invoke szCatStr,addr text, addr buffer
			invoke szCatStr,addr text, addr sSp
			xor eax,eax
			mov ax,syst.wHour
			invoke dwtoa,eax,addr buffer
			invoke szCatStr,addr text, addr buffer
			invoke szCatStr,addr text,addr sDash
			xor eax,eax
			mov ax,syst.wMinute
			invoke dwtoa,eax,addr buffer
			invoke szCatStr,addr text, addr buffer
			invoke szCatStr,addr text,addr sEOL
			invoke szCatStr,addr text,addr sProfileResults
			invoke szCatStr,addr text,addr sEOL
			invoke szCatStr,addr text,addr sEOL

			invoke szCatStr, ADDR text, ADDR s0
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE0, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,0,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,0, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL
			invoke szCatStr, ADDR text, ADDR s1
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE1, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,1,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,1, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke szCatStr, ADDR text, ADDR s2
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE2, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,2,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,2, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke szCatStr, ADDR text, ADDR s3
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE3, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,3,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,3, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke szCatStr, ADDR text, ADDR s4
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE4, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,4,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,4, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke szCatStr, ADDR text, ADDR s5
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE5, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,5,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,5, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke szCatStr, ADDR text, ADDR s6
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE6, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,6,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,6, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke szCatStr, ADDR text, ADDR s7
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE7, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,7,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,7, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke szCatStr, ADDR text, ADDR s8
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE8, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,8,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,8, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke szCatStr, ADDR text, ADDR s9
			invoke szCatStr, ADDR text, ADDR sSp
			invoke GetWindowText,hE9, ADDR buffer,512
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sSp
			invoke memfill, ADDR buffer,512,32
			invoke SendMessage,hEmemo,EM_LINELENGTH,9,0
			dec eax
			mov buffer[eax],0
			invoke SendMessage,hEmemo,EM_GETLINE,9, ADDR buffer
			invoke szCatStr, ADDR text, ADDR buffer
			invoke szCatStr, ADDR text, ADDR sEOL

			invoke RtlZeroMemory,addr ofn,sizeof ofn
			mov ofn.lStructSize,SIZEOF ofn
			push hWnd
			pop  ofn.hWndOwner
			push hInstance
			pop  ofn.hInstance
			mov  ofn.lpstrFilter, OFFSET FilterString
			mov  ofn.lpstrFile, OFFSET buffer
			mov  ofn.nMaxFile,MAXSIZE
			mov buffer[0],0
			mov ofn.Flags,OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
			invoke GetSaveFileName, ADDR ofn
			.if eax==TRUE
				invoke szCatStr, ADDR buffer, ADDR sLog
				invoke CreateFile, ADDR buffer,\
					GENERIC_READ or GENERIC_WRITE ,\
					FILE_SHARE_READ or FILE_SHARE_WRITE,\
					NULL,CREATE_NEW,FILE_ATTRIBUTE_ARCHIVE,NULL
				mov hFile,eax
				invoke lstrlen, ADDR text
				invoke _lwrite,hFile, ADDR text,eax
				invoke CloseHandle,hFile
			.endif
		.ELSEIF ax==eB4
			.IF rtflag==1 
				mov rtflag,0
			.ELSE
				mov rtflag,1
			.ENDIF
		.ELSEIF ax==eB5
			invoke lstrcpy, ADDR buffer, ADDR sCLeft
			invoke dwtoa,hWnd,addr buf1
			invoke szCatStr, ADDR buffer, ADDR buf1
			invoke szCatStr, ADDR buffer, ADDR sCRight
			invoke MessageBox,0, ADDR buffer, ADDR sCopyToClipboard,MB_YESNO
			.IF eax==IDYES
				invoke OpenClipboard,0
				invoke EmptyClipboard
				invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_DDESHARE,64
				mov hand,eax
				invoke GlobalLock,hand
				mov addre,eax
				invoke lstrcpy,addre, ADDR buffer
				invoke GlobalUnlock,hand
				invoke SetClipboardData,CF_TEXT,hand
				invoke CloseClipboard
			.ENDIF	
		.ELSEIF ax==eButton
			inc Button_count
		.ENDIF
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp
end start
