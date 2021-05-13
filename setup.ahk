IfNotExist, files\sounds.ini
{
msgBox, 4, Bienvenido al administrador de ventanas: , ¿Quieres que el script se ejecute cada vez que se inicie el sistema?
ifMsgBox yes
startUp()
iniWrite, 0, files\sounds.ini, DesactivarLosSonidos, value
}

IfNotExist, config.ini
fileCreate()
else
fileRead()

fileCreate() {
iniWrite, !o, config.ini, OcultarVentana, hk
iniWrite, !m, config.ini, MostrarVentana, hk
iniWrite, !l, config.ini, ActivarMenú, hk
iniWrite, !c, config.ini, CopiarRutaDelArchivoAlPortapapeles, hk
iniWrite, ^!1, config.ini, Favorita1, hk
iniWrite, ^!2, config.ini, Favorita2, hk
iniWrite, ^!3, config.ini, Favorita3, hk
iniWrite, ^!r, config.ini, ResetearFavoritos, hk
fileRead()
}

fileRead() {
global sounds
iniRead, hide, config.ini, OcultarVentana, hk
Hotkey, %hide%, OcultarVentana, on
iniRead, show, config.ini, MostrarVentana, hk
Hotkey, %show%, MostrarVentana, on
iniRead, pc, config.ini, CopiarRutaDelArchivoAlPortapapeles, hk
hotkey, %pc%, CopiarRutaDelArchivoAlPortapapeles, on
iniRead, mn, config.ini, ActivarMenú, hk
hotkey, %mn%, mwt_menuShow, on
iniRead, sounds, files\sounds.ini, DesactivarLosSonidos, value
iniRead, ft1, config.ini, Favorita1, hk
hotkey, %ft1%, Favorita1, on
iniRead, ft2, config.ini, Favorita2, hk
hotkey, %ft2%, Favorita2, on
iniRead, ft3, config.ini, Favorita3, hk
hotkey, %ft3%, Favorita3, on
iniRead, ftr, config.ini, ResetearFavoritos, hk
hotkey, %ftr%, ResetearFavoritos, on
}

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if sounds = 0
soundPlay, files\start.mp3

mwt_MaxWindows = 50
#HotkeyModifierTimeout 100
SetWinDelay 10
SetKeyDelay 0

#SingleInstance  ; Allow only one instance of this script to be running.

OnExit, mwt_RestoreAllThenExit
w1:="",w2:="",w3:=""

Menu, Tray, NoStandard
menu, tray, tip, Administrador de ventanas
menu, tray, add, Desactivar los sonidos del script, soundsToggle
Menu, Tray, Add, Salir y mostrar todo, mwt_RestoreAllThenExit
Menu, Tray, Add, Mostrar todas las ventanas ocultas, mwt_RestoreAll
Menu, Tray, Add  ; Another separator line to make the above more special.

if sounds = 0
menu, tray, unCheck, Desactivar los sonidos del script
else
menu, tray, check, Desactivar los sonidos del script

mwt_MaxLength = 260

return

Favorita1:
if not w1
w1 := assignWindow()
else
activateWindow(w1)
return

Favorita2:
if not w2
w2 := assignWindow()
else
activateWindow(w2)
return

Favorita3:
if not w3
w3 := assignWindow()
else
activateWindow(w3)
return

save:
gui, config:submit, hide
if newHK
{
iniWrite, %newHK%, config.ini, %comando%, hk
reload
}
else {
msgBox, 0, Atención; , Este campo no puede quedar vacío, por favor ingrese un atajo.
gui, show,, Configuración
}
return

cancel:
gui, config:hide
return

CopiarRutaDelArchivoAlPortapapeles:
if sounds = 0
soundPlay, files\copy.mp3
sleep 50
send, ^c
sleep 50
path := clipboard
sleep 50
clipboard := path
return

mwt_menuShow:
menu, tray, show
return

OcultarVentana:
if sounds = 0
soundPlay, files\close.mp3
if mwt_WindowCount >= %mwt_MaxWindows%
{
    MsgBox No pueden ocultarse más de %mwt_MaxWindows% ventanas simultáneamente.
    return
}

WinWait, A,, 2
if ErrorLevel <> 0  ; It timed out, so do nothing.
    return

WinGet, mwt_ActiveID, ID
WinGetTitle, mwt_ActiveTitle
WinGetClass, mwt_ActiveClass
if mwt_ActiveClass in Shell_TrayWnd,Progman
{
    MsgBox El escritorio y la barra de tareas no se pueden ocultar.
    return
}
Send, !{esc}
WinHide

if mwt_ActiveTitle =
    mwt_ActiveTitle = ahk_class %mwt_ActiveClass%
StringLeft, mwt_ActiveTitle, mwt_ActiveTitle, %mwt_MaxLength%

Loop, %mwt_MaxWindows%
{
    if mwt_WindowTitle%a_index% = %mwt_ActiveTitle%
    {
        StringTrimLeft, mwt_ActiveIDShort, mwt_ActiveID, 2
        StringLen, mwt_ActiveIDShortLength, mwt_ActiveIDShort
        StringLen, mwt_ActiveTitleLength, mwt_ActiveTitle
        mwt_ActiveTitleLength += %mwt_ActiveIDShortLength%
        mwt_ActiveTitleLength += 1 ; +1 the 1 space between title & ID.
        if mwt_ActiveTitleLength > %mwt_MaxLength%
        {
            TrimCount = %mwt_ActiveTitleLength%
            TrimCount -= %mwt_MaxLength%
            StringTrimRight, mwt_ActiveTitle, mwt_ActiveTitle, %TrimCount%
        }
        mwt_ActiveTitle = %mwt_ActiveTitle% %mwt_ActiveIDShort%
        break
    }
}

