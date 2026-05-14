require("dotenv").config(); 
const { PrismaClient } = require("@prisma/client");
const { Pool } = require("pg");
const { PrismaPg } = require("@prisma/adapter-pg");

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
    throw new Error("Не знайдено DATABASE_URL у файлі .env");
}

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);

const prisma = new PrismaClient({ adapter });

async function main() {
    console.log("=== Початок перевірки схеми Обліку Майна ===");

    const timestamp = Date.now();

    // 1. Створюємо базові довідники, щоб задовольнити зовнішні ключі
    const department = await prisma.department.create({
        data: {
            name: `IT Відділ_${timestamp}`,
            phone_ext: "101",
        },
    });

    const building = await prisma.building.create({
        data: {
            name: `Головний офіс_${timestamp}`,
        },
    });

    const category = await prisma.category.create({
        data: {
            name: `Ноутбуки_${timestamp}`,
            // depreciation_rate ми прибрали у 3-й міграції, тому його тут немає
        },
    });

    const status = await prisma.assetstatus.create({
        data: {
            name: `В експлуатації_${timestamp}`,
        },
    });

    // 2. Створюємо двох співробітників (від кого і кому передаємо майно)
    const employeeSender = await prisma.employee.create({
        data: {
            department_id: department.id,
            first_name: "Олександр",
            last_name: "Системний",
            position: "Системний адміністратор",
            email: `alex_${timestamp}@company.com`, // Поле з 2-ї міграції
            is_active: true,                        // Поле з 2-ї міграції
        },
    });

    const employeeReceiver = await prisma.employee.create({
        data: {
            department_id: department.id,
            first_name: "Марія",
            last_name: "Дизайнер",
            position: "UI/UX Дизайнер",
            email: `maria_${timestamp}@company.com`,
            is_active: true,
        },
    });

    // 3. Створюємо дві кімнати
    const roomFrom = await prisma.room.create({
        data: {
            room_number: `100-${timestamp}`, // Унікальний номер завдяки timestamp
            building_id: building.id,
            capacity: 5,
        },
    });

    const roomTo = await prisma.room.create({
        data: {
            room_number: `205-${timestamp}`,
            building_id: building.id,
            capacity: 2,
        },
    });

    // 4. Створюємо майно і відразу записуємо історію його передачі (Міграція 1)
    const newAsset = await prisma.asset.create({
        data: {
            inventory_number: `INV-${timestamp}`,
            name: "Apple MacBook Pro 16",
            cost: 2500.00,
            status_id: status.id,
            category_id: category.id,
            room_id: roomTo.id,             // Поточне місцезнаходження
            employee_id: employeeReceiver.id, // Поточний власник
            
            // Вкладене створення запису в історію переміщень
            transfer_history: {
                create: [
                    {
                        from_room_id: roomFrom.id,
                        to_room_id: roomTo.id,
                        from_employee_id: employeeSender.id,
                        to_employee_id: employeeReceiver.id,
                    },
                ],
            },
        },
        include: {
            employee: true,           // Підтягуємо дані про поточного власника
            room: true,               // Підтягуємо дані про поточну кімнату
            transfer_history: true,   // Підтягуємо історію переміщень
        },
    });

    console.log("Успішно створено майно та запис історії!");
    console.dir(newAsset, { depth: null });
}

main()
    .catch((e) => {
        console.error("Помилка під час виконання запитів:", e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
