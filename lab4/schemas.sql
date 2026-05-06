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
