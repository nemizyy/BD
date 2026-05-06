CREATE TABLE Department (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор відділу
    name VARCHAR(100) UNIQUE NOT NULL, -- Назва підрозділу (має бути унікальною)
    phone_ext VARCHAR(20) -- Внутрішній телефон для зв'язку
);
CREATE TABLE Employee (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор працівника
    department_id INT NOT NULL REFERENCES Department(id) ON DELETE RESTRICT, -- Прив'язка до відділу
    full_name VARCHAR(150) NOT NULL, -- ПІБ працівника
    position VARCHAR(100) NOT NULL -- Посада
);
CREATE TABLE Room (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор приміщення
    room_number VARCHAR(20) UNIQUE NOT NULL, -- Номер кабінету/аудиторії
    building VARCHAR(50) NOT NULL, -- Назва або номер корпусу
    capacity INT CHECK (capacity >= 0) -- Місткість або площа
);
CREATE TABLE Category (
    id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор категорії
    name VARCHAR(100) UNIQUE NOT NULL, -- Назва категорії (наприклад, "Меблі")
    depreciation_rate DECIMAL(5,2) CHECK (depreciation_rate >= 0 AND depreciation_rate <= 100) -- Відсоток річної амортизації
);
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
