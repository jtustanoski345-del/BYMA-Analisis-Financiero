# Proyecto BYMA 

Registro de medidas DAX originales
Fuente: Modelo Power-BI definitivo.

Las fórmulas corresponden a las medidas originales utilizadas en el modelo Power BI del proyecto BYMA. 
Se documentan como referencia técnica y no constituyen un script ejecutable de manera independiente.


# MEDIDAS DAX UTILIZADAS:


## 1: Medidas base

### Ingresos de mercado
```dax
Ingresos Mercado SQL = 
CALCULATE(
    SUM(fact_resultados_byma[valor]),
    dim_cuenta[cuenta] = "Ingresos Mercado"
)
```
### Ingresos de depositaria
```dax
Ingresos Depositaria SQL = 
CALCULATE(
    SUM(fact_resultados_byma[valor]),
    dim_cuenta[cuenta] = "Ingresos Depositaria"
)
```
### Ingresos operativos
```dax
Ingresos Operativos SQL = 
CALCULATE(
    SUM(fact_resultados_byma[valor]),
    dim_cuenta[cuenta] = "Total ingresos operativos"
)
```
### Ingresos de negocios principales
```dax
Ingresos Negocios Principales SQL = 
CALCULATE(
    SUM(fact_resultados_byma[valor]),
    dim_cuenta[cuenta] IN {
        "Ingresos Depositaria",
        "Ingresos Mercado"
    }
)
```
### Ingresos del año anterior
```dax
Ingresos Año Anterior SQL = 
VAR PeriodoActual =
    SELECTEDVALUE(dim_fecha[orden_trimestre])
RETURN
IF(
    NOT ISBLANK(PeriodoActual),
    CALCULATE(
        [Ingresos Operativos SQL],
        REMOVEFILTERS(dim_fecha),
        dim_fecha[orden_trimestre] = PeriodoActual - 4
    )
)
```
### Ingresos del trimestre anterior
```dax
Ingresos Trimestre Anterior SQL = 
VAR PeriodoActual =
    SELECTEDVALUE(dim_fecha[orden_trimestre])
RETURN
IF(
    NOT ISBLANK(PeriodoActual),
    CALCULATE(
        [Ingresos Operativos SQL],
        REMOVEFILTERS(dim_fecha),
        dim_fecha[orden_trimestre] = PeriodoActual - 1
    )
)
```
### Otros ingresos operativos 
```dax
Otros Ingresos Operativos SQL = 
CALCULATE(
    SUM(fact_resultados_byma[valor]),
    dim_cuenta[cuenta] = "Otros Ingresos Operativos"
)
```
### Gastos operativos
```dax
Gastos Operativos SQL = 
CALCULATE(
    SUM(fact_resultados_byma[valor]),
    dim_cuenta[cuenta] = "Total gastos operativos"
)
```
### Gastos totales, que incluyen depreciaciones y amortizaciones
```dax
Gastos Totales Incl D&A SQL = 
[Gastos Operativos SQL] +
CALCULATE(
    SUM(fact_resultados_byma[valor]),
    dim_cuenta[cuenta] = "D&A"
)
```
### EBITDA publicado por BYMA
```dax
EBITDA Publicado SQL = 
CALCULATE(
    SUM(fact_resultados_byma[valor]),
    dim_cuenta[cuenta] = "EBITDA"
)
```


## 2: Medidas de resultados y rentabilidad

### EBIT calculado
```dax
EBIT Calculado SQL = 
[Ingresos Operativos SQL] -
[Gastos Totales Incl D&A SQL]
```
### EBITDA calculado
```dax
EBITDA Calculado SQL = 
[Ingresos Operativos SQL] - [Gastos Operativos SQL]
```
### Margen EBIT
```dax
Margen EBIT SQL = 
DIVIDE(
    [EBIT Calculado SQL],
    [Ingresos Operativos SQL]
)
```
### Margen EBITDA
```dax
Margen EBITDA SQL = 
DIVIDE(
    [EBITDA Calculado SQL],
    [Ingresos Operativos SQL]
)
```
### Ratio Gastos totales/ ingresos operativos
```dax
Ratio Gastos Incl DA SQL = 
DIVIDE(
    [Gastos Totales Incl D&A SQL],
    [Ingresos Operativos SQL]
)
```
### Ratio Gastos operativos/ ingresos operativos
```dax
Ratio Gastos Operativos SQL = 
DIVIDE(
    [Gastos Operativos SQL],
    [Ingresos Operativos SQL]
)
```


## 3: Composición de ingresos 

