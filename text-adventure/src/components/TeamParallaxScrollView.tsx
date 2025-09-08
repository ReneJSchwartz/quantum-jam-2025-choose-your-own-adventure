import { useState, type PropsWithChildren } from 'react';
import { StyleSheet, View, Dimensions} from 'react-native';
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

const HEADER_HEIGHT = 300;
const SCREEN_HEIGHT = Dimensions.get('window').height; // Approximate height for bounce calculations
const SCREEN_WIDTH = Dimensions.get('window').width; // Approximate width for bounce calculations

type Props = PropsWithChildren<{
  headerBackgroundColor: { dark: string; light: string };
}>;

export default function TeamParallaxScrollView({
  children,
  headerBackgroundColor,
}: Props) {
  const colorScheme = useColorScheme() ?? 'light';
  const scrollRef = useAnimatedRef<Animated.ScrollView>();
  const scrollOffset = useScrollViewOffset(scrollRef);
  const bottom = useBottomTabOverflow();
  const [contentHeight, setContentHeight] = useState(SCREEN_HEIGHT);

  // Layer 1: Echo background (slowest)
  const echoBackgroundAnimatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        {
          translateY: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [-120, 0, 500],
            Extrapolation.CLAMP
          ),
        },
        {
          scale: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [1.1, 1, 1.1],
            Extrapolation.CLAMP
          ),
        },
      ],
    };
  });

  // Layer 3: Dev icons (fast)
  const devIconFieldAnimatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        {
          translateY: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [-360, 0, 100],
            Extrapolation.CLAMP
          ),
        },
        {
          rotate: interpolate(
            scrollOffset.value,
            [-600, 0, 600],
            [-10, 0, 10],
            Extrapolation.CLAMP
          ) + 'deg',
        },
      ],
    };
  });

  // Layer 4: Main qubit (fastest) - Moves from top-right to bottom-left
  const qubitAnimatedStyle = useAnimatedStyle(() => {
    // Define the scroll range - adjust these values to control when animation starts/ends
    const qubitHeight = 150; // from styles.qubit
    const qubitWidth = 150;  // from styles.qubit

    // Start when header is visible, end when qubit would reach bottom of content
    const scrollStart = 0;
    const scrollEnd = contentHeight - SCREEN_HEIGHT; // 32 is padding from styles.content

    // Vertical movement: starts at top (-50px from top) and goes down to bottom edge
    const verticalMovement = interpolate(
      scrollOffset.value,
      [scrollStart, scrollEnd/3, scrollEnd*2/3, scrollEnd],
      [50, SCREEN_HEIGHT - 100, 50, SCREEN_HEIGHT - 100], // 50 to (screen height - qubit height - some padding)
      Extrapolation.CLAMP
    );
    
    // Horizontal movement: starts at right edge and Fmoves to left edge
    const horizontalMovement = interpolate(
      scrollOffset.value,
      [scrollStart, scrollEnd],
      [SCREEN_WIDTH - qubitWidth, 20], // (screen width - qubit width - padding) to left padding
      Extrapolation.CLAMP
    );
    
    return {
      transform: [
        {
          translateY: verticalMovement,
        },
        {
          translateX: horizontalMovement,
        },
        {
          rotate: interpolate(
            scrollOffset.value,
            [scrollStart, scrollEnd],
            [0, 360],
            Extrapolation.CLAMP
          ) + 'deg',
        },
        {
          scale: interpolate(
            scrollOffset.value,
            [scrollStart, scrollEnd],
            [2, 0.5],
            Extrapolation.CLAMP
          ),
        },
      ],
    };
  });

  const devIcons = ['💻', '⚛️', 'TS', '🔧', '📱', '🌐', '⚡', '🎮'];

  return (
    <ThemedView style={styles.container}>
      {/* Layer 4: Main qubit (positioned to float above content) */}
      <Animated.Image
        source={require('@/assets/images/HUD_Qubit.png')}
        style={[styles.qubit, qubitAnimatedStyle]}
      />
      
      <Animated.ScrollView
        ref={scrollRef}
        scrollEventThrottle={16}
        scrollIndicatorInsets={{ bottom }}
        contentContainerStyle={{ paddingBottom: bottom }}
        onContentSizeChange={(w, h) => setContentHeight(h)}
      >
        <View
          style={[
            styles.header,
            { backgroundColor: headerBackgroundColor[colorScheme] },
          ]}>
          
          {/* Layer 1: Echo background (slowest parallax) */}
          <Animated.Image
            source={require('@/assets/images/echo.png')}
            style={[styles.echoBackground, echoBackgroundAnimatedStyle]}
          />
          
          {/* Layer 2: Team title (medium parallax)
          <Animated.View style={[styles.teamTitleContainer, teamTitleAnimatedStyle]}>
            <Image
              source={require('@/assets/images/HUD_Qubit.png')}
              style={styles.titleQubit}
            />
            <ThemedText type="title" style={styles.teamTitle}>
              Development Team
            </ThemedText>
          </Animated.View> */}
          
          {/* Layer 3: Floating dev icons (fast parallax) */}
          <Animated.View style={[styles.devIconField, devIconFieldAnimatedStyle]}>
            {devIcons.map((icon, i) => (
              <View key={i} style={[styles.devIcon, { 
                left: `${10 + i * 11}%`, 
                top: `${15 + (i % 4) * 20}%`,
              }]}>
                <ThemedText style={styles.devIconText}>
                  {icon}
                </ThemedText>
              </View>
            ))}
          </Animated.View>
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
    position: 'relative',
    zIndex: 1, // Above the floating qubit
  },
  // Parallax layer styles
  echoBackground: {
    height: '100%',
    width: '100%',
    zIndex: 1,
    opacity: 0.4,
  },
  teamTitleContainer: {
    position: 'absolute',
    top: '30%',
    left: '5%',
    right: '5%',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 3,
  },
  titleQubit: {
    height: 50,
    width: 50,
    marginRight: 12,
  },
  teamTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    textShadowColor: 'rgba(0, 0, 0, 0.7)',
    textShadowOffset: { width: 2, height: 2 },
    textShadowRadius: 4,
    color: '#fff',
  },
  devIconField: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 2,
  },
  devIcon: {
    position: 'absolute',
  },
  devIconText: {
    fontSize: 20,
    opacity: 0.6,
  },
  qubit: {
    height: 120,
    width: 120,
    position: 'absolute',
    top: 0, // We'll control position via translateY
    left: 0, // We'll control position via translateX
    zIndex: 1, // Behind the text but above background
    opacity: 0.7, // Semi-transparent for background effect
  },
});
