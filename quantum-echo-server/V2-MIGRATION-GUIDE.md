# Quantum API v2.0.0 - URL Migration Guide

## What Changed in v2.0.0

### URL Structure Update
The Quantum API has moved to a new URL structure for better organization and discoverability:

**Old URLs (v1.x - DEPRECATED):**
- `https://quantum-api.davidjgrimsley.com/quantum_text`
- `https://quantum-api.davidjgrimsley.com/quantum_gate`
- `http://108.175.12.95:8000/quantum_text` (direct IP - discontinued)

**New URLs (v2.0.0):**
- `https://DavidJGrimsley.com/api/quantum/quantum_text`
- `https://DavidJGrimsley.com/api/quantum/quantum_gate`
- `https://DavidJGrimsley.com/api/quantum/quantum_echo_types`
- `https://DavidJGrimsley.com/api/quantum/health`

### Documentation & Resources
- **Interactive Page**: `https://DavidJGrimsley.com/api/quantum`
- **API Documentation (Swagger)**: `https://DavidJGrimsley.com/api/quantum/docs`
- **OpenAPI Spec**: `https://DavidJGrimsley.com/api/quantum/openapi.yaml`
- **API List**: `https://DavidJGrimsley.com/api`

## Semantic Versioning

The API now follows semantic versioning (MAJOR.MINOR.PATCH):

- **Major (2.x.x)**: Breaking changes (like this URL restructure)
- **Minor (2.1.x)**: New features, backward compatible
- **Patch (2.0.1)**: Bug fixes

## Migration Steps

### For Client Applications

1. **Update base URL:**
   ```javascript
   // Old
   const BASE_URL = "https://quantum-api.davidjgrimsley.com";
   
   // New
   const BASE_URL = "https://DavidJGrimsley.com/api/quantum";
   ```

2. **Update endpoint paths** (if using full URLs):
   ```javascript
   // Old
   fetch("https://quantum-api.davidjgrimsley.com/quantum_text", {...})
   
   // New
   fetch("https://DavidJGrimsley.com/api/quantum/quantum_text", {...})
   ```

3. **No changes to request/response format** - All payloads remain the same

### For Godot Projects

Update the `SERVER_URL` constant in your quantum service files:

```gdscript
# Old
const SERVER_URL = "https://108.175.12.95:8000"

# New
const SERVER_URL = "https://DavidJGrimsley.com/api/quantum"
```

### For React/Expo Projects

Update fetch calls to use the new base URL:

```typescript
// Old
const response = await fetch('http://108.175.12.95:8000/quantum_gate', {...});

// New
const response = await fetch('https://DavidJGrimsley.com/api/quantum/quantum_gate', {...});
```

## Technical Details

### Architecture
- API server still runs on `quantum-api.davidjgrimsley.com` backend
- Nginx reverse proxy routes requests from `DavidJGrimsley.com/api/quantum/*` to backend
- SSL/TLS handled by portfolio site certificate
- CORS enabled for cross-origin requests

### Backend Configuration
- Flask app updated with `/api/quantum/` route prefix
- Version info available in API response (2.0.0)
- Health check available at `/api/quantum/health`

## Testing

Test the new endpoints:

```bash
# Get API info
curl https://DavidJGrimsley.com/api/quantum/

# Health check
curl https://DavidJGrimsley.com/api/quantum/health

# Transform text
curl -X POST https://DavidJGrimsley.com/api/quantum/quantum_text \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello quantum world!"}'

# Apply quantum gate
curl -X POST https://DavidJGrimsley.com/api/quantum/quantum_gate \
  -H "Content-Type: application/json" \
  -d '{"gate": "bit_flip"}'
```

## Support

For issues or questions:
- Documentation: https://DavidJGrimsley.com/api/quantum/docs
- GitHub: [Your repository URL]
- Portfolio: https://DavidJGrimsley.com

## Deployment Checklist

- [x] Flask app updated with v2 routes
- [x] OpenAPI spec updated to v2.0.0
- [x] Nginx reverse proxy configured
- [x] Godot client code updated
- [x] React/Expo client code updated
- [ ] Deploy nginx configuration to Plesk
- [ ] Restart quantum-api backend service
- [ ] Test all endpoints
- [ ] Update portfolio website with API pages
- [ ] Announce migration to users
