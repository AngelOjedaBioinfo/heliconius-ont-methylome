#!/bin/bash
# =============================================
# filter_coverage.sh
# Filtrado por cobertura mínima
#
# Usage: bash filter_coverage.sh <min_coverage>
# Example: bash filter_coverage.sh 10
#
# Si no se pasa argumento, usa COVERAGE_MIN de config.sh
# =============================================
set -euo pipefail
source scripts/bash/config.sh

# Usar argumento de línea de comandos si se proporciona,
# si no, usar el valor de config.sh
MIN_COV="${1:-$COVERAGE_MIN}"

cd "${BAM_DIR}"

echo "Filtrando sitios con cobertura >= ${MIN_COV}x..."

awk -v cov="$MIN_COV" '$4 == "m" && $10 >= cov' Hlat.C.cpg.bed > Hlat.C.5mC.cov${MIN_COV}.bed &
awk -v cov="$MIN_COV" '$4 == "h" && $10 >= cov' Hlat.C.cpg.bed > Hlat.C.5hmC.cov${MIN_COV}.bed &
awk -v cov="$MIN_COV" '$4 == "m" && $10 >= cov' Hlat.T.cpg.bed > Hlat.T.5mC.cov${MIN_COV}.bed &
awk -v cov="$MIN_COV" '$4 == "h" && $10 >= cov' Hlat.T.cpg.bed > Hlat.T.5hmC.cov${MIN_COV}.bed &

wait

echo "Filtrado completado."
echo "  Control 5mC:    $(wc -l < Hlat.C.5mC.cov${MIN_COV}.bed) sitios"
echo "  Control 5hmC:   $(wc -l < Hlat.C.5hmC.cov${MIN_COV}.bed) sitios"
echo "  Treatment 5mC:  $(wc -l < Hlat.T.5mC.cov${MIN_COV}.bed) sitios"
echo "  Treatment 5hmC: $(wc -l < Hlat.T.5hmC.cov${MIN_COV}.bed) sitios"