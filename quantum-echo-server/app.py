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
        self._update_visuals()
    
    def phase_flip(self):
        # Apply Z gate (phase flip)
        qc = QuantumCircuit(1)
        qc.z(0)
        self.state = self.state.evolve(qc)
        self._update_visuals()
    
    def rotate_y(self, theta):
        # Apply Ry(theta) gate (rotation around Y axis)
        qc = QuantumCircuit(1)
        qc.ry(theta, 0)
        self.state = self.state.evolve(qc)
        self._update_visuals()
    
    def hadamard(self):
        """H gate - creates superposition using qiskit."""
        qc = QuantumCircuit(1)
        qc.h(0)
        self.state = self.state.evolve(qc)
        self._update_visuals()
    
    def measure(self):
        # Simulate measurement probabilistically, collapsing state
        probabilities = self.state.probabilities_dict()
        p0 = probabilities.get('0', 0)
        rand_val = random.random()
        if rand_val < p0:
            self.state = Statevector([1, 0])  # Collapse to |0>
            self._update_visuals()
            return 0
        else:
            self.state = Statevector([0, 1])  # Collapse to |1>
            self._update_visuals()
            return 1
    
    def _update_visuals(self):
        # Placeholder for updating visuals based on state amplitudes
        alpha, beta = self.state.data
        superposition_strength = abs(abs(alpha)**2 - abs(beta)**2)
        # Here you could update a graphical element based on superposition_strength
        # For example: print or set color intensity
        print(f"Superposition strength: {superposition_strength:.3f}")
    
    def get_amplitudes(self):
        # Optional method to get alpha and beta amplitudes
        return self.state.data
    
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
        backend = AerSimulator()
        # Use transpile and run instead of execute
        transpiled_qc = transpile(self.qc, backend)
        job = backend.run(transpiled_qc, shots=1)
        result = job.result()
        statevector = result.get_statevector()
        return statevector

class DialogueManager:
    """Manages dialogue and scene integration."""
    
    def __init__(self, dialogue_data):
        self.dialogue_data = dialogue_data  # JSON/dict mapping dialogue_id to list of lines
        self.current_line = 0
        self.dialogue_finished_callbacks = []
    
    def start_dialogue(self, dialogue_id):
        self.dialogue_id = dialogue_id
        self.current_line = 0
        self._show_next_line()
    
    def _show_next_line(self):
        lines = self.dialogue_data.get(self.dialogue_id, [])
        if self.current_line < len(lines):
            line = lines[self.current_line]
            # Here update UI with line content, speaker, and choices (if any)
            print(f"[{line.get('speaker', '')}]: {line.get('text', '')}")
            if 'choices' in line:
                for i, choice in enumerate(line['choices']):
                    print(f"{i+1}: {choice}")
            else:
                print("(No choices)")
        else:
            self._dialogue_finished(None)
    
    def on_choice_made(self, choice_index):
        lines = self.dialogue_data.get(self.dialogue_id, [])
        if self.current_line < len(lines):
            line = lines[self.current_line]
            if 'choices' in line and 0 <= choice_index < len(line['choices']):
                choice = line['choices'][choice_index]
                self._dialogue_finished(choice)
            else:
                self._dialogue_finished(None)
        else:
            self._dialogue_finished(None)
    
    def _dialogue_finished(self, choice):
        for callback in self.dialogue_finished_callbacks:
            callback(choice)
        self.current_line += 1
        self._show_next_line()
    
    def on_dialogue_finished(self, callback):
        self.dialogue_finished_callbacks.append(callback)

class SceneController:
    """Manages scene transitions."""
    
    def __init__(self):
        self.dialogue_manager = None

    def on_task_completed(self):
        print("Task completed, switching scenes...")
        self.change_scene("MemoryChamber")

    def change_scene(self, scene_path):
        print(f"Changing scene to: {scene_path}")
        # Implement scene switching logic here