### Participación de mercado
```dax
Participacion Mercado SQL = 
DIVIDE(
    [Ingresos Mercado SQL],
    [Ingresos Operativos SQL]
)
```
### Participación de depositaria
```dax
Participacion Depositaria SQL = 
DIVIDE(
    [Ingresos Depositaria SQL],
    [Ingresos Operativos SQL]
)
```
### Participación de otros
```dax
Participacion Otros SQL = 
DIVIDE(
    [Otros Ingresos Operativos SQL],
    [Ingresos Operativos SQL]
)
```
### Participación de mercado s/negocios principales
```dax
Participacion Mercado Negocios Principales SQL = 
DIVIDE(
    [Ingresos Mercado SQL],
    [Ingresos Negocios Principales SQL]
)
```
### Participación de depositaria s/negocios principales
```dax
Participacion Depositaria Negocios Principales SQL = 
DIVIDE(
    [Ingresos Depositaria SQL],
    [Ingresos Negocios Principales SQL]
)
```


## 4: Análisis temporal

### Variación de ingresos trimestre a trimestre

```dax
Variacion Ingresos QoQ SQL = 
DIVIDE(
    [Ingresos Operativos SQL]
        - [Ingresos Trimestre Anterior SQL],
    [Ingresos Trimestre Anterior SQL]
)
```
### Variación de ingresos interanual
```dax
Variacion Ingresos YoY SQL = 
DIVIDE(
    [Ingresos Operativos SQL]
        - [Ingresos Año Anterior SQL],
    [Ingresos Año Anterior SQL]
)
```
**Nota metodológica:** 
Las medidas QoQ y YoY fueron diseñadas para contextos de evaluación que identifican un único trimestre mediante SELECTEDVALUE(). Los resultados representan variaciones nominales de los ingresos operativos históricos y no deben interpretarse como crecimiento real ajustado por inflación.

## 5: Indicadores anuales (para el año 2025)

### Margen EBIT año 2025
```dax
Margen EBIT 2025 KPI = 
CALCULATE(
    [Margen EBIT SQL],
    REMOVEFILTERS(dim_fecha),
    dim_fecha[año] = 2025
)
```
### Margen EBITDA año 2025
```dax
Margen EBITDA 2025 KPI = 
CALCULATE(
    [Margen EBITDA SQL],
    REMOVEFILTERS(dim_fecha),
    dim_fecha[año] = 2025
)
```


## 6: Medidas de auditoría y control 

### Control de composición de ingresos
```dax
Diferencia Composicion Ingresos SQL = 
[Ingresos Operativos SQL]
    - [Ingresos Depositaria SQL]
    - [Ingresos Mercado SQL]
    - [Otros Ingresos Operativos SQL]
```
### Control diferencia de EBITDA 
```dax
Diferencia EBITDA SQL = 
[EBITDA Calculado SQL] - [EBITDA Publicado SQL]
```
### Conciliación del EBITDA según tolerancia establecida
```dax
Estado Conciliacion EBITDA SQL = 
VAR Diferencia =
    ABS([Diferencia EBITDA SQL])
RETURN
SWITCH(
    TRUE(),
    ISBLANK(Diferencia), BLANK(),
    Diferencia > 0.005, "Revisar",
    "Conciliado"
)
```
### Ingresos negativos
```dax
Otros Ingresos Negativos SQL = 
IF(
    [Otros Ingresos Operativos SQL] < 0,
    1,
    0
)
```
### Diferencia relativa con respecto al EBITDA publicado
```dax
Diferencia Relativa EBITDA SQL = 
VAR Diferencia =
    ABS([Diferencia EBITDA SQL])
VAR EBITDAPublicado =
    ABS([EBITDA Publicado SQL])
RETURN
    DIVIDE(
        Diferencia,
        EBITDAPublicado
    )
```
### Detección de excepciones EBITDA
```dax
Excepcion EBITDA Auditoria = 
VAR Diferencia =
    ABS([Diferencia EBITDA SQL])
RETURN
    IF(
        NOT ISBLANK([Diferencia EBITDA SQL])
            && Diferencia > 0.005,
        1,
        0
    )
```
**Nota metodológica:** 
La conciliación del EBITDA se evalúa individualmente para cada trimestre, aplicando una tolerancia operativa de 0,005 millones de ARS. Esta evaluación evita que diferencias positivas y negativas correspondientes a distintos períodos se compensen al agregarse.

**Nota sobre los archivos Power BI:** 
Las medidas documentadas corresponden al modelo principal del proyecto BYMA, con excepción de `Diferencia Relativa EBITDA SQL` y `Excepcion EBITDA Auditoria`, desarrolladas en una copia del archivo PBIX para construir la tabla complementaria de auditoría del EBITDA. Ambas versiones utilizan el mismo modelo relacional de datos.
