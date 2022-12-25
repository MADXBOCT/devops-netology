GROUP VARS \
clickhouse_version: "{{ '22.3.3.44' if ansible_architecture == 'x86_64' else '22.3.6.5' }}" - подбирается нужная версия в зависимости от того где запускается зlaybook на macmini или m1 \
ch_arc_var - архитектура процессора для Clickhouse в зависимости от того где запускается playbook на macmini или m1

vector_version - версия vector \
vec_arc_var - архитектура процессора для vector в зависимости от того где запускается playbook на macmini или m1 \
vector_home - переменная домашнего каталога для Vector

Описание Play \
добавлен Install vector
 установлены тэги *vector* для дальнейшего использования и отладки 
 - загрузка архива 
 - создание рабочего каталога
 - распаковка в рабочий каталог из архива
 - копирование конфига



