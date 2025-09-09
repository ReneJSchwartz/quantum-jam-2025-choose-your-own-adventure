import type { PropsWithChildren } from 'react';
import { View } from 'react-native';
import { Image } from 'expo-image';
import Animated, {
  interpolate,
  useAnimatedRef,
  useAnimatedStyle,
  useScrollViewOffset,
  Extrapolation,
} from 'react-native-reanimated';

import { ThemedView } from '@/src/components/ThemedView';
import { ThemedText } from '@/src/components/ThemedText';
import { useBottomTabOverflow } from '@/src/components/ui/TabBarBackground';
import { useColorScheme } from '@/hooks/useColorScheme';

const HEADER_HEIGHT = 250;

type Props = PropsWithChildren<{
  headerBackgroundColor: { dark: string; light: string };
}>;

export default function MultiLayerParallaxScrollView({
  children,
  headerBackgroundColor,
}: Props) {
  const colorScheme = useColorScheme() ?? 'light';
  const scrollRef = useAnimatedRef<Animated.ScrollView>();
  const scrollOffset = useScrollViewOffset(scrollRef);
  const bottom = useBottomTabOverflow();

  // Layer 1: Background grid (slowest)
  const gridBackgroundAnimatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        {
          translateY: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [-150, 0, 150],
            Extrapolation.CLAMP
          ),
        },
        {
          scale: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [1.2, 1, 1.2],
            Extrapolation.CLAMP
          ),
        },
      ],
    };
  });

  // Layer 2: Game title (medium speed)
  const gameTitleAnimatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        {
          translateY: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [-300, 0, 300],
            Extrapolation.CLAMP
          ),
        },
        {
          scale: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [0.8, 1, 0.8],
            Extrapolation.CLAMP
          ),
        },
      ],
      opacity: interpolate(
        scrollOffset.value,
        [-600, 0, 300],
        [0, 1, 0.1],
        Extrapolation.CLAMP
      ),
    };
  });

  // Layer 3: Floating particles (fast)
  const particleFieldAnimatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        {
          translateY: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [-450, 0, 450],
            Extrapolation.CLAMP
          ),
        },
        {
          rotate: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [-15, 0, 15],
            Extrapolation.CLAMP
          ) + 'deg',
        },
      ],
    };
  });

  // Layer 4: Main qubit (fastest)
  const qubitAnimatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        {
          translateY: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [-600, 0, 600],
            Extrapolation.CLAMP
          ),
        },
        {
          rotate: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [180, 0, -180],
            Extrapolation.CLAMP
          ) + 'deg',
        },
        {
          scale: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [0.5, 1, 0.5],
            Extrapolation.CLAMP
          ),
        },
      ],
    };
  });

  // THIS IS KEY: Wrap in View with flex:1 to constrain ScrollView
  return (
    <View style={{ flex: 1 }}>
      <Animated.ScrollView
        ref={scrollRef}
        style={{ flex: 1 }} 
        scrollEventThrottle={16}
        scrollIndicatorInsets={{ bottom }}
        contentContainerStyle={{ paddingBottom: bottom }}
        showsVerticalScrollIndicator={false}
        scrollEnabled={true} // Force enable scrolling
      >
        <View
          style={{
            height: HEADER_HEIGHT, 
            backgroundColor: headerBackgroundColor[colorScheme],
            overflow: 'hidden',
            position: 'relative'
          }}
        >
          {/* Layer 1: Background grid (slowest parallax) */}
          <View pointerEvents="none" style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}>
            <Animated.Image
              source={require('@/assets/images/HUD_GridBackground.png')}
              style={[
                { height: '120%', width: '120%', position: 'absolute', top: -50, left: -50, opacity: 0.4 },
                gridBackgroundAnimatedStyle
              ]}
            />
          </View>
          
          {/* Layer 2: Game title (medium parallax) */}
          <View pointerEvents="none" style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}>
            <Animated.View 
              style={[
                { position: 'absolute', top: '35%', left: '5%', right: '5%', flexDirection: 'row', alignItems: 'center', justifyContent: 'center' },
                gameTitleAnimatedStyle
              ]}
            >
              <Image
                source={require('@/assets/images/HUD_Qubit.png')}
                style={{ height: 40, width: 40, marginRight: 12 }}
              />
              <ThemedText 
                type="title" 
                style={{
                  fontSize: 24,
                  fontWeight: 'bold',
                  textShadowColor: 'rgba(0, 0, 0, 0.7)',
                  textShadowOffset: { width: 2, height: 2 },
                  textShadowRadius: 4,
                  color: '#fff',
                }}
              >
                Echoes of Light
              </ThemedText>
            </Animated.View>
          </View>
          
          {/* Layer 3: Floating particles (fast parallax) */}
          <View pointerEvents="none" style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}>
            <Animated.View style={[{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }, particleFieldAnimatedStyle]}>
              {[...Array(6)].map((_, i) => (
                <View key={i} style={{ position: 'absolute', left: `${15 + i * 12}%`, top: `${20 + (i % 3) * 25}%` }}>
                  <ThemedText style={{ fontSize: 16, opacity: 0.7 }}>
                    {['⚛️', '🌌', '⭐', '✨', '💫', '🌊'][i]}
                  </ThemedText>
                </View>
              ))}
            </Animated.View>
          </View>
          
          {/* Layer 4: Main qubit (fastest parallax) */}
          <View pointerEvents="none" style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}>
            <Animated.Image
              source={require('@/assets/images/HUD_Qubit.png')}
              style={[{ height: 200, width: 200, position: 'absolute', top: 20, right: 20 }, qubitAnimatedStyle]}
            />
          </View>
        </View>
        
        {/* Content area - kept simple */}
        <View style={{ padding: 32, gap: 16 }}>
          {children}
        </View>
      </Animated.ScrollView>
    </View>
  );
}
