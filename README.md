# DNA Methylation Analysis Pipeline for *Heliconius erato* (v1.0)

Este repositorio contiene el flujo de trabajo bioinformático desarrollado para la identificación y caracterización de modificaciones de ADN (**5mC** y **5hmC**) en cerebros de *Heliconius erato*. El pipeline procesó ~90 millones de sitios CpG únicos, evaluando el efecto del inhibidor **RG108** sobre el paisaje epigenético.

## 1. Especificaciones Técnicas y Versiones
Para garantizar la reproducibilidad científica, se detallan las versiones validadas en este estudio:

* **Llamada de Modificaciones:** `modkit v0.5.0` (Oxford Nanopore Technologies).
* **Manejo de Alineamientos:** `samtools v1.16.1` y `minimap2 v2.24`.
* **Aritmética Genómica:** `bedtools v2.30.0`.
* **Análisis Estadístico:** `R v4.2.2` con el paquete `DSS v2.46.0` (Bioconductor).
* **Visualización:** `ggplot2`, `scales` y `patchwork`.

## 2. Metodología Visual y Toma de Decisiones
Para garantizar la transparencia en el análisis, se detallan los flujos de trabajo y los criterios técnicos adoptados:

### 2.1 Pipeline General de Análisis
Flujo completo desde el basecalling con Dorado dúplex hasta la identificación de regiones diferencialmente metiladas (DMRs).
![Pipeline General](assets/figures/A_pipeline_general.png)

### 2.2 Calibración del Umbral Probabilístico
A diferencia del umbral por defecto (0.5), se realizó una calibración empírica basada en el p10 de la distribución de modkit (0.793). Esto asegura que las llamadas sean compatibles con las tasas globales reportadas en la literatura para lepidópteros.
![Decisión Umbral](assets/figures/B_decision_umbral.png)

### 2.3 Estimación de Dispersión en DSS
Dado el diseño experimental (n=1 pooled), se adoptó el método `smoothing=TRUE` (Park & Wu, 2016) para la estimación del parámetro de dispersión, optimizando la sensibilidad en la detección de DMRs.
![Decisión Dispersión](assets/figures/C_decision_dispersion.png)

### 2.4 Lógica de Clasificación Genómica
Los sitios CpG se categorizaron mediante intersecciones jerárquicas con el archivo de anotación `Hlat.v1.1.CAT.gff3`, identificando intrones por exclusión.
![Clasificación Contexto](assets/figures/D_clasificacion_contexto.png)

## 3. Arquitectura del Proyecto (Scripts)

### Procesamiento Core (Bash)
- `scripts/bash/modkit_pileup.sh`: Ejecución de pileup para detección dual de 5mC y 5hmC.
- `scripts/bash/filter_coverage.sh`: Filtrado técnico por profundidad y probabilidad.
- `scripts/bash/prepare_dss_input.sh`: Conversión de datos al formato `(chr, pos, N, X)`.
- `scripts/bash/run_pipeline_core.sh`: Orquestador principal del flujo de trabajo.

### Análisis y Visualización (R)
- `scripts/R/dss_analysis.R`: Detección estadística de DML y DMR.
- `scripts/R/genomic_context.R`: Anotación funcional (Exones, Intrones e Intergénico).
- `scripts/R/dmr_visualization.R`: Generación de perfiles de metilación para genes candidatos.

## 4. Instrucciones de Uso
1. **Ambiente:** Recree el entorno con `mamba env create -f bioinfo.yml`.
2. **Configuración:** Actualice las rutas en `scripts/bash/config.sh`.
3. **Ejecución:** Ejecute `bash scripts/bash/run_pipeline_core.sh`.

## 5. Instituciones y Créditos
Investigación para el Máster en Bioinformática de la **Universidad Internacional de Valencia (VIU)** en colaboración con **Universidad Regional Amazónica IKIAM**.
- **Autor:** Angel Ojeda
- **Tutor:** Pablo Marín, PhD.

## 6. Licencia
Este proyecto se distribuye bajo la Licencia MIT.
