#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

echo "=========================================="
echo "   Ting CUDA High-Performance Miner v1.0   "
echo "=========================================="

if [ ! -d "$HOME/.ting" ]; then
    echo "[+] Initializing ~/.ting data directory..."
    ./ting init
fi

if [ ! -f "$HOME/.ting/miner.json" ]; then
    echo "[+] Copying default miner.example.json to ~/.ting/miner.json..."
    cp miner.example.json "$HOME/.ting/miner.json"
fi

# Ensure search is set to cuda
python3 -c "
import json, os
path = os.path.expanduser('~/.ting/miner.json')
try:
    with open(path) as f: d = json.load(f)
    if d.get('search') != 'cuda':
        d['search'] = 'cuda'
        with open(path, 'w') as f: json.dump(d, f, indent=2)
except Exception: pass
" 2>/dev/null || true

echo "[+] Starting background node..."
./ting start

echo "[+] Starting native CUDA search..."
./ting miner start

sleep 2
echo ""
echo "[✓] Status:"
./ting miner status

echo ""
echo "Commands:"
echo "  Check status : ./ting miner status"
echo "  Stop miner   : ./ting miner stop && ./ting stop"
