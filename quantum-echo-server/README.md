# Quantum Echo Server

A Flask-based quantum computing server that uses Qiskit to create "quantum echoes" of dialogue text. This server can transform text using real quantum circuits, creating interesting effects for games and interactive applications.

## Features

- **Quantum Text Transformation**: Uses Qiskit quantum circuits to transform dialogue
- **Multiple Echo Types**: Different quantum transformations (scramble, reverse, ghost, quantum_caps)
- **CORS Enabled**: Works with web-based games and applications
- **RESTful API**: Simple JSON-based API endpoints
- **Health Monitoring**: Built-in health check endpoint

## Echo Types

1. **Scramble**: Quantum superposition creates special character replacements
2. **Reverse**: Quantum-influenced case reversal
3. **Ghost**: Converts characters to superscript "ghostly" versions
4. **Quantum Caps**: Random capitalization based on quantum measurements

## Installation & Setup

### Local Development

1. **Clone and Navigate**:
   ```bash
   cd quantum-echo-server
   ```

2. **Create Virtual Environment**:
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # Linux/Mac
   source venv/bin/activate
   ```

3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the Server**:
   ```bash
   python app.py
   ```

5. **Test the Server**:
   ```bash
   curl -X POST http://108.175.12.95:8000/quantum_echo \
        -H "Content-Type: application/json" \
        -d '{"text": "Hello quantum world!", "echo_type": "scramble"}'
   ```

### VPS Deployment (Production)

#### Option 1: Using systemd (Recommended)

1. **Upload Files to VPS**:
   ```bash
   scp -r quantum-echo-server/ user@your-vps:/home/user/
   ```

2. **Connect to VPS and Setup**:
   ```bash
   ssh user@your-vps
   cd /home/user/quantum-echo-server
   
   # Install Python and pip if needed
   sudo apt update
   sudo apt install python3 python3-pip python3-venv
   
   # Create virtual environment
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Create systemd Service**:
   ```bash
   sudo nano /etc/systemd/system/quantum-echo.service
   ```

   Add this content:
   ```ini
   [Unit]
   Description=Quantum Echo Server
   After=network.target

   [Service]
   Type=simple
   User=user
   WorkingDirectory=/home/user/quantum-echo-server
   Environment=PATH=/home/user/quantum-echo-server/venv/bin
   ExecStart=/home/user/quantum-echo-server/venv/bin/python app.py
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

4. **Start the Service**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable quantum-echo
   sudo systemctl start quantum-echo
   sudo systemctl status quantum-echo
   ```

#### Option 2: Using Gunicorn (Alternative)

1. **Install Gunicorn**:
   ```bash
   pip install gunicorn
   ```

2. **Run with Gunicorn**:
   ```bash
   gunicorn --bind 0.0.0.0:8000 --workers 4 app:app
   ```

#### Option 3: Using Docker

1. **Create Dockerfile**:
   ```dockerfile
   FROM python:3.9-slim

   WORKDIR /app
   COPY requirements.txt .
   RUN pip install -r requirements.txt

   COPY app.py .

   EXPOSE 8000
   CMD ["python", "app.py"]
   ```

2. **Build and Run**:
   ```bash
   docker build -t quantum-echo .
   docker run -p 8000:8000 quantum-echo
   ```

### Nginx Reverse Proxy (Optional)

To serve on port 80/443 with SSL:

1. **Install Nginx**:
   ```bash
   sudo apt install nginx
   ```

