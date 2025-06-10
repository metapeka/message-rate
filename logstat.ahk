; ===============================================
; Twitch Chat Statistics Monitor v2.4 (Debug)
; AutoHotkey v2 Script
; ===============================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; Глобальные переменные
global LogFile := "TwitchChatLog.txt"
global ErrorLogFile := "log_errors.txt"
global SettingsFile := "setting_rate.ini"
global WordCount := 0
global CharCount := 0
global MessageCount := 0
global StartTime := A_TickCount
global LastActivityTime := A_TickCount
global StatsWindow := ""
global StatsText := ""
global TimerText := ""
global UpdateInterval := 1000
global InactivityTimeout := 30000

; Новые переменные для метрики "слов за 60 секунд"
global WordHistory := []
global WordsLast60Seconds := 0

; Переменные для метрики "сообщений за 60 секунд"
global MessageHistory := []
global MessagesLast60Seconds := 0

; Переменная для секундомера
global LastMessageTime := 0

; Функция логирования ошибок (перенесена в начало)
LogError(Message, Context := "")
{
    try {
        Timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        LogEntry := "[" . Timestamp . "] " . (Context != "" ? "[" . Context . "] " : "") . Message . "`n"
        FileAppend(LogEntry, ErrorLogFile)
    } catch {
        ; Игнорируем ошибки логирования
    }
}

; Инициализация с отладкой
try {
    LogError("=== ЗАПУСК ПРИЛОЖЕНИЯ ===", "INIT")
    
    LogError("Загрузка настроек...", "INIT")
    LoadSettings()
    LogError("Настройки загружены успешно", "INIT")
    
    LogError("Создание GUI...", "INIT")
    CreateStatsWindow()
    
    ; Проверяем, создалось ли окно
    if (StatsWindow == "" || !IsObject(StatsWindow)) {
        LogError("КРИТИЧЕСКАЯ ОШИБКА: GUI не создан!", "INIT")
        MsgBox("Критическая ошибка: не удалось создать окно статистики!", "Ошибка", "Icon!")
        ExitApp()
    }
    
    LogError("GUI создан успешно", "INIT")
    
    LogError("Запуск таймера обновления...", "INIT")
    SetTimer(UpdateStats, UpdateInterval)
    LogError("Таймер запущен успешно", "INIT")
    
    LogError("=== ПРИЛОЖЕНИЕ ЗАПУЩЕНО УСПЕШНО ===", "INIT")
    
} catch Error as e {
    LogError("КРИТИЧЕСКАЯ ОШИБКА ИНИЦИАЛИЗАЦИИ: " . e.Message, "INIT")
    MsgBox("Критическая ошибка инициализации: " . e.Message, "Ошибка", "Icon!")
    ExitApp()
}

; Функция загрузки настроек
LoadSettings()
{
    global UpdateInterval, InactivityTimeout
    try {
        LogError("Начало загрузки настроек", "LoadSettings")
        
        if (FileExist(SettingsFile)) {
            LogError("Файл настроек найден", "LoadSettings")
            ReadUpdateInterval := IniRead(SettingsFile, "Settings", "UpdateInterval", 1000)
            ReadInactivityTimeout := IniRead(SettingsFile, "Settings", "InactivityTimeout", 30000)
            
            if (ReadUpdateInterval < 100 || ReadUpdateInterval > 10000) {
                UpdateInterval := 1000
                IniWrite(UpdateInterval, SettingsFile, "Settings", "UpdateInterval")
                LogError("UpdateInterval исправлен на: " . UpdateInterval, "LoadSettings")
            } else {
                UpdateInterval := ReadUpdateInterval
            }
            
            if (ReadInactivityTimeout < 5000 || ReadInactivityTimeout > 300000) {
                InactivityTimeout := 30000
                IniWrite(InactivityTimeout, SettingsFile, "Settings", "InactivityTimeout")
                LogError("InactivityTimeout исправлен на: " . InactivityTimeout, "LoadSettings")
            } else {
                InactivityTimeout := ReadInactivityTimeout
            }
            
        } else {
            LogError("Файл настроек не найден, создаем новый", "LoadSettings")
            UpdateInterval := 1000
            InactivityTimeout := 30000
            
            IniWrite(UpdateInterval, SettingsFile, "Settings", "UpdateInterval")
            IniWrite(InactivityTimeout, SettingsFile, "Settings", "InactivityTimeout")
            FileAppend("`n; Настройки программы Twitch Chat Statistics Monitor`n", SettingsFile)
            FileAppend("; UpdateInterval - интервал обновления статистики в миллисекундах (100-10000)`n", SettingsFile)
            FileAppend("; 1000 мс = 1 секунда, 2000 мс = 2 секунды`n", SettingsFile)
            FileAppend("; InactivityTimeout - время бездействия для автосброса в миллисекундах (5000-300000)`n", SettingsFile)
            FileAppend("; 30000 мс = 30 секунд, 60000 мс = 1 минута, 300000 мс = 5 минут`n", SettingsFile)
        }
        
        LogError("Настройки загружены: UpdateInterval=" . UpdateInterval . ", InactivityTimeout=" . InactivityTimeout, "LoadSettings")
        
    } catch Error as e {
        LogError("Ошибка загрузки настроек: " . e.Message, "LoadSettings")
        UpdateInterval := 1000
        InactivityTimeout := 30000
    }
}