mwt_AlreadyExists = n
Loop, %mwt_MaxWindows%
{
    if mwt_WindowID%a_index% = %mwt_ActiveID%
    {
        mwt_AlreadyExists = y
        break
    }
}

if mwt_AlreadyExists = n
{
    Menu, Tray, add, %mwt_ActiveTitle%, RestoreFromTrayMenu
				
    mwt_WindowCount += 1
    Loop, %mwt_MaxWindows%  ; Search for a free slot.
    {
        if mwt_WindowID%a_index% =  ; An empty slot was found.
        {
            mwt_WindowID%a_index% = %mwt_ActiveID%
            mwt_WindowTitle%a_index% = %mwt_ActiveTitle%
            break
        }
    }
}
return


RestoreFromTrayMenu:
if sounds = 0
soundPlay files\open.mp3
Menu, Tray, delete, %A_ThisMenuItem%
Loop, %mwt_MaxWindows%
{
    if mwt_WindowTitle%a_index% = %A_ThisMenuItem%  ; Match found.
    {
        StringTrimRight, IDToRestore, mwt_WindowID%a_index%, 0
        WinShow, ahk_id %IDToRestore%
        WinActivate ahk_id %IDToRestore%  ; Sometimes needed.
        mwt_WindowID%a_index% =  ; Make it blank to free up a slot.
        mwt_WindowTitle%a_index% =
        mwt_WindowCount -= 1
        break
    }
}
return


MostrarVentana:
if mwt_WindowCount > 0 
{
    StringTrimRight, IDToRestore, mwt_WindowID%mwt_WindowCount%, 0
    WinShow, ahk_id %IDToRestore%
    WinActivate ahk_id %IDToRestore%
    
    StringTrimRight, MenuToRemove, mwt_WindowTitle%mwt_WindowCount%, 0
    Menu, Tray, delete, %MenuToRemove%
    if sounds = 0
				soundPlay files\open.mp3
    mwt_WindowID%mwt_WindowCount% =
    mwt_WindowTitle%mwt_WindowCount% = 
    mwt_WindowCount -= 1
}
return


mwt_RestoreAllThenExit:
Gosub, mwt_RestoreAll
ExitApp


mwt_RestoreAll:
Loop, %mwt_MaxWindows%
{
    if mwt_WindowID%a_index% <>
    {
        StringTrimRight, IDToRestore, mwt_WindowID%a_index%, 0
        WinShow, ahk_id %IDToRestore%
        WinActivate ahk_id %IDToRestore%  ; Sometimes needed.
        StringTrimRight, MenuToRemove, mwt_WindowTitle%a_index%, 0
        Menu, Tray, delete, %MenuToRemove%
        mwt_WindowID%a_index% =  ; Make it blank to free up a slot.
        mwt_WindowTitle%a_index% =
        mwt_WindowCount -= 1
    }
    if mwt_WindowCount = 0
        break
}
if sounds = 0
soundPlay files\restore.mp3
return

soundsToggle:
if sounds = 0
iniWrite, 1, files\sounds.ini, DesactivarLosSonidos, value
else
iniWrite, 0, files\sounds.ini, DesactivarLosSonidos, value
reload
return

+f1::
commandList:
gui, List:Default
Gui, List:Add, ListView,, Comando|Atajo: 
iniRead, file, config.ini
loop, parse, file, `n`r
{
iniRead, content, config.ini,% a_loopField, hk
content := strReplace(content, "^", "control, ")
content := strReplace(content, "+", "shift, ")
content := strReplace(content, "!", "alt, ")
LV_Add("",a_loopField,content)
}
gui, List:add, button, gconfig, Cambiar el atajo de teclado
gui, list:show,, Lista de comandos
return

startUp() {
runWait cmd.exe /c mklink "%a_startMenuCommon%\programs\StartUp\AdministradorDeVentanas" "%a_workingDir%\setup.exe",, hide
}

config:
fila := lv_getNext()
lv_getText(comando, fila)
gui, list:destroy
gui, config:default
gui, config:add, text,, Ingresa un comando de teclado
gui, config:add, hotKey, vnewHK
gui, config:add, button, gSave, Guardar los cambios
gui, config:add, button, gCancel, Cancelar
gui, config:show,, Configuración
return

assignWindow() {
winGetTitle, title, a
speak("ventana asignada")
return title
}

activateWindow(window) {
if winExist(window)
winActivate
}

Speak(Str) {
	Process, Exist, jfw.exe
	If ErrorLevel != 0
		{
		Jaws := ComObjCreate("FreedomSci.JawsApi")
		Jaws.SayString(Str)
		}
	Else {
		return DllCall("files\nvdaControllerClient" A_PtrSize*8 ".dll\nvdaController_speakText", "wstr", Str)
		}
	}

ResetearFavoritos:
w1:="",w2:="",w3:=""
speak("favoritos reseteados")
return

#if winActive("Lista de comandos")
esc::
winClose

#if