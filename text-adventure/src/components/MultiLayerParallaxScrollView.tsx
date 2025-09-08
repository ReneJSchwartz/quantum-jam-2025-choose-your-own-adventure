import type { PropsWithChildren } from 'react';
import { StyleSheet, View } from 'react-native';
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

const HEADER_HEIGHT = 200;

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

  return (
    <ThemedView style={styles.container}>
      <Animated.ScrollView
        ref={scrollRef}
        scrollEventThrottle={16}
        scrollIndicatorInsets={{ bottom }}
        contentContainerStyle={{ paddingBottom: bottom }}>
        <View
          style={[
            styles.header,
            { backgroundColor: headerBackgroundColor[colorScheme] },
          ]}>
          
          {/* Layer 1: Background grid (slowest parallax) */}
          <Animated.Image
            source={require('@/assets/images/HUD_GridBackground.png')}
            style={[styles.gridBackground, gridBackgroundAnimatedStyle]}
          />
          
          {/* Layer 2: Game title (medium parallax) */}
          <Animated.View style={[styles.gameTitleContainer, gameTitleAnimatedStyle]}>
            <Image
              source={require('@/assets/images/HUD_Qubit.png')}
              style={styles.titleQubit}
            />
            <ThemedText type="title" style={styles.gameTitle}>
              Echoes of Light
            </ThemedText>
          </Animated.View>
          
          {/* Layer 3: Floating particles (fast parallax) */}
          <Animated.View style={[styles.particleField, particleFieldAnimatedStyle]}>
            {[...Array(6)].map((_, i) => (
              <View key={i} style={[styles.particle, { 
                left: `${15 + i * 12}%`, 
                top: `${20 + (i % 3) * 25}%`,
                animationDelay: `${i * 0.5}s`
              }]}>
                <ThemedText style={styles.particleText}>
                  {['⚛️', '🌌', '⭐', '✨', '💫', '🌊'][i]}
                </ThemedText>
              </View>
            ))}
          </Animated.View>
          
          {/* Layer 4: Main qubit (fastest parallax) */}
          <Animated.Image
            source={require('@/assets/images/HUD_Qubit.png')}
            style={[styles.qubit, qubitAnimatedStyle]}
          />
        </View>
        <ThemedView style={styles.content}>{children}</ThemedView>
      </Animated.ScrollView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    height: HEADER_HEIGHT,
    overflow: 'hidden',
  },
  content: {
    flex: 1,
    padding: 32,
    gap: 16,
    overflow: 'hidden',
  },
  // Parallax layer styles
  gridBackground: {
    height: '120%',
    width: '120%',
    position: 'absolute',
    top: -50,
    left: -50,
    zIndex: 1,
    opacity: 0.4,
  },
  gameTitleContainer: {
    position: 'absolute',
    top: '35%',
    left: '5%',
    right: '5%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 3,
  },
  titleQubit: {
    height: 40,
    width: 40,
    marginRight: 12,
  },
  gameTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    textShadowColor: 'rgba(0, 0, 0, 0.7)',
    textShadowOffset: { width: 2, height: 2 },
    textShadowRadius: 4,
    color: '#fff',
  },
  particleField: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 2,
  },
  particle: {
    position: 'absolute',
  },
  particleText: {
    fontSize: 16,
    opacity: 0.7,
  },
  qubit: {
    height: 200,
    width: 200,
    position: 'absolute',
    top: 20,
    right: 20,
    zIndex: 4,
  },
});
