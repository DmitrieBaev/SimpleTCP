# SimpleTCP
## Простейшее клиент-серверное приложение с использованием TCP сокетов

### Концепции взаимодействия программы-клиента и программы сервера, взаимодействующих по протоколу TCP:
1. Сервер инициирует TCP сокет по адресу localhost:8080 и переходит в состояние ожидания.
2. Клиент подключается к TCP сокету.
3. Сервер фиксирует подключение в хэш и ожидает сообщения от клиента.
4. Клиент отправляет сообщение.
5. Сервер обрабатывает это сообщение и посылает данное сообщение всем остальным клиентам. Переходит в режим ожидания сообщения.
6. Клиент отправляет сообщение, начинающееся с «::».
7. Сервер принимает это сообщение, обрабатывает и посылает ответ только этому клиенту. Переходит в режим ожидания сообщения.
8. Клиент бездействует.
9. Сервер, ожидая N секунд, не получает от клиента сообщение. Посылает бездействующему клиенту сообщение о прерывании соединения и завершает само соединение.

### Пример использования
Тестирование работы TCP чата проводилось с ограничением на подключение 2-х клиентов и временным лимитом бездействия в 1500 секунд.
Попытка подключить четыре клиента и один сервер:

![image](https://user-images.githubusercontent.com/47382305/171628603-a97a5ab0-3975-4c37-9877-b21fe716dfe2.png)

Лог на сервере:

![image](https://user-images.githubusercontent.com/47382305/171628610-e24531d6-5c31-4845-bd6f-81a321d87911.png)

Отображение дисконнекта:

![image](https://user-images.githubusercontent.com/47382305/171628709-427a4d80-c128-49f5-87bd-d334b07e95c3.png)

Лог на сервере:

![image](https://user-images.githubusercontent.com/47382305/171628814-75591c21-f10a-4388-b334-e68b018172c6.png)

Тестирование отключения по таймауту с параметрами: максимальное количество подключений - 2, лимит времени - 15 секунд.
Результат вылета по таймауту на клиенте:

![image](https://user-images.githubusercontent.com/47382305/171628987-2116063a-ed2f-458f-ad47-20d05fefd24e.png)


Лог на сервере:

![image](https://user-images.githubusercontent.com/47382305/171629011-17320124-5f1a-4965-9742-6c164409449f.png)