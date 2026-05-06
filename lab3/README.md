

# Документація до Лабораторної №3 (README)

## Зміст

1. [Короткий виклад вимог](#Короткий-виклад-вимог)
2. [Код відповідних OLTP запитів та Результати перевірки роботи запитів](#Код-відповідних-OLTP-запитів-та-Результати-перевірки-роботи-запитів)
3. [Висновок до лабораторної роботи](#Висновок)

## Короткий виклад вимог

- Написати запити `SELECT` для отримання даних (включаючи фільтрацію за допомогою `WHERE` та вибір певних стовпців).
- Практикувати використання операторів `INSERT` для додавання нових рядків до таблиць.
- Практикувати використання оператора `UPDATE` для зміни існуючих рядків (використовуючи `SET` та `WHERE`).
- Практикувати використання операторів `DELETE` для безпечного видалення рядків (за допомогою `WHERE`).
- Вивчити основні операції маніпулювання даними (DML) у PostgreSQL та спостерігати за їхнім впливом.

## Код відповідних OLTP запитів та Результати перевірки роботи запитів
(даних було замало для виконання різних операцій, додаємо ще)

```sql
-- Додавання нових відділів
INSERT INTO Department (name, phone_ext) VALUES
('Відділ кадрів', '103'),
('Господарський відділ', '104'),
('Лабораторія фізики', '105');

-- Додавання нових приміщень
INSERT INTO Room (room_number, building, capacity) VALUES
('102', 'Корпус 2', 15),
('Склад №2', 'Господарський блок', 0),
('305', 'Корпус 1', 40);

-- Додавання нових категорій майна
INSERT INTO Category (name, depreciation_rate) VALUES
('Лабораторне обладнання', 15.00),
('Транспортні засоби', 20.00),
('Кліматична техніка', 10.00);

-- Додавання нових працівників
INSERT INTO Employee (department_id, full_name, position) VALUES
(4, 'Сидоренко Олена', 'Інспектор з кадрів'),
(5, 'Коваленко Василь', 'Завгосп'),
(6, 'Мельник Андрій', 'Старший науковий співробітник');

-- Створення нових записів про майно (різні статуси та локації)
INSERT INTO Asset (inventory_number, name, purchase_date, cost, status, category_id, room_id, employee_id) VALUES
-- Майно 5: Новий кондиціонер для відділу кадрів
('INV-1005', 'Кондиціонер Cooper&Hunter', '2026-05-01', 15000.00, 'InUse', 6, 4, 4),
-- Майно 6: Зламаний мікроскоп у лабораторії
('INV-1006', 'Мікроскоп електронний', '2020-09-15', 85000.00, 'InRepair', 4, 6, 6),
-- Майно 7: Автомобіль на балансі завгоспа
('INV-1007', 'Автомобіль Renault Logan', '2019-11-20', 350000.00, 'InUse', 5, 5, 5),
-- Майно 8: Списані старі стільці на складі
('INV-1008', 'Стілець офісний (5 шт)', '2015-02-10', 2500.00, 'WrittenOff', 2, 5, 5);

-- (Складніше вставлення даних: Додаємо новий ноутбук останньому доданому працівнику у найновіше приміщення)
INSERT INTO public.asset (inventory_number, name, purchase_date, cost, status, category_id, room_id, employee_id) 
VALUES (
    'INV-1009',
    'Ноутбук Apple MacBook Pro',
    CURRENT_DATE,
    65000.00,
    'InStorage',
    1, -- Комп'ютерна техніка
    (SELECT MAX(id) FROM public.room), -- Останнє створене приміщення (305)
    (SELECT MAX(id) FROM public.employee) -- Останній доданий працівник
);
```

### 
<img width="444" height="200" alt="image" src="https://github.com/user-attachments/assets/23f57e90-3b21-408a-8991-d5e41af3a1fa" />

#### Рис. 1. Результат запиту для заповнення таблиці Department

<img width="519" height="203" alt="image" src="https://github.com/user-attachments/assets/15a6dd46-878f-4163-ab48-ba1e68781a38" />

#### Рис. 2. Результат запиту для заповнення таблиці Room

<img width="445" height="197" alt="image" src="https://github.com/user-attachments/assets/5a3e8e76-e141-4287-a92d-b1148e9c8157" />

#### Рис. 3. Результат запиту для заповнення таблиці Category

<img width="604" height="197" alt="image" src="https://github.com/user-attachments/assets/7a37067e-aed5-489f-b753-9204c88ea390" />

#### Рис. 4. Результат запиту для заповнення таблиці Employee

<img width="1085" height="169" alt="5" src="https://github.com/user-attachments/assets/5fd35107-0679-4d96-9d19-1a277f0ba1a7" />

#### Рис. 5. Результат запиту для заповнення таблиці Asset (включно зі складним INSERT)

***
## SELECT - Отримання даних (фільтрація та вибір певних стовпців)

```sql
-- Вивести назву, інвентарний номер та вартість майна, яке коштує дорожче 20000 грн
SELECT inventory_number, name, cost 
FROM public.asset 
WHERE cost > 20000.00;

-- Знайти все майно, яке зараз знаходиться в ремонті ('InRepair')
SELECT id, inventory_number, name, room_id, employee_id 
FROM public.asset 
WHERE status = 'InRepair';

-- Знайти всіх співробітників конкретного відділу (наприклад, 'Кафедра інформатики', id=1)
SELECT id, full_name, position 
FROM public.employee 
WHERE department_id = 1;
```
<img width="482" height="147" alt="image" src="https://github.com/user-attachments/assets/894f9f1c-e3c5-490e-b8d1-473463e769bb" />

<img width="611" height="99" alt="image" src="https://github.com/user-attachments/assets/8d603459-bfef-4852-85be-ea86ad23dca0" />

<img width="462" height="101" alt="image" src="https://github.com/user-attachments/assets/d730085d-9fcb-4500-afa1-0e167a064e38" />



***
## UPDATE - Зміна існуючих даних

```sql
-- Майно полагодили (наприклад, мікроскоп з id=6): змінюємо статус на 'InUse'
UPDATE public.asset 
SET status = 'InUse' 
WHERE id = 6 AND status = 'InRepair';

-- Переміщення ноутбука зі складу (id=9) у кабінет 212 (room_id=2)
UPDATE public.asset 
SET room_id = 2, status = 'InUse' 
WHERE id = 9;

-- Підвищення працівника на посаді (наприклад, Тараса Мельниченка, id=1)
UPDATE public.employee 
SET position = 'Старший лаборант' 
WHERE id = 1;
```
<img width="1070" height="73" alt="image" src="https://github.com/user-attachments/assets/b633e34b-a248-44be-88af-e887b23d315d" />

<img width="1087" height="71" alt="image" src="https://github.com/user-attachments/assets/25a19456-5a1b-40c9-8639-7fcf9b635639" />

<img width="564" height="78" alt="image" src="https://github.com/user-attachments/assets/6e397fd8-d361-4c21-b69c-a26b908cd81f" />



***
## DELETE - Видалення даних

```sql
-- Видаляємо всі об'єкти майна, які офіційно списані, щоб не засмічувати активну базу
DELETE FROM public.asset 
WHERE status = 'WrittenOff';

-- Видаляємо випадково створену категорію, до якої ще не прив'язано жодного майна
-- (Припустимо, ми створили тестову категорію)
INSERT INTO public.category (name, depreciation_rate) VALUES ('Тестова категорія для видалення', 0.00); 

DELETE FROM public.category 
WHERE name = 'Тестова категорія для видалення';
```
<img width="1085" height="145" alt="image" src="https://github.com/user-attachments/assets/3ef205e4-8b2d-4af2-a959-b875875f1dcb" />

<img width="483" height="228" alt="image" src="https://github.com/user-attachments/assets/aa2245d4-b708-4571-af89-b6ba3e42ca92" />

<img width="445" height="200" alt="image" src="https://github.com/user-attachments/assets/9c4d9b77-6229-42b2-9ce9-79048f2e9629" />



***
## Висновок

Виконання даної лабораторної роботи дозволило поглибити теоретичні знання та отримати практичний досвід використання інструментів DML у PostgreSQL. Реалізовані транзакційні запити наочно продемонстрували базові принципи функціонування OLTP-баз даних на прикладі системи інвентаризації. Засвоєні методи маніпулювання даними (додавання нового майна, зміна статусів, переміщення об'єктів та списання) складають основу для розробки реальних облікових систем, де пріоритетом є висока швидкість, точність відстеження активів та безперебійність обробки запитів від користувачів.