; Функция форматирования времени секундомера
FormatTimerDisplay(Milliseconds)
{
    try {
        if (Milliseconds <= 0) {
            return "00:00"
        }
        
        TotalSeconds := Floor(Milliseconds / 1000)
        Minutes := Floor(TotalSeconds / 60)
        Seconds := Mod(TotalSeconds, 60)
        
        return Format("{:02}:{:02}", Minutes, Seconds)
    } catch Error as e {
        LogError("Ошибка форматирования времени: " . e.Message, "FormatTimerDisplay")
        return "00:00"
    }
}

; Создание окна для статистики с улучшенной отладкой
CreateStatsWindow()
{
    global StatsWindow, StatsText, TimerText, UpdateInterval, InactivityTimeout
    
    try {
        LogError("Начало создания GUI", "CreateStatsWindow")
        
        UpdateIntervalSeconds := UpdateInterval / 1000.0
        InactivityTimeoutSeconds := InactivityTimeout / 1000.0
        
        LogError("Создание объекта Gui", "CreateStatsWindow")
        StatsWindow := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "Статистика чата v2.4")
        
        if (!IsObject(StatsWindow)) {
            LogError("ОШИБКА: Объект Gui не создан", "CreateStatsWindow")
            return ""
        }
        
        LogError("Добавление элементов в GUI", "CreateStatsWindow")
        StatsWindow.Add("Text", "w260 h30 Center", "Статистика печати:")
        ; Увеличиваем высоту для новых метрик
        StatsText := StatsWindow.Add("Text", "w260 h110 Center", "Слов в минуту: 0`nЗнаков в минуту: 0`nСообщений в минуту: 0`nСлов за 60 сек: 0`nСообщений за 60 сек: 0")
        
        ; Добавляем секундомер
        StatsWindow.Add("Text", "w260 h20 Center", "Время с последнего сообщения:")
        TimerText := StatsWindow.Add("Text", "w260 h30 Center c0x0000FF", "00:00")
        
        StatsWindow.Add("Text", "w260 h40 Center", "Обновление: " . UpdateIntervalSeconds . "с`nСброс при бездействии: " . InactivityTimeoutSeconds . "с")
        StatsWindow.Add("Text", "w260 h80 Center", "F8 - перезагрузить настройки`nF9 - открыть настройки`nF10 - диагностика`nF11 - лог ошибок`nF12 - сброс статистики")
        
        LogError("Установка обработчика события закрытия", "CreateStatsWindow")
        StatsWindow.OnEvent("Close", GuiCloseHandler)
        
        LogError("Отображение окна", "CreateStatsWindow")
        ; Увеличиваем высоту окна для секундомера
        StatsWindow.Show("x10 y10 w280 h330")
        
        LogError("GUI создан и отображен успешно", "CreateStatsWindow")
        return StatsWindow
        
    } catch Error as e {
        LogError("КРИТИЧЕСКАЯ ОШИБКА создания GUI: " . e.Message, "CreateStatsWindow")
        MsgBox("Ошибка создания GUI: " . e.Message, "Ошибка", "Icon!")
        return ""
    }
}

; Отдельный обработчик закрытия окна
GuiCloseHandler(*)
{
    LogError("Пользователь закрыл окно", "GuiClose")
    ExitApp()
}

; Функция для обновления истории слов за последние 60 секунд
UpdateWordHistory(WordsToAdd)
{
    global WordHistory
    try {
        CurrentTime := A_TickCount
        
        ; Добавляем новую запись
        if (WordsToAdd > 0) {
            WordHistory.Push({time: CurrentTime, words: WordsToAdd})
        }
        
        ; Удаляем записи старше 60 секунд (60000 миллисекунд)
        while (WordHistory.Length > 0 && (CurrentTime - WordHistory[1].time) > 60000) {
            WordHistory.RemoveAt(1)
        }
        
    } catch Error as e {
        LogError("Ошибка обновления истории слов: " . e.Message, "UpdateWordHistory")
    }
}

