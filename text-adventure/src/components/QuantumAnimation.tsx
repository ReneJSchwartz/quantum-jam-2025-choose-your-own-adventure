import { useEffect, useState, useRef } from 'react';
import { View, Pressable } from 'react-native';
import {
  useSharedValue,
  withRepeat,
  withSequence,
  withTiming,
} from 'react-native-reanimated';
import LottieView from 'lottie-react-native';

import { ThemedText } from '@/src/components/ThemedText';
import { useThemeColor } from '@/hooks/useThemeColor';
import { Colors } from '@/constants/Colors';


export function HelloWave() {
  const quantumBaseUrl = 'https://108.175.12.95:8000';
  const quantumEndpoint = `${quantumBaseUrl}/quantum_gate`;
  const rotationAnimation = useSharedValue(0);
  const scaleAnimation = useSharedValue(1);
  const [robotMessage, setRobotMessage] = useState('🤖 Initializing quantum circuit...');
  const [isRobotLooping, setIsRobotLooping] = useState(true);
  const [isAnimating, setIsAnimating] = useState(false);
  const [isComplete, setIsComplete] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [quantumLevel, setQuantumLevel] = useState<'low' | 'medium' | 'high'>('medium');
  const [lottieSpeed, setLottieSpeed] = useState(1);
  const [lottieLoop, setLottieLoop] = useState(true);
  const [isRestartPlaying, setIsRestartPlaying] = useState(false);
  const loadingStartTime = useRef(Date.now());
  const lottieRef = useRef<LottieView>(null);
  const [technicalDetails, setTechnicalDetails] = useState<{
    gate: string;
    angle: number;
    state: string;
    backend: string;
  } | null>(null);

  const startClassicalFallback = (reason: string) => {
    console.log('🌊 [QuantumWave] 🎲 Falling back to classical physics animation:', reason);

    setRobotMessage('⚠️ Quantum server offline - Running classical animation mode');
    setTechnicalDetails({
      gate: 'Classical Fallback',
      angle: 0,
      state: 'Deterministic',
      backend: 'Local JavaScript'
    });

    // Classical fallback animation
    rotationAnimation.value = withRepeat(
      withSequence(
        withTiming(25, { duration: 150 }),
        withTiming(-25, { duration: 150 }),
        withTiming(0, { duration: 100 })
      ),
      20
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
      setIsComplete(true);
      setIsLoading(false);
      setRobotMessage('✅ Classical animation complete!');
    }, 8000);
  };

  const fetchQuantumTiming = async () => {
    console.log('🌊 [QuantumWave] Starting dramatic quantum-controlled animation...');
    setIsRobotLooping(true);
    setRobotMessage('🤖 Connecting to quantum server...');
    setIsAnimating(true);
    setIsComplete(false);
    setIsLoading(true);
    loadingStartTime.current = Date.now();

    // Robot speaks through the process
    setTimeout(() => setRobotMessage('🔬 Measuring qubit state...'), 1500);
    setTimeout(() => setRobotMessage('⚛️ Calculating superposition...'), 3000);

    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => {
        controller.abort();
      }, 5000);

      console.log(`🌊 [QuantumWave] Sending request to quantum server: ${quantumEndpoint}`);

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

      const response = await fetch(quantumEndpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          gate_type: 'rotation',
          rotation_angle: randomAngle,
        }),
        signal: controller.signal,
      });

      clearTimeout(timeout);

      console.log('🌊 [QuantumWave] Response status:', response.status);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const result = await response.json();
      console.log('🌊 [QuantumWave] Quantum server response:', JSON.stringify(result, null, 2));

      // Ensure minimum 5 seconds of loading animation
      const elapsedTime = Date.now() - loadingStartTime.current;
      const remainingTime = Math.max(0, 5000 - elapsedTime);
      
      if (remainingTime > 0) {
        console.log(`🌊 [QuantumWave] Waiting ${remainingTime}ms to meet minimum loading time`);
        await new Promise(resolve => setTimeout(resolve, remainingTime));
      }

      // Store technical details for display
      setTechnicalDetails({
        gate: 'RY (Rotation around Y-axis)',
        angle: randomAngle,
        state: `|ψ⟩ = cos(${(randomAngle/2).toFixed(3)})|0⟩ + sin(${(randomAngle/2).toFixed(3)})|1⟩`,
        backend: 'Qiskit Aer Simulator'
      });

      // Icon based on superposition strength (0.0 - 1.0)
      let level: 'low' | 'medium' | 'high' = 'medium';
      
      if (result.superposition_strength > 0.7) {
        level = 'high';
      } else if (result.superposition_strength > 0.3) {
        level = 'medium';
      } else {
        level = 'low';
      }

      setQuantumLevel(level);

      // Looping based on measurement: 0 = no loop (false), 1 = loop (true)
      const looping = result.measurement === 1;
      setLottieLoop(looping);
      setRobotMessage(
        `🎯 Measurement collapsed to ${result.measurement}! Setting looping to ${looping ? 'true' : 'false'}.`
      );

      // Brief pause to show measurement result
      await new Promise(resolve => setTimeout(resolve, 1500));

      // Speed mapped within level range: very slow (0.3) to very fast (3.0)
      let speed = 1;
      const strength = result.superposition_strength;
      
      if (level === 'low') {
        // Map 0.0-0.3 to 0.3-1.2 (very slow to medium)
        speed = 0.3 + (strength / 0.3) * 0.9;
      } else if (level === 'medium') {
        // Map 0.3-0.7 to 1.2-2.0 (medium to fast)
        speed = 1.2 + ((strength - 0.3) / 0.4) * 0.8;
      } else {
        // Map 0.7-1.0 to 2.0-3.0 (fast to very fast)
        speed = 2.0 + ((strength - 0.7) / 0.3) * 1.0;
      }
      
      setLottieSpeed(speed);
      setRobotMessage(
        `💫 Superposition strength: ${(strength * 100).toFixed(1)}% (${level} intensity) - Setting speed to ${speed.toFixed(2)}x`
      );

      // Brief pause to show speed configuration
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Robot announces the quantum results
      const quantumType = result.superposition_strength > 0.5 ? 'Superposition' : 'Collapsed';
      const animationStyle = result.measurement === 0 ? 'Orbital' : 'Oscillation';
      const intensity = result.superposition_strength > 0.7 ? 'High' : 
                       result.superposition_strength > 0.3 ? 'Medium' : 'Low';
      
      setRobotMessage(
        `⚛️ Quantum State: ${quantumType} | 📏 Strength: ${(result.superposition_strength * 100).toFixed(1)}% | ` +
        `🎯 Measurement: ${result.measurement} | 🎭 Style: ${animationStyle} | 💫 Intensity: ${intensity}`
      );

      console.log(`🌊 [QuantumWave] Result - Measurement: ${result.measurement}, Superposition: ${result.superposition_strength}, Level: ${level}`);

      // Wait 2 seconds to show final state, then start quantum animation
      await new Promise(resolve => setTimeout(resolve, 2000));
      setRobotMessage('🎬 Starting quantum animation...');
      
      // Brief pause to let robot "say" the starting message, then stop talking and start quantum animation
      await new Promise(resolve => setTimeout(resolve, 1000));
      setIsLoading(false);
      setIsRobotLooping(false);

      // Reset animation state after 10 seconds
      setTimeout(() => {
        setIsAnimating(false);
        setIsComplete(true);
        setRobotMessage('✨ Animation complete! Tap the restart button to run again.');
      }, 10000);

      console.log('🌊 [QuantumWave] ✅ 10-second quantum animation initiated!');
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      console.log('🌊 [QuantumWave] ❌ Quantum server error:', errorMsg);
      startClassicalFallback(errorMsg);
    }
  };

  useEffect(() => {
    fetchQuantumTiming();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const themedBg = useThemeColor({}, 'icon');

  const handleRestartClick = () => {
    // Only allow click if restart is not currently playing
    if (!isRestartPlaying) {
      setIsRestartPlaying(true);
      setIsRobotLooping(true);
      setRobotMessage('🔄 Restarting quantum simulation...');
      lottieRef.current?.play();
    }
  };

  const handleRestartComplete = () => {
    // When restart animation finishes, fetch new quantum data
    setIsRestartPlaying(false);
    fetchQuantumTiming();
  };

  return (
    <View style={{ backgroundColor: themedBg, paddingVertical: 12, paddingHorizontal: 16, borderRadius: 8, marginVertical: 8, maxWidth: '100%', width: '100%' }}>
      {/* Top status text */}
      

      {/* Three column layout */}
      <View style={{ flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between', gap: 16, flexWrap: 'wrap' }}>
        {/* Left: Robot always looping */}
        <View style={{ flex: 1, minWidth: 150, alignItems: 'center' }}>
          <LottieView
            source={require('@/assets/lottie/loading_robot.json')}
            autoPlay
            loop={isRobotLooping}
            style={{ width: 150, height: 150 }}
          />
          {/* Speech bubble below robot */}
          <View style={{ 
            backgroundColor: 'rgba(255, 255, 255, 0.95)', 
            borderColor: Colors.dark.tint, 
            borderWidth: 2, 
            borderRadius: 12, 
            padding: 12, 
            marginTop: 8,
            maxWidth: 200
          }}>
            <ThemedText style={{ 
              color: '#000', 
              fontSize: 12, 
              fontWeight: 'bold', 
              textAlign: 'center' 
            }}>
              {robotMessage}
            </ThemedText>
          </View>
        </View>

        {/* Middle: Restart lottie (loading animation or button) */}
        <View style={{ flex: 1, minWidth: 150, alignItems: 'center', justifyContent: 'center', minHeight: 200 }}>
          {isComplete ? (
            <Pressable 
              onPress={handleRestartClick}
              style={({ pressed }) => ({ opacity: pressed && !isRestartPlaying ? 0.7 : 1 })}
              disabled={isRestartPlaying}
            >
              <LottieView
                ref={lottieRef}
                source={require('@/assets/lottie/restart.json')}
                autoPlay={false}
                loop={false}
                onAnimationFinish={handleRestartComplete}
                style={{ width: 120, height: 120 }}
              />
            </Pressable>
          ) : isLoading ? (
            <LottieView
              source={require('@/assets/lottie/restart.json')}
              autoPlay
              loop
              style={{ width: 150, height: 150 }}
            />
          ) : (
            <LottieView
              source={
                quantumLevel === 'high' ? require('@/assets/lottie/quantum_high.json') :
                quantumLevel === 'medium' ? require('@/assets/lottie/quantum_medium.json') :
                require('@/assets/lottie/quantum_low.json')
              }
              autoPlay
              loop={lottieLoop}
              speed={lottieSpeed}
              style={{ width: 200, height: 200 }}
            />
          )}
        </View>

        {/* Right: Technical details */}
        <View style={{ flex: 1, minWidth: 200 }}>
          {technicalDetails && (
            <View>
              <ThemedText style={{ fontSize: 14, fontWeight: 'bold', textAlign: 'left', marginBottom: 8 }}>
                🔬 Technical Details
              </ThemedText>
              <View style={{ gap: 6 }}>
                <ThemedText style={{ fontSize: 13, opacity: 0.9, flexWrap: 'wrap' }}>
                  <ThemedText style={{ fontWeight: 'bold' }}>Quantum Gate:</ThemedText> {technicalDetails.gate}
                </ThemedText>
                <ThemedText style={{ fontSize: 13, opacity: 0.9, flexWrap: 'wrap' }}>
                  <ThemedText style={{ fontWeight: 'bold' }}>Rotation Angle:</ThemedText> {technicalDetails.angle.toFixed(4)} rad ({(technicalDetails.angle * 180 / Math.PI).toFixed(1)}°)
                </ThemedText>
                <ThemedText style={{ fontSize: 13, opacity: 0.9, flexWrap: 'wrap' }}>
                  <ThemedText style={{ fontWeight: 'bold' }}>Quantum State:</ThemedText> {technicalDetails.state}
                </ThemedText>
                <ThemedText style={{ fontSize: 13, opacity: 0.9, flexWrap: 'wrap' }}>
                  <ThemedText style={{ fontWeight: 'bold' }}>Backend:</ThemedText> {technicalDetails.backend}
                </ThemedText>
              </View>
            </View>
          )}
        </View>
      </View>

      {/* Explanation */}
      <View style={{ marginTop: 12, paddingTop: 12, borderTopWidth: 1, borderTopColor: 'rgba(128, 128, 128, 0.3)' }}>
        <ThemedText style={{ fontSize: 12, opacity: 0.7, textAlign: 'left', fontStyle: 'italic', flexWrap: 'wrap' }}>
          💡 This animation is different every time you load it due to quantum randomness! It makes a live API call 
          to a Python server hosted on my VPS, which runs Qiskit quantum circuit calculations in a simulated environment. 
          The RY gate creates a superposition state, and when measured, the quantum wavefunction collapses to produce 
          truly random results that drive the animation&apos;s behavior, intensity, and duration.
        </ThemedText>
      </View>
    </View>
  );
}

// Remove StyleSheet - replaced with NativeWind classes
