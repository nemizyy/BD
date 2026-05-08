Мета:

Пошук надлишковості та аномалій: виявлення потенційної надлишковості даних (наприклад, повторювані текстові значення) або аномалій оновлення (проблеми вставки/оновлення/видалення) у поточній схемі.

Перелік функціональних залежностей: визначення та перелік функціональних залежностей (ФЗ) для кожної проблемної таблиці.

Перевірка нормальних форм: оцінка поточної нормальної форми кожної таблиці (1NF, 2NF, 3NF) на основі її функціональних залежностей (ФЗ) та структури ключа.

Застосування нормалізації: перетворення таблиць у вищі нормальні форми (до 3НФ) для усунення порушень атомарності та транзитивних залежностей.

1. Початковий дизайн таблиць
Для демонстрації процесу нормалізації розглянемо початковий стан бази даних системи обліку майна установи. Припустимо, що на етапі проєктування дані про працівників, приміщення та статуси майна зберігалися у частково нормалізованих структурах, де допускалися комплексні рядки та дублювання текстових значень.

Проблемні атрибути початкової схеми:

У таблиці Employee поле full_name містить прізвище, ім'я та по батькові працівника разом.

У таблиці Room поле building містить текстову назву або номер корпусу.

У таблиці Asset поле status зберігає текстове значення стану майна (наприклад, 'InUse', 'InRepair'), яке обмежене через CHECK.

Аналіз проблеми:
Поточна схема порушує 1NF через наявність неатомарних полів (комбіноване ПІБ у full_name). Також порушується 3NF через наявність прихованих транзитивних залежностей (текстові назви корпусів та статусів дублюються і ускладнюють оновлення чи розширення довідників).

2. Функціональні залежності (ФЗ)
Аналіз початкової (ненормалізованої) структури виявляє наступний набір функціональних залежностей:

ФЗ 1 (Повна залежність): inventory_number -> {name, purchase_date, cost, status, category_id, room_id, employee_id}. Усі дані про майно залежать від його унікального інвентарного номера (або сурогатного id).

ФЗ 2 (Порушення атомарності): id (Employee) -> {department_id, full_name, position}. Дані працівника залежать від його ідентифікатора, але full_name потребує декомпозиції.

ФЗ 3 (Транзитивна залежність): id (Room) -> {room_number, building, capacity}. Поле building логічно є окремою сутністю (Корпус). Зберігання його як тексту створює аномалію оновлення: при перейменуванні корпусу доведеться оновлювати всі приміщення в ньому.

ФЗ 4 (Транзитивна залежність): id (Asset) -> {..., status}. Статус є категорійним довідковим значенням. Залежність статусу від об'єкта майна є прямою, але зберігання його у вигляді тексту VARCHAR дублює дані та обмежує масштабованість (додавання нових статусів).

3. Нормалізація
1. Перехід до 1NF. Усунення неатомарних атрибутів
Проблема: Поле full_name у таблиці Employee порушує вимогу атомарності атрибутів.

Рішення: Розділяємо це поле на окремі атомарні стовпці: first_name та last_name.

Результат: Таблиця відповідає 1NF. Кожне поле містить лише одне логічне значення.

2. Перехід до 2NF. Фіксація логічних складених ключів
Проблема: Оскільки використовуються сурогатні ключі SERIAL, технічно часткової залежності від частини ключа немає. Однак логічно у таблиці Room не було обмеження на те, що номери кімнат можуть повторюватися в межах різних корпусів.

Рішення: Створюємо обмеження UNIQUE для логічного композитного ключа (номер кімнати + ідентифікатор корпусу).

Результат: Таблиці відповідають 2NF, усунено можливість логічного дублювання приміщень.

3. Перехід до 3NF. Усунення транзитивних залежностей
Проблема: У таблицях Room та Asset використовуються текстові поля для корпусів (building) та статусів (status), що призводить до дублювання та аномалій оновлення.

Рішення: Створюємо окремі таблиці-довідники Building та AssetStatus. Замінюємо текстові поля в оригінальних таблицях на зовнішні ключі building_id та status_id.