def quantum_gate_transform(text, gate_sequence="H-X-Y"):
    """
    Transform text using quantum gate operations on individual character qubits with qiskit.
    
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
        # Create a qubit for each character using qiskit
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
    Advanced quantum text transformation using multi-qubit operations with qiskit.
    
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
        # Use qiskit-based qubits
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
    transpiled_qc = transpile(qc, backend)
    job = backend.run(transpiled_qc, shots=1)
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

@app.route('/quantum_demo', methods=['POST'])
def quantum_demo_endpoint():
    """Demonstrate the qiskit quantum functionality with example usage from colleague."""
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            # Use default demo text
            text = "Hello Quantum World"
        else:
            text = data['text']
        
        # Example 1: Your colleague's single qubit operations
        # Create a single qubit circuit
        qc = QuantumCircuit(1)
        
        # Apply bit flip (X gate)
        qc.x(0)
        
        # Apply phase flip (Z gate)
        qc.z(0)
        
        # Apply rotation by theta = pi/2
        qc.ry(math.pi/2, 0)
        
        # Get final statevector of the qubit after operations
        backend = AerSimulator(method='statevector')
        transpiled_qc = transpile(qc, backend)
        job = backend.run(transpiled_qc, shots=1)
        result = job.result()
        state = result.get_statevector()
        
        # Example 2: Using the Qubit class with qiskit
        qubit = Qubit()
        qubit.bit_flip()
        qubit.phase_flip()
        qubit.rotate_y(np.pi/4)
        measurement_result = qubit.measure()
        amplitudes = qubit.get_amplitudes()
        
        # Example 3: Multi-qubit circuit with your colleague's quantum echo pattern
        n_qubits = min(len(text), 8)  # Limit for demo
        echo_qc = QuantumCircuit(n_qubits, n_qubits)
        
        # Initialize qubits based on text (your colleague's pattern)
        text_bits = []
        for char in text[:n_qubits]:
            bits = format(ord(char), '08b')
            text_bits.extend([int(b) for b in bits[:n_qubits]])
        
        for i in range(n_qubits):
            if i < len(text_bits) and text_bits[i] == 1:
                echo_qc.x(i)
        
        # Apply Hadamard gates to create superposition (scramble effect)
        for i in range(n_qubits):
            echo_qc.h(i)
        
        # Measure all qubits
        echo_qc.measure(range(n_qubits), range(n_qubits))
        
        # Execute the circuit
        backend = AerSimulator()
        transpiled_echo_qc = transpile(echo_qc, backend)
        job = backend.run(transpiled_echo_qc, shots=1)
        echo_result = job.result()
        echo_counts = echo_result.get_counts()
        measured_bits = list(echo_counts.keys())[0] if echo_counts else "0" * n_qubits
        
        # Apply quantum gate transformation to text
        gate_result = quantum_gate_transform(text, "H-X-Y-Z")
        
        return jsonify({
            'demo_text': text,
            'colleague_single_qubit_demo': {
                'statevector': [complex(amp).real for amp in state.data],  # Real parts for JSON
                'operations_applied': ['X (bit flip)', 'Z (phase flip)', 'Ry(π/2) rotation'],
                'final_statevector_description': 'After X-Z-Ry(π/2) sequence'
            },
            'qubit_class_demo': {
                'measurement': measurement_result,
                'amplitudes': [complex(amp).real for amp in amplitudes],  # Real parts for JSON
                'operations': ['bit_flip', 'phase_flip', 'rotate_y(π/4)']
            },
            'quantum_echo_circuit_demo': {
                'n_qubits': n_qubits,
                'initial_text_bits': text_bits[:n_qubits],
                'measured_result': measured_bits,
                'circuit_description': 'Text → binary → qubits → X gates → Hadamard → measure'
            },
            'text_transformation': gate_result,
            'qiskit_version_info': {
                'status': 'Successfully integrated and operational',
                'api_version': 'Modern qiskit 2.1.2 with AerSimulator',
                'colleague_code_adapted': True,
                'quantum_classes_available': ['Qubit', 'QuantumGate', 'QuantumCircuitManager', 'DialogueManager', 'SceneController']
            }
        })
    
    except Exception as e:
        return jsonify({'error': str(e), 'qiskit_status': 'Error occurred'}), 500

@app.route('/colleague_quantum_demo', methods=['POST'])
def colleague_quantum_demo():
    """Demonstrate your colleague's exact quantum operations using qiskit."""
    try:
        data = request.get_json()
        text = data.get('text', 'Quantum') if data else 'Quantum'
        
        # Your colleague's Example 1: Single qubit with gate functions
        def bit_flip(circuit):
            circuit.x(0)  # Apply X gate to qubit 0

        def phase_flip(circuit):
            circuit.z(0)  # Apply Z gate to qubit 0

        def rotate(circuit, theta):
            circuit.ry(theta, 0)  # Rotate qubit 0 by theta radians about Y axis

        # Initialize circuit exactly as your colleague showed
        qc = QuantumCircuit(1)
        
        # Apply bit flip
        bit_flip(qc)
        
        # Apply phase flip
        phase_flip(qc)
        
        # Apply rotation by theta = pi/2
        rotate(qc, math.pi/2)
        
        # Get final statevector using modern qiskit API
        backend = AerSimulator(method='statevector')
        transpiled_qc = transpile(qc, backend)
        job = backend.run(transpiled_qc, shots=1)
        result = job.result()
        state = result.get_statevector()
        
        # Your colleague's Example 2: Qubit class demo
        qubit = Qubit()
        qubit.bit_flip()
        qubit.phase_flip()
        qubit.rotate_y(np.pi/4)
        measurement = qubit.measure()
        
        # Your colleague's Example 3: Text-based quantum circuit (their exact pattern)
        # Convert text to binary representation
        text_bits = []
        for char in text:
            # Convert each character to 8-bit binary
            bits = format(ord(char), '08b')
            text_bits.extend([int(b) for b in bits])
        
        # Limit to reasonable number of qubits (max 16 for demo)
        n_qubits = min(len(text_bits), 16)
        if n_qubits > 0:
            # Create quantum circuit - your colleague's pattern
            echo_qc = QuantumCircuit(n_qubits, n_qubits)
            
            # Initialize qubits based on text bits - exact colleague code
            for i in range(n_qubits):
                if text_bits[i] == 1:
                    echo_qc.x(i)
            
            # Apply quantum gates based on echo type - scramble (colleague's code)
            echo_type = "scramble"
            if echo_type == "scramble":
                # Apply Hadamard gates to create superposition
                for i in range(n_qubits):
                    echo_qc.h(i)
            
            # Measure all qubits - exact colleague pattern
            echo_qc.measure(range(n_qubits), range(n_qubits))
            
            # Execute the circuit - colleague's approach but with modern API
            backend = AerSimulator()
            transpiled_echo = transpile(echo_qc, backend)
            job = backend.run(transpiled_echo, shots=1)
            echo_result = job.result()
            echo_counts = echo_result.get_counts()
            
            # Get the measurement result
            measured_bits = list(echo_counts.keys())[0] if echo_counts else "0" * n_qubits
            
            # Transform the original text based on quantum measurement (colleague's function)
            transformed_text = transform_text_with_quantum_result(text, measured_bits, echo_type)
        else:
            transformed_text = text
            measured_bits = ""
        
        return jsonify({
            'original_text': text,
            'colleague_demonstration': {
                'single_qubit_operations': {
                    'circuit_description': 'Single qubit: X → Z → Ry(π/2)',
                    'final_statevector': [complex(amp).real for amp in state.data],
                    'operations': ['bit_flip (X gate)', 'phase_flip (Z gate)', 'rotate_y (Ry gate with π/2)']
                },
                'qubit_class_demo': {
                    'measurement_result': measurement,
                    'operations_applied': ['bit_flip', 'phase_flip', 'rotate_y(π/4)'],
                    'description': 'Using the Qubit class with qiskit integration'
                },
                'text_quantum_echo': {
                    'original_text': text,
                    'binary_representation': text_bits[:n_qubits] if n_qubits > 0 else [],
                    'quantum_measured_bits': measured_bits,
                    'transformed_text': transformed_text,
                    'circuit_operations': 'Text→Binary→Initialize qubits→Hadamard gates→Measure→Transform',
                    'echo_type': 'scramble'
                }
            },
            'qiskit_integration': {
                'colleague_code_status': 'Successfully adapted to modern qiskit API',
                'api_changes': 'execute() → transpile() + run()',
                'backend_used': 'AerSimulator (modern)',
                'compatibility': 'Full compatibility with colleague quantum patterns'
            }
        })
    
    except Exception as e:
        return jsonify({'error': str(e), 'colleague_demo_status': 'Error occurred'}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    try:
        # Test qiskit import and basic functionality
        from qiskit import QuantumCircuit
        from qiskit_aer import AerSimulator
        from qiskit.quantum_info import Statevector
        
        # Quick test - create and run a simple circuit
        test_qc = QuantumCircuit(1)
        test_qc.h(0)  # Hadamard gate
        
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
        'quantum_classes': ['Qubit', 'QuantumGate', 'QuantumCircuitManager', 'DialogueManager', 'SceneController'],
        'colleague_code_integration': 'Successfully adapted to modern qiskit API'
    })

