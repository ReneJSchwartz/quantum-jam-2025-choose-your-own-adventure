# 🌀 Quantum Echo Integration for Godot

This integration connects your Godot choose-your-own-adventure game to the Quantum Echo Server for real-time text transformation using quantum effects.

## 🔧 **What I've Added**

### **New Files Created:**
1. **`quantum_echo_service.gd`** - Service to communicate with your quantum server
2. **`quantum_test.gd`** - Test script to verify the integration works
3. **Modified existing dialogue system** - Now processes all dialogue through quantum effects

### **Modified Files:**
1. **`dialogue_ui_manager.gd`** - Now processes text through quantum server before display
2. **`dialogue.gd`** - Fixed SignalBus references for proper scene structure
3. **`main_menu_screen.gd`** - Fixed SignalBus references
4. **`game_tree.tscn`** - Added SignalBus to the scene tree

## 🎮 **How It Works**

1. **Player starts dialogue** → Text is sent to your quantum echo server
2. **Server processes text** → Using quantum circuits (scramble, ghost, etc.)
3. **Transformed text returns** → Displayed with quantum effects to the player
4. **Fallback system** → If server is down, shows original text

## 🚀 **Testing the Integration**

### **Option 1: Quick Test Script**
1. Add the `quantum_test.gd` script to any scene
2. Run the scene to see console output testing the quantum service

### **Option 2: Full Game Test**
1. Run your main game scene (`game_tree.tscn`)
2. Click "New Game" to start the dialogue
3. Watch dialogue text get quantum-processed in real-time!

## ⚡ **Current Configuration**

- **Echo Type**: SCRAMBLE (you can easily change this in `dialogue_ui_manager.gd`)
- **Server URL**: `http://108.175.12.95:5000`
- **Fallback**: Shows original text if server is unavailable

## 🎨 **Available Echo Types**

You can change the echo type in `dialogue_ui_manager.gd` line 185:

```gdscript
quantum_echo_service.EchoType.SCRAMBLE    # Scrambles letters
quantum_echo_service.EchoType.CASE_FLIP   # Flips case randomly  
quantum_echo_service.EchoType.GHOST       # Ghostly appearance
quantum_echo_service.EchoType.QUANTUM_CAPS # Quantum capitalization
quantum_echo_service.EchoType.ORIGINAL    # No transformation
```

## 🔍 **How to Change Echo Types**

To use different echo effects for different characters or situations:

```gdscript
# In dialogue_ui_manager.gd, modify the write_text function:
var echo_type = quantum_echo_service.EchoType.SCRAMBLE

# For different speakers, you could do:
if talker == "Mysterious Voice":
    echo_type = quantum_echo_service.EchoType.GHOST
elif talker == "AI Assistant":  
    echo_type = quantum_echo_service.EchoType.QUANTUM_CAPS
else:
    echo_type = quantum_echo_service.EchoType.SCRAMBLE
```

## 🐛 **Troubleshooting**

### **Server Not Responding**
- Check if your quantum server is still running
- Look in Godot console for "❌ Quantum echo server error" messages
- Game will automatically fall back to original text

### **No Quantum Effects Visible**
- Check Godot console for "✨ Quantum echo received:" messages
- Verify your server URL is correct in `quantum_echo_service.gd`
- Test the quantum_test.gd script first

### **Console Messages to Look For**
```
🌀 Sending quantum echo request: scramble for text: Hello quantum world!...
✅ Quantum server is healthy!
✨ Quantum echo received: Hlleo qautnum wrodl!...
```

## 🎯 **Next Steps**

1. **Start your quantum server** (check if it's still running)
2. **Test in Godot** - Run the game and start a new game to see quantum dialogue
3. **Customize echo types** - Different effects for different characters/situations
4. **Add more effects** - You can extend the server with more quantum transformations

Your game now has **REAL QUANTUM-POWERED DIALOGUE**! 🚀✨
