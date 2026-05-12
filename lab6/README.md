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
npx prisma init --datasorce-provider postgresql
```
перед виконанням наступної команди треба налаштувати DATABASE_URL в .env 
```
npx prisma db pull
```
В ході виконання db pull, Prisma успішно зчитала поточні таблиці бази даних у новий файл схеми schema.prisma. Було вирішено проблему розсинхронізації (Drift detected) шляхом створення базової лінії (Baselining) для існуючих таблиць, щоб Prisma почала вважати існуючу структуру початковою точкою історії.

---

## Застосування міграцій 
- Міграція 1(`add-user-notes-table`)Створено нову модель chat_message для повідомлень під час партії.
- Міграція 2(`add-is-premium-field`) додаємо поле avatar_url та логічний прапорець is_active для гравця.
- Міграція 3(`drop-transaction-description`) У моделі game закомнтовуємо (`прибираємо`) інформацію про турніри бо їх підримка поки не планується в проекті. 

Кожна зміна була ізольована та застосована командою npx prisma migrate dev --name <назва_міграції>, що згенерувало відповідні SQL-файли у папці prisma/migrations/.

---

## Перероблений дизайн схеми 
Нижче представлено готовий код фінальної схеми Prisma з урахуванням усіх застосованих міграцій.
<details>
<summary>Переглянути фінальний schema.prisma </summary>
  
generator client {
  provider = "prisma-client"
  output   = "../generated/prisma"
}

datasource db {
  provider = "postgresql"
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model friendship {
  user1_id                           Int
  user2_id                           Int
  status                             String?   @default("pending") @db.VarChar(20)
  created_at                         DateTime? @default(now()) @db.Timestamp(6)
  player_friendship_user1_idToplayer player    @relation("friendship_user1_idToplayer", fields: [user1_id], references: [id], onDelete: Cascade, onUpdate: NoAction)
  player_friendship_user2_idToplayer player    @relation("friendship_user2_idToplayer", fields: [user2_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@id([user1_id, user2_id])
}

model game {
  id                                  Int            @id @default(autoincrement())
  white_player_id                     Int
  black_player_id                     Int?
  time_control_id                     Int
  /// tournament_id                   Int?
  played_at                           DateTime?      @default(now()) @db.Timestamp(6)
  result_id                           Int?
  game_result                         game_result?   @relation(fields: [result_id], references: [id], onDelete: Restrict, onUpdate: NoAction, map: "fk_game_result")
  player_game_black_player_idToplayer player?        @relation("game_black_player_idToplayer", fields: [black_player_id], references: [id], onDelete: Restrict, onUpdate: NoAction)
  time_control                        time_control   @relation(fields: [time_control_id], references: [id], onUpdate: NoAction)
  /// tournament                      tournament?  @relation(fields: [tournament_id], references: [id], onUpdate: NoAction)
  player_game_white_player_idToplayer player         @relation("game_white_player_idToplayer", fields: [white_player_id], references: [id], onUpdate: NoAction)
  move                                move[]
  chat_message                        chat_message[]
}

model game_result {
  id          Int    @id @default(autoincrement())
  code        String @unique @db.VarChar(20)
  description String @db.VarChar(50)
  game        game[]
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model move {
  game_id     Int
  move_number Int
  notation    String @db.VarChar(10)
  game        game   @relation(fields: [game_id], references: [id], onDelete: Cascade, onUpdate: NoAction)

  @@id([game_id, move_number])
}

/// This table contains check constraints and requires additional setup for migrations. Visit https://pris.ly/d/check-constraints for more info.
model player {
  id                                     Int            @id @default(autoincrement())
  username                               String         @unique @db.VarChar(50)
  email                                  String         @unique @db.VarChar(100)
  password_hash                          String         @db.VarChar(255)
  rating                                 Int            @default(1200)
  avatar_url                             String?        @db.VarChar(255)
  is_active                              Boolean        @default(true)
  friendship_friendship_user1_idToplayer friendship[]   @relation("friendship_user1_idToplayer")
  friendship_friendship_user2_idToplayer friendship[]   @relation("friendship_user2_idToplayer")
  game_game_black_player_idToplayer      game[]         @relation("game_black_player_idToplayer")
  game_game_white_player_idToplayer      game[]         @relation("game_white_player_idToplayer")
  chat_message                           chat_message[]
}



model time_control {
  id               Int    @id @default(autoincrement())
  name             String @db.VarChar(50)
  initial_time_sec Int
  increment_sec    Int
  game             game[]
}

model tournament {
  id         Int      @id @default(autoincrement())
  title      String   @db.VarChar(100)
  start_date DateTime @db.Timestamp(6)
}

model chat_message {
  id        Int      @id @default(autoincrement())
  game_id   Int
  player_id Int
  message   String   @db.Text
  sent_at   DateTime @default(now()) @db.Timestamp(6)
  game      game     @relation(fields: [game_id], references: [id], onDelete: Cascade)
  player    player   @relation(fields: [player_id], references: [id], onDelete: Cascade)
}
</details>

---

## Результати та скріншоти тестів
<details>
  <summary>ER-діагрма після всіх операцій</summary>
  <img width="1193" height="748" alt="image" src="https://github.com/user-attachments/assets/3610c135-bcc3-43cf-a03e-dd3a8f01eec4" />
  
  до них були відповідні звязки між tournament і game
</details>
<details>
  <summary>Додані данні в нову таблицю</summary>
 <img width="1302" height="449" alt="image" src="https://github.com/user-attachments/assets/93d57bb9-75f0-40a8-a191-98915078b414" />
</details>
<details>
  <summary>Додаємо данні через Prisma studio</summary>
  <img width="1675" height="255" alt="image" src="https://github.com/user-attachments/assets/dd0d6858-61ab-4678-9d01-c36812d0d8ed" />
  і перевірити можем через pgadmin 
  <img width="1297" height="163" alt="image" src="https://github.com/user-attachments/assets/81852910-de25-4712-9bf9-4c70f17e63b5" />
</details>

---

## Висновок
В ході виконання лабораторної роботи було успішно застосовано інструменти Prisma ORM для еволюції та керування схемою бази даних PostgreSQL. Було виконано зворотний інжиніринг поточної БД (за допомогою команди db pull), вирішено конфлікти розсинхронізації історії бази даних та коректно налаштовано середовище розробки з використанням актуального адаптера pg.
Використовуючи декларативний синтаксис файлу schema.prisma, було створено та застосовано три ізольовані міграції:

- Додано нову таблицю chat_message з налаштуванням каскадних зв'язків.

- Розширено сутність player новими полями стану та профілю (avatar_url, is_active).

- Оптимізовано таблицю game шляхом видалення надлишкового стовпця.
  
Тестування через Prisma Client підтвердило цілісність даних та правильність налаштованих зв'язків. Цей підхід довів ефективність та безпеку інкрементального оновлення виробничих баз даних.

