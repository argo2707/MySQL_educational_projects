use grafs; #подключение к БД
#---------------Создание таблиц------------------
create table autors (
id_autor integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
name varchar(20) null,
surname varchar(20) null,
middle_name varchar(20) null
create table edge (
id_edge integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
value integer NULL
)
create table graf (
id_graf integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
name_graf varchar(20) null,
id_autor integer DEFAULT NULL,
constraint graf_autor foreign key (id_autor)
references autors (id_autor)
on delete set null
on update restrict
)
create table top (
id_top integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
name_top varchar(20) null,
coordinat_x integer null,
coordinat_y integer null,
width integer null,
height integer null,
id_graf integer not NULL,
constraint graf_top foreign key (id_graf)
references graf (id_graf)
on delete restrict
on update cascade
)

create table top_edge (
id_top integer NOT NULL,
id_edge integer not NULL,
primary key(id_top,id_edge),
constraint edge_ foreign key (id_edge)
references edge (id_edge)
on delete cascade
on update cascade,
constraint top_ foreign key (id_top)
references top (id_top)
on delete restrict
on update cascade
)
#------------------------------------------------

#------------Заполнение таблиц данными-----------
insert into edge(id_edge,value)
values (1,1),
(2,5),
(3,2),
(4,3),
(5,1),
(6,2),
(7,5),
(8,8),
(9,1),
(10,4);

insert into top(id_top,name_top,coordinat_x,
coordinat_y,width,height,id_graf)
values (1,'1_отказ_top',2,2,3,4,1),
(2,'2_отказ',16,10,2,3,1),
(3,'l',10,1,3,3,1),
(4,'b',5,5,1,1,1),
(5,'ошибка',2,1,1,3,2),
(6,'d',1,9,2,1,2),
(7,'c',4,6,1,1,2),
(8,'3_отказ_top',1,1,2,2,3),
(9,'d',9,7,1,1,3),
(10,'h',5,5,1,2,3),
(11,'k',0,5,2,2,4),
(12,'y',5,0,3,2,4);

insert into top_edge(id_top,id_edge,direct)
values (1,1,false),(1,2,false),(1,3,false),
(1,4,true),(2,1,true),(3,2,true),
(4,3,true),(4,4,false),(5,5,false),
(6,5,true),(5,6,false),(7,6,true),
(9,7,false),(8,7,true),(10,9,true),
(9,9,false),(10,8,false),(9,8,true),
(8,10,false),(10,10,true);

insert into autors(id_autor,name,surname,middle_name)
values (1,'Dasha','Argokova','Andreevna'),
(2,'Danila','Danilov','Danilovich'),
(3,'Marya','Vetrova','Alekseevna'),
(4,'Ivan','Ivanov','Ivanovich');

insert into graf(id_graf,name_graf,id_autor)
values (1,'One',1),
(2,'Two',2),
(3,'Three',3),
(4,'Four',1);
#------------------------------------------------

#------------Изменение данных--------------------
update autors
set surname = 'Petotv'
where surname='Ivanov'
LIMIT 1000;
#------------------------------------------------

#------------Удаление строк----------------------
delete from autors
where surname = 'Petotv'
LIMIT 1000;
#------------------------------------------------

#------------Вывод данных------------------------
/*Вершины, название/текст которых содержит слово «отказ», но не заканчивается им*/
select id_top, name_top,top.id_graf
from top
where
top.name_top like '%отказ%_';

/*Вершины, у которых нет исходящих ребер*/
select distinct top_edge.id_top, top.id_top
from top
left Join top_edge on top.id_top=top_edge.id_top and top_edge.direct=false
where top_edge.id_top is null;

/*Графы, в которых есть пара вершин, связанных ребрами в обе стороны*/
select distinct graf.id_graf
from graf
inner join top on graf.id_graf=top.id_graf
inner join top as top2 on graf.id_graf=top2.id_graf
inner JOIN top_edge on top.id_top=top_edge.id_top and top_edge.direct=false
inner JOIN top_edge as top_edge2 on top_edge2.id_edge=top_edge.id_edge and top_edge2.direct=true
inner JOIN top_edge as top_edge3 on top_edge3.id_top=top2.id_top and top_edge3.direct=false
inner join top_edge as top_edge4 on top_edge3.id_edge=top_edge4.id_edge and top.id_top=top_edge4.id_top
where top2.id_top=top_edge2.id_top and top.id_top!=top2.id_top;

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

/*Вершины, для которых есть исходящие ребра, ведущие ко всем остальным вершинам её графа*/
select distinct top.*
from top
inner join top as top3 on top.id_graf=top3.id_graf and top.id_top!=top3.id_top
where not exists
(select * from top as top2
where top.id_graf=top2.id_graf and top2.id_top!=top.id_top and not exists
(select * from top_edge
inner join top_edge as t_e on t_e.id_edge=top_edge.id_edge
where top_edge.id_top=top.id_top and t_e.id_top=top2.id_top 
and top_edge.direct=false and t_e.direct=true and t_e.id_top!=top_edge.id_top));

/*Вершины, для которых есть исходящие ребра, ведущие ко всем остальным вершинам её графа*/
#NOT IN
select distinct top.*
from top 
where top.id_top not in
(select distinct top.id_top
from top
inner join top_edge on top.id_top=top_edge.id_top
inner join top_edge as t_e on top_edge.id_edge=t_e.id_edge
inner join top as top2 on t_e.id_top=top2.id_top
where top_edge.direct=true and t_e.direct=false and top2.name_top like '%ошибка%');
#EXCEPT
select distinct top.*
from top except
select distinct top.*
from top
inner join top_edge on top.id_top=top_edge.id_top
inner join top_edge as t_e on top_edge.id_edge=t_e.id_edge
inner join top as top2 on t_e.id_top=top2.id_top
where top_edge.direct=true and t_e.direct=false and top2.name_top like '%ошибка%';
#LEFT/RIGHT JOIN
select distinct top.*
from top
left join
(select distinct top.*
from top
inner join top_edge on top.id_top=top_edge.id_top
inner join top_edge as t_e on top_edge.id_edge=t_e.id_edge
inner join top as top2 on t_e.id_top=top2.id_top
where top_edge.direct=true and t_e.direct=false and top2.name_top like '%ошибка%') ad on top.id_top=ad.id_top
where ad.id_top is null;
#------------------------------------------------

#---------------Хранимые процедуры---------------
/*При добавлении графа добавляется и автор*/
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
#Демонстрация процедуры
call graf_autor("1","2","3","4");
SELECT * FROM grafs.graf;
SELECT * FROM grafs.autors;

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
#Демонстрация процедуры


#------------------------------------------------

#------------------------------


