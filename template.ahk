; Переменная для регулирования скорости выполнения
Playspeed := 1

SelectWindowTitle()
{
    ToolTip, Выберите окно...
    KeyWait, LButton, D
    MouseGetPos, , , id
    WinGetTitle, windowTitle, ahk_id %id%
    ToolTip
    return windowTitle
}

; Пример использования:
F1::
{
    selectedWindow := SelectWindowTitle()
    MsgBox, Выбранное окно: %selectedWindow%
    return
}


Loop
{
    
    SetTitleMatchMode, 2
    CoordMode, Mouse, Window
    
    ; Информация о целевом окне
    tt = Windows PowerShell ahk_class CASCADIA_HOSTING_WINDOW_CLASS ;  Windows PowerShell ahk_class CASCADIA_HOSTING_WINDOW_CLASS - заменить на своё окно
    
    IfWinNotExist, %tt%
    {
        Run, %tt%
        WinWait, %tt%,, 10  ; Ожидаем до 10 секунд для запуска
        if ErrorLevel  ; Если не удалось запустить
        {
            MsgBox, Не удалось запустить
            continue 
        }
    }
    
    
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
    WinWaitActive, %tt%
    
    ; =========================================
    ;       Здесь вставляешь свой код
    ; =========================================
    
    ; Добавляем информационное сообщение о завершении цикла
    ToolTip, Цикл завершен. Ожидание 60 секунд перед следующим запуском..., 100, 100
    
    ; Ожидаем 5 секунд перед следующим выполнением цикла
    Sleep, 5000
    
    ; Убираем информационное сообщение
    ToolTip
}