#!/usr/bin/env bash
set -euo pipefail

OUT="results_mcmtc_security.csv"
LOGDIR="logs_mcmtc"
mkdir -p "$LOGDIR"

# CSV header
echo "scheduler_id,scheduler_name,attack_type,ue_count,bandwidth_MHz,dlDataSymbolsFpattern,mu,pktBytes,avg_ms,min_ms,max_ms,count" > "$OUT"

# Map scheduler id → name
sname() {
  case "$1" in
    0) echo "TDMA" ;;
    1) echo "5GL-OFDMA" ;;
    2) echo "Sym-OFDMA" ;;
    3) echo "RB-OFDMA" ;;
    *) echo "UNKNOWN" ;;
  esac
}

# Extract min/avg/max/count from a log (ns → ms)
metrics() {
  local log="$1"
  grep -oE '\+[0-9]+ns' "$log" | tr -d '+ns' | \
  awk '$1>0 {s+=$1;n++; if(!min||$1<min)min=$1; if($1>max)max=$1}
       END{
         if(!n){printf "0,0,0,0"; exit}
         printf "%.3f,%.3f,%.3f,%d", s/n/1e6, min/1e6, max/1e6, n
       }'
}

# Run one simulation and append a CSV row
run_case() {
  local sch="$1"       # 0..3
  local attack="$2"    # baseline-load | attack-load | baseline-slot | attack-slot
  local ue="$3"        # e.g., 15 or 60
  local bw="$4"        # 10e6 / 20e6 / 40e6
  local dls="$5"       # 1 (1D13U) or 9 (9D5U)
  local mu="1"
  local pkt="10"
  local sname_val
  sname_val="$(sname "$sch")"
  local mhz="${bw%e6}"        # turn "10e6" → "10"
  local tag="${attack}_sch${sch}_ue${ue}_bw${bw}_dls${dls}"
  local log="${LOGDIR}/${tag}.log"

  ./ns3 run "scratch/ConfiguredGrant_firstTest --scheduler=${sch} --ueNumPergNb=${ue} --numerologyBwp1=${mu} --centralFrequencyBand1=3.75e9 --bandwidthBand1=${bw} --packetSize=${pkt} --startingMcsUl=12 --dlDataSymbolsFpattern=${dls}" > "$log" 2>&1

  IFS=',' read -r avg min max cnt <<<"$(metrics "$log")"
  printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n" \
    "$sch" "$sname_val" "$attack" "$ue" "$mhz" "$dls" "$mu" "$pkt" "$avg" "$min" "$max" "$cnt" >> "$OUT"
}

# ---------- SWEEPS ----------
BWS=("10e6" "20e6" "40e6")

# (1) Load-injection: baseline 15 UEs vs attack 60 UEs, DLS=1, all schedulers
for bw in "${BWS[@]}"; do
  for sch in 0 1 2 3; do
    run_case "$sch" "baseline-load" 15 "$bw" 1
    run_case "$sch" "attack-load"   60 "$bw" 1
  done
done

# (2) Slot-format abuse: baseline DLS=1 vs attack DLS=9, schedulers 1/2/3 (OFDMA family)
for bw in "${BWS[@]}"; do
  for sch in 1 2 3; do
    run_case "$sch" "baseline-slot" 15 "$bw" 1
    run_case "$sch" "attack-slot"   15 "$bw" 9
  done
done

echo "Done. Wrote $(wc -l < "$OUT") rows to $OUT and logs in $LOGDIR/"
