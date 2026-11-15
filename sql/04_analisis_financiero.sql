/*
Proyecto: BYMA - Analisis historico financiero
Archivo: 04_analisis_financiero.sql

Objetivo:
Analizar la evolucion nominal de los ingresos
operativos mediante consultas SQL.

Dependencias:
- dim_cuenta
- dim_fecha
- fact_resultados_byma

Nota:
Los resultados corresponden a cifras historicas
nominales y no representan crecimiento real.
*/


--A: Serie temporal de ingresos

select t.trimestre,
       t.año,
	   t.numero_trimestre,
	   f. valor as ingresos_operativos
from fact_resultados_byma as f
inner join dim_fecha as t
on f.id_periodo=t.id_periodo
inner join dim_cuenta as c
on f.id_cuenta=c.id_cuenta
where c.cuenta='Total ingresos operativos'
order by t.orden_trimestre;


--B: Comparaciones intertemporales

with serie as(
     select 
	 t.trimestre,
	 t.orden_trimestre,
	 f.valor as ingresos_operativos
	 from fact_resultados_byma as f
	 inner join dim_fecha as t 
	 on f.id_periodo=t.id_periodo
	 inner join dim_cuenta as c
	 on f.id_cuenta=c.id_cuenta
	 where c.cuenta='Total ingresos operativos'
)
     select trimestre,
	        ingresos_operativos,
			lag(ingresos_operativos,1)
			over (order by orden_trimestre)
			as ingresos_trimestre_anterior,

			lag(ingresos_operativos,4)
			over (order by orden_trimestre)
			as ingresos_año_anterior

from serie
order by orden_trimestre;


--C: Variaciones nominales trimestre a trimestre (QoQ) e interanual (YoY)

with serie as(
     select 
	 t.trimestre,
	 t.orden_trimestre,
	 f.valor as ingresos_operativos
   from fact_resultados_byma as f
   inner join dim_fecha as t
   on f.id_periodo=t.id_periodo
   inner join dim_cuenta as c
   on f.id_cuenta=c.id_cuenta
   where c.cuenta='Total ingresos operativos'
),
comparaciones as (
   select trimestre,
          orden_trimestre,
		  ingresos_operativos,
		  lag(ingresos_operativos,1)
			over (order by orden_trimestre)
			as ingresos_trimestre_anterior,

			lag(ingresos_operativos,4)
			over (order by orden_trimestre)
			as ingresos_año_anterior

	from serie
)
select trimestre,
        ingresos_operativos,
		ingresos_trimestre_anterior,
		ingresos_año_anterior,
		
		100.0*(ingresos_operativos-ingresos_trimestre_anterior)/nullif(ingresos_trimestre_anterior,0)
		as variacion_qoq_nominal_pct,

		100.0*(ingresos_operativos-ingresos_año_anterior)/nullif(ingresos_año_anterior,0)
		as variacion_yoy_nominal_pct

from comparaciones
order by orden_trimestre;
