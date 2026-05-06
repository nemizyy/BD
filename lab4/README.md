# Документація до Лабораторної №4 

### Зміст

1. [Короткий виклад вимог](#Короткий-виклад-вимог)
    
2. [Код відповідних OLAP запитів та Результати перевірки роботи запитів](#Код-відповідних-OLAP-запитів)
    
3. [Висновок до лабораторної роботи](#Висновок)

### Короткий виклад вимог
- Використовувати агрегатні функції, такі як `COUNT`, `SUM`, `AVG`, `MIN` та `MAX`, для обчислення зведеної статистики з даних системи обліку майна.
- Написати запити `GROUP BY` для групування рядків за одним або кількома стовпцями та обчислення агрегатів для кожної групи.
- Використовувати `HAVING` для фільтрації результатів згрупованих запитів на основі агрегованих умов.
- Виконувати операції `JOIN` (принаймні `INNER JOIN` та `LEFT JOIN`), щоб об'єднати дані з кількох таблиць.
- Створювати об'єднані запити на агрегацію для кількох таблиць, які поєднують таблиці та формують згрупований, агрегований вивід.
- Інтерпретувати результати запитів та пояснити, що робить кожен із них.

### Код відповідних OLAP запитів

#### 1. Агрегаційні функції

```sql
-- 1.1. Загальна кількість одиниць майна
SELECT COUNT(*) AS total_assets 
FROM Asset;

-- 1.2. Середня, максимальна та мінімальна вартість майна
SELECT 
    AVG(cost) AS average_cost,
    MAX(cost) AS highest_cost,
    MIN(cost) AS lowest_cost
FROM Asset;

-- 1.3. Кількість об'єктів майна для кожного статусу
SELECT status, COUNT(*) AS assets_count
FROM Asset
GROUP BY status;

-- 1.4. Підрахунок кількості одиниць майна в кожній категорії
SELECT category_id, COUNT(*) AS total_assets
FROM Asset
GROUP BY category_id;
```
<img width="148" height="71" alt="image" src="https://github.com/user-attachments/assets/3d1aaa2d-4286-47c7-addd-626007cb9a04" />

**1.1 Загальна кількість одиниць майна в системі**

<img width="388" height="74" alt="image" src="https://github.com/user-attachments/assets/e1110364-abae-4a0b-9eec-5627346508d7" />

**1.2 Середня, максимальна та мінімальна вартість майна**

<img width="301" height="122" alt="image" src="https://github.com/user-attachments/assets/648389e0-2983-42dc-a91c-170f02ca0069" />

**1.3 Кількість об'єктів майна для кожного статусу**

<img width="241" height="148" alt="image" src="https://github.com/user-attachments/assets/f56edb8a-9299-4767-bb70-5c6bc2c9e699" />

**1.4 Підрахунок кількості одиниць майна в кожній категорії**

#### 2. Запити з JOIN

```sql
-- 2.1. INNER JOIN: Список майна з ПІБ відповідального працівника, категорією та приміщенням
SELECT 
    a.inventory_number,
    a.name AS asset_name,
    e.full_name AS responsible_employee,
    c.name AS category_name,
    r.room_number
FROM Asset a
JOIN Employee e ON a.employee_id = e.id
JOIN Category c ON a.category_id = c.id
JOIN Room r ON a.room_id = r.id;

-- 2.2. LEFT JOIN: Список усіх працівників та кількість закріпленого за ними майна
-- (включає працівників, за якими ще не закріплено жодного об'єкта)
SELECT 
    e.full_name,
    COUNT(a.id) AS assets_count
FROM Employee e
LEFT JOIN Asset a ON e.id = a.employee_id
GROUP BY e.id, e.full_name;

-- 2.3. LEFT JOIN: Список усіх приміщень та кількість майна в кожному з них
-- (включає приміщення, у яких ще немає жодного майна)
SELECT 
    r.room_number,
    r.building,
    COUNT(a.id) AS assets_in_room
FROM Room r
LEFT JOIN Asset a ON r.id = a.room_id
GROUP BY r.id, r.room_number, r.building;
```
<img width="835" height="146" alt="image" src="https://github.com/user-attachments/assets/2bd64cde-5948-4756-8a32-50393dc005f5" />

**2.1 Список майна з ПІБ відповідального працівника, категорією та приміщенням**

<img width="306" height="194" alt="image" src="https://github.com/user-attachments/assets/dd02509d-2db9-4315-af6a-3cb5232bcd7e" />

**2.2 Список усіх працівників та кількість закріпленого за ними майна**

<img width="462" height="201" alt="image" src="https://github.com/user-attachments/assets/3216a2db-13c6-4e26-8c12-c596d4f993f7" />

**2.3 Список усіх приміщень та кількість майна в кожному з них**


#### 3. Використання підзапитів

```sql
-- 3.1. Підзапит у WHERE: Знайти майно, вартість якого вища за середню по базі
SELECT inventory_number, name, cost
FROM Asset
WHERE cost > (SELECT AVG(cost) FROM Asset);

-- 3.2. Підзапит у SELECT: Вивести назву відділу та кількість працівників у ньому
SELECT 
    d.name,
    (SELECT COUNT(*) 
     FROM Employee e 
     WHERE e.department_id = d.id) AS employees_count
FROM Department d;

-- 3.3. Підзапит у HAVING: Знайти категорії, у яких кількість майна більша за середню кількість об'єктів на категорію
SELECT 
    c.name,
    COUNT(a.id) AS asset_count
FROM Category c
LEFT JOIN Asset a ON c.id = a.category_id
GROUP BY c.id, c.name
HAVING COUNT(a.id) > (
    SELECT AVG(category_asset_count)
    FROM (
        SELECT COUNT(*) AS category_asset_count
        FROM Asset
        GROUP BY category_id
    ) sub
);
```
<img width="471" height="71" alt="image" src="https://github.com/user-attachments/assets/50ec0cc9-a88a-401f-a730-b6cc31a9b125" />

**3.1 Підзапит у WHERE: Знайти майно, вартість якого вища за середню по базі**

<img width="339" height="195" alt="image" src="https://github.com/user-attachments/assets/b82fe3c2-7888-49a7-a186-d01da58e1166" />

**3.2 Підзапит у SELECT: Вивести назву відділу та кількість працівників у ньому**

<img width="308" height="46" alt="image" src="https://github.com/user-attachments/assets/3b34119f-10d0-467c-8855-f2abfcece372" />

**3.3 Підзапит у HAVING: Знайти категорії, у яких кількість майна більша за середню кількість об'єктів на категорію**

#### 4. Фільтрування груп (HAVING) та багатотаблична агрегація

```sql
-- 4.1. Знайти працівників, за якими закріплено більше однієї одиниці майна
SELECT 
    e.full_name,
    d.name AS department_name,
    COUNT(a.id) AS assets_count,
    SUM(a.cost) AS total_asset_value
FROM Employee e
JOIN Department d ON e.department_id = d.id
LEFT JOIN Asset a ON e.id = a.employee_id
GROUP BY e.id, e.full_name, d.name
HAVING COUNT(a.id) > 1;
```
<img width="597" height="80" alt="image" src="https://github.com/user-attachments/assets/c3bcd5ac-2e96-4a25-a9f9-745f24bc80b5" />

**4.1 Знайти працівників, за якими закріплено більше однієї одиниці майна**



## Висновок
У ході лабораторної роботи було опрацьовано побудову OLAP-запитів для аналізу даних у базі даних системи обліку майна установи. Було використано агрегатні функції `COUNT`, `SUM`, `AVG`, `MIN` та `MAX`, а також підзапити, `GROUP BY`, `HAVING` і різні типи `JOIN` для отримання аналітичної інформації з кількох таблиць. Отримані результати показали, як засобами PostgreSQL можна формувати зведену статистику щодо кількості майна, його вартості, розподілу за категоріями, приміщеннями та відповідальними працівниками.
