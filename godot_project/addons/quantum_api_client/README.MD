# Quantum API Client for Godot

This game contains the Quantum API runtime addon at
`addons/quantum_api_client/`. It handles text transformation, quick simulator
gate effects, IBM backend discovery, transpilation, and asynchronous IBM
hardware jobs.

## Configure This Game

1. Open **Project > Project Settings > Plugins** in Godot.
2. Enable **Quantum API Client Settings**. This is an editor helper only; it
   adds the Quantum API fields to **General > Quantum Api**.
3. For the jam's direct connection, turn **Backend Proxy Mode** off, set the
   Quantum API base URL, and enter the direct API key.
4. To choose a specific IBM credential profile, enter its exact profile name in
   **Default Ibm Profile**. Leave it blank to use the Quantum API account's
   default IBM profile.

The key and IBM credentials are separate: the game sends its Quantum API key;
Quantum API holds the IBM token in the selected profile.

## What Runs Where

| Game action | Result | IBM hardware job? |
| --- | --- | --- |
| Dialogue text transformation | API returns transformed text | No |
| Quick gate visual/effect | API simulator response | No |
| Hardware gate mode | Game submits a circuit job and polls it | Yes |

Text successfully transforming proves the game can reach Quantum API. It does
not create an IBM job. To test IBM, reach a gate choice in the game while
**Gate Execution Mode** is `hardware`; the game will submit and wait for the
job result. IBM queues can take a while.

## Troubleshooting

- **No Default Ibm Profile field:** enable **Quantum API Client Settings** in
  Project Settings > Plugins, then open General > Quantum Api again.
- **No IBM job appears:** make sure Gate Execution Mode is `hardware`, then
  actually choose a gate in dialogue. Text transformation alone is unrelated.
- **Profile error:** verify the profile in the Quantum API web portal and make
  sure the spelling in Godot matches it exactly. Or leave the field blank to
  use your account default profile.

The full reusable-addon guide is maintained in the Quantum API repository at
`addons/quantum_api_client/README.md`.
