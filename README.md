# Тестовое задание open-solution

## По проекту

Реализовано в конейнерах Docker.
Честь логики для повышения произовдительности была перемещена в базу:

  1. триггеры для вычисления среднего значения в таблице posts;
  2. использовалась конструкция INSERT...ON CONFLICT для добавдения нового пользователя;
  3. запросы с использованием CTE и оконных функций, для максимальной производительности

## Задание на знание SQL

Дана таблица users вида - id, group_id

```sql
create temp table users(id bigserial, group_id bigint);
insert into users(group_id) values (1), (1), (1), (2), (1), (3);
```

1. В этой таблице, упорядоченной по ID необходимо:
2. выделить непрерывные группы по group_id с учетом указанного порядка записей (их 4)
3. подсчитать количество записей в каждой группе
4. вычислить минимальный ID записи в группе

[Пример в песочнице](https://www.db-fiddle.com/f/byav3cdfcuc2vG2gDFnGwP/5)

```sql
SELECT MIN(id) as min_id,
       group_id,
       COUNT(*) AS count
FROM (
  SELECT id,
         group_id,
         ROW_NUMBER() OVER row_all - ROW_NUMBER() OVER row_group AS gr
  FROM users
  WINDOW row_all AS (ORDER BY id),
         row_group AS (PARTITION BY group_id ORDER BY id)
  ) AS tb
GROUP BY group_id, gr
ORDER BY min_id
```
