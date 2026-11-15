/*
Proyecto: BYMA - Analisis historico financiero
Archivo: 03_validaciones.sql

Objetivo:
Verificar cobertura, integridad relacional,
consistencia de importes y conciliaciones financieras.

Dependencias:
- 01_staging.sql
- 02_modelo_relacional.sql
- Archivos CSV previamente importados

IMPORTANTE:
Este archivo contiene consultas de lectura (SELECT).
No modifica las tablas existentes.
*/



--A: Cobertura y completitud del staging

select
     count(*) as total_registros,
	 count(distinct cuenta) as cuentas_unicas,
	 count(distinct trimestre) as trimestres,
	 count (*) filter (where cuenta is null) as cuentas_nulas,
	 count (*) filter (where trimestre is null) as trimestres_nulos,
	 count (*) filter (where valor is null) as valores_nulos
from stg_byma_importacion;


--B1: duplicados cuenta-trimestre

select cuenta,
       trimestre,
	   count(*) as cantidad
from stg_byma_importacion
group by cuenta, trimestre
having count (*) > 1; 


--B2: Combinaciones faltantes

with combinaciones_esperadas as(
     select c.cuenta,
	        t.trimestre
	 from (
     select distinct cuenta
	 from stg_byma_importacion
	 ) as c
	 
	 cross join(
     select distinct trimestre
	 from stg_byma_importacion
	 ) as t	 
)
select 
     e.cuenta,
	 e.trimestre
from combinaciones_esperadas as e
left join stg_byma_importacion as s
on e.cuenta=s.cuenta
and e.trimestre=s.trimestre
where s.cuenta is null 
order by e.cuenta, e.trimestre; 


--C1: control de dimension de cuentas

select 
     count(*) as total_cuentas,
	 count(distinct cuenta) as cuentas_unicas,
	 count (distinct orden_presentacion) as ordenes_unicos,
	 count(*) filter (
     where categoria_financiera is null
	 or tipo_partida is null
	 or orden_presentacion is null
	 ) as clasificaciones_incompletas
from dim_cuenta;


--C2: control de dimensión temporal 

select 
    count(*) as total_periodos,
	count (distinct trimestre) as trimestres_unicos,
	count (distinct orden_trimestre) as ordenes_unicos,
	min (orden_trimestre) as primer_orden,
	max (orden_trimestre) as ultimo_orden
from dim_fecha;


--C3: Continuidad de la serie temporal

select count(*) as total_periodos,
max(orden_trimestre) - min(orden_trimestre) + 1
as periodos_esperados
from dim_fecha;


--D1: Cobertura de tabla de hechos

select
    count (*) as total_registro,
	count (distinct id_cuenta) as cuentas,
	count (distinct id_periodo) as periodos
from fact_resultados_byma;


--D2: Verificación de claves foraneas

select
    count (*) filter (
    where c.id_cuenta is null 
	) as cuentas_huerfanas,

	count (*) filter (
    where t.id_periodo is null
	) as periodos_huerfanos

from fact_resultados_byma as f
left join dim_cuenta as c
on f.id_cuenta=c.id_cuenta
left join dim_fecha as t 
on f.id_periodo=t.id_periodo;


--E: Conciliacion entre staging y tabla de hechos

select
    count(*) as registros_comparados,
	count(*) filter (
    where f.valor is distinct from s.valor 
	) as valores_diferentes

from fact_resultados_byma as f 
inner join dim_cuenta as c
on f.id_cuenta=c.id_cuenta
inner join dim_fecha as t 
on f.id_periodo=t.id_periodo
inner join stg_byma_importacion as s
on c.cuenta=s.cuenta
and t.trimestre=s.trimestre;


--F: Conciliación EBITDA

with resultados as(
     select trimestre,
	 max (valor) filter(
     where cuenta= 'Total ingresos operativos'
	 ) as ingresos,
	 max (valor) filter (
     where cuenta= 'Total gastos operativos'
	 ) as gastos,
	 max (valor) filter (
     where cuenta = 'EBITDA'
	 ) as ebitda_publicado
from stg_byma_importacion
group by trimestre
),
conciliacion as(
     select 
	 trimestre,
	 ingresos,
	 gastos,
	 ebitda_publicado,
	 ingresos-gastos as ebitda_calculado,
	 ingresos-gastos-ebitda_publicado as diferencia_ebitda
	 from resultados
)
select trimestre,
       ingresos,
	   gastos,
	   ebitda_publicado,
	   ebitda_calculado,
	   diferencia_ebitda,
	   100*ABS(diferencia_ebitda)/nullif(abs(ebitda_publicado),0)
	   as diferencia_relativa_pct

from conciliacion
where abs(diferencia_ebitda)>0.005
order by trimestre;


--G (Adicional): Verificacion de que gastos,ingresos y EBITDA estan presentes en los 38 periodos

select t.trimestre,
       count(distinct s.cuenta) as cuentas_presentes
	   from dim_fecha as t 
	   left join stg_byma_importacion as s
	   on t.trimestre=s.trimestre
	   and s.cuenta in ('Total ingresos operativos', 
	                    'Total gastos operativos',
						'EBITDA')
group by t.trimestre,t.orden_trimestre
having count(distinct s.cuenta) <> 3
order by t.orden_trimestre;
 



















	