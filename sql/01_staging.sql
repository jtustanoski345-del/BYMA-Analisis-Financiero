/*
Proyecto: Análisis histórico de resultados BYMA
Período: 1T2017 - 2T2026

Archivo: 01_staging.sql

Objetivo:
Definir las tablas intermedias utilizadas para
recibir los datos financieros y el diccionario
de cuentas antes de construir el modelo relacional.

Fuente: Información financiera histórica de BYMA.
*/


--1: Creación de la tabla de importacion


create table stg_byma_importacion(
             cuenta text not null,
			 trimestre varchar(4),
			 valor numeric);

--2: Tipos y restricciones de la tabla 

select column_name,
       data_type,
	   is_nullable,
	   numeric_precision,
	   numeric_scale
from information_schema.columns
where table_schema= 'public'
and table_name= 'stg_byma_importacion'
order by ordinal_position;


--3: Creación del diccionario de cuentas

create table stg_diccionario_cuentas (
cuenta text,
categoria_financiera text,
tipo_partida text,
orden_presentacion integer
);



-- =====================================================
-- 4- IMPORTACION DE DATOS (PASO MANUAL)
-- =====================================================

-- Antes de ejecutar 02_modelo_relacional.sql,
-- importar mediante pgAdmin los archivos CSV
-- correspondientes a:

-- A) stg_byma_importacion
-- Columnas: cuenta, trimestre, valor
-- Registros esperados: 870

-- B) stg_diccionario_cuentas
-- Columnas: cuenta, categoria_financiera,
--           tipo_partida, orden_presentacion
-- Registros esperados: 23

-- Configurar correctamente encabezados,
-- delimitador, codificacion y formato decimal
-- segun las caracteristicas de cada CSV.

-- No continuar hasta verificar ambas importaciones.



--5: Verificacion del diccionario. Debe ejecutarse despues de importar datos vía archivos CSV.

select 
    count(*) as total_cuentas,
	count(distinct cuenta) as cuentas_unicas,
	count(distinct orden_presentacion) as ordenes_unicos,
	count(*) filter (
             where cuenta is null
			 or categoria_financiera is null
			 or tipo_partida is null
			 or orden_presentacion is null
	) as registros_incompletos
from stg_diccionario_cuentas;


--6: Verificacion de cuentas sin correspondencia en el diccionario

select distinct s.cuenta
from stg_byma_importacion as s
left join stg_diccionario_cuentas as d
on s.cuenta=d.cuenta
where d.cuenta is null
order by s.cuenta;


--7: Verificacion de duplicados en el diccionario

select cuenta,
       count(*) as cantidad
from stg_diccionario_cuentas
group by cuenta
having count (*) >1;
