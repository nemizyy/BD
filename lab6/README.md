# Документація до Лабораторної роботи: Нормалізація БД

## Зміст

- [Короткий виклад вимог](#Короткий-виклад-вимог)
- [Ініціалізація та аналіз БД](#Ініціалізація-та-аналіз-БД)
- [Застосування міграцій](#Застосування-міграцій)
- [Перероблений дизайн схеми (schema.prisma)](#Перероблений-дизайн-схеми)
- [Результати та скріншоти тестів](#Результати-та-скріншоти-тестів)
  
    
- [Висновок](#Висновок)
    

---

## Короткий виклад вимог

- Використати Prisma ORM для керування схемами та дослідити, як Prisma може аналізувати та змінювати схему бази даних.

- Застосувати міграції: генерування та застосування змін схеми (таблиць, стовпців, зв'язків) за допомогою prisma migrate.

- Виконати моделювання за допомогою файлів схеми: визначення таблиць та зв'язків у schema.prisma.

- Перевірити зміни базовими запитами: вставити та запитати дані за допомогою клієнта Prisma через скрипт Node.js.
    

---

## Ініціалізація та аналіз БД
Для розгортання середовища Prisma у поточному проєкті, було ініціалізовано нову конфігурацію та виконано аналіз існуючої БД з попередньої лабораторної роботи.
<br>Початкові команди для налаштування наведено нижче:
```
npm init -y
npm install prisma --save-dev
npx prisma init --datasource-provider postgresql
```
перед виконанням наступної команди треба налаштувати DATABASE_URL в .env 
```
npx prisma db pull
```
В ході виконання db pull, Prisma успішно зчитала поточні таблиці бази даних у новий файл схеми schema.prisma. Було вирішено проблему розсинхронізації (Drift detected) шляхом створення базової лінії (Baselining) для існуючих таблиць, щоб Prisma почала вважати існуючу структуру початковою точкою історії.

---

## Застосування міграцій 
- Міграція 1(`add-transfer-history-table`) Створено нову модель transfer_history для фіксації історії передачі майна (`asset`) між різними кімнатами (`room`) та співробітниками (`employee`).
- Міграція 2(`add-is-active-field`) додаємо поле email та логічний прапорець is_active (чи працює зараз людина в компанії) для співробітника (`employee`).
- Міграція 3(`drop-depreciation-rate`) У моделі category закоментовуємо (`прибираємо`) інформацію про depreciation_rate (`ставку амортизації`), бо її підтримка поки не планується в проекті.

Кожна зміна була ізольована та застосована командою npx prisma migrate dev --name <`назва_міграції`>, що згенерувало відповідні SQL-файли у папці prisma/migrations/.

---

## Перероблений дизайн схеми 
Нижче представлено готовий код фінальної схеми Prisma з урахуванням усіх застосованих міграцій.
<details>
<summary>Переглянути фінальний schema.prisma </summary>
  
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
}

model asset {
  id               Int         @id @default(autoincrement())
  inventory_number String      @unique @db.VarChar(50)
  name             String      @db.VarChar(200)
  purchase_date    DateTime?   @default(dbgenerated("CURRENT_DATE")) @db.Date
  cost             Decimal     @db.Decimal(10, 2)
  status_id        Int
  category_id      Int
  room_id          Int
  employee_id      Int
  category         category    @relation(fields: [category_id], references: [id], onUpdate: NoAction)
  employee         employee    @relation(fields: [employee_id], references: [id], onUpdate: NoAction)
  room             room        @relation(fields: [room_id], references: [id], onUpdate: NoAction)
  assetstatus      assetstatus @relation(fields: [status_id], references: [id], onUpdate: NoAction)
  transfer_history transfer_history[]
}

model assetstatus {
  id    Int     @id @default(autoincrement())
  name  String  @unique @db.VarChar(50)
  asset asset[]
}

model building {
  id   Int    @id @default(autoincrement())
  name String @unique @db.VarChar(100)
  room room[]
}

model category {
  id                Int      @id @default(autoincrement())
  name              String   @unique @db.VarChar(100)
  //depreciation_rate Decimal? @db.Decimal(5, 2)
  asset             asset[]
}

model department {
  id        Int        @id @default(autoincrement())
  name      String     @unique @db.VarChar(100)
  phone_ext String?    @db.VarChar(20)
  employee  employee[]
}

model employee {
  id                    Int                @id @default(autoincrement())
  department_id         Int
  first_name            String             @db.VarChar(50)
  last_name             String             @db.VarChar(50)
  position              String             @db.VarChar(100)
  
  // ДОДАНІ ПОЛЯ ДЛЯ МІГРАЦІЇ 2:
  email                 String?            @unique @db.VarChar(100)
  is_active             Boolean            @default(true)

  asset                 asset[]
  department            department         @relation(fields: [department_id], references: [id], onUpdate: NoAction)
  transfer_history_from transfer_history[] @relation("TransferFromEmployee")
  transfer_history_to   transfer_history[] @relation("TransferToEmployee")
}

model room {
  id          Int      @id @default(autoincrement())
  room_number String   @db.VarChar(20)
  building_id Int
  capacity    Int?
  asset       asset[]
  building    building @relation(fields: [building_id], references: [id], onUpdate: NoAction)
  transfer_history_from transfer_history[] @relation("TransferFromRoom")
  transfer_history_to   transfer_history[] @relation("TransferToRoom")

  @@unique([room_number, building_id], map: "unique_room_in_building")
}

model transfer_history {
  id               Int       @id @default(autoincrement())
  asset_id         Int
  from_room_id     Int?
  to_room_id       Int?
  from_employee_id Int?
  to_employee_id   Int?
  transfer_date    DateTime  @default(now()) @db.Timestamp(6)

  // Зв'язки (Relations)
  asset            asset     @relation(fields: [asset_id], references: [id], onDelete: Cascade)
  from_room        room?     @relation("TransferFromRoom", fields: [from_room_id], references: [id], onUpdate: NoAction)
  to_room          room?     @relation("TransferToRoom", fields: [to_room_id], references: [id], onUpdate: NoAction)
  from_employee    employee? @relation("TransferFromEmployee", fields: [from_employee_id], references: [id], onUpdate: NoAction)
  to_employee      employee? @relation("TransferToEmployee", fields: [to_employee_id], references: [id], onUpdate: NoAction)
}
```
</details>

---

## Результати та скріншоти тестів
<details>
  <summary>ER-діагрма після всіх операцій</summary>
  <img width="649" height="437" alt="image" src="https://github.com/user-attachments/assets/e01b4879-1554-4512-8449-30eee3d62b89" />

</details>
<details>
  <summary>Додані данні в таблицю</summary>
  <img width="1095" height="271" alt="image" src="https://github.com/user-attachments/assets/8fe92ebe-6d8e-483c-ac59-938df66b7970" />

</details>
<details>
  <summary>Додаємо данні через Prisma studio</summary>
  
  <img width="560" height="166" alt="image" src="https://github.com/user-attachments/assets/f2743902-bb13-475d-aa2b-7e6f092c3fa5" />
  
  і перевірити можем через pgadmin 

  <img width="554" height="410" alt="image" src="https://github.com/user-attachments/assets/5b0e3ac4-9006-4209-a8d7-9e10fcf99725" />

</details>

---

## Висновок
В ході виконання лабораторної роботи було успішно застосовано інструменти Prisma ORM для еволюції та керування схемою бази даних PostgreSQL (`система обліку майна`). Було вирішено конфлікти розсинхронізації історії бази даних (`шляхом скидання та перестворення міграцій`) та коректно налаштовано середовище розробки з використанням актуального адаптера pg і стандартного генератора клієнта.

Використовуючи декларативний синтаксис файлу schema.prisma, було створено та послідовно застосовано три ізольовані міграції:

Додано нову таблицю `transfer_history` для фіксації історії переміщень майна з налаштуванням каскадного видалення та складних двосторонніх зв'язків (`між кімнатами та співробітниками`).

Розширено сутність співробітника (`employee`) новими полями контактів та поточного стану (`email, is_active`).

Оптимізовано таблицю категорій (`ategory`) шляхом видалення надлишкового стовпця ставки амортизації (`depreciation_rate`).

Тестування через Prisma Client (`за допомогою комплексного скрипта зі створенням довідників, майна та вкладеним записом історії переміщення`) підтвердило цілісність даних та правильність налаштованих зв'язків. Цей підхід довів ефективність та безпеку інкрементального оновлення баз даних та роботи з ORM.

