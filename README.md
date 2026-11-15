# BYMA — Análisis financiero histórico (2017–2T2026)

Proyecto de análisis de la rentabilidad operativa y composición de ingresos de Bolsas y Mercados Argentinos (BYMA), desarrollado a partir de información financiera histórica.

**Herramientas:** PostgreSQL, SQL, Power Query y Power BI (DAX).

**Datos analizados:** 38 trimestres, 23 cuentas financieras y 870 observaciones.

**Contenido del repositorio:**
- `informe/`: informe financiero con resultados, metodología y limitaciones.
- `sql/`: scripts de construcción del modelo, validaciones y análisis temporal.
- `dax/`: documentación de las medidas utilizadas en Power BI.

**Principales resultados:** evolución de los márgenes EBITDA y EBIT, cambios en la participación relativa de Mercado y Depositaria y conciliaciones financieras.

**Nota metodológica:** el análisis utiliza cifras históricas nominales, sin reexpresión integral bajo NIC 29. La reconstrucción de la base requiere importar previamente los archivos CSV utilizados.

### Datos y reproducibilidad

El proyecto utiliza información financiera histórica publicada por Bolsas y Mercados Argentinos (BYMA), correspondiente al período 1T2017–2T2026.

El repositorio incluye el diccionario de clasificación de cuentas elaborado para el modelo relacional. La serie financiera utilizada se obtuvo de la sección de información financiera de BYMA y fue transformada mediante Power Query.

Los scripts SQL permiten reconstruir el modelo relacional, previa importación de los archivos CSV correspondientes. La redistribución del archivo financiero procesado queda sujeta a las condiciones de utilización de la información de origen.

**Fuente:** https://www.byma.com.ar/relacion-con-inversores/informacion-financiera

### Uso de herramientas de inteligencia artificial

Durante el desarrollo de este proyecto se utilizó ChatGPT como herramienta de asistencia técnica y aprendizaje, principalmente para orientar la construcción de consultas SQL y medidas DAX, resolver dudas, revisar procedimientos y mejorar la documentación.

El procesamiento de los datos, la implementación del modelo en PostgreSQL y Power BI, la ejecución de consultas y las comprobaciones de resultados se realizaron mediante trabajo práctico sobre las herramientas correspondientes, con verificaciones adicionales frente a los datos originales.

Por lo tanto, el proyecto refleja un proceso de aprendizaje y aplicación práctica de herramientas de análisis financiero y de datos, desarrollado con asistencia de IA y sometido a comprobaciones técnicas y financieras.