; Функция подсчета слов за последние 60 секунд
CalculateWordsLast60Seconds()
{
    global WordHistory, WordsLast60Seconds
    try {
        WordsLast60Seconds := 0
        for entry in WordHistory {
            WordsLast60Seconds += entry.words
        }
    } catch Error as e {
        LogError("Ошибка подсчета слов за 60 секунд: " . e.Message, "CalculateWordsLast60Seconds")
        WordsLast60Seconds := 0
    }
}

; Функция для обновления истории сообщений за последние 60 секунд
UpdateMessageHistory()
{
    global MessageHistory
    try {
        CurrentTime := A_TickCount
        
        ; Добавляем новую запись о сообщении
        MessageHistory.Push({time: CurrentTime})
        
        ; Удаляем записи старше 60 секунд (60000 миллисекунд)
        while (MessageHistory.Length > 0 && (CurrentTime - MessageHistory[1].time) > 60000) {
            MessageHistory.RemoveAt(1)
        }
        
    } catch Error as e {
        LogError("Ошибка обновления истории сообщений: " . e.Message, "UpdateMessageHistory")
    }
}

; Функция подсчета сообщений за последние 60 секунд
CalculateMessagesLast60Seconds()
{
    global MessageHistory, MessagesLast60Seconds
    try {
        CurrentTime := A_TickCount
        
        ; Удаляем устаревшие записи
        while (MessageHistory.Length > 0 && (CurrentTime - MessageHistory[1].time) > 60000) {
            MessageHistory.RemoveAt(1)
        }
        
        ; Подсчитываем количество сообщений
        MessagesLast60Seconds := MessageHistory.Length
        
    } catch Error as e {
        LogError("Ошибка подсчета сообщений за 60 секунд: " . e.Message, "CalculateMessagesLast60Seconds")
        MessagesLast60Seconds := 0
    }
}

; Функция подсчета слов, знаков и сообщений
UpdateCounts(Message)
{
    global WordCount, CharCount, MessageCount, LastActivityTime, LastMessageTime
    try {
        LastActivityTime := A_TickCount
        LastMessageTime := A_TickCount  ; Обновляем время последнего сообщения
        MessageCount += 1
        
        ; Обновляем историю сообщений для метрики "за 60 секунд"
        UpdateMessageHistory()
        
        Words := StrSplit(RegExReplace(Trim(Message), "\s+", " "), " ")
        CurrentWordCount := 0
        if (Words.Length = 1 && Words[1] = "")
            CurrentWordCount := 0
        else
            CurrentWordCount := Words.Length
        
        WordCount += CurrentWordCount
        CharCount += StrLen(Message)
        
        ; Обновляем историю слов для метрики "за 60 секунд"
        UpdateWordHistory(CurrentWordCount)
        
    } catch Error as e {
        LogError("Ошибка при подсчете: " . e.Message, "UpdateCounts")
    }
}

; Функция обновления статистики
UpdateStats()
{
    global WordCount, CharCount, MessageCount, StartTime, StatsText, TimerText, LastActivityTime, InactivityTimeout
    global WordHistory, WordsLast60Seconds, MessageHistory, MessagesLast60Seconds, LastMessageTime
    try {
        TimeSinceLastActivity := A_TickCount - LastActivityTime
        
        if (TimeSinceLastActivity > InactivityTimeout && (WordCount > 0 || CharCount > 0 || MessageCount > 0)) {
            WordCount := 0
            CharCount := 0
            MessageCount := 0
            StartTime := A_TickCount
            LastActivityTime := A_TickCount
            LastMessageTime := 0  ; Сбрасываем время последнего сообщения
            WordHistory := []  ; Очищаем историю слов
            MessageHistory := []  ; Очищаем историю сообщений
            WordsLast60Seconds := 0
            MessagesLast60Seconds := 0
            
            if (StatsText != "")
                StatsText.Value := "Слов в минуту: 0`nЗнаков в минуту: 0`nСообщений в минуту: 0`nСлов за 60 сек: 0`nСообщений за 60 сек: 0"
            
            if (TimerText != "")
                TimerText.Value := "00:00"
            
            LogError("Статистика сброшена автоматически", "UpdateStats")
            return
        }
        
        ; Обновляем секундомер
        if (LastMessageTime > 0 && TimerText != "") {
            TimeSinceLastMessage := A_TickCount - LastMessageTime
            TimerText.Value := FormatTimerDisplay(TimeSinceLastMessage)
        } else if (TimerText != "") {
            TimerText.Value := "00:00"
        }
        
        ; Обновляем историю слов и сообщений (удаляем старые записи)
        UpdateWordHistory(0)
        CalculateWordsLast60Seconds()
        CalculateMessagesLast60Seconds()
        
        ElapsedMinutes := (A_TickCount - StartTime) / 60000.0
        if (ElapsedMinutes > 0 && (WordCount > 0 || CharCount > 0 || MessageCount > 0))
        {
            WordsPerMinute := Round(WordCount / ElapsedMinutes, 2)
            CharsPerMinute := Round(CharCount / ElapsedMinutes, 2)
            MessagesPerMinute := Round(MessageCount / ElapsedMinutes, 2)
            StatsTextValue := "Слов в минуту: " . WordsPerMinute . "`nЗнаков в минуту: " . CharsPerMinute . "`nСообщений в минуту: " . MessagesPerMinute . "`nСлов за 60 сек: " . WordsLast60Seconds . "`nСообщений за 60 сек: " . MessagesLast60Seconds
            
            if (StatsText != "")
                StatsText.Value := StatsTextValue
        } else {
            if (StatsText != "")
                StatsText.Value := "Слов в минуту: 0`nЗнаков в минуту: 0`nСообщений в минуту: 0`nСлов за 60 сек: " . WordsLast60Seconds . "`nСообщений за 60 сек: " . MessagesLast60Seconds
        }
    } catch Error as e {
        LogError("Ошибка в UpdateStats: " . e.Message, "UpdateStats")
    }
}

