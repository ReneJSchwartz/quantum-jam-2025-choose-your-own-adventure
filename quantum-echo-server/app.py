from flask import Flask, request, jsonify
from flask_cors import CORS
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
import random
import string
import math

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests from web games

class Qubit:
    """Simulate a qubit with quantum amplitudes for text transformation."""
    
    def __init__(self):
        self.alpha = 1.0  # amplitude for |0>
        self.beta = 0.0   # amplitude for |1>
    
    def bit_flip(self):
        """X gate - flips amplitudes (bit flip)."""
        temp = self.alpha
        self.alpha = self.beta
        self.beta = temp
    
    def phase_flip(self):
        """Z gate - flips phase of |1> amplitude."""
        self.beta = -self.beta
    
    def rotate_y(self, theta):
        """Y rotation gate - rotates qubit around Y axis."""
        cos_half = math.cos(theta / 2)
        sin_half = math.sin(theta / 2)
        new_alpha = cos_half * self.alpha - sin_half * self.beta
        new_beta = sin_half * self.alpha + cos_half * self.beta
        self.alpha = new_alpha
        self.beta = new_beta
    
    def hadamard(self):
        """H gate - creates superposition."""
        new_alpha = (self.alpha + self.beta) / math.sqrt(2)
        new_beta = (self.alpha - self.beta) / math.sqrt(2)
        self.alpha = new_alpha
        self.beta = new_beta
    
    def measure(self):
        """Measure qubit - collapses to |0> or |1> based on probability."""
        p0 = self.alpha * self.alpha
        if random.random() < p0:
            self.alpha = 1.0
            self.beta = 0.0
            return 0
        else:
            self.alpha = 0.0
            self.beta = 1.0
            return 1
    
    def get_superposition_strength(self):
        """Get strength of superposition (0 = classical, 1 = maximum superposition)."""
        return 2 * abs(self.alpha * self.beta)

def quantum_gate_transform(text, gate_sequence="H-X-Y"):
    """
    Transform text using quantum gate operations on individual character qubits.
    
    Args:
        text (str): Input text to transform
        gate_sequence (str): Sequence of quantum gates to apply (H, X, Y, Z)
    
    Returns:
        dict: Transformed text with quantum state information
    """
    if not text:
        return {"transformed_text": "", "quantum_state": "empty"}
    
    # Parse gate sequence
    gates = gate_sequence.split('-')
    valid_gates = ['H', 'X', 'Y', 'Z', 'ROT']
    gates = [g.upper().strip() for g in gates if g.upper().strip() in valid_gates]
    
    if not gates:
        gates = ['H']  # Default to Hadamard
    
    transformed_chars = []
    quantum_states = []
    
    for i, char in enumerate(text):
        # Create a qubit for each character
        qubit = Qubit()
        
        # Initialize qubit based on character properties
        if char.isupper():
            qubit.bit_flip()  # Start in |1> for uppercase
        
        # Apply quantum gates
        for gate in gates:
            if gate == 'H':
                qubit.hadamard()
            elif gate == 'X':
                qubit.bit_flip()
            elif gate == 'Y':
                qubit.rotate_y(math.pi/2)
            elif gate == 'Z':
                qubit.phase_flip()
            elif gate == 'ROT':
                # Rotation angle based on character position
                angle = (i + 1) * math.pi / len(text)
                qubit.rotate_y(angle)
        
        # Measure the qubit to get classical result
        measurement = qubit.measure()
        superposition = qubit.get_superposition_strength()
        
        # Transform character based on quantum measurement and superposition
        transformed_char = transform_character_quantum(char, measurement, superposition)
        
        transformed_chars.append(transformed_char)
        quantum_states.append({
            'char': char,
            'measurement': measurement,
            'superposition': round(superposition, 3)
        })
    
    return {
        "transformed_text": ''.join(transformed_chars),
        "quantum_states": quantum_states,
        "gates_applied": gates,
        "superposition_average": round(sum(qs['superposition'] for qs in quantum_states) / len(quantum_states), 3)
    }