Результат (Фінальні таблиці в 3NF): Схема повністю нормалізована. Всі неключові атрибути залежать виключно від первинних ключів своїх таблиць, текстове дублювання усунуто.

4. Трансформація структури (ALTER TABLE)
Нижче наведено команди для переведення початкових таблиць до відповідних нормальних форм.

Крок 1: Перехід до 1NF:

'''sql
-- Розділення імені працівника
ALTER TABLE Employee DROP COLUMN full_name;
ALTER TABLE Employee ADD COLUMN first_name VARCHAR(50) NOT NULL;
ALTER TABLE Employee ADD COLUMN last_name VARCHAR(50) NOT NULL;
Крок 2 та 3: Перехід до 2NF та 3NF:

-- Створення нових довідкових таблиць для 3NF
CREATE TABLE Building (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE AssetStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Наповнення довідників (опціональний крок для збереження існуючих даних)
INSERT INTO AssetStatus (name) VALUES ('InUse'), ('InStorage'), ('InRepair'), ('WrittenOff');
INSERT INTO Building (name) VALUES ('Корпус 1'), ('Господарський блок');

-- Модифікація таблиці Room (3NF та 2NF)
ALTER TABLE Room ADD COLUMN building_id INT;
-- (Тут має бути UPDATE для перенесення даних, після чого:)
ALTER TABLE Room DROP COLUMN building;
ALTER TABLE Room ALTER COLUMN building_id SET NOT NULL;
ALTER TABLE Room ADD CONSTRAINT fk_room_building FOREIGN KEY (building_id) REFERENCES Building(id) ON DELETE RESTRICT;
-- Забезпечення цілісності логічних ключів (2NF)
ALTER TABLE Room DROP CONSTRAINT room_room_number_key; -- видалення старого унікального ключа, якщо був
ALTER TABLE Room ADD CONSTRAINT unique_room_in_building UNIQUE (room_number, building_id);

-- Модифікація таблиці Asset (3NF)
ALTER TABLE Asset ADD COLUMN status_id INT;
-- (Тут має бути UPDATE для перенесення даних, після чого:)
ALTER TABLE Asset DROP COLUMN status;
ALTER TABLE Asset ALTER COLUMN status_id SET NOT NULL;
ALTER TABLE Asset ADD CONSTRAINT fk_asset_status FOREIGN KEY (status_id) REFERENCES AssetStatus(id) ON DELETE RESTRICT;
'''

5. Перероблений дизайн таблиць (SQL)
Нижче наведено фінальні команди CREATE TABLE для ключових таблиць у 3NF з урахуванням усіх змін.

'''sql
CREATE TABLE Building (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE AssetStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Employee (
    id SERIAL PRIMARY KEY,
    department_id INT NOT NULL REFERENCES Department(id) ON DELETE RESTRICT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(100) NOT NULL
);

CREATE TABLE Room (
    id SERIAL PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL,
    building_id INT NOT NULL REFERENCES Building(id) ON DELETE RESTRICT,
    capacity INT CHECK (capacity >= 0),
    CONSTRAINT unique_room_in_building UNIQUE (room_number, building_id) -- Фіксація 2NF
);

CREATE TABLE Asset (
    id SERIAL PRIMARY KEY,
    inventory_number VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    purchase_date DATE DEFAULT CURRENT_DATE,
    cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
    status_id INT NOT NULL REFERENCES AssetStatus(id) ON DELETE RESTRICT,
    category_id INT NOT NULL REFERENCES Category(id) ON DELETE RESTRICT,
    room_id INT NOT NULL REFERENCES Room(id) ON DELETE RESTRICT,
    employee_id INT NOT NULL REFERENCES Employee(id) ON DELETE RESTRICT
);
'''
Висновок
У ході виконання лабораторної роботи було проаналізовано початкову схему бази даних обліку майна установи. Було виявлено порушення 1NF (неатомарний атрибут full_name працівників) та 3NF (транзитивні залежності у вигляді текстових полів корпусів та статусів майна, які викликали дублювання). Шляхом декомпозиції полів, додавання унікальних обмежень для логічних зв'язків та винесення категорійних даних в окремі таблиці-довідники (Building, AssetStatus), схему було успішно приведено до Третьої нормальної форми 3NF.
