# Quantum API Godot Client

Reusable Godot runtime client for the mounted Quantum API `/v1` contract.

## What This Is

This folder is the promoted home for the reusable Godot addon/client.

- Runtime-focused, not an editor plugin
- Intended to be copied into a Godot project as `addons/quantum_api_client/`
- Supports gameplay/runtime plus IBM hardware profile usage:
  - `health_check`
  - `transform_text`
  - `run_gate`
  - `list_backends`
  - `transpile`
  - `submit_circuit_job`

## Install

1. Install the addon directory as `addons/quantum_api_client/` in your Godot
   project. This game already vendors that exact directory.
2. In your game script, preload `res://addons/quantum_api_client/quantum_api_client.gd`.
3. Create the client as a child node at runtime.
4. Call `apply_project_settings()` at startup (or set values manually via setters).

## Project Settings

Add this to your `project.godot`:

```ini
[quantum_api]
base_url="https://davidjgrimsley.com/public-facing/api/quantum"
backend_proxy_mode=true
direct_api_key=""
default_ibm_profile=""
request_timeout_seconds=10.0
```

Field usage:

- `base_url`: mounted Quantum API root (`/v1` is auto-normalized by the addon)
- `backend_proxy_mode`: when `false`, protected runtime endpoints call Quantum API directly
- `direct_api_key`: direct-mode key used by this jam game; it is intentionally
  bundled and therefore not private
- `default_ibm_profile`: optional fallback profile name for IBM routes
- `request_timeout_seconds`: positive REST timeout in seconds (defaults to `10.0`)

## Layout

- `addons/quantum_api_client/quantum_api_client.gd` - shared runtime client

## AssetLib Submission Metadata

Use these values for the current AssetLib submission form:

- Asset Name: Quantum API Client
- Category: Network
- Godot Version: 4.x
- License: Apache-2.0
- Repository URL: https://github.com/DavidJGrimsley/quantum-api
- Install Path Inside ZIP: addons/quantum_api_client
- Icon URL (direct): https://i.imgur.com/mbMnGVA.jpeg

## Base URL Behavior

The client normalizes either of these:

- `https://your-backend.example.com/public-facing/api/quantum`
- `https://your-backend.example.com/public-facing/api/quantum/v1`

## Auth Modes

- Echoes of Light uses direct API-key mode. It sends `X-API-Key` to the hosted
  Quantum API and does not require a separate game server.
- Backend proxy mode remains supported by the reusable addon for projects that
  want to keep a key off the player device.

If required auth is missing, the addon now fails early with clear diagnostics instead of sending doomed requests.

For a reusable production game, do not embed a live API key in a player build.
This game deliberately accepts that trade-off to stay simple for the jam.

## IBM Profiles (Per-User IBM Credentials)

How a developer running an operator-only direct-mode IBM validation gets credentials and profiles:

1. Open `https://davidjgrimsley.com/public-facing/api/quantum` and sign in with an Identerest account.
2. In the `Api Keys` panel, create a Quantum API key and copy the raw key immediately (it is shown once).
3. In the `IBM Credentials` panel, create an IBM profile (`profile_name`, IBM API token, IBM instance/CRN, channel), then click verify.
4. Optionally mark one profile as default on that same public page.

Profile management (create/list/update/delete/verify) stays on your portfolio website.
This addon only consumes existing profile names for IBM runtime calls.

For IBM-specific runtime routes, pass `ibm_profile` explicitly or configure `default_ibm_profile` in project settings.

## Sample Usage

```gdscript
const QuantumApiClientScript = preload("res://addons/quantum_api_client/quantum_api_client.gd")

var quantum_api_client: QuantumApiClient

func _ready() -> void:
	quantum_api_client = QuantumApiClientScript.new()
	add_child(quantum_api_client)
	quantum_api_client.apply_project_settings()
```

Echoes of Light direct API usage:

```gdscript
quantum_api_client.apply_project_settings()
quantum_api_client.set_backend_proxy_mode(false)
```

IBM hardware usage example:

```gdscript
quantum_api_client.apply_project_settings()
quantum_api_client.set_backend_proxy_mode(false)
quantum_api_client.set_default_ibm_profile("Echo Text Adventure Godot Game")

quantum_api_client.list_backends(func(success: bool, payload: Dictionary) -> void:
    print(success, payload)
, "ibm")
```
