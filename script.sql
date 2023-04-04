use grafs;
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
