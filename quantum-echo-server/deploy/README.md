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
   curl -X POST http://localhost:5000/quantum_echo \
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
   gunicorn --bind 0.0.0.0:5000 --workers 4 app:app
   ```

#### Option 3: Using Docker

1. **Create Dockerfile**:
   ```dockerfile
   FROM python:3.9-slim

   WORKDIR /app
   COPY requirements.txt .
   RUN pip install -r requirements.txt

   COPY app.py .

   EXPOSE 5000
   CMD ["python", "app.py"]
   ```

2. **Build and Run**:
   ```bash
   docker build -t quantum-echo .
   docker run -p 5000:5000 quantum-echo
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
           proxy_pass http://127.0.0.1:5000;
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
var server_url = "http://localhost:5000"  # Change to your VPS URL

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
PORT=5000
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
curl http://your-server:5000/health

# Echo types
curl http://your-server:5000/quantum_echo_types

# Quantum echo
curl -X POST http://your-server:5000/quantum_echo \
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
