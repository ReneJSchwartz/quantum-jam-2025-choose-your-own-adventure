# 🌟 Quantum Text Transformation API Documentation

## Overview
Your game has a sophisticated quantum text transformation system that connects to a Flask quantum server to apply real quantum computing effects to dialogue text. The system uses qiskit and quantum circuits to create dynamic text transformations based on story content and context.

## 📡 Server Architecture

**Server Location:** `108.175.12.95:8000` (VPS deployment)
**Local Development:** `localhost:8000` (change SERVER_URL for local testing)

### Available Endpoints

#### 1. `/quantum_echo` - Basic Text Transformation
```json
POST /quantum_echo
{
  "text": "Hello quantum world!",
  "echo_type": "scramble"
}

Response:
{
  "echo": "Hqllo euantum worlk!",
  "quantum_state": {...},
  "measurement_result": [0, 1, 1, 0]
}
```

#### 2. `/quantum_memory` - Advanced Memory Effects
```json
POST /quantum_memory
{
  "text": "I remember the quantum experiments...",
  "memory_type": "fragmented", 
  "intensity": 0.7
}

Response:
{
  "memory_echo": "I rem...ber the qu@ntum exper|ments...",
  "memory_state": "coherent_decoherence",
  "quantum_coherence": 0.342
}
```

#### 3. `/health` - Server Status
```json
GET /health

Response:
{
  "status": "healthy",
  "qiskit_available": true,
  "server_info": {...}
}
```

## 🎭 Quantum Echo Types

| Echo Type | Quantum Method | Visual Effect | Use Case |
|-----------|---------------|---------------|----------|
| `SCRAMBLE` | Hadamard gates + measurement | Random character scrambling | Default text transformation |
| `CASE_FLIP` | X gates in superposition | Case switching | Emphasis and contrast |  
| `GHOST` | Y gate interference | Spectral text effects | Quantum/supernatural terms |
| `QUANTUM_CAPS` | Z-rotation gates | Quantum capitalization | AI/technological dialogue |
| `ORIGINAL` | Quantum bypass | No transformation | Fallback/classical text |

## 🧠 Quantum Memory Types

| Memory Type | Quantum Science | Storytelling Effect | Intensity Range |
|-------------|----------------|--------------------|-----------------| 
| `FRAGMENTED` | Quantum decoherence | Memory fragmentation | 0.1-1.0 |
| `ENTANGLED` | Quantum entanglement | Connected text segments | 0.1-1.0 |
| `SUPERPOSITION` | Multiple quantum states | Multiple reality states | 0.1-1.0 |

## 🎮 Smart Context Detection

The system automatically chooses quantum effects based on dialogue content:

### 🧠 Memory-Related Dialogue → Quantum Memory
**Triggers:** "memory", "remember", "forgot", "vanished"
**Effect:** FRAGMENTED memory with 0.7 intensity
**Purpose:** Dramatic memory-related storytelling

### 🤖 AI Character Dialogue → Quantum Caps  
**Triggers:** Speaker = "Ava" or "AI Assistant"
**Effect:** QUANTUM_CAPS transformation
**Purpose:** Technological/AI dialogue styling

### 👻 Quantum Terminology → Ghost Effects
**Triggers:** "echo", "quantum", "burst" in text
**Effect:** GHOST echo transformation  
**Purpose:** Atmospheric quantum descriptions

### 🌀 Default Content → Scramble
**Triggers:** All other dialogue
**Effect:** SCRAMBLE transformation
**Purpose:** General quantum uncertainty

## 🔧 Implementation Files

### `quantum_echo_service.gd` - Core API Service
- **Purpose:** HTTP client for quantum server communication
- **Features:** Async requests, error handling, fallback text
- **Methods:** 
  - `process_quantum_echo()` - Basic text transformation
  - `process_quantum_memory()` - Advanced memory effects
  - `test_server_health()` - Connectivity checking

### `dialogue_ui_manager.gd` - Game Integration
- **Purpose:** Integrates quantum effects into dialogue system
- **Features:** Context-aware quantum selection, typewriter animation
- **Methods:**
  - `_process_text_with_quantum_effects()` - Smart context detection
  - `_on_quantum_text_received()` - Response handler and animation

### `quantum_gate_manager.gd` - Advanced System (UNUSED)
- **Purpose:** Sophisticated quantum gate management (currently unused)
- **Features:** Player choice → quantum gate mapping, story state tracking
- **Potential:** Could replace manual quantum logic with full qiskit integration

## 🚀 Usage Examples

### Basic Quantum Echo
```gdscript
quantum_echo_service.process_quantum_echo(
    "Hello quantum world!",
    QuantumEchoService.EchoType.SCRAMBLE,
    func(result): print("Quantum result: ", result),
    "Hello quantum world!"  # fallback
)
```

### Advanced Memory Processing  
```gdscript
quantum_echo_service.process_quantum_memory(
    "I remember the experiments...",
    QuantumEchoService.QuantumMemoryType.FRAGMENTED,
    0.8,  # high intensity
    func(result): print("Memory fragment: ", result),
    "I remember the experiments..."  # fallback
)
```

### Health Check
```gdscript
quantum_echo_service.test_server_health(func(healthy, message):
    if healthy:
        print("✅ Quantum server ready!")
    else:
        print("❌ Server issue: ", message)
)
```

## 🔬 Quantum Science Integration

The system uses **real quantum computing principles**:

- **qiskit 2.1.2** with AerSimulator for quantum circuit simulation
- **Real quantum gates:** H (Hadamard), X (bit-flip), Y (rotation), Z (phase-flip)  
- **Quantum measurement:** Circuit outcomes determine text transformations
- **Superposition effects:** Multiple states collapsed to create story outcomes
- **Entanglement patterns:** Create correlations between text segments

## 🎯 Integration Status

✅ **Active Systems:**
- Quantum echo service with full API integration
- Context-aware quantum effect selection  
- Fallback handling for server errors
- Typewriter animation with quantum text

🚧 **Available but Unused:**
- Sophisticated quantum gate management system
- Player choice → quantum gate mapping
- Advanced story state with quantum tracking

🔄 **Connection Issues:**
- SSL/port conflicts when connecting from game to server
- VPS configuration at 108.175.12.95:8000 vs localhost:8000

## 📝 Next Steps

1. **Resolve Connection Issues:** Debug SSL/port conflicts between game and server
2. **Test Quantum Effects:** Verify all echo types work with actual gameplay
3. **Expand Integration:** Consider using quantum_gate_manager.gd for more advanced features
4. **Performance Optimization:** Monitor quantum processing latency in gameplay
5. **Error Handling:** Improve fallback strategies for offline/slow connections

---

*This documentation covers the complete quantum text transformation API system found in your Choose Your Own Adventure quantum game project.*
