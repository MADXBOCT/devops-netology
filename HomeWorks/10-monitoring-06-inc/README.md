###  Краткое описание инцидента
В 22:52 21 октября 2018 были затронуты некоторые службы GitHub в связи с сетевой проблемой и последующим сбоем на БД. В результате возникла несогласованность информации на сервисах (данных). Произошла деградация сервиса в течение 24 часов и 11 минут.

### Предшествующие события
Регламентные работы по замене отказавшего оптического оборудования, в результате которых была потеряна связь между US East Coast Hub и US East Coast data center на 43 секунды; 

### Причина инцидента
Потеря соединения междуна Рассогласованность кластеров MySQL в результате предшествующих событий.

### Воздействие
Несогласованность предоставляемой информации (отображение не актуальной информации). Невозможность работы событий WebHook и недоступность работы страниц GitHub

### Обнаружение
Обнаружено инженерами обрабтывающими алерты монторинга

### Реакция
Деградаия сервиса в теении 24 часов и 11 минут

### Восстановление
Восстановление полной производительности было выполнено за счет восстановления данных из бэкаповх и повторных репликаций всех имеющихся данных с хостов с актуальными данными для восстановления 100% целостности данных во всех кластерах хранения данных.

### Таймлайн 	

2018.10.21 22:52 UTC - потеря консенсуса между серверами в дата хабах в результате описанного инцидента. После восстановления была попытка восстановления целостности кластера, восстановления консенсуса, но данные в БД различялись что привело к несогласованности в рамках кластера

2018.10.21 22:54 UTC - Мониторинг генерировал Алерты, инженера поддержки обрабатывали реагировали на алерты, в 23:02 обнаружили несоответсвие статуса Кластера ожиаемому. Выявлено отсутсвие серверов из US East Coast

2018.10.21 23:07 UTC - отключены внутренние инструменты развертывания для предотвращения дополнительных изменений. Сайт переведен в желтый статус и автомтически зафикисрован инциден в системе управления сбоями \
2018.10.21 23:13 UTC - после выявления воздействия на множественные сервера , выведены дополнительные инженеры, выпонены действия для сохраненияпользоательских данных. но деградация системы не была остановлена \
2018.10.21 23:19 UTC - Были остановлены некоторые процессы (принудительная деградация системы) с целью повышения скорости восстановления \
2018.10.22 00:05 UTC - Разработка плана по восстановления системы и синхронизаии репликаций данных. Обновлен статус, чтобы сообщить пользователям, что мы собираемся выполнить контролируемую отработку отказа внутренней системы хранения данных. \
2018.10.22 00:41 UTC - Запущен процесс бэкапирования данных, мониторинг состяния работ \
2018.10.22 06:51 UTC - бэкапы выаолнены US East Coast data center и запущенно реплецирование с серверов в West Coast. \
2018.10.22 07:46 UTC - опубликована расширенная информация для пользователей \
2018.10.22 11:12 UTC - Востановлены сервера в US East Coast, продолжается реплицирование. налюдается повышенная нагрузка при реплицировании. \
2018.10.22 13:15 UTC - Приближались к пиковому периоду нагрузок. Увеличили количество репликаций для сняти растущей нагрузки по реклицированию. \
2018.10.22 16:24 UTC - реплицированиее синхронизировано, переключение в штатную топологию MySQL \
2018.10.22 16:45 UTC - После восстановления возникла необходимость балансировки нагрузки да восстановления 100% услуг клиентам. Для восстановления уже имеющихся данных пользователей включили обработку, так же подняли TTL до полного завершения и возвращения к штатной работе. \
2018.10.22 23:03 UTC - Работа возвращена к шаттному поведению \

### Последующие действия 	

Собранны логи по всем серверам подвергнутых сбоя, производится анализ логов для выявления запросов которые требуется обработать в ручну и информировать пользователей о возможных проблемах.

### Запланированы иннициативы:
Настройка конфигурациии Оркестратора для снижения рисков поведения вызвашего инцидент
Изменить скорость сбора информации для эффективного взаимодествия/ изменен способ сбора и передачи информации
Запланировано изменение работы систем и цодов для возможности сохранения работоспособности при полной потере одного из цодов в полнофункциональнос состоянии в том числе в переход на режим active/active/active)
Так же запланирован ряд других иннициатив для повышения ээфективности работы системыи и снижения риска потери работоспособности системы