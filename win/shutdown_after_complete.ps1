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

# Сбрасывать флаг выключения (ставить спец торрент на паузу перед выключением)
$ClearShutdown=$true

# Время в секундах для ожидания (и возможности отмены) выключения компьютера
$timetoshutdown=30
#---------------------------------------------------------------------------------------
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PsCredential ($User,$secpasswd)


# Форма для отмены выключения компьютера
function ShowShutdownForm
{
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$Font = New-Object System.Drawing.Font("Cambria",10,[System.Drawing.FontStyle]::Italic)
#Placering

$objForm = New-Object System.Windows.Forms.Form
$objForm.Font =$Font
$objForm.Text = "Computer will be shudown"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"
$objForm.MinimizeBox = $False
$objForm.MaximizeBox = $False
$objForm.WindowState = "Normal"
$objForm.SizeGripStyle = "Hide"
$objForm.ShowInTaskbar = $False

#Enter och Esc kan användas

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$objForm.close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close(); shutdown -a}})

    #En av knapparna

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(50,120)
$OKButton.Size = New-Object System.Drawing.Size(100,23)
$OKButton.Text = "Shutdown"
$OKButton.Add_Click({$objForm.Close();shutdown -a; shutdown -s -f})
$objForm.Controls.Add($OKButton)

#Den andra knappen

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(100,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close(); shutdown -a})
$objForm.Controls.Add($CancelButton)

#En text och dess placering och storlek

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,100) 
$objLabel.Text = "Компьютер будет выключен через $timetoshutdown секунд. Для отмены нажмите Cancel"
$objForm.Controls.Add($objLabel)


$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

}

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
$isShutdown = $torr | where {($_.name -eq $shutdown_name) -and ($_.status -ne "Paused")}

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
        #ShowForm
        #"Now stopping!"
        #Stop-Computer
        shutdown -s -t $timetoshutdown
        ShowShutdownForm
        }

    }
else
    {
    "No shutdown command"
    }