def transform_character_quantum(char, measurement, superposition_strength):
    """Transform a character based on quantum measurement and superposition."""
    if not char.isalpha():
        return char
    
    # High superposition = more exotic transformations
    if superposition_strength > 0.7:
        # Maximum quantum weirdness
        quantum_chars = {
            'a': '⟨ᵃ⟩', 'e': '⟨ᵉ⟩', 'i': '⟨ⁱ⟩', 'o': '⟨ᵒ⟩', 'u': '⟨ᵘ⟩',
            'A': '⟨ᴬ⟩', 'E': '⟨ᴱ⟩', 'I': '⟨ᴵ⟩', 'O': '⟨ᴼ⟩', 'U': '⟨ᵁ⟩',
            's': '⟨ˢ⟩', 't': '⟨ᵗ⟩', 'n': '⟨ⁿ⟩', 'r': '⟨ʳ⟩', 'l': '⟨ˡ⟩'
        }
        return quantum_chars.get(char, f'⟨{char}⟩')
    
    elif superposition_strength > 0.4:
        # Medium quantum effects
        if measurement == 1:
            # Quantum diacritics
            diacritic_chars = {
                'a': 'ā', 'e': 'ē', 'i': 'ī', 'o': 'ō', 'u': 'ū',
                'A': 'Ā', 'E': 'Ē', 'I': 'Ī', 'O': 'Ō', 'U': 'Ū',
                's': 'š', 't': 'ť', 'n': 'ň', 'c': 'č', 'z': 'ž'
            }
            return diacritic_chars.get(char, char)
        else:
            # Quantum case flip
            return char.swapcase()
    
    else:
        # Low superposition = subtle changes
        if measurement == 1:
            return char.upper()
        else:
            return char.lower()

def quantum_circuit_transform(text, circuit_type="entanglement"):
    """
    Advanced quantum text transformation using multi-qubit operations.
    
    Args:
        text (str): Input text
        circuit_type (str): Type of quantum circuit ("entanglement", "interference", "teleportation")
    
    Returns:
        dict: Advanced quantum transformation result
    """
    if not text or len(text) < 2:
        return {"transformed_text": text, "circuit_type": circuit_type, "entangled_pairs": []}
    
    # Work with pairs of characters for entanglement
    char_pairs = []
    for i in range(0, len(text) - 1, 2):
        char_pairs.append((text[i], text[i + 1] if i + 1 < len(text) else ' '))
    
    transformed_pairs = []
    entangled_info = []
    
    for i, (char1, char2) in enumerate(char_pairs):
        qubit1 = Qubit()
        qubit2 = Qubit()
        
        # Initialize qubits based on characters
        if char1.isupper():
            qubit1.bit_flip()
        if char2.isupper():
            qubit2.bit_flip()
        
        if circuit_type == "entanglement":
            # Create Bell pair (maximally entangled state)
            qubit1.hadamard()
            # Simulate CNOT: if qubit1 is |1>, flip qubit2
            if qubit1.measure() == 1:
                qubit2.bit_flip()
                qubit1.bit_flip()  # Reset for entanglement
        
        elif circuit_type == "interference":
            # Quantum interference pattern
            qubit1.hadamard()
            qubit2.hadamard()
            qubit1.phase_flip()
            qubit2.rotate_y(math.pi / 4)
        
        elif circuit_type == "teleportation":
            # Quantum teleportation simulation
            qubit1.hadamard()
            qubit1.phase_flip()
            qubit2.rotate_y(math.pi / 3)
        
        # Measure and transform
        m1 = qubit1.measure()
        m2 = qubit2.measure()
        
        s1 = qubit1.get_superposition_strength()
        s2 = qubit2.get_superposition_strength()
        
        # Entangled transformation - characters influence each other
        if m1 == m2:  # Correlated measurement
            new_char1 = transform_character_quantum(char1, m1, max(s1, s2))
            new_char2 = transform_character_quantum(char2, m2, max(s1, s2))
        else:  # Anti-correlated
            new_char1 = transform_character_quantum(char1, 1 - m1, s1)
            new_char2 = transform_character_quantum(char2, 1 - m2, s2)
        
        transformed_pairs.append(new_char1 + new_char2)
        entangled_info.append({
            'original': char1 + char2,
            'transformed': new_char1 + new_char2,
            'measurements': [m1, m2],
            'correlation': 'correlated' if m1 == m2 else 'anti-correlated'
        })
    
    return {
        "transformed_text": ''.join(transformed_pairs),
        "circuit_type": circuit_type,
        "entangled_pairs": entangled_info,
        "quantum_correlation": sum(1 for info in entangled_info if info['correlation'] == 'correlated') / len(entangled_info)
    }

