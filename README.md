# Ting CUDA High-Performance Miner 🚀

High-performance native **NVIDIA CUDA** miner for the **Ting ($DLR / Daler)** Proof-of-Work blockchain.

Engineered specifically for NVIDIA Turing, Ampere, Ada Lovelace, and Blackwell architectures (RTX 20xx / 30xx / 40xx / 50xx).

---

## ⚡ Why Ting CUDA Miner?

The official stock miner (`ting-miner`) relies on cross-platform WebGPU/WGSL compute shaders (`wgpu`). While portable, WGSL cannot leverage NVIDIA-specific hardware instructions and incurs significant host-GPU synchronization overhead.

**Ting CUDA Miner** replaces the WGSL pipeline with a hand-tuned, hardware-level CUDA kernel:

* **Hardware `lop3.b32` Instructions**: SHA-256 logic functions (`ch`, `maj`, `bsig`, `ssig`) are executed using single-cycle ternary logic hardware units.
* **Zero Register Spilling**: Compiled strictly to 32 registers per thread (`0 bytes spill loads/stores`), guaranteeing **100% SM occupancy**.
* **Zero-Copy Solution Detection**: Solutions are polled asynchronously through pinned host-mapped memory (`cudaHostAllocMapped`), eliminating blocking device stalls.
* **Massive Power Efficiency (VRAM Underclocking)**: Because Ting's PoW is 100% compute-bound on the SM core and requires zero VRAM bandwidth, memory can be locked to minimum clocks (e.g., **810 MHz**), dropping power consumption by **15–20%** while running icy cold (40–49°C)!
* **Built-in Multi-GPU Load Balancing**: Automatically detects all installed NVIDIA GPUs and evenly distributes nonce space across all cards.

---

## 📊 Benchmarks Comparison

| GPU Architecture | Model | Stock WGSL Miner | **Ting CUDA Miner** | Speedup |
| :--- | :--- | :---: | :---: | :---: |
| **Ada Lovelace** | RTX 4080 Laptop (87W) | ~7.08 GH/s | **8.24 GH/s** | **+16.4%** |
| **Blackwell** | RTX 5070 Ti (135W, Mem @ 810 MHz) | ~5.80 GH/s | **10.50 GH/s** | **+81.0%** |
| **Blackwell** | 2× RTX 5080 Desktop | ~15.70 GH/s | **~30.50 GH/s** | **+94.2%** |
| **Full Rig** | 3× RTX 5070 Ti (RTX5070Ti-1) | ~17.50 GH/s | **31.70 GH/s** | **+81.1%** |

---

## 🚀 Quick Start (Linux x86_64)

### 1. Download Release
Download the latest `ting-cuda-miner-v1.0.0-linux-x86_64.tar.gz` from [Releases](https://github.com/Dreamer-58/ting-cuda-miner/releases).

```bash
tar -xzvf ting-cuda-miner-v1.0.0-linux-x86_64.tar.gz
cd ting-cuda-miner-v1.0.0
chmod +x ting start-miner.sh
```

### 2. Set Payout Address
If you haven't created a wallet or set a payout address:

```bash
# Create wallet (or use existing)
./ting wallet create

# Show your 64-hex account address
./ting wallet account

# Set your payout account
./ting miner payout <YOUR_64_HEX_ACCOUNT>
```

### 3. Launch Miner
```bash
./start-miner.sh
```

To monitor live status at any time:
```bash
./ting miner status
```

To stop mining:
```bash
./ting miner stop && ./ting stop
```

---

## 💡 Recommended Overclocking Settings

Because SHA-256 runs entirely in GPU registers and needs **zero memory bandwidth**:

* **Core Clock**: Set locked high core clock (e.g., `+100` to `+200` MHz or lock to target curve via `nvidia-smi -lgc 2600,2850`).
* **Memory Clock**: **LOCK TO 810 MHz** (minimum P-state).  
  ```bash
  # Using py-nvtool or nvidia-smi
  sudo py-nvtool --setmem 810
  # Or with nvidia-smi:
  sudo nvidia-smi -lmc 810
  ```
  *Result:* Identical hashrate, ~15–20% lower wattage, and whisper-quiet fans at ~42–48°C.

---

## ⚙️ Developer Fee
A standard **1% DevFee** is included to support ongoing development, kernel optimizations, and updates.

---

## 🛡️ Requirements
* Linux x86_64 (glibc 2.31+)
* NVIDIA GPU Driver 525+ (Driver 570+ recommended for Blackwell RTX 50-series)
* No CUDA Toolkit installation required (standalone static binary).
