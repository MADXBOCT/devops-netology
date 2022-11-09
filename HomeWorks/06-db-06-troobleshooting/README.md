1

составим список текущих операций командой `db.currentOp()`
https://www.mongodb.com/docs/v6.0/reference/method/db.currentOp/ \

так же можно получить список операций всего инстанса
`
db.adminCommand(
   {
     currentOp: 1
   }
)
`
https://www.mongodb.com/docs/v6.0/reference/command/currentOp/ \

удалим зависшую операцию командой `db.killOp()` по id, полученному в результате выполнения предыдущей команды
https://www.mongodb.com/docs/v6.0/reference/method/db.killOp/

вариант решения - оптимизация индекса(ов) для ускорения обработки запросов

2