def quantum_echo(text, echo_type="scramble"):
    """
    Generate a quantum echo of the input text using Qiskit quantum circuits.
    
    Args:
        text (str): Input dialogue text
        echo_type (str): Type of echo transformation - "scramble", "reverse", "ghost", "quantum_caps"
    
    Returns:
        str: Quantum-transformed echo of the input text
    """
    if not text:
        return ""
    
    # Convert text to binary representation
    text_bits = []
    for char in text:
        # Convert each character to 8-bit binary
        bits = format(ord(char), '08b')
        text_bits.extend([int(b) for b in bits])
    
    # Limit to reasonable number of qubits (max 20 for performance)
    n_qubits = min(len(text_bits), 20)
    if n_qubits == 0:
        return text
    
    # Create quantum circuit
    qc = QuantumCircuit(n_qubits, n_qubits)
    
    # Initialize qubits based on text bits
    for i in range(n_qubits):
        if text_bits[i] == 1:
            qc.x(i)
    
    # Apply quantum gates based on echo type
    if echo_type == "scramble":
        # Apply Hadamard gates to create superposition
        for i in range(n_qubits):
            qc.h(i)
    elif echo_type == "reverse":
        # Apply X gates and controlled operations
        for i in range(n_qubits // 2):
            qc.cx(i, n_qubits - 1 - i)
    elif echo_type == "ghost":
        # Apply rotation gates for subtle changes
        for i in range(n_qubits):
            qc.ry(0.5, i)
    elif echo_type == "quantum_caps":
        # Mix of Hadamard and Pauli-Z gates
        for i in range(0, n_qubits, 2):
            qc.h(i)
        for i in range(1, n_qubits, 2):
            qc.z(i)
    
    # Measure all qubits
    qc.measure(range(n_qubits), range(n_qubits))
    
    # Execute the circuit
    backend = AerSimulator()
    job = backend.run(qc, shots=1)
    result = job.result()
    counts = result.get_counts()
    
    # Get the measurement result
    measured_bits = list(counts.keys())[0]
    
    # Transform the original text based on quantum measurement
    transformed_text = transform_text_with_quantum_result(text, measured_bits, echo_type)
    
    return transformed_text

def transform_text_with_quantum_result(text, quantum_bits, echo_type):
    """Transform text based on quantum measurement results."""
    if not text or not quantum_bits:
        return text
    
    result = ""
    bit_index = 0
    
    for i, char in enumerate(text):
        if bit_index >= len(quantum_bits):
            bit_index = 0
        
        quantum_bit = quantum_bits[bit_index]
        
        if echo_type == "scramble":
            # Randomly scramble characters based on quantum bit
            if quantum_bit == '1':
                if char.isalpha():
                    # Replace with random similar character
                    similar_chars = {
                        'a': 'ă', 'e': 'ē', 'i': 'ī', 'o': 'ō', 'u': 'ū',
                        'A': 'Ā', 'E': 'Ē', 'I': 'Ī', 'O': 'Ō', 'U': 'Ū',
                        's': 'ş', 't': 'ţ', 'n': 'ñ', 'c': 'ç'
                    }
                    result += similar_chars.get(char, char)
                else:
                    result += char
            else:
                result += char
        
        elif echo_type == "reverse":
            # Reverse segments based on quantum bits
            if quantum_bit == '1':
                result += char.upper() if char.islower() else char.lower()
            else:
                result += char
        
        elif echo_type == "ghost":
            # Make text appear ghostly/faded
            if quantum_bit == '1' and char.isalpha():
                ghost_chars = {
                    'a': 'ᵃ', 'e': 'ᵉ', 'i': 'ⁱ', 'o': 'ᵒ', 'u': 'ᵘ',
                    'n': 'ⁿ', 's': 'ˢ', 't': 'ᵗ', 'r': 'ʳ', 'l': 'ˡ'
                }
                result += ghost_chars.get(char.lower(), char)
            else:
                result += char
        
        elif echo_type == "quantum_caps":
            # Quantum-influenced capitalization
            if quantum_bit == '1':
                result += char.upper()
            else:
                result += char.lower()
        
        bit_index += 1
    
    return result

@app.route('/quantum_echo', methods=['POST'])
def quantum_echo_endpoint():
    """Main endpoint for quantum echo transformation."""
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing text parameter'}), 400
        
        text = data['text']
        echo_type = data.get('echo_type', 'scramble')
        
        # Validate echo_type
        valid_types = ['scramble', 'reverse', 'ghost', 'quantum_caps']
        if echo_type not in valid_types:
            echo_type = 'scramble'
        
        # Generate quantum echo
        echoed_text = quantum_echo(text, echo_type)
        
        return jsonify({
            'original': text,
            'echo': echoed_text,
            'echo_type': echo_type,
            'quantum_processed': True
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/quantum_gates', methods=['POST'])
def quantum_gates_endpoint():
    """Apply quantum gate sequences to text transformation."""
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing text parameter'}), 400
        
        text = data['text']
        gate_sequence = data.get('gate_sequence', 'H-X')
        
        # Apply quantum gate transformation
        result = quantum_gate_transform(text, gate_sequence)
        
        return jsonify({
            'original': text,
            'transformed': result['transformed_text'],
            'quantum_states': result['quantum_states'],
            'gates_applied': result['gates_applied'],
            'superposition_average': result['superposition_average'],
            'transformation_type': 'quantum_gates'
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/quantum_entanglement', methods=['POST'])
def quantum_entanglement_endpoint():
    """Advanced quantum text transformation using entanglement."""
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing text parameter'}), 400
        
        text = data['text']
        circuit_type = data.get('circuit_type', 'entanglement')
        
        # Valid circuit types
        valid_circuits = ['entanglement', 'interference', 'teleportation']
        if circuit_type not in valid_circuits:
            circuit_type = 'entanglement'
        
        # Apply quantum circuit transformation
        result = quantum_circuit_transform(text, circuit_type)
        
        return jsonify({
            'original': text,
            'transformed': result['transformed_text'],
            'circuit_type': result['circuit_type'],
            'entangled_pairs': result['entangled_pairs'],
            'quantum_correlation': result['quantum_correlation'],
            'transformation_type': 'quantum_circuit'
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/quantum_memory', methods=['POST'])
def quantum_memory_endpoint():
    """Simulate quantum memory effects for story integration."""
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing text parameter'}), 400
        
        text = data['text']
        memory_type = data.get('memory_type', 'fragmented')
        intensity = data.get('intensity', 0.5)  # 0.0 to 1.0
        
        # Create quantum memory effects
        if memory_type == 'fragmented':
            # Fragment memories using quantum interference
            result = quantum_circuit_transform(text, 'interference')
            memory_state = 'fragmented'
        elif memory_type == 'entangled':
            # Entangled memories - parts influence each other
            result = quantum_circuit_transform(text, 'entanglement')
            memory_state = 'quantum_entangled'
        elif memory_type == 'superposition':
            # Memory in superposition - multiple states
            gate_seq = f"H-ROT-Y-Z"
            result = quantum_gate_transform(text, gate_seq)
            memory_state = 'superposition'
        else:
            # Default to quantum echo
            echo_result = quantum_echo(text, 'ghost')
            result = {
                'transformed_text': echo_result,
                'quantum_states': [],
                'superposition_average': intensity
            }
            memory_state = 'quantum_echo'
        
        # Adjust intensity of transformation
        if intensity < 0.3:
            # Low intensity - subtle changes
            transformed_text = text  # Keep some original
            for i in range(0, len(result['transformed_text']), 3):
                if i < len(transformed_text):
                    transformed_text = transformed_text[:i] + result['transformed_text'][i] + transformed_text[i+1:]
        else:
            transformed_text = result['transformed_text']
        
        return jsonify({
            'original': text,
            'memory_echo': transformed_text,
            'memory_type': memory_type,
            'memory_state': memory_state,
            'intensity': intensity,
            'quantum_coherence': result.get('superposition_average', intensity),
            'story_context': 'quantum_memory_fragment'
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/quantum_echo_types', methods=['GET'])
def get_echo_types():
    """Get available quantum transformation types."""
    return jsonify({
        'basic_echo_types': [
            {
                'name': 'scramble',
                'description': 'Quantum scrambling with special characters'
            },
            {
                'name': 'reverse',
                'description': 'Quantum case reversal'
            },
            {
                'name': 'ghost',
                'description': 'Ghostly superscript transformation'
            },
            {
                'name': 'quantum_caps',
                'description': 'Quantum-influenced capitalization'
            }
        ],
        'advanced_transformations': [
            {
                'name': 'quantum_gates',
                'description': 'Apply quantum gate sequences (H, X, Y, Z, ROT)',
                'endpoint': '/quantum_gates',
                'parameters': ['text', 'gate_sequence']
            },
            {
                'name': 'quantum_entanglement',
                'description': 'Multi-qubit entanglement transformations',
                'endpoint': '/quantum_entanglement',
                'parameters': ['text', 'circuit_type'],
                'circuit_types': ['entanglement', 'interference', 'teleportation']
            },
            {
                'name': 'quantum_memory',
                'description': 'Quantum memory effects for story integration',
                'endpoint': '/quantum_memory',
                'parameters': ['text', 'memory_type', 'intensity'],
                'memory_types': ['fragmented', 'entangled', 'superposition']
            }
        ]
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'service': 'quantum-echo-server',
        'qiskit_available': True
    })

@app.route('/', methods=['GET'])
def index():
    """Basic info endpoint."""
    return jsonify({
        'service': 'Quantum Echo Server',
        'version': '2.0.0',
        'description': 'Advanced quantum text transformation using quantum gates and circuits',
        'endpoints': {
            'POST /quantum_echo': 'Basic quantum echo transformation',
            'POST /quantum_gates': 'Apply quantum gate sequences (H, X, Y, Z, ROT)',
            'POST /quantum_entanglement': 'Multi-qubit quantum circuits (entanglement, interference, teleportation)',
            'POST /quantum_memory': 'Quantum memory effects for story integration',
            'GET /quantum_echo_types': 'Get available transformation types',
            'GET /health': 'Health check'
        },
        'quantum_features': [
            'Real Qiskit quantum circuits',
            'Quantum gate operations (Hadamard, Pauli-X/Y/Z, Rotations)',
            'Multi-qubit entanglement',
            'Quantum superposition effects',
            'Story-integrated memory fragments'
        ]
    })

if __name__ == '__main__':
    # Development server
    app.run(host='0.0.0.0', port=8000, debug=True)
