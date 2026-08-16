#!/usr/bin/env bash
# Reproduce the wrong-code bug and print the condition table.
#
#   ./repro.sh           one run per configuration
#   N=100 ./repro.sh     N runs per configuration, counted
set -u
cd "$(dirname "$0")" || exit 1

DOTNET=${DOTNET:-dotnet}
N=${N:-1}
DLL=bin/Release/net10.0/repro.dll

[ -f "$DLL" ] || "$DOTNET" build -c Release || exit 1

count() {
  local label=$1
  shift
  local hits=0 i
  for i in $(seq 1 "$N"); do
    ( for kv in "$@"; do export "${kv?}"; done
      "$DOTNET" "$DLL" >/dev/null 2>&1 ) || hits=$((hits + 1))
  done
  printf '%-46s %s\n' "$label" "$hits/$N wrong"
}

"$DOTNET" --list-runtimes | grep -o 'Microsoft.NETCore.App [^ ]*' | tail -1
echo

count "defaults (no configuration at all)"      NOTHING=1
count "  DOTNET_TieredCompilation=0"            DOTNET_TieredCompilation=0
count "  DOTNET_TieredPGO=0"                    DOTNET_TieredPGO=0
count "  DOTNET_TC_QuickJitForLoops=0"          DOTNET_TC_QuickJitForLoops=0
count "  DOTNET_TC_OnStackReplacement=0"        DOTNET_TC_OnStackReplacement=0
count "  DOTNET_JitEnablePhysicalPromotion=0"   DOTNET_JitEnablePhysicalPromotion=0
count "  DOTNET_ReadyToRun=0"                   DOTNET_ReadyToRun=0

echo
echo "one failing run:"
"$DOTNET" "$DLL"
