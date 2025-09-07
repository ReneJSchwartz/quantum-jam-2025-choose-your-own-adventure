from flask import Flask, request, jsonify
from flask_cors import CORS
from qiskit import QuantumCircuit, transpile
from qiskit.quantum_info import Statevector
from qiskit_aer import AerSimulator
from enum import Enum
import numpy as np
import random
import string
import math

# Import quantum word dictionary
try:
    from quantum_word_dictionary import get_quantum_category_for_word, analyze_text_coverage
except ImportError:
    print("Warning: quantum_word_dictionary.py not found. Using fallback categorization.")
    
    def get_quantum_category_for_word(word):
        """Fallback categorization if dictionary not available - MODERATE COVERAGE!"""
        word_lower = word.lower()
        
        # Keep some common words original to reduce overall coverage
        common_words = ['the', 'and', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should', 'can', 'may', 'might', 'must', 'shall', 'of', 'in', 'on', 'at', 'by', 'for', 'with', 'to', 'from']
        if word_lower in common_words:
            return 'original'
        
        # Ghost category - vowel-heavy words and quantum terms
        if any(char in word_lower for char in 'aeiou') and len(word) > 4:
            return 'ghost'
        
        # Quantum_gates - technical/science words
        elif word_lower in ['quantum', 'gate', 'circuit', 'pulse', 'energy', 'memory', 'system', 'core', 'data', 'process', 'signal', 'echo', 'pattern', 'resonance', 'frequency', 'analysis', 'protocol', 'control', 'stable', 'surface', 'adjust', 'phase', 'collapse', 'interference']:
            return 'quantum_gates'
        
        # Quantum_entanglement - emotional/story words  
        elif word_lower in ['belief', 'create', 'miracles', 'flare', 'fades', 'light', 'hope', 'moment', 'time', 'reality', 'truth', 'understanding', 'darkness', 'uncertainty', 'resolve', 'piercing', 'taught', 'beacon']:
            return 'quantum_entanglement'
        
        # Scramble - some short words
        elif word_lower in ['or', 'through', 'over', 'under', 'next', 'avoid', 'our', 'that', 'just', 'even', 'this']:
            return 'scramble'
        
        # Original - keep some words unchanged for balance
        elif len(word) <= 3 or word_lower in ['into', 'also', 'more', 'some', 'only', 'very', 'much', 'such', 'each', 'most', 'many']:
            return 'original'
        
        # Reverse - everything else gets reverse treatment
        else:
            return 'reverse'
    
    def analyze_text_coverage(text):
        """Fallback analysis"""
        return {'message': 'Using fallback categorization - install quantum_word_dictionary.py for full coverage'}

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests from web games

# Quantum gate types
class GateType(Enum):
    BIT_FLIP = 1
    PHASE_FLIP = 2
    ROTATE_Y = 3

class Qubit:
    """Represents a single qubit with superposition amplitudes using qiskit."""
    
    def __init__(self):
        # Start in |0> state, amplitudes alpha=1, beta=0
        self.state = Statevector([1, 0])
    
    def bit_flip(self):
        # Apply X gate (bit flip)
        qc = QuantumCircuit(1)
        qc.x(0)
        self.state = self.state.evolve(qc)
    
    def phase_flip(self):
        # Apply Z gate (phase flip)
        qc = QuantumCircuit(1)
        qc.z(0)
        self.state = self.state.evolve(qc)
    
    def rotate_y(self, theta):
        # Apply Ry(theta) gate (rotation around Y axis)
        qc = QuantumCircuit(1)
        qc.ry(theta, 0)
        self.state = self.state.evolve(qc)
    
    def hadamard(self):
        """H gate - creates superposition using qiskit."""
        qc = QuantumCircuit(1)
        qc.h(0)
        self.state = self.state.evolve(qc)
    
    def measure(self):
        # Simulate measurement probabilistically, collapsing state
        probabilities = self.state.probabilities_dict()
        p0 = probabilities.get('0', 0)
        rand_val = random.random()
        if rand_val < p0:
            self.state = Statevector([1, 0])  # Collapse to |0>
            return 0
        else:
            self.state = Statevector([0, 1])  # Collapse to |1>
            return 1
    
    def get_superposition_strength(self):
        """Get strength of superposition (0 = classical, 1 = maximum superposition)."""
        alpha, beta = self.state.data
        return 2 * abs(alpha * beta)

class QuantumGate:
    """Represents a quantum gate that can be applied to qubits."""
    
    def __init__(self, gate_type: GateType, rotation_angle: float = 0.0):
        self.gate_type = gate_type
        self.rotation_angle = rotation_angle

    def apply_to(self, qc: QuantumCircuit, qubit_index: int):
        if self.gate_type == GateType.BIT_FLIP:
            qc.x(qubit_index)
        elif self.gate_type == GateType.PHASE_FLIP:
            qc.z(qubit_index)
        elif self.gate_type == GateType.ROTATE_Y:
            qc.ry(self.rotation_angle, qubit_index)

class QuantumCircuitManager:
    """Manages quantum circuit operations."""
    
    def __init__(self, num_qubits: int):
        self.num_qubits = num_qubits
        self.qc = QuantumCircuit(num_qubits)
    
    def apply_gate_to_qubit(self, gate: QuantumGate, qubit_index: int):
        if 0 <= qubit_index < self.num_qubits:
            gate.apply_to(self.qc, qubit_index)
    
    def simulate(self):
        # Use statevector simulator to ensure statevector is available
        backend = AerSimulator(method='statevector')
        
        # Add save_statevector instruction to the circuit
        self.qc.save_statevector()
        
        # Use transpile and run instead of execute
        transpiled_qc = transpile(self.qc, backend)
        job = backend.run(transpiled_qc, shots=1)
        result = job.result()
        
        # Get statevector from the result
        statevector = result.get_statevector()
        return statevector

# Helper functions for quantum transformations (condensed)
def apply_basic_transformation(text, category):
    """Apply basic quantum transformations using individual qubits."""
    result = ""
    for char in text:
        if not char.isalpha():
            result += char
            continue
        
        qubit = Qubit()
        
        # Initialize based on character
        if char.isupper():
            qubit.bit_flip()
        
        # Apply category-specific gates
        if category == 'scramble':
            qubit.hadamard()
        elif category == 'reverse':
            qubit.bit_flip()
        elif category == 'ghost':
            qubit.rotate_y(math.pi/3)
        elif category == 'quantum_caps':
            qubit.hadamard() if random.random() > 0.5 else qubit.phase_flip()
        
        # Measure and transform
        measurement = qubit.measure()
        superposition = qubit.get_superposition_strength()
        result += transform_char_basic(char, measurement, superposition)
    
    return result

def apply_advanced_transformation(text, category):
    """Apply advanced quantum transformations using multi-qubit circuits."""
    if len(text) < 2:
        return text
    
    num_qubits = min(len(text), 8)
    qc_manager = QuantumCircuitManager(num_qubits)
    
    # Apply gates based on category
    if category == 'quantum_entanglement':
        for i in range(0, num_qubits-1, 2):
            gate = QuantumGate(GateType.BIT_FLIP)
            qc_manager.apply_gate_to_qubit(gate, i)
    elif category == 'quantum_gates':
        for i in range(num_qubits):
            gate_type = GateType.BIT_FLIP if i % 3 == 0 else GateType.PHASE_FLIP
            gate = QuantumGate(gate_type, math.pi/4 if gate_type == GateType.ROTATE_Y else 0)
            qc_manager.apply_gate_to_qubit(gate, i)
    
    # Get state and transform
    statevector = qc_manager.simulate()
    return transform_text_from_statevector(text, statevector)

def transform_char_basic(char, measurement, superposition):
    """Basic character transformation based on quantum results - MODERATE EFFECTS!"""
    rand_val = random.random()
    
    # Apply transformation with moderate probability
    if superposition > 0.3 or rand_val < 0.5:  # 50% chance for exotic effects
        # Quantum brackets for special emphasis - reduced frequency
        quantum_chars = {
            'a': '⟨ᵃ⟩', 'e': '⟨ᵉ⟩', 'i': '⟨ⁱ⟩', 'o': '⟨ᵒ⟩', 'u': '⟨ᵘ⟩',
            'A': '⟨ᴬ⟩', 'E': '⟨ᴱ⟩', 'I': '⟨ᴵ⟩', 'O': '⟨ᴼ⟩', 'U': '⟨ᵁ⟩',
            'n': '⟨ⁿ⟩', 's': '⟨ˢ⟩', 't': '⟨ᵗ⟩', 'r': '⟨ʳ⟩', 'l': '⟨ˡ⟩'
        }
        if char.lower() in quantum_chars and rand_val < 0.2:  # 20% chance for brackets
            return quantum_chars[char.lower()]
    
    if rand_val < 0.6:  # 60% chance for diacritics
        # Diacritics and special characters
        diacritic_chars = {
            'a': 'ā', 'e': 'ē', 'i': 'ī', 'o': 'ō', 'u': 'ū', 'y': 'ÿ',
            'A': 'Ā', 'E': 'Ē', 'I': 'Ī', 'O': 'Ō', 'U': 'Ū', 'Y': 'Ÿ',
            'n': 'ñ', 'N': 'Ñ', 'c': 'ç', 'C': 'Ç',
            's': 'š', 'S': 'Š', 'z': 'ž', 'Z': 'Ž',
            'd': 'đ', 'D': 'Đ', 'l': 'ł', 'L': 'Ł',
            'g': 'ğ', 'G': 'Ğ', 'h': 'ħ', 'H': 'Ħ'
        }
        if char in diacritic_chars:
            return diacritic_chars[char]
    
    # If no transformation applied, return original character sometimes
    if rand_val > 0.4:  # 40% chance to keep original
        return char
    
    # Final fallback - swap case
    return char.swapcase()

def transform_text_from_statevector(text, statevector):
    """Transform text based on quantum circuit statevector - MODERATE EFFECTS!"""
    amplitudes = abs(statevector.data)
    result = ""
    
    # Create moderate transformations based on quantum amplitudes
    for i, char in enumerate(text):
        if not char.isalpha():
            result += char
            continue
            
        if i < len(amplitudes):
            amplitude = amplitudes[i]
            
            # Use amplitude to determine transformation intensity - more selective
            if amplitude > 0.8:
                # Very high amplitude - quantum brackets (rare)
                quantum_map = {'a': '⟨ᵃ⟩', 'e': '⟨ᵉ⟩', 'i': '⟨ⁱ⟩', 'o': '⟨ᵒ⟩', 'u': '⟨ᵘ⟩'}
                result += quantum_map.get(char.lower(), char.swapcase())
            elif amplitude > 0.7:
                # High amplitude - diacritics
                diacritic_map = {'a': 'ā', 'e': 'ē', 'i': 'ī', 'o': 'ō', 'u': 'ū', 'n': 'ñ', 's': 'š'}
                result += diacritic_map.get(char.lower(), char.swapcase())
            elif amplitude > 0.5:
                # Medium amplitude - case flip
                result += char.swapcase()
            else:
                # Low amplitude - keep original or simple case change
                result += char if amplitude < 0.3 else (char.upper() if char.islower() else char.lower())
        else:
            # Default: 50% chance to keep original
            result += char if random.random() < 0.5 else char.swapcase()
    
    return result

def apply_quantum_transformation(text, category):
    """Main dispatcher for quantum transformations."""
    if category in ['scramble', 'reverse', 'ghost', 'quantum_caps']:
        return apply_basic_transformation(text, category)
    elif category in ['quantum_entanglement', 'quantum_gates', 'quantum_interference']:
        return apply_advanced_transformation(text, category)
    else:
        return text

@app.route('/quantum_gate', methods=['POST'])
def quantum_gate_endpoint():
    """
    Minimal endpoint for quantum gate operations compatible with Godot game logic.
    Handles bit_flip, phase_flip, and rotation gates.
    """
    try:
        print("=" * 50)
        print("[Flask] QUANTUM GATE REQUEST RECEIVED")
        print("=" * 50)
        
        data = request.get_json()
        print(f"[Flask] Raw request data: {data}")
        
        if not data:
            print("[Flask] ❌ ERROR: No JSON data received")
            return jsonify({'error': 'No JSON data provided'}), 400
            
        # Handle both 'gate' and 'gate_type' for compatibility
        gate_type = data.get('gate_type') or data.get('gate')
        
        if not gate_type:
            print("[Flask] ❌ ERROR: Missing gate_type/gate parameter")
            return jsonify({'error': 'Missing gate_type or gate parameter'}), 400
            
        print(f"[Flask] 📡 Gate type received: '{gate_type}'")
        
        gate_type = gate_type.lower()
        rotation_angle = data.get('rotation_angle', math.pi/4)  # Default rotation
        
        print(f"[Flask] 🔧 Normalized gate_type: '{gate_type}'")
        print(f"[Flask] 🔄 Rotation angle: {rotation_angle}")
        
        # Create qubit and apply gate
        print("[Flask] 🎲 Creating new qubit...")
        qubit = Qubit()
        
        # Apply the requested gate
        print(f"[Flask] ⚛️ Applying {gate_type} gate...")
        if gate_type == 'bit_flip':
            qubit.bit_flip()
            print("[Flask] ✅ Bit-flip gate applied")
        elif gate_type == 'phase_flip':
            qubit.phase_flip()
            print("[Flask] ✅ Phase-flip gate applied")
        elif gate_type == 'rotation':
            qubit.rotate_y(rotation_angle)
            print(f"[Flask] ✅ Rotation gate applied with angle {rotation_angle}")
        else:
            print(f"[Flask] ❌ ERROR: Invalid gate_type: '{gate_type}'")
            return jsonify({'error': f'Invalid gate_type: {gate_type}. Use: bit_flip, phase_flip, or rotation'}), 400
        
        # Measure the result
        print("[Flask] 📊 Measuring qubit...")
        measurement = qubit.measure()
        superposition = qubit.get_superposition_strength()
        
        success = measurement == 0  # Success if measurement collapses to |0>
        
        result = {
            'gate_type': gate_type,
            'measurement': measurement,
            'superposition_strength': round(superposition, 3),
            'success': success
        }
        
        print(f"[Flask] 🎯 Measurement result: {measurement}")
        print(f"[Flask] 🌊 Superposition strength: {round(superposition, 3)}")
        print(f"[Flask] ✅ Gate operation {'SUCCESS' if success else 'FAILURE'}")
        print(f"[Flask] 📤 Sending response: {result}")
        print("=" * 50)
        
        return jsonify(result)
        
    except Exception as e:
        print(f"[Flask] ❌ CRITICAL ERROR in quantum_gate_endpoint: {str(e)}")
        print(f"[Flask] 📋 Exception type: {type(e).__name__}")
        import traceback
        print(f"[Flask] 📍 Traceback: {traceback.format_exc()}")
        return jsonify({
            'error': str(e),
            'debug_info': f'Exception type: {type(e).__name__}'
        }), 500

@app.route('/quantum_text', methods=['POST'])
def quantum_text_endpoint():
    """
    Single comprehensive endpoint for quantum text processing.
    Receives a paragraph, categorizes words using quantum_word_dictionary,
    and applies appropriate quantum transformations.
    """
    try:
        print("=== QUANTUM TEXT REQUEST ===")
        data = request.get_json()
        print(f"Received data: {data}")
        
        if not data or 'text' not in data:
            print("ERROR: Missing text parameter")
            return jsonify({'error': 'Missing text parameter'}), 400
        
        text = data['text']
        print(f"Processing text: {text}")
        
        # Process each word with quantum transformations
        import re
        words = re.findall(r'\b\w+\b|\W+', text)
        
        transformed_words = []
        stats = {'quantum_words': 0, 'total_words': 0}
        
        for word in words:
            if not word.strip().isalpha():
                transformed_words.append(word)
                continue
                
            stats['total_words'] += 1
            print(f"Processing word: '{word}'")
            
            category = get_quantum_category_for_word(word)
            print(f"Word '{word}' categorized as: {category}")
            
            if category != 'original':
                stats['quantum_words'] += 1
                print(f"Applying quantum transformation to '{word}' with category '{category}'")
                transformed_word = apply_quantum_transformation(word, category)
                print(f"Transformed '{word}' -> '{transformed_word}'")
            else:
                transformed_word = word
                print(f"Word '{word}' kept original")
                
            transformed_words.append(transformed_word)
        
        # Calculate coverage
        coverage = (stats['quantum_words'] / stats['total_words'] * 100) if stats['total_words'] > 0 else 0
        
        return jsonify({
            'original': text,
            'transformed': ''.join(transformed_words),
            'coverage_percent': round(coverage, 1),
            'quantum_words': stats['quantum_words'],
            'total_words': stats['total_words']
        })
        
    except Exception as e:
        print(f"ERROR in quantum_text_endpoint: {str(e)}")
        print(f"Exception type: {type(e)}")
        import traceback
        print(f"Traceback: {traceback.format_exc()}")
        return jsonify({'error': str(e), 'debug_info': f'Exception type: {type(e).__name__}'}), 500

@app.route('/quantum_echo_types', methods=['GET'])
def get_echo_types():
    """Get available quantum transformation types."""
    return jsonify({
        'basic_echo_types': [
            {'name': 'scramble', 'description': 'Quantum scrambling with special characters'},
            {'name': 'reverse', 'description': 'Quantum case reversal'},
            {'name': 'ghost', 'description': 'Ghostly superscript transformation'},
            {'name': 'quantum_caps', 'description': 'Quantum-influenced capitalization'}
        ],
        'advanced_transformations': [
            {'name': 'quantum_gates', 'description': 'Apply quantum gate sequences (H, X, Y, Z, ROT)'},
            {'name': 'quantum_entanglement', 'description': 'Multi-qubit entanglement transformations'},
            {'name': 'quantum_memory', 'description': 'Quantum memory effects for story integration'}
        ]
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    try:
        from qiskit import QuantumCircuit
        from qiskit_aer import AerSimulator
        
        test_qc = QuantumCircuit(1)
        test_qc.h(0)
        
        backend = AerSimulator(method='statevector')
        transpiled_test = transpile(test_qc, backend)
        job = backend.run(transpiled_test, shots=1)
        result = job.result()
        
        qiskit_status = True
        qiskit_version = "qiskit 2.1.2, qiskit-aer 0.17.1 - Fully operational"
    except Exception as e:
        qiskit_status = False
        qiskit_version = f"Error: {str(e)}"
    
    return jsonify({
        'status': 'healthy',
        'service': 'quantum-echo-server',
        'qiskit_available': qiskit_status,
        'qiskit_status': qiskit_version,
        'quantum_classes': ['Qubit', 'QuantumGate', 'QuantumCircuitManager']
    })

@app.route('/', methods=['GET'])
def index():
    """Basic info endpoint."""
    return jsonify({
        'service': 'Quantum Echo Server',
        'version': '3.0.0',
        'description': 'Advanced quantum text transformation using real qiskit quantum gates and circuits',
        'endpoints': {
            'POST /quantum_text': 'Comprehensive quantum text processing with word dictionary',
            'GET /quantum_echo_types': 'Get available transformation types',
            'GET /health': 'Health check with qiskit functionality test'
        },
        'quantum_features': [
            'Real qiskit quantum circuits with Statevector simulation',
            'Quantum word dictionary for intelligent categorization',
            'Condensed transformation functions for efficiency'
        ]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
