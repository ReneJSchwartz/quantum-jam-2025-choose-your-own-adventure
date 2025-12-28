import { useEffect, useState } from 'react';
import { View } from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withRepeat,
  withSequence,
  withTiming,
} from 'react-native-reanimated';

import { ThemedText } from '@/src/components/ThemedText';
import { ServerLink } from '@/src/components/ServerLink';

export function HelloWave() {
  const rotationAnimation = useSharedValue(0);
  const scaleAnimation = useSharedValue(1);
  const [quantumIcon, setQuantumIcon] = useState('⚛️');
  const [quantumDetails, setQuantumDetails] = useState('Initializing quantum circuit...');
  const [isAnimating, setIsAnimating] = useState(false);

  const fetchQuantumTiming = async () => {
    console.log('🌊 [QuantumWave] Starting dramatic quantum-controlled animation...');
    setQuantumDetails('🔄 Contacting quantum server...');
    setIsAnimating(true);

    try {
      console.log('🌊 [QuantumWave] Sending request to quantum server: https://DavidJGrimsley.com/api/quantum/quantum_gate');

      // Generate truly random quantum rotation angle for variety!
      const quantumAngles = [
        Math.PI / 8,    // 22.5° → ~38% superposition
        Math.PI / 6,    // 30°   → ~50% superposition  
        Math.PI / 4,    // 45°   → ~71% superposition
        Math.PI / 3,    // 60°   → ~87% superposition
        Math.PI / 2.5,  // 72°   → ~95% superposition
        Math.PI / 2,    // 90°   → ~100% superposition
      ];
      
      const randomAngle = quantumAngles[Math.floor(Math.random() * quantumAngles.length)];
      console.log(`🌊 [QuantumWave] Using random quantum angle: ${randomAngle.toFixed(4)} radians (${(randomAngle * 180 / Math.PI).toFixed(1)}°)`);

      const response = await fetch('https://DavidJGrimsley.com/api/quantum/quantum_gate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          gate_type: 'rotation',
          rotation_angle: randomAngle,
        }),
      });

      console.log('🌊 [QuantumWave] Response status:', response.status);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const result = await response.json();
      console.log('🌊 [QuantumWave] Quantum server response:', JSON.stringify(result, null, 2));

      // Icon based on superposition strength (0.0 - 1.0)
      let icon = '⚛️'; // Default atom
      if (result.superposition_strength > 0.7) {
        icon = '🌌'; // Galaxy for high superposition
      } else if (result.superposition_strength > 0.3) {
        icon = '⭐'; // Star for medium superposition  
      } else {
        icon = '⚛️'; // Atom for low superposition
      }

      // Animation timing based on measurement (0 or 1)
      const baseTiming = result.measurement === 0 ? 100 : 200; // Fast vs slow
      
      // Animation intensity based on superposition
      const maxRotation = 20 + (result.superposition_strength * 40); // 20-60 degrees
      const cycles = Math.ceil(15 + (result.superposition_strength * 15)); // 15-30 cycles for 30 seconds
      
      setQuantumIcon(icon);
      
      // Create beautiful quantum details message
      const quantumType = result.superposition_strength > 0.5 ? 'Superposition' : 'Collapsed';
      const animationStyle = result.measurement === 0 ? 'Orbital' : 'Oscillation';
      const intensity = result.superposition_strength > 0.7 ? 'High' : 
                       result.superposition_strength > 0.3 ? 'Medium' : 'Low';
      
      setQuantumDetails(
        `⚛️ Quantum State: ${quantumType} | 📏 Strength: ${(result.superposition_strength * 100).toFixed(1)}% | ` +
        `🎯 Measurement: ${result.measurement} | 🎭 Animation: ${animationStyle} | 💫 Intensity: ${intensity}`
      );

      console.log(`🌊 [QuantumWave] Dramatic quantum result - Measurement: ${result.measurement}, Superposition: ${result.superposition_strength}, Icon: ${icon}, Cycles: ${cycles}, Rotation: ±${maxRotation}°`);

      // Start dramatic 30-second animation
      if (result.measurement === 0) {
        // Orbital animation for measurement 0
        console.log(`🌊 [QuantumWave] Starting dramatic orbital animation (${cycles} cycles, ±${maxRotation}° rotation)`);
        rotationAnimation.value = withRepeat(
          withSequence(
            withTiming(maxRotation, { duration: baseTiming }),
            withTiming(-maxRotation, { duration: baseTiming }),
            withTiming(0, { duration: baseTiming })
          ),
          cycles
        );
        
        // Add scale pulsing for extra drama
        scaleAnimation.value = withRepeat(
          withSequence(
            withTiming(1.2, { duration: baseTiming * 1.5 }),
            withTiming(0.9, { duration: baseTiming * 1.5 }),
            withTiming(1, { duration: baseTiming })
          ),
          Math.ceil(cycles * 0.6)
        );
      } else {
        // Oscillation animation for measurement 1
        console.log(`🌊 [QuantumWave] Starting dramatic oscillation animation (${cycles} cycles, ±${maxRotation}° swing)`);
        rotationAnimation.value = withRepeat(
          withSequence(
            withTiming(maxRotation * 0.7, { duration: baseTiming }),
            withTiming(-maxRotation * 0.7, { duration: baseTiming })
          ),
          cycles
        );
        
        // Add gentle breathing scale for oscillation
        scaleAnimation.value = withRepeat(
          withSequence(
            withTiming(1.1, { duration: baseTiming * 2 }),
            withTiming(1, { duration: baseTiming * 2 })
          ),
          Math.ceil(cycles * 0.4)
        );
      }

      // Reset animation state after 30 seconds
      setTimeout(() => {
        setIsAnimating(false);
        setQuantumDetails('✨ Quantum animation sequence complete');
      }, 30000);

      console.log('🌊 [QuantumWave] ✅ Dramatic 30-second quantum animation initiated!');
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      console.log('🌊 [QuantumWave] ❌ Quantum server error:', errorMsg);
      console.log('🌊 [QuantumWave] 🎲 Falling back to classical physics animation');

      setQuantumIcon('⚗️');
      setQuantumDetails('⚠️ Quantum server offline - Classical animation mode | 🎲 Random timing | 🧪 Chemistry fallback');
      
      // Classical fallback - still dramatic but shorter
      rotationAnimation.value = withRepeat(
        withSequence(
          withTiming(25, { duration: 150 }),
          withTiming(-25, { duration: 150 }),
          withTiming(0, { duration: 100 })
        ),
        20 // 8 seconds of classical animation
      );
      
      scaleAnimation.value = withRepeat(
        withSequence(
          withTiming(1.15, { duration: 200 }),
          withTiming(1, { duration: 200 })
        ),
        10
      );

      setTimeout(() => {
        setIsAnimating(false);
        setQuantumDetails('🧪 Classical animation complete - Try refreshing for quantum mode');
      }, 8000);
    }
  };

  useEffect(() => {
    fetchQuantumTiming();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { rotate: `${rotationAnimation.value}deg` },
      { scale: scaleAnimation.value }
    ],
  }));

  const containerStyle = useAnimatedStyle(() => ({
    opacity: isAnimating ? 1 : 0.8,
  }));

  return (
    <View style={{ alignItems: 'center', marginVertical: 8 }}>
      <Animated.View style={[animatedStyle, containerStyle]}>
        <ThemedText style={{ fontSize: 40, lineHeight: 36, marginTop: -6 }}>{quantumIcon}</ThemedText>
      </Animated.View>
      <View style={{ marginTop: 12, paddingHorizontal: 16, alignItems: 'center' }}>
        <ThemedText style={{ fontSize: 16, textAlign: 'center', opacity: 0.8, lineHeight: 16 }}>{quantumDetails}</ThemedText>
        {isAnimating && (
          <ThemedText style={{ fontSize: 16, textAlign: 'center', opacity: 0.6, marginTop: 4, fontStyle: 'italic' }}>
            🔄 Running a 30-second quantum sequence active based on the quantum Qiskit code in the python server:{' '}
          <ServerLink />
          </ThemedText>
        )}
      </View>
    </View>
  );
}

// Remove StyleSheet - replaced with NativeWind classes
