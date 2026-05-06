# Документація до Лабораторної (README)
## Зміст
Короткий виклад вимог

- ER-діаграма, за якою створювалась БД
- Код створення таблиць SQL
- Код заповнення таблиць тестовими даними
- Результати перевірки результатів
  
---

## Короткий виклад вимог
-Написати SQL DDL-інструкції для створення кожної таблиці з розробленої ERD в PostgreSQL.

-Вказати відповідні типи даних для кожного стовпця, вибрати первинний ключ (Primary Key) для кожної таблиці та визначити необхідні зовнішні ключі (Foreign Keys), а також обмеження UNIQUE, NOT NULL, CHECK або DEFAULT.

-Вставити зразки рядків (тестові дані) за допомогою INSERT INTO.

-Протестувати все в клієнті pgAdmin, щоб переконатися, що таблиці створені правильно, зв'язки працюють, а дані завантажуються коректно.

---

## Код створення таблиць SQL

Для зручності загальний код SQL-запиту розділено на логічні частини з поясненням призначення кожної таблиці.

### Код SQL-запиту для створення таблиці `Department`
SQL
```
CREATE TABLE Department (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор відділу
    name VARCHAR(100) UNIQUE NOT NULL, -- Назва підрозділу (має бути унікальною)
    phone_ext VARCHAR(20) -- Внутрішній телефон для зв'язку
);
```
`Department` — базова таблиця-довідник, що зберігає інформацію про структурні підрозділи (відділи, кафедри) установи.

### Код SQL-запиту для створення таблиці `Employee`
SQL
```
CREATE TABLE Employee (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор працівника
    department_id INT NOT NULL REFERENCES Department(id) ON DELETE RESTRICT, -- Прив'язка до відділу
    full_name VARCHAR(150) NOT NULL, -- ПІБ працівника
    position VARCHAR(100) NOT NULL -- Посада
);
```
`Employee` — таблиця, що зберігає дані про працівників установи, які виступають матеріально відповідальними особами.

### Код SQL-запиту для створення таблиці `Room`
SQL
```
CREATE TABLE Room (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор приміщення
    room_number VARCHAR(20) UNIQUE NOT NULL, -- Номер кабінету/аудиторії
    building VARCHAR(50) NOT NULL, -- Назва або номер корпусу
    capacity INT CHECK (capacity >= 0) -- Місткість або площа
);
```
`Room` — таблиця для фіксації фізичних локацій в установі, що дозволяє відстежувати, де саме знаходиться майно.

### Код SQL-запиту для створення таблиці `Category`
SQL
```
CREATE TABLE Category (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор категорії
    name VARCHAR(100) UNIQUE NOT NULL, -- Назва категорії (наприклад, "Меблі")
    depreciation_rate DECIMAL(5,2) CHECK (depreciation_rate >= 0 AND depreciation_rate <= 100) -- Відсоток річної амортизації
);
```
`Category` — таблиця-класифікатор для групування різних типів майна, що спрощує формування звітів та інвентаризацію.

### Код SQL-запиту для створення таблиці `Asset`
SQL
```
CREATE TABLE Asset (
    id SERIAL PRIMARY KEY, -- Системний ідентифікатор майна
    inventory_number VARCHAR(50) UNIQUE NOT NULL, -- Бухгалтерський інвентарний номер
    name VARCHAR(200) NOT NULL, -- Назва або модель об'єкта
    purchase_date DATE DEFAULT CURRENT_DATE, -- Дата взяття на баланс
    cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0), -- Початкова вартість (не може бути від'ємною)
    status VARCHAR(20) CHECK (status IN ('InUse', 'InStorage', 'InRepair', 'WrittenOff')) DEFAULT 'InUse', -- Поточний стан
    category_id INT NOT NULL REFERENCES Category(id) ON DELETE RESTRICT, -- Прив'язка до категорії
    room_id INT NOT NULL REFERENCES Room(id) ON DELETE RESTRICT, -- Де знаходиться
    employee_id INT NOT NULL REFERENCES Employee(id) ON DELETE RESTRICT -- Хто матеріально відповідальний
);
```
`Asset` — центральна таблиця системи, яка фіксує всі наявні матеріальні цінності та пов'язує між собою категорії, приміщення та працівників.

---

## Код заповнення таблиць тестовими даними
Для перевірки працездатності бази даних та коректності зв'язків таблиці було заповнено довільними даними.

SQL
```
-- Додавання відділів
INSERT INTO Department (name, phone_ext) VALUES
('Кафедра інформатики', '101'),
('Бухгалтерія', '102'),
('Адміністрація', '100');

-- Додавання приміщень
INSERT INTO Room (room_number, building, capacity) VALUES
('405а', 'Корпус 1', 30),
('212', 'Корпус 1', 5),
('Склад №1', 'Господарський блок', 0);

-- Додавання категорій
INSERT INTO Category (name, depreciation_rate) VALUES
('Комп''ютерна техніка', 20.00),
('Офісні меблі', 10.00),
('Мультимедійне обладнання', 15.00);

-- Додавання співробітників
INSERT INTO Employee (department_id, full_name, position) VALUES
(1, 'Тарас Мельниченко', 'Лаборант'),
(2, 'Іваненко Марія', 'Головний бухгалтер'),
(1, 'Петренко Олександр', 'Завідувач кафедри');

-- Додавання майна
INSERT INTO Asset (inventory_number, name, purchase_date, cost, status, category_id, room_id, employee_id) VALUES
('INV-1001', 'Ноутбук Dell Latitude', '2023-09-01', 25000.00, 'InUse', 1, 1, 1),
('INV-1002', 'Проєктор Epson', '2022-05-15', 18500.00, 'InRepair', 3, 3, 1),
('INV-1003', 'Стіл офісний кутовий', '2021-11-10', 4500.00, 'InUse', 2, 2, 2),
('INV-1004', 'Серверна стійка', '2024-01-20', 12000.00, 'InStorage', 1, 3, 3);
```
---

## Результати перевірки результатів

Після виконання запитів за допомогою інструменту **pgAdmin 4**, перевірено наявність даних у таблицях.


<img width="451" height="120" alt="image" src="https://github.com/user-attachments/assets/5353279f-1f93-4608-be60-65de1fa30c6f" />

**Рис. 1. Таблиця Department з доданими даними.**

<img width="565" height="122" alt="image" src="https://github.com/user-attachments/assets/bb0b48c6-d881-49af-af7f-d6a8f72a5093" />

**Рис. 2. Таблиця Employee з доданими даними.**

<img width="520" height="120" alt="image" src="https://github.com/user-attachments/assets/87f32496-9997-4379-badf-a09a76eca800" />

**Рис. 3. Таблиця Room з доданими даними.**


<img width="442" height="118" alt="image" src="https://github.com/user-attachments/assets/20205fb7-7a12-491e-9cbb-34cdcd6edce5" />
**Рис. 4. Таблиця Category з доданими даними.**


<img width="1065" height="140" alt="image" src="https://github.com/user-attachments/assets/4c6a0d4c-c232-4ff4-a288-129de2005e12" />
**Рис. 5. Центральна таблиця Asset із записами про майно.**

