IfNotExist, files\config.ini
fileCreate()
else
fileRead()

fileCreate() {
iniWrite, !o, files\config.ini, OcultarVentana, hk
iniWrite, !m, files\config.ini, MostrarVentana, hk
iniWrite, !l, files\config.ini, ActivarMenú, hk
iniWrite, !q, files\config.ini, ActivarMenúDeOpciones, hk
iniWrite, !c, files\config.ini, CopiarRutaDelArchivoAlPortapapeles, hk
iniWrite, ^!1, files\config.ini, Favorita1, hk
iniWrite, ^!2, files\config.ini, Favorita2, hk
iniWrite, ^!3, files\config.ini, Favorita3, hk
iniWrite, ^!r, files\config.ini, ResetearFavoritos, hk
iniWrite, ^f1, files\config.ini, SuspenderYReactivarElScript, hk
iniWrite, !b, files\config.ini, Buscador, hk
iniWrite, 0, files\sounds.ini, DesactivarLosSonidos, value
iniWrite, 0, files\sounds.ini, IniciarAlArrancar, value
fileRead()
}

fileRead() {
global sounds, runStart
iniRead, hide, files\config.ini, OcultarVentana, hk
Hotkey, %hide%, OcultarVentana, on
iniRead, show, files\config.ini, MostrarVentana, hk
Hotkey, %show%, MostrarVentana, on
iniRead, pc, files\config.ini, CopiarRutaDelArchivoAlPortapapeles, hk
hotkey, %pc%, CopiarRutaDelArchivoAlPortapapeles, on
iniRead, mn, files\config.ini, ActivarMenú, hk
hotkey, %mn%, mwt_menuShow, on
iniRead, mc, files\config.ini, ActivarMenúDeOpciones, hk
hotkey, %mc%, mwt_menuConfigShow, on
iniRead, sounds, files\sounds.ini, DesactivarLosSonidos, value
iniRead, runStart, files\sounds.ini, IniciarAlArrancar, value
iniRead, ft1, files\config.ini, Favorita1, hk
hotkey, %ft1%, Favorita1, on
iniRead, ft2, files\config.ini, Favorita2, hk
hotkey, %ft2%, Favorita2, on
iniRead, ft3, files\config.ini, Favorita3, hk
hotkey, %ft3%, Favorita3, on
iniRead, ftr, files\config.ini, ResetearFavoritos, hk
hotkey, %ftr%, ResetearFavoritos, on
iniRead, suspender, files\config.ini, SuspenderYReactivarElScript, hk
hotkey, %suspender%, SuspenderYReactivarElScript, on
iniRead, buscador, files\config.ini, Buscador, hk
hotkey, %buscador%, buscador, on
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

#SingleInstance Force

OnExit, mwt_RestoreAllThenExit
w1:="",w2:="",w3:=""

Menu, Tray, NoStandard
menu, tray, tip, Administrador de ventanas
Menu, Tray, Add, Salir y mostrar todo, mwt_RestoreAllThenExit
Menu, Tray, Add, Mostrar todas las ventanas ocultas, mwt_RestoreAll
;Menu, Tray, Add
menu, config, add, Desactivar los sonidos del script, soundsToggle
menu, config, add, Ejecutar el script al iniciar el sistema, loginToggle

webs := "&Google,&Youtube,&Wikipedia,&Real academia española,&Tecnoconocimiento accesible"
loop, parse, webs, `,
menu, buscador, add,% a_loopField, search

if sounds = 0
menu, config, unCheck, Desactivar los sonidos del script
else
menu, config, check, Desactivar los sonidos del script

if runStart = 1
menu, config, check, Ejecutar el script al iniciar el sistema
else
menu, config, unCheck, Ejecutar el script al iniciar el sistema

mwt_MaxLength = 260

return

buscador:
sleep 50
inputBox, palabras, Ingrese los términos de búsqueda
menu, buscador, show
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
iniWrite, %newHK%, files\config.ini, %comando%, hk
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

mwt_menuConfigShow:
menu, config, show
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

loginToggle:
if runStart = 0
{
iniWrite, 1, files\sounds.ini, IniciarAlArrancar, value
fileCreateShortcut, %a_workingDir%\setup.exe, %a_startMenuCommon%\Programs\StartUp\AdministradorDeVentanas.lnk, %a_workingDir%
}
else {
iniWrite, 0, files\sounds.ini, IniciarAlArrancar, value
fileDelete, %a_startMenuCommon%\Programs\StartUp\AdministradorDeVentanas.lnk
}
reload
return

soundsToggle:
if sounds = 0
iniWrite, 1, files\sounds.ini, DesactivarLosSonidos, value
else
iniWrite, 0, files\sounds.ini, DesactivarLosSonidos, value
reload

+f1::
commandList:
gui, List:Default
Gui, List:Add, ListView,, Comando|Atajo: 
iniRead, file, files\config.ini
loop, parse, file, `n`r
{
iniRead, content, files\config.ini,% a_loopField, hk
content := strReplace(content, "^", "control, ")
content := strReplace(content, "+", "shift, ")
content := strReplace(content, "!", "alt, ")
LV_Add("",a_loopField,content)
}
gui, List:add, button, gconfig, Cambiar el atajo de teclado
gui, list:show,, Lista de comandos
return

config:
fila := lv_getNext()
lv_getText(comando, fila)
iniRead, oldHK, files\config.ini, %comando%, hk
gui, list:destroy
gui, config:default
gui, config:add, text,, Ingresa un nuevo atajo de teclado
gui, config:add, hotKey, vnewHK, %oldHK%
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

SuspenderYReactivarElScript:
suspend
speak((t:=!t)? "Script suspendido" : "Script reactivado")
return

#if winActive("Lista de comandos")
esc::
winClose

search(itemName, itemPos, menuName) {
global palabras
links := ["https://www.google.com/search?q=", "https://www.youtube.com/results?search_query=", "https://es.wikipedia.org/wiki/", "https://dle.rae.es/", "https://tecnoconocimientoaccesible.blogspot.com/search?q="]
run % links[itemPos] palabras
}

#if