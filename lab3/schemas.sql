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
-- Видаляємо всі об'єкти майна, які офіційно списані, щоб не засмічувати активну базу
DELETE FROM public.asset 
WHERE status = 'WrittenOff';

-- Видаляємо випадково створену категорію, до якої ще не прив'язано жодного майна
-- (Припустимо, ми створили тестову категорію)
INSERT INTO public.category (name, depreciation_rate) VALUES ('Тестова категорія для видалення', 0.00); 

DELETE FROM public.category 
WHERE name = 'Тестова категорія для видалення';