2. **Create Nginx Config**:
   ```bash
   sudo nano /etc/nginx/sites-available/quantum-echo
   ```

   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://127.0.0.1:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       }
   }
   ```

3. **Enable Site**:
   ```bash
   sudo ln -s /etc/nginx/sites-available/quantum-echo /etc/nginx/sites-enabled/
   sudo systemctl restart nginx
   ```

## API Endpoints

### POST /quantum_echo
Transform text using quantum circuits.

**Request**:
```json
{
    "text": "Hello world!",
    "echo_type": "scramble"
}
```

**Response**:
```json
{
    "original": "Hello world!",
    "echo": "Hēllō wōrld!",
    "echo_type": "scramble",
    "quantum_processed": true
}
```

### GET /quantum_echo_types
Get available echo transformation types.

**Response**:
```json
{
    "echo_types": [
        {
            "name": "scramble",
            "description": "Quantum scrambling with special characters"
        }
    ]
}
```

### GET /health
Health check endpoint.

**Response**:
```json
{
    "status": "healthy",
    "service": "quantum-echo-server",
    "qiskit_available": true
}
```

## Godot Integration

### GDScript HTTP Request Example

```gdscript
extends Node

var http_request: HTTPRequest
var server_url = "http://108.175.12.95:8000"  # Change to your VPS URL

func _ready():
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_quantum_echo_received)

func get_quantum_echo(dialogue_text: String, echo_type: String = "scramble"):
    var headers = ["Content-Type: application/json"]
    var json_data = {
        "text": dialogue_text,
        "echo_type": echo_type
    }
    var json_string = JSON.stringify(json_data)
    http_request.request(server_url + "/quantum_echo", headers, HTTPClient.METHOD_POST, json_string)

