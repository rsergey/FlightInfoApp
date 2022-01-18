# FlightInfoApp
Приложение основано на данных сервиса [aviationstack.com](https://aviationstack.com/) и предоставляет информацию о перелётах с привязкой к аэропорту.

Проект является учебным. В качестве архитектурного паттерна используется традиционный MVC, так как приложение изначально не планировалось перегружать функциональностью и дополнять тестами. Вёрстка интерфейса через Storyboard. Проект умышленно реализован без использования сторонних фреймворков.

*UPD: с конца 2021 года сервис aviationstack.com существенно сократил число запросов на всех тарифах (в частности с 500 до 100 в месяц на бесплатном тарифе), что снижает удобство и эффективность данного приложения.*

## ViewControllers

### SelectionViewController
![](/Screenshots/SelectionViewController.png "SelectionViewController")  
Стартовый экран приложения.

SelectionViewController содержит текстовое поле для ввода IATA кода аэропорта по которому осуществляется запрос данных о перелётах. Реализована фильтрация вводимых данных по допустимым символам и их количеству. Введённый код сохраняется в UserDefaults как IATA код по умолчанию для последующих сеансов использования приложения.

Возможен переход на:
* SettingsViewController по кнопке в NavigationBar
* ArrivalTableViewController (DepartureTableViewController) с передачей введённого IATA кода
* AirportListTableViewController по кнопке "Find your airport"

### SettingsViewController
![](/Screenshots/SettingsViewController.png "SettingsViewController")  
Экран настроек приложения.

SettingsViewController содержит текстовое поле для ввода пользовательского API ключа. Введённый ключ сохраняется в Keychain. Слайдером задаётся период хранения данных о перелётах (в диапазоне от 1 до 12 часов). Установленное значение сохраняется в UserDefaults. По кнопке "aviationstack.com" осуществляется переход на сайт сервиса.

### ArrivalTableViewController (DepartureTableViewController)
![](/Screenshots/ArrivalTableViewController.png "ArrivalTableViewController")  
Связанные через TabBar эраны со списками прибывыющих/вылетающих рейсов выбранного аэропорта.

ArrivalTableViewController (DepartureTableViewController) осуществляет загрузку списка рейсов выбранного аэропорта из базы данных или из сети (если превышено время хранения данных или если он не был загружен ранее). Реализованы функции pull-to-refresh и поиск по списку. Отсутствие сохранённого API ключа или ошибка сетевого запроса вызывает соответствующее уведомление для пользователя. При выборе перелёта из списка осуществляется переход на DetailsTableViewController с передачей данных о выбранном перелёте.

### AirportListTableViewController
![](/Screenshots/AirportListTableViewController.png "AirportListTableViewController")  
Экран со списком всех доступных в сервисе Aviationstack аэропортов (в алфавитном порядке IATA кодов) с указанием их места расположения.

AirportListTableViewController осуществляет загрузку списка аэропортов из базы данных или из сети (если он не был загружен ранее). Реализованы функции pull-to-refresh и поиск по списку. Отсутствие сохранённого API ключа или ошибка сетевого запроса вызывает соответствующее уведомление для пользователя. Попытка принудительного обновления списка из сети сопровождается предупреждением о нецелесообразности частого обновления из-за редко меняющихся данных, с возможностью продолжить или отменить действие. При выборе аэропорта из списка осуществляется переход на ArrivalTableViewController (DepartureTableViewController) с передачей IATA кода выбранного аэропорта и сохранением его как аэропорт по умолчанию.

### DetailsTableViewController
![](/Screenshots/DetailsTableViewController.png "DetailsTableViewController")  
Экран детальной информации о выбранном перелёте.

В табличном виде представлена детальная информация о выбранном перелёте. Реализована возможность сворачивать и разворачивать секции таблицы.

## Models

### Flights
Модель данных о перелётах. Полная структура данных о перелётах, с вложенностью, соответствующей JSON выдаваемого сервисом Aviationstack.

### Airports
Модель данных о аэропортах. Структура данных, подготовленная для автоматического парсинга.

### Attributes
Набор перечислейний, содержащих сервисную информацию для формирования сетевых запросов и запросов в базу данных, а также для классификации данных.

### FlightMenu
Вспомогательная структура данных, используемая в реализации сворачивающихся секций DetailsTableViewController.

## Services

### NetworkManager
Сервисный класс, реализующий сетевые запросы с использованием URLSession, парсинг полученных данных и их сортировку. Организованы методы для получения данных перелётов и списка аэропортов.

### StorageManager
Сервисные класс, реализующий работу с CoreData. Организованы методы чтения из базы, сохранения и очистки данных для перелётов и списка аэропортов.

### DataManager
Сервисный класс, реализующий сохранение и получение данных с использованием UserDefaults. Организована работа с параметрами настройки работы приложения (IATA код по умолчанию, заданный период хранения данных перелётов), а также служебных данных (дата сохранения в базу данных информации о перелётах и IATA код связанного с этими данными аэропорта).

### KeychainManager
Сервисный класс, реализующий сохранение, чтение и очистку данных из зашифрованной базы данных Keychain. Используется для хранения пользовательского API ключа.

*API ключи для тестирования приложения (бесплатный тариф aviationstack.com): bf9f1644f60ea683c4a27c95035f65ab, 86a9e685862108f5593b73388f3246a5*
