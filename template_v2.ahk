#SingleInstance Force
#NoEnv ; Рекомендуется для совместимости с будущими версиями AutoHotkey
SendMode Input ; Рекомендуется для новых скриптов
SetWorkingDir %A_ScriptDir% ; Устанавливает рабочую директорию
SetBatchLines -1 ; Максимальная скорость выполнения
FileEncoding, UTF-8 
; Глобальные переменные
global targetWindow := ""
global isRunning := false
global delay := 5000 ; Задержка между циклами в мс
global isPaused := false

global title_select_window := "Select the window for automation:"
global title_selected_window := "Window not selected"
global title_delay := "Delay between cycles (ms):"
global title_start := "Start (F9)"
global title_stop := "Stop (F12)"
global title_pause := "Pause/Continue (F10)"
global title_status := "Ready to work"
; Создаем GUI для выбора параметров

Gui, Font, s10, Times New Roman
Gui, Add, Text, x10 y10 w250, %title_select_window_utf%
Gui, Add, Button, x10 y30 w250 h30 gSelectWindow, %title_select_window%
Gui, Add, Text, x10 y70 w250 vSelectedWindowText, %title_selected_window%
Gui, Add, Text, x10 y90 w250, %title_delay%
Gui, Add, Edit, x10 y110 w250 vDelayEdit, %delay%
Gui, Add, Button, x10 y140 w120 h30 gStartScript, Start (F9)
Gui, Add, Button, x140 y140 w120 h30 gStopScript, Stop (F12)
Gui, Add, Button, x10 y180 w250 h30 gPauseScript, Pause/Continue (F10)
Gui, Add, Text, x10 y220 w250 vStatusText c0000FF, Ready to work
Gui, Show, w270 h250, Automation of actions

; Горячие клавиши
F9::
    Gosub, StartScript
return

F12::
    Gosub, StopScript
return

F10::
    Gosub, PauseScript
return

; Выбор целевого окна
SelectWindow:
    Gui, +OwnDialogs
    MsgBox, 0, Select a window, Click OK and then left-click on the desired window
    
    ; Запоминаем текущее состояние сочетания клавиш
    Hotkey, LButton, SelectWindowClick, On
return

; Обработка клика по окну
SelectWindowClick:
    Hotkey, LButton, Off
    MouseGetPos,,, windowId
    WinGetTitle, windowTitle, ahk_id %windowId%
    WinGetClass, windowClass, ahk_id %windowId%
    
    ; Формируем информацию о выбранном окне
    targetWindow := windowTitle . " ahk_class " . windowClass
    
    ; Обновляем информацию в GUI
    GuiControl,, SelectedWindowText, % "Selected: " . windowTitle
    
    ; Обновляем статус
    GuiControl,, StatusText, Window selected. Ready to start.
return

; Запуск скрипта
StartScript:
    ; Проверяем, выбрано ли окно
    if (targetWindow = "") {
        MsgBox, Please, first select the target window.
        return
    }
    
    ; Получаем значение задержки из поля ввода
    GuiControlGet, delay,, DelayEdit
    
    ; Обновляем статус
    GuiControl,, StatusText, Running...
    GuiControl, +c008000, StatusText
    
    ; Запускаем выполнение в отдельном потоке
    isRunning := true
    isPaused := false
    SetTimer, RunMainLoop, -1
return

; Остановка скрипта
StopScript:
    isRunning := false
    isPaused := false
    
    ; Обновляем статус
    GuiControl,, StatusText, Stopped.
    GuiControl, +c0000FF, StatusText
    
    ; Убираем все всплывающие подсказки
    ToolTip
return

; Пауза/Продолжение скрипта
PauseScript:
    if (isRunning) {
        isPaused := !isPaused
        
        if (isPaused) {
            ; Обновляем статус на "Пауза"
            GuiControl,, StatusText, Paused. Click F10 to continue.
            GuiControl, +cFF8000, StatusText
            ToolTip, Execution paused., 100, 100
        } else {
            ; Обновляем статус на "Выполнение"
            GuiControl,, StatusText, Running...
            GuiControl, +c008000, StatusText
            ToolTip
        }
    }
return

; Основной цикл выполнения
RunMainLoop:
    while (isRunning) {
        ; Проверка паузы
        while (isPaused && isRunning) {
            Sleep, 100
        }
        
        if (!isRunning) {
            break
        }
        
        SetTitleMatchMode, 2
        CoordMode, Mouse, Window
        
        ; Проверяем существование целевого окна
        IfWinNotExist, %targetWindow%
        {
            ; Информируем пользователя, что окно не найдено
            ToolTip, Target window not found. Waiting..., 100, 100
            Sleep, 2000
            continue
        }
        
        ; Активируем целевое окно
        WinActivate, %targetWindow%
        WinWaitActive, %targetWindow%,, 5
        if (ErrorLevel) {
            ToolTip, Failed to activate the window., 100, 100
            Sleep, 2000
            continue
        }
        
        ; =========================================
        ;       Здесь вставляешь свой код
        ; =========================================
        
                
        ; Добавляем информационное сообщение о завершении цикла
        ToolTip, Цикл завершен. Ожидание %delay% мс перед следующим запуском..., 100, 100
        
        ; Ожидаем указанное время перед следующим выполнением цикла
        countDown := delay
        while (countDown > 0 && isRunning && !isPaused) {
            ToolTip, Цикл завершен. Ожидание %countDown% мс перед следующим запуском..., 100, 100
            Sleep, 100
            countDown -= 100
        }
        
        ; Убираем информационное сообщение
        if (isRunning && !isPaused) {
            ToolTip
        }
    }
return

; Обработка закрытия GUI
GuiClose:
    isRunning := false
    ExitApp
return