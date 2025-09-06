from flask import Flask, request, jsonify
from flask_cors import CORS
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
import random
import string

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests from web games

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

@app.route('/quantum_echo_types', methods=['GET'])
def get_echo_types():
    """Get available echo transformation types."""
    return jsonify({
        'echo_types': [
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
        'version': '1.0.0',
        'endpoints': {
            'POST /quantum_echo': 'Generate quantum echo of text',
            'GET /quantum_echo_types': 'Get available echo types',
            'GET /health': 'Health check'
        }
    })

if __name__ == '__main__':
    # Development server
    app.run(host='0.0.0.0', port=5000, debug=True)
