import { useState, type PropsWithChildren } from 'react';
import { View, Dimensions} from 'react-native';
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
    const qubitHeight = 120; // Adjusted to match actual size
    const qubitWidth = 120;  // Adjusted to match actual size

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
    
    // Horizontal movement: starts at right edge and moves to left edge
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

  // THIS IS KEY: Wrap in View with flex:1 to constrain ScrollView
  return (
    <View style={{ flex: 1 }}>
      {/* Layer 4: Main qubit (positioned to float above content) */}
      <Animated.Image
        source={require('@/assets/images/HUD_Qubit.png')}
        style={[
          { 
            height: 120, 
            width: 120, 
            position: 'absolute', 
            top: 0, // Controlled via translateY
            left: 0, // Controlled via translateX
            zIndex: 100, // Above everything
            opacity: 0.7, 
          }, 
          qubitAnimatedStyle
        ]}
      />
      
      <Animated.ScrollView
        ref={scrollRef}
        style={{ flex: 1 }}
        scrollEventThrottle={16}
        scrollIndicatorInsets={{ bottom }}
        contentContainerStyle={{ paddingBottom: bottom}}
        onContentSizeChange={(w, h) => setContentHeight(h)}
        showsVerticalScrollIndicator={false}
        scrollEnabled={true} // Force enable scrolling
      >
        <View
          style={[
            { 
              height: HEADER_HEIGHT, 
              overflow: 'hidden',
              backgroundColor: headerBackgroundColor[colorScheme] 
            },
          ]}>
          
          {/* Layer 1: Echo background (slowest parallax) */}
          <Animated.Image
            source={require('@/assets/images/echo.png')}
            style={[
              { height: '100%', width: '100%', zIndex: 1, opacity: 0.4 },
              echoBackgroundAnimatedStyle
            ]}
          />
          
          {/* Layer 3: Floating dev icons (fast parallax) */}
          <Animated.View 
            style={[
              { 
                position: 'absolute', 
                top: 0, 
                left: 0, 
                right: 0, 
                bottom: 0, 
                zIndex: 2 
              }, 
              devIconFieldAnimatedStyle
            ]}
          >
            {devIcons.map((icon, i) => (
              <View key={i} style={{ 
                position: 'absolute',
                left: `${10 + i * 11}%`, 
                top: `${15 + (i % 4) * 20}%`,
              }}>
                <ThemedText style={{ fontSize: 20, opacity: 0.6 }}>
                  {icon}
                </ThemedText>
              </View>
            ))}
          </Animated.View>
        </View>
        
        <ThemedView className="flex-1 p-8 space-y-4">
          {children}
        </ThemedView>
      </Animated.ScrollView>
    </View>
  );
}
