#!/bin/bash

# /scripts/tests/test-src-R.sh
#
# Runs R CMD check after installing dependencies

# Find Rscript
if command -v Rscript &> /dev/null; then
    RSCRIPT="Rscript"
elif [[ "$OSTYPE" == msys* || "$OSTYPE" == mingw* ]]; then
    RSCRIPT="$(cmd.exe //c where Rscript 2>/dev/null | head -1 | tr -d '\r')"
    [ -z "$RSCRIPT" ] && { echo "Error: Rscript not found" >&2; exit 1; }
else
    echo "Error: Rscript not found" >&2
    exit 1
fi

# Detect if running from src/ directory or project root
if [ -f "src/DESCRIPTION" ]; then
    # root directory

    # 1. Set directory for check
    PKG_PATH="./src"

    # 2. Install dependencies if necessary
    "$RSCRIPT" -e "renv::restore()"

elif [ -f "DESCRIPTION" ] && [ "$(basename "$PWD")" = "src" ]; then
    # ./src directory
    # Does not use renv

    # 1. Set directory for check
    PKG_PATH="."

else
    echo "Error: Must run from project root or src/ directory" >&2
    exit 1
fi

# R CMD check
"$RSCRIPT" -e "devtools::check('$PKG_PATH')"
