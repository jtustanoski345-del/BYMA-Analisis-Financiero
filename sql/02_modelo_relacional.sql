/*
Proyecto: Análisis histórico de resultados BYMA
Período: 1T2017 - 2T2026

Archivo: 02_modelo_relacional.sql

Objetivo:
Construir el modelo estrella de datos con fact_resultados_byma, dim_cuenta y dim_fecha

Dependencias:
- stg_byma_importacion
- stg_diccionario_cuentas

Ejecucion:
Solo sobre una base preparada para reconstruir el modelo.
No ejecutar sobre la base de produccion ya cargada.
*/


--1: Dimension de cuentas financieras (creacion de dim_cuenta)

create table dim_cuenta (
             id_cuenta bigint generated always as identity primary key,
             cuenta text not null unique,
			 categoria_financiera text not null,
			 tipo_partida text not null,
			 orden_presentacion integer not null unique
			 ); 


--2: Dimension temporal (creacion de dim_fecha)

create table dim_fecha(
             id_periodo bigint generated always as identity primary key,
			 trimestre varchar(4) not null unique,
			 año integer not null,
			 numero_trimestre integer not null check (numero_trimestre between 1 and 4),
			 orden_trimestre integer not null unique
);



--3: Construccion Tabla de hechos (creacion de fact_resultados_byma)

create table fact_resultados_byma(
             id_cuenta bigint not null,
			 id_periodo bigint not null,
			 valor numeric not null,
			 
			 constraint fk_id_cuenta
			 foreign key (id_cuenta)
			 references dim_cuenta(id_cuenta),
			 
			 constraint fk_id_periodo
			 foreign key (id_periodo)
			 references dim_fecha(id_periodo),

			 constraint uq_cuenta_periodo
			 unique (id_cuenta, id_periodo)
);


--4: Carga de valores para dim_cuenta

insert into dim_cuenta (
            cuenta, 
			categoria_financiera,
			tipo_partida,
			orden_presentacion
) 
select 
            c.cuenta,
			d.categoria_financiera,
			d.tipo_partida,
			d.orden_presentacion
from (
     select distinct cuenta
	 from stg_byma_importacion
) as c inner join stg_diccionario_cuentas as d
  on c.cuenta = d.cuenta 
order by d.orden_presentacion;


--5: Carga de valores para dim_fecha 

insert into dim_fecha(
            trimestre,
			año,
			numero_trimestre,
			orden_trimestre
)
with periodos as (
            select distinct 
			trimestre,
			cast(left(trimestre,1) as integer) as numero_trimestre,
			2000 + cast(right(trimestre,2) as integer) as año
			from stg_byma_importacion

)
select trimestre,
       año,
	   numero_trimestre,
	   año * 4 + numero_trimestre as orden_trimestre
from periodos 
order by orden_trimestre;


--6: Carga de valores para la tabla de hechos fact_resultados_byma

insert into fact_resultados_byma (
            id_cuenta,
			id_periodo,
			valor
)
select 
     c.id_cuenta,
	 t.id_periodo,
	 s.valor
from stg_byma_importacion as s
inner join dim_cuenta as c
on s.cuenta=c.cuenta 
inner join dim_fecha as t
on s.trimestre=t.trimestre; 
