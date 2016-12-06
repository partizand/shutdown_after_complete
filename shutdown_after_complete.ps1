# Скрипт для transmission-qt
# Выключает компьютер по завершении всех загрузок, если запущен специальный торрент
# Таким образом можно управлять выключением компьютера через любой клиент,
# запуская или останавливая торрент со специальным именем


# Требует PowerShell 3.0 или выше.
# Для Windows 7 (по умолчанию стоит 2.0) можно скачать обновление с 
# http://www.microsoft.com/en-us/download/details.aspx?id=40855
# Так же нужен netframework 4.5


# Имя торрента для команды выключения компьютера
# Торрент должен быть запущен для выключения или стоять на паузе для бездействия
$shutdown_name="shutdown_after_complete"

# Адрес для подключения к transmission
$TransmissionUrl="http://127.0.0.1:9091/transmission/rpc"

# Имя пользователя и пароль для transmission (если не требуется укажите любые)
$User="None"
$Password="None"

# Сбрасывать флаг выключения (ставить торрент на паузу перед выключением)
$ClearShutdown=$true
#---------------------------------------------------------------------------------------
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential ($User,$secpasswd)

#$ne_shutdown_status="Paused"
# для отладки, неверно при работе!
#$ne_shutdown_status="Downloading"

# Загрузка модуля работы с transmission
$here=Split-Path -Parent $MyInvocation.MyCommand.Path
$trmodoath=";$here"
$PSModulePath = $env:PSModulePath # Запомнить каталоги модулей
$env:PSModulePath = $env:PSModulePath + $trmodoath
Import-Module Transmission
$env:PSModulePath = $PSModulePath # Восстановить каталоги модулей

# Получение списка торрентов
$torr=Get-TransmissionTorrent -TransmissionUrl $TransmissionUrl -credential $credential

# Поиск спец торрента в нужном статусе
$isShutdown = $torr | where {($_.name -eq $shutdown_name) -and ($_.status -ne "Paused") -and ($_.status -ne "Completed")}

if ($isShutdown -ne $null)
    {
    # Включен спец торрент, необходимо выключение
    "Shutdown command is on"
    # Список загружающихся торрентов
    $Downloading = $torr | where {$_.status -eq "Downloading"}
    if ($Downloading -eq $null)
        {
        # Ничего не загружается, нужно выключить комп
        if ($ClearShutdown)
            {
            "Pause torrent $shutdown_name"
            Suspend-TransmissionTorrent -TransmissionUrl $TransmissionUrl -credential $credential -Torrentid $isShutdown.id
            }
        
        
        "Shutdown now"
        #Stop-Computer
        }

    }
else
    {
    "No shutdown command"
    }


