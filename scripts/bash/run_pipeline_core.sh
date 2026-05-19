#!/bin/bash
# =============================================
# run_pipeline_core.sh
# Ejecuta todos los pasos bash del pipeline
# =============================================
set -euo pipefail
source scripts/bash/config.sh

echo "=== Iniciando Pipeline Core ==="
echo "    Threads:      ${THREADS}"
echo "    Cobertura:    ${COVERAGE_MIN}x"
echo "    Umbral mod:   ${MOD_THRESHOLD}"
echo "    BAM dir:      ${BAM_DIR}"
echo ""

mkdir -p "${BAM_DIR}" "${ANNOTATION_DIR}"

# Paso 1: QC técnico de los modBAM
# Input:  Hlat.C.ONT.modmapped.bam, Hlat.T.ONT.modmapped.bam
# Output: samtools_stats_control.txt, samtools_stats_treatment.txt
# Métricas: reads totales, mapeados, longitud media, Q-score
bash scripts/bash/samtools_stats.sh

# Paso 2: Llamada de modificaciones con modkit pileup
# Input:  modBAM files (etiquetas MM/ML de Dorado duplex)
# Output: Hlat.C.cpg.bed, Hlat.T.cpg.bed (formato BEDMethyl)
# Flags:  --cpg, --mod-thresholds m:${MOD_THRESHOLD} h:${MOD_THRESHOLD}, --threads ${THREADS}
bash scripts/bash/modkit_pileup.sh

# Paso 3: Filtrado por cobertura mínima
# Input:  Hlat.C.cpg.bed, Hlat.T.cpg.bed
# Output: Hlat.[C|T].5mC.cov${COVERAGE_MIN}.bed, Hlat.[C|T].5hmC.cov${COVERAGE_MIN}.bed
# Nota:   col 4 = código de modificación (m=5mC, h=5hmC); col 10 = cobertura total
bash scripts/bash/filter_coverage.sh "${COVERAGE_MIN}"

# Paso 4: Intersección de sitios comunes (control ∩ tratamiento)
# Input:  BEDMethyl filtrados del paso 3
# Output: sitios presentes en ambas condiciones (requerido para DSS)
# Nota:   secuencial (no paralelo) para evitar presión de memoria en WSL2
bash scripts/bash/common_sites.sh

# Paso 5: Preparación del input para DSS
# Input:  sitios comunes del paso 4
# Output: 4 tablas (chr, pos_1based, cobertura, reads_modificados)
# Nota:   col 12 = reads modificados (NO col 11, que es porcentaje)
#         posición convertida de 0-based BEDMethyl a 1-based para DSS
bash scripts/bash/prepare_dss_input.sh

# Paso 6: Generación de bedGraphs para IGV
# Input:  BEDMethyl filtrados (paso 3); col 11 = % metilación
# Output: 4 bedGraph (5mC + 5hmC × control + tratamiento)
# Colores IGV: T.5mC=#E8470A  C.5mC=#888780  T.5hmC=#1D6FA4  C.5hmC=#78C4A8
bash scripts/bash/generate_bedgraphs.sh

# Paso 7: Tabla de longitudes cromosómicas desde el índice .fai
# Input:  archivo .fai de la referencia (longitudes por scaffold)
# Output: longitudes a nivel cromosoma (Mb) para normalización de DMRs
# Nota:   sufijo de scaffold eliminado con gsub("_[0-9]+$","") antes de agregar
bash scripts/bash/genome_sizes.sh

echo ""
echo "=== Pipeline Core completado correctamente ==="
echo "    Salidas en: ${BAM_DIR}/"