# MySQL_educational_projects

## Физическая модель базы данных, находящаяся в третьей нормальной форме
![image](https://user-images.githubusercontent.com/79849850/232898689-8ce2125c-3a52-44e6-8879-fa53abef1cb7.png)

## В данной работе представлено:

### Создание базы данных и таблиц
````
CREATE DATABASE IF NOT EXISTS grafs;
use grafs; #подключение к БД
create table autors (
id_autor integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
name varchar(20) null,
surname varchar(20) null,
middle_name varchar(20) null
create table edge (
id_edge integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
value integer NULL
)
````
### Заполнение таблиц данными, также изменение и удаление
#### - left Join
````
/*Вершины, у которых нет исходящих ребер*/
select distinct top_edge.id_top, top.id_top
from top
left Join top_edge on top.id_top=top_edge.id_top and top_edge.direct=false
where top_edge.id_top is null;
````
#### - max и all
````
/*Ширина графа в пикселях (от максимальной сумма координаты по горизонтали с шириной отнять минимальную левую координату)*/
select max( (top.coordinat_x+top.width)) - min(top.coordinat_x) as width_graf,graf.id_graf
from graf
inner join top on graf.id_graf=top.id_graf
group by id_graf;

/*Пользователи-авторы графов с максимальных количеством вершин*/
select graf.id_autor,graf.id_graf,count(top.id_top)
from graf
inner join top on graf.id_graf=top.id_graf
group by graf.id_graf
having count(top.id_top)>=all(select count(top.id_top)
from graf as graf2
inner join top on graf2.id_graf=top.id_graf
group by graf2.id_graf);
````
#### - Также в файле [script.sql](https://github.com/argo2707/MySQL_educational_projects/blob/main/script.sql) представлены запросы с NOT IN, EXCEPT
### Запросы к таблицам
````
insert into autors(id_autor,name,surname,middle_name)
values (1,'Dasha','Argokova','Andreevna'),
(2,'Danila','Danilov','Danilovich'),
(3,'Marya','Vetrova','Alekseevna'),
(4,'Ivan','Ivanov','Ivanovich');
````
### Процедуры
#### - Добавление данных
````
*При добавлении графа добавляется и автор*/
delimiter //
Create procedure graf_autor (autor_n varchar(20),autor_s varchar(20)
,autor_m varchar(20), name_g varchar(20))
Begin
declare id_gr_new int;
declare id_au_new int;
if exists(select * from autors where autor_n=name and
autor_s=surname and autor_m=middle_name)
	then select id_autor into id_au_new from autors 
	where autor_n=name and autor_s=surname and autor_m=middle_name;
	else   begin
	insert into autors(id_autor,name,surname,middle_name) values 
	(id_au_new, autor_n,autor_s,autor_m);
    set id_au_new=(select last_insert_id());
		   end;
	end if;
insert into graf (id_graf,name_graf,id_autor) 
values (id_gr_new,name_g,id_au_new);
end;//
delimiter ;
````
#### - Каскадное удаление
````
/*При удалении вершины удаляется граф*/
delimiter //
Create procedure del_top (id_tp int)
Begin
declare id_gr_del int;
select id_graf into id_gr_del from top where id_top=id_tp;
delete from top where id_top=id_tp;
if not exists(select* from top where id_graf=id_gr_del)
then delete from graf where id_graf=id_gr_del;
end if;
end;//
delimiter ;
````
#### - Вычисление и возврат значения агрегатной функции
````
/*Максимальное значение ширины вершин*/
delimiter //
create function max_width() returns int deterministic
begin
declare mx_w int;
set mx_w=(select ifnull(max(width),0) from top);
return mx_w;
end;//
delimiter ;
````
### Триггеры для событий (insert, delete, update) до и после
````
/*After insert (при добавлении графа увеличивается количество графов в таблице автор)*/
delimiter //
create trigger my_triger3
after insert on graf for each row
begin
update autors 
set count_graf=count_graf+1
where id_autor=new.id_autor;
end//
delimiter ;
````

### Навигация по script.sql
1. Строки 1-50 - Создание БД
2. Строки 51-113 - Заполнение БД
3. Строки 115-198 - Запросы к БД 
4. Строки 200-301 - Процедуры
5. Строки 303-378 - Триггеры для событий (insert, delete, update) до и после