; Перехват Enter
$Enter::
{
    try {
        ActiveWindow := WinGetTitle("A")
        
        try {
            ControlText := ControlGetText(ControlGetFocus("A"), "A")
        } catch {
            ControlText := ""
        }
        
        if (ControlText != "") {
            UpdateCounts(ControlText)
            
            try {
                Timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
                LogEntry := "[" . Timestamp . "] [" . ActiveWindow . "] " . ControlText . "`n"
                FileAppend(LogEntry, LogFile)
            } catch Error as e {
                LogError("Ошибка записи в лог: " . e.Message, "Enter Handler")
            }
        }
        
        Send("{Enter}")
    } catch Error as e {
        LogError("Ошибка в обработчике Enter: " . e.Message, "Enter Handler")
        Send("{Enter}")
    }
    return
}

; Горячие клавиши
$F8::
{
    global StatsWindow
    try {
        LoadSettings()
        SetTimer(UpdateStats, 0)
        SetTimer(UpdateStats, UpdateInterval)
        
        if (StatsWindow != "") {
            StatsWindow.Destroy()
            CreateStatsWindow()
        }
        
        UpdateIntervalSeconds := UpdateInterval / 1000.0
        InactivityTimeoutSeconds := InactivityTimeout / 1000.0
        
        MsgBox("Настройки перезагружены!`nИнтервал обновления: " . UpdateIntervalSeconds . " сек`nТайм-аут бездействия: " . InactivityTimeoutSeconds . " сек", "Настройки", "T3")
        LogError("Настройки перезагружены", "F8 Handler")
    } catch Error as e {
        LogError("Ошибка перезагрузки настроек: " . e.Message, "F8 Handler")
    }
    return
}

$F12::
{
    global WordCount, CharCount, MessageCount, StartTime, LastActivityTime, StatsText, TimerText
    global WordHistory, WordsLast60Seconds, MessageHistory, MessagesLast60Seconds, LastMessageTime
    try {
        WordCount := 0
        CharCount := 0
        MessageCount := 0
        StartTime := A_TickCount
        LastActivityTime := A_TickCount
        LastMessageTime := 0  ; Сбрасываем время последнего сообщения
        WordHistory := []  ; Очищаем историю слов
        MessageHistory := []  ; Очищаем историю сообщений
        WordsLast60Seconds := 0
        MessagesLast60Seconds := 0
        if (StatsText != "")
            StatsText.Value := "Слов в минуту: 0`nЗнаков в минуту: 0`nСообщений в минуту: 0`nСлов за 60 сек: 0`nСообщений за 60 сек: 0"
        if (TimerText != "")
            TimerText.Value := "00:00"
        LogError("Статистика сброшена пользователем", "F12 Handler")
    } catch Error as e {
        LogError("Ошибка сброса статистики: " . e.Message, "F12 Handler")
    }
    return
}

; Обработка закрытия приложения
OnExit(ExitFunc)

ExitFunc(ExitReason, ExitCode)
{
    LogError("Приложение завершено. Причина: " . ExitReason . ", Код: " . ExitCode, "Exit")
}

