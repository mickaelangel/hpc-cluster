#!/bin/bash
# ============================================================================
# Tests Applications - Cluster HPC
# Tests automatisés des applications scientifiques
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TESTS APPLICATIONS${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. TEST GROMACS
# ============================================================================
echo -e "\n${YELLOW}[1/4] Test GROMACS...${NC}"

if command -v gmx &> /dev/null || module avail gromacs 2>&1 | grep -q gromacs; then
    module load gromacs/2023.2 2>/dev/null || true
    if gmx --version &> /dev/null; then
        echo -e "${GREEN}  ✅ GROMACS fonctionnel${NC}"
    else
        echo -e "${YELLOW}  ⚠️  GROMACS installé mais non fonctionnel${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  GROMACS non installé${NC}"
fi

# ============================================================================
# 2. TEST OPENFOAM
# ============================================================================
echo -e "\n${YELLOW}[2/4] Test OpenFOAM...${NC}"

if module avail openfoam 2>&1 | grep -q openfoam; then
    module load openfoam/2312 2>/dev/null || true
    if command -v simpleFoam &> /dev/null || foamInfo &> /dev/null; then
        echo -e "${GREEN}  ✅ OpenFOAM fonctionnel${NC}"
    else
        echo -e "${YELLOW}  ⚠️  OpenFOAM installé mais non fonctionnel${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  OpenFOAM non installé${NC}"
fi

# ============================================================================
# 3. TEST QUANTUM ESPRESSO
# ============================================================================
echo -e "\n${YELLOW}[3/4] Test Quantum ESPRESSO...${NC}"

if module avail quantum-espresso 2>&1 | grep -q quantum-espresso; then
    module load quantum-espresso/7.2 2>/dev/null || true
    if command -v pw.x &> /dev/null; then
        echo -e "${GREEN}  ✅ Quantum ESPRESSO fonctionnel${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Quantum ESPRESSO installé mais non fonctionnel${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  Quantum ESPRESSO non installé${NC}"
fi

# ============================================================================
# 4. TEST PARAVIEW
# ============================================================================
echo -e "\n${YELLOW}[4/4] Test ParaView...${NC}"

if module avail paraview 2>&1 | grep -q paraview; then
    module load paraview/5.11.2 2>/dev/null || true
    if command -v paraview &> /dev/null || command -v pvbatch &> /dev/null; then
        echo -e "${GREEN}  ✅ ParaView fonctionnel${NC}"
    else
        echo -e "${YELLOW}  ⚠️  ParaView installé mais non fonctionnel${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  ParaView non installé${NC}"
fi

echo -e "\n${GREEN}=== TESTS APPLICATIONS TERMINÉS ===${NC}"
