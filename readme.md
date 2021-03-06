# shutdown_after_complete

Скрипт для transmission. Выключает компьютер по завершении всех загрузок, если запущен специальный торрент.
Таким образом можно управлять выключением компьютера через любой клиент, запуская или останавливая торрент со специальным именем

Добавил отдельный скрипт для linux `tansmission-monitor.sh`
Монитор для убунтовской приблуды powernap.
Процесс контролирует свой повторный запуск и висит в процессах пока идет закачка торрента transmission.
В powernap нужно соответсвенно добавить монитор на этот процесс.
Сам скрипт нужно запускать при старте системы и при запуске на закачку торрента.

## Linux version

Настраивал на lubuntu 16.04

### Разрешение пользователю выключить компьютер без ввода пароля

sudo позволяет разрешать или запрещать пользователям выполнение конкретного набора программ. Все настройки, связанные с правами доступа, хранятся в файле /etc/sudoers. Это не совсем обычный файл. Для его редактирования необходимо (в целях безопасности) использовать команду

	sudo visudo

Для того, что бы система не запрашивала пароль при определенных командах необходимо в sudoers после строки **# Cmnd alias specification** добавить строку, где через запятую перечислить желаемые команды с полным путём (путь команды можно узнать, выполнив which имя_команды:
	
```bash
# Cmnd alias specification
Cmnd_Alias SHUTDOWN_CMDS = /sbin/shutdown, /usr/sbin/pm-hibernate, /sbin/reboot
```
	
И в конец файла дописать строку
	
	имя_пользователя ALL=(ALL) NOPASSWD: SHUTDOWN_CMDS
		
Внимание! Вышеописанные действия не отменяют необходимости ввода команды sudo перед вашей командой 

### Скрипт для выключения по завершении всех закачек

Требуется установленный transmission-remote

Расположите скрипт *transmission-shutdown* в своем домашнем каталоге.

Дайте себе права на запуск

	chmod +x ~/transmission-shutdown

Добавьте в Transmission настройку запуска скрипта *transmission-shutdown* по завершении закачки торрента, отредактировав settings.json, изменив строчки:

	"script-torrent-done-enabled": true,
	"script-torrent-done-filename": "/home/USER_NAME/transmission-shutdown",

Теперь если запустить торрент shutdown_after_complete, то компьютер будет выключен после окончания всех загрузок.

Перед выключением флаг выключения будет сброшен (управляющий торрент будет поставлен на паузу) и в следующий раз необходимо будет стартовать его опять. Можно отменить такое поведение закоментировав строчку (поставить перед ней #) 
	
	transmission-remote $auth -t $specid --stop

## Windows version	

### Требования

- PowerShell 3.0 или выше. Для Windows 7 (по умолчанию стоит 2.0) можно скачать обновление с 
http://www.microsoft.com/en-us/download/details.aspx?id=40855
- .netframework 4.5

### Как пользоваться

- Разрешить удаленное управление transmission-qt
- Добавить в Правка - Настройки - Загрузка - Выполнить сценарий, после завершения загрузки: shutdown_after_complete.bat.
- Добавить торрент shutdown_after_complete.torrent, не начиная скачивание, (поставить его на паузу).

Теперь если запустить торрент shutdown_after_complete, то компьютер будет выключен после окончания всех загрузок.

При выключении будет 30 сек. для отмены.

Перед выключением флаг выключения будет сброшен (управляющий торрент будет поставлен на паузу) и в следующий раз необходимо будет стартовать его опять. Можно отменить такое поведение исправив $ClearShutdown=$true на $ClearShutdown=$false

## Заметки

Не стал делать кроссплатформенно через python, т.к. потребуется установка питона и модулей. Для linux разумнее реализовывать через bash и transmission-remote.

Имя управляющего торрента может быть произвольным, можно задать в скрипте. Пауза - ничего не делать, все остальное - выключить.

Подключение к transmission через rpc на PowerShell утащено с https://github.com/trondhindenes/PowershellModules

## License

Windows version MIT, Linux version GNU GPL 3

## Надерганные примеры скриптов для bash

### transmission script 1

```bash
# Shutdown tranmission and eventually NAS
#count=$(transmission-remote --auth username:password --list | sed '1d;$d' | grep -v Done | wc -l)
count=$(transmission-remote --list | sed '1d;$d' | grep -v Done | wc -l)
if [ $count -eq 0 ]; then
	transmission-remote --auth username:password --exit
	sleep 10
	sudo -h shutdown now
fi
```

### transmission script 2
	
Еще одно маленькое замечание: в принципе, почти всё это делается вот таким однострочником на unix shell:
	
```bash
while true; do [ -z "$(transmission-remote -l | cut -c25-31 | sed -e '/^Done/ d; 1d; $d')" ] && sudo /sbin/poweroff || sleep 5; done
```

while true; do [ -z "$(transmission-remote -l | cut -c25-31 | sed -e '/^Done/ d; /^Unknown/ d; 1d; $d')" ] && sudo /sbin/poweroff || sleep

Если демон transmission закрыт авторизацией, то нужно в вызов transmission-remote добавить -nlogin:password. Если нужно добавить какие-то еще условия, по которым можно разрешить poweroff — например, разрешить poweroff не только, когда все торренты «Done», но еще когда есть часть торрентов в «Unknown» — то нужно добавить это /^Unknown/ d в регулярное выражение в аргументе sed'а.

Если кому-нибудь будут полезные еще какие-то пояснения по тому, как работает такой скрипт — спрашивайте ;) 	

### transmission script  3
	
еще можно if [[ `transmission-remote -l | grep Done | wc -l` == `transmission-remote -l | wc -l`]]
как видно сранивается кол-во завершенных закачен с общим кол-вом закачек. ИМХО намного проще того, что у вас. Еще можно добавить проверку Unknown, если послев течении n проверок число не меняется — выключать компьютер. 	