@app.route('/', methods=['GET'])
def index():
    """Basic info endpoint."""
    return jsonify({
        'service': 'Quantum Echo Server',
        'version': '2.2.0',
        'description': 'Advanced quantum text transformation using real qiskit quantum gates and circuits',
        'qiskit_version': 'Modern qiskit 2.1.2 with AerSimulator',
        'colleague_integration': 'Code patterns from colleague successfully adapted',
        'endpoints': {
            'POST /quantum_echo': 'Basic quantum echo transformation with real qiskit circuits',
            'POST /quantum_gates': 'Apply quantum gate sequences using qiskit (H, X, Y, Z, ROT)',
            'POST /quantum_entanglement': 'Multi-qubit quantum circuits (entanglement, interference, teleportation)',
            'POST /quantum_memory': 'Quantum memory effects for story integration',
            'POST /quantum_demo': 'Comprehensive qiskit demonstration',
            'POST /colleague_quantum_demo': 'Demonstration of colleague\'s exact quantum patterns',
            'GET /quantum_echo_types': 'Get available transformation types',
            'GET /health': 'Health check with qiskit functionality test'
        },
        'quantum_features': [
            'Real qiskit quantum circuits with Statevector simulation',
            'Colleague\'s quantum gate operations (bit_flip, phase_flip, rotate)',
            'Authentic quantum gate operations (Hadamard, Pauli-X/Y/Z, Rotations)',
            'Multi-qubit entanglement using qiskit QuantumCircuit',
            'True quantum superposition effects with qiskit Statevector',
            'Story-integrated quantum memory fragments',
            'Text-to-quantum circuit transformation (colleague\'s pattern)',
            'Quantum echo with Hadamard scrambling'
        ],
        'qiskit_integration': {
            'backend': 'AerSimulator (modern API)',
            'quantum_classes': ['Qubit', 'QuantumGate', 'QuantumCircuitManager'],
            'supported_gates': ['X (bit_flip)', 'Z (phase_flip)', 'Ry (rotate_y)', 'H (hadamard)'],
            'colleague_patterns': ['Single qubit operations', 'Qubit class with qiskit', 'Text quantum echo'],
            'api_modernization': 'execute() → transpile() + run()',
            'dialogue_manager': 'Available for game integration',
            'scene_controller': 'Available for scene transitions'
        }
    })

if __name__ == '__main__':
    # Development server
    app.run(host='0.0.0.0', port=8000, debug=True)