func _on_quantum_echo_received(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    if response_code == 200:
        var json = JSON.new()
        var parse_result = json.parse(body.get_string_from_utf8())
        if parse_result == OK:
            var response_data = json.data
            var quantum_echo = response_data.echo
            print("Quantum Echo: ", quantum_echo)
            # Use the quantum echo in your dialogue system
            display_quantum_dialogue(quantum_echo)
    else:
        print("Error: ", response_code)

func display_quantum_dialogue(echo_text: String):
    # Integrate with your dialogue system
    # For example, show this as a "quantum reflection" of the dialogue
    pass
```

### Integration with Your Dialogue System

1. **Normal Dialogue**: Display regular dialogue text
2. **Quantum Echo**: Call the server to get a quantum transformation
3. **Display Both**: Show original dialogue, then show quantum echo as a "reflection" or "whisper"

Example usage in your dialogue system:
```gdscript
# In your dialogue manager
func show_dialogue_with_echo(text: String):
    # Show normal dialogue
    dialogue_label.text = text
    
    # Get quantum echo
    get_quantum_echo(text, "ghost")
    
    # The echo will be displayed when the HTTP request completes
```

## Production Configuration

### Environment Variables
Create a `.env` file for production:
```env
FLASK_ENV=production
FLASK_DEBUG=False
HOST=0.0.0.0
PORT=8000
```

### Security Considerations
- Use HTTPS in production
- Implement rate limiting
- Add authentication if needed
- Monitor resource usage (quantum circuits can be CPU intensive)

## Troubleshooting

### Common Issues

1. **Import Errors**: Make sure virtual environment is activated and dependencies are installed
2. **Port Already in Use**: Change the port in `app.py` or kill the process using the port
3. **CORS Issues**: The server includes CORS headers, but check your browser's developer tools
4. **Quantum Circuit Errors**: Large texts are limited to 20 qubits for performance

### Logs
Check logs with:
```bash
# For systemd service
sudo journalctl -u quantum-echo -f

# For direct Python execution
python app.py  # Logs will appear in terminal
```

### Testing
Test all endpoints:
```bash
# Health check
curl http://your-server:8000/health

# Echo types
curl http://your-server:8000/quantum_echo_types

# Quantum echo
curl -X POST http://your-server:8000/quantum_echo \
     -H "Content-Type: application/json" \
     -d '{"text": "Test message", "echo_type": "scramble"}'
```

## Performance Notes

- Quantum circuits are limited to 20 qubits for performance
- Large texts are automatically truncated
- Consider implementing caching for repeated requests
- Monitor CPU usage during heavy quantum computations

## Contributing

Feel free to extend the quantum transformations by adding new echo types or improving the quantum circuits!


######
yes. look at my original file. I feel like you're not using the quantumgate class or quantumcircuitmanager class like you should. 

# Quantum Gate Operation

from qiskit import QuantumCircuit, Aer, execute
from qiskit.quantum_info import Statevector

# Create a single qubit circuit
qc = QuantumCircuit(1)

# Initial state |0> by default

# Bit flip (X gate)
def bit_flip(circuit):
    circuit.x(0)  # Apply X gate to qubit 0

# Phase flip (Z gate)
def phase_flip(circuit):
    circuit.z(0)  # Apply Z gate to qubit 0

# Rotation around Y axis (Ry gate)
def rotate(circuit, theta):
    circuit.ry(theta, 0)  # Rotate qubit 0 by theta radians about Y axis

# Example usage:
# Initialize circuit
qc = QuantumCircuit(1)

# Apply bit flip
bit_flip(qc)

# Apply phase flip
phase_flip(qc)

# Apply rotation by theta = pi/2
from math import pi
rotate(qc, pi/2)

# Get final statevector of the qubit after operations
backend = Aer.get_backend('statevector_simulator')
result = execute(qc, backend).result()
state = result.get_statevector()

print("Final statevector:", state)



# Represents a single qubit with superposition amplitudes

from qiskit import QuantumCircuit, Aer, execute
from qiskit.quantum_info import Statevector
import numpy as np
import random

class Qubit:
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

# Example usage:
qubit = Qubit()
qubit.bit_flip()
qubit.phase_flip()
qubit.rotate_y(np.pi/4)
print("Measurement result:", qubit.measure())



# Represents a quantum gate that can be applied to qubits and dialouge and sceen management parts

from qiskit import QuantumCircuit, Aer, execute
from enum import Enum

# Quantum gate types
class GateType(Enum):
    BIT_FLIP = 1
    PHASE_FLIP = 2
    ROTATE_Y = 3

class Qubit:
    def __init__(self):
        self.state = [1, 0]  # Placeholder, real state vector managed by QuantumCircuit

class QuantumGate:
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
    def __init__(self, num_qubits: int):
        self.num_qubits = num_qubits
        self.qc = QuantumCircuit(num_qubits)
    
    def apply_gate_to_qubit(self, gate: QuantumGate, qubit_index: int):
        if 0 <= qubit_index < self.num_qubits:
            gate.apply_to(self.qc, qubit_index)
    
    def simulate(self):
        backend = Aer.get_backend('statevector_simulator')
        result = execute(self.qc, backend).result()
        statevector = result.get_statevector()
        return statevector

class DialogueManager:
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
    def __init__(self):
        self.dialogue_manager = None

    def on_task_completed(self):
        print("Task completed, switching scenes...")
        self.change_scene("MemoryChamber")

    def change_scene(self, scene_path):
        print(f"Changing scene to: {scene_path}")
        # Implement scene switching logic here

# Example data and usage:

dialogue_data = {
    "memory_unlock": [
        {"speaker": "Narrator", "text": "You have unlocked a memory."},
        {"speaker": "Main Character", "text": "What should I do?", "choices": ["Explore", "Leave"]}
    ]
}

# Setup
qc_manager = QuantumCircuitManager(num_qubits=3)

# Apply a bit flip to qubit 0
bit_flip_gate = QuantumGate(GateType.BIT_FLIP)
qc_manager.apply_gate_to_qubit(bit_flip_gate, 0)

# Simulate and print the statevector
statevector = qc_manager.simulate()
print("Quantum statevector:", statevector)

# Dialogue system
dialogue_manager = DialogueManager(dialogue_data)

def handle_choice(choice):
    print(f"Dialogue finished with choice: {choice}")

dialogue_manager.on_dialogue_finished(handle_choice)
dialogue_manager.start_dialogue("memory_unlock")

# Simulate user choice (choosing option 0 = "Explore")
dialogue_manager.on_choice_made(0)

# Scene controller example
scene_controller = SceneController()
scene_controller.on_task_completed()

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

remove the 'memory type' or 'speaker'. it's just text. 

  try something more succint. we will have the quantum_word_dictionary in the server with the app.py so we can get those categories. 

