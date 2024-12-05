#Persistent
#SingleInstance Force

; Переменные для хранения настроек
global interval := 100  ; Задержка по умолчанию в миллисекундах
global targetWindow := ""
global selectedKey := "LShift"  ; Клавиша по умолчанию
global targetWindowId := ""

; Создание GUI
Gui, Add, Text,, Выберите задержку (в мс):
Gui, Add, Edit, vIntervalInput w150, %interval%
Gui, Add, Text,, Выберите окно:
Gui, Add, ComboBox, vWindowChoice w200, % GetWindowList()
Gui, Add, Text,, Выберите клавишу:
Gui, Add, DropDownList, vKeyChoice w150, Alt|Shift|Ctrl
Gui, Add, Button, gStartClicker w100, Запустить
Gui, Add, Button, gStopClicker w100, Остановить
Gui, Show,, Кликер

return

; Получение списка окон
GetWindowList() {
    WinGet, windows, List
    list := ""
    Loop %windows%
    {
        WinGetTitle, title, % "ahk_id " windows%A_Index%
        if (title != "")
            list .= title "|"
    }
    return list
}

; Начало работы авто-кликера
StartClicker:
    Gui, Submit, NoHide  ; Получить значения из GUI
    interval := IntervalInput
    GuiControlGet, targetWindow,, WindowChoice
    GuiControlGet, selectedKey,, KeyChoice

    if (targetWindow = "")
    {
        MsgBox, Выберите окно для работы!
        return
    }

    ; Найти идентификатор выбранного окна
    WinGet, targetWindowId, ID, %targetWindow%
    if (targetWindowId = "")
    {
        MsgBox, Невозможно найти указанное окно.
        return
    }

    ; Установить клавишу
    selectedKey := (selectedKey = "Alt" ? "LAlt" : (selectedKey = "Shift" ? "LShift" : "LCtrl"))

    ; Сворачиваем окно, но оно остаётся доступным для переключения
    WinMinimize, ahk_id %targetWindowId%

    ; Включить авто-клик
    SetTimer, AutoClick, %interval%
    return

; Остановка авто-кликера
StopClicker:
    SetTimer, AutoClick, Off
    return

; Основная функция авто-кликера
AutoClick:
    ; Проверить, существует ли целевое окно
    if (WinExist("ahk_id " targetWindowId)) {
        ; Отправить нажатие выбранной клавиши в выбранное окно без блокировки фокуса
        ControlSend,, {%selectedKey% Down}{%selectedKey% Up}, ahk_id %targetWindowId%
    } else {
        SetTimer, AutoClick, Off
        MsgBox, Целевое окно закрыто. Кликер остановлен.
    }
    return

GuiClose:
    ExitApp
