from flask import Flask, request, jsonify
from flask_cors import CORS
import random
import string

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests from web games

def pseudo_quantum_echo(text, echo_type="scramble"):
    """
    Generate a pseudo-quantum echo using random transformations (fallback version).
    This version doesn't use real quantum circuits but simulates the effects.
    """
    if not text:
        return ""
    
    result = ""
    
    if echo_type == "scramble":
        # Pseudo-quantum scrambling with special characters
        char_map = {
            'a': ['ă', 'ā', 'à', 'á'], 'e': ['ē', 'è', 'é', 'ê'], 
            'i': ['ī', 'ì', 'í', 'î'], 'o': ['ō', 'ò', 'ó', 'ô'], 
            'u': ['ū', 'ù', 'ú', 'û'], 's': ['ş', 'š'], 't': ['ţ', 'ť'], 
            'n': ['ñ', 'ň'], 'c': ['ç', 'č']
        }
        
        for char in text:
            if char.lower() in char_map and random.random() > 0.7:
                result += random.choice(char_map[char.lower()])
            else:
                result += char
    
    elif echo_type == "reverse":
        # Pseudo-quantum case reversal
        for char in text:
            if random.random() > 0.5:
                result += char.upper() if char.islower() else char.lower()
            else:
                result += char
    
    elif echo_type == "ghost":
        # Ghostly superscript transformation
        ghost_chars = {
            'a': 'ᵃ', 'e': 'ᵉ', 'i': 'ⁱ', 'o': 'ᵒ', 'u': 'ᵘ',
            'n': 'ⁿ', 's': 'ˢ', 't': 'ᵗ', 'r': 'ʳ', 'l': 'ˡ'
        }
        
        for char in text:
            if char.lower() in ghost_chars and random.random() > 0.6:
                result += ghost_chars[char.lower()]
            else:
                result += char
    
    elif echo_type == "quantum_caps":
        # Pseudo-quantum capitalization
        for char in text:
            if random.random() > 0.5:
                result += char.upper()
            else:
                result += char.lower()
    
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
        
        # Generate pseudo-quantum echo
        echoed_text = pseudo_quantum_echo(text, echo_type)
        
        return jsonify({
            'original': text,
            'echo': echoed_text,
            'echo_type': echo_type,
            'quantum_processed': True,
            'mode': 'pseudo-quantum'  # Indicates fallback mode
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
                'description': 'Pseudo-quantum scrambling with special characters'
            },
            {
                'name': 'reverse',
                'description': 'Pseudo-quantum case reversal'
            },
            {
                'name': 'ghost',
                'description': 'Ghostly superscript transformation'
            },
            {
                'name': 'quantum_caps',
                'description': 'Pseudo-quantum-influenced capitalization'
            }
        ]
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'service': 'quantum-echo-server',
        'qiskit_available': False,
        'mode': 'pseudo-quantum'
    })

@app.route('/', methods=['GET'])
def index():
    """Basic info endpoint."""
    return jsonify({
        'service': 'Quantum Echo Server (Pseudo-Quantum Mode)',
        'version': '1.0.0',
        'endpoints': {
            'POST /quantum_echo': 'Generate pseudo-quantum echo of text',
            'GET /quantum_echo_types': 'Get available echo types',
            'GET /health': 'Health check'
        }
    })

if __name__ == '__main__':
    # Production server
    app.run(host='0.0.0.0', port=5000, debug=False)
