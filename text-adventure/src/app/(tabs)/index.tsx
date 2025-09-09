import { Image } from 'expo-image';
import { Platform, View } from 'react-native';
import { useState, useEffect, useRef } from 'react';

import { HelloWave } from '@/src/components/HelloWave';
import MultiLayerParallaxScrollView from '@/src/components/MultiLayerParallaxScrollView';
import { ThemedView } from '@/src/components/ThemedView';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

export default function HomeScreen() {
  const [allowScroll, setAllowScroll] = useState(true); // Start with scroll enabled
  const hoverTimeoutRef = useRef<number | null>(null);
  const unhoverTimeoutRef = useRef<number | null>(null);
  const colorScheme = useColorScheme() ?? 'light';


  useEffect(() => {
    // ESC key listener
    const handleEscKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && !allowScroll) {
        setAllowScroll(true);
        console.log('ESC pressed - Scroll mode enabled, game disabled');
        
        // Clear any active timeouts
        if (hoverTimeoutRef.current) {
          clearTimeout(hoverTimeoutRef.current);
          hoverTimeoutRef.current = null;
        }
        if (unhoverTimeoutRef.current) {
          clearTimeout(unhoverTimeoutRef.current);
          unhoverTimeoutRef.current = null;
        }
      }
    };

    if (Platform.OS === 'web') {
      document.addEventListener('keydown', handleEscKey);
      return () => document.removeEventListener('keydown', handleEscKey);
    }
  }, [allowScroll]);

  const handleIframeClick = () => {
    console.log('Iframe clicked - Game mode enabled immediately');
    setAllowScroll(false);
    
    // Clear any active timeouts
    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
      hoverTimeoutRef.current = null;
    }
    if (unhoverTimeoutRef.current) {
      clearTimeout(unhoverTimeoutRef.current);
      unhoverTimeoutRef.current = null;
    }
  };

  const handleIframeMouseEnter = () => {
    console.log('Mouse entered iframe');
    
    // Clear any existing unhover timeout
    if (unhoverTimeoutRef.current) {
      clearTimeout(unhoverTimeoutRef.current);
      unhoverTimeoutRef.current = null;
    }

    // Start 1-second countdown to enable game mode (disable scroll)
    if (allowScroll && !hoverTimeoutRef.current) {
      console.log('Starting 1-second countdown to enable game mode...');
      hoverTimeoutRef.current = setTimeout(() => {
        setAllowScroll(false);
        console.log('Game mode enabled - Scroll disabled');
        hoverTimeoutRef.current = null;
      }, 1000);
    }
  };

  const handleIframeMouseLeave = () => {
    console.log('Mouse left iframe');
    
    // Clear hover timeout if still counting
    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
      hoverTimeoutRef.current = null;
      console.log('Hover countdown cancelled');
    }

    // Start 1.5-second countdown to re-enable scroll mode
    if (!allowScroll) {
      console.log('Starting 1.5-second countdown to re-enable scroll mode...');
      unhoverTimeoutRef.current = setTimeout(() => {
        setAllowScroll(true);
        console.log('Scroll mode re-enabled - Game disabled');
        unhoverTimeoutRef.current = null;
      }, 1500);
    }
  };

  return (
    <MultiLayerParallaxScrollView
      headerBackgroundColor={{ light: '#A1CEDC', dark: '#1D3D47' }}>
      <ThemedView className="flex-row items-center justify-center gap-2 mb-4 p-4 rounded-xl">
        <HelloWave />
      </ThemedView>
      <ThemedView className="flex-col items-center gap-3 py-5 px-4 rounded-2xl">
        <div
          onMouseEnter={handleIframeMouseEnter}
          onMouseLeave={handleIframeMouseLeave}
          onClick={handleIframeClick}
          style={{ position: 'relative', width: '100%', cursor: allowScroll ? 'pointer' : 'default' }}
          className="rounded-2xl overflow-hidden shadow-lg mb-4"
        >
          <iframe
            title="Echoes of Light Game"
            src="/godot_web/index.html"
            style={{
              width: '100%',
              height: 600,
              borderRadius: 16,
              border: 'none',
              overflow: 'hidden',
              pointerEvents: allowScroll ? 'none' : 'auto',
              transition: 'opacity 0.2s ease',
              opacity: allowScroll ? 0.8 : 1,
            }}
            allowFullScreen
            id="godot-iframe"
          />
          {allowScroll && (
            <div style={{
              position: 'absolute',
              top: 12,
              left: 12,
              background: Colors[colorScheme].background,
              color: 'white',
              padding: '6px 10px',
              borderRadius: '8px',
              fontSize: '11px',
              pointerEvents: 'none',
              zIndex: 10,
              boxShadow: '0 2px 8px rgba(0,0,0,0.3)',
            }}>
              🖱️ Click game to play • Hover for 1s • Press ESC to scroll
            </div>
          )}
          {!allowScroll && (
            <div style={{
              position: 'absolute',
              top: 12,
              right: 12,
              background: Colors[colorScheme].kaela,
              color: Colors[colorScheme].text,
              padding: '6px 10px',
              borderRadius: '8px',
              fontSize: '11px',
              pointerEvents: 'none',
              zIndex: 10,
              boxShadow: '0 2px 8px rgba(0,0,0,0.3)',
            }}>
              🎮 Game active • Press ESC to scroll page
            </div>
          )}
        </div>
        <button
          onClick={() => {
            const iframe = document.getElementById('godot-iframe');
            if (iframe && iframe.requestFullscreen) {
              iframe.requestFullscreen();
            }
          }}
          className="mx-auto block px-6 py-3 text-base rounded-xl shadow-md transition-all hover:shadow-lg"
          style={{ 
            margin: '12px auto', 
            display: 'block', 
            padding: '10px 20px', 
            fontSize: '16px', 
            borderRadius: '12px', 
            background: Colors[colorScheme].rival, 
            color: Colors[colorScheme].background, 
            border: 'none', 
            cursor: 'pointer',
            boxShadow: '0 4px 12px rgba(0,0,0,0.2)'
          }}
        >
          🖥️ Fullscreen Game
        </button>
        <View className="flex-row justify-center items-center gap-4 px-4 flex-wrap">
          <View className="rounded-2xl overflow-hidden shadow-lg bg-opacity-10 p-2">
            <Image
              source={require('@/assets/images/definition.png')}
              style={{ height: 400, width: 800, maxWidth: '100%', borderRadius: 12 }}
            />
          </View>
          <View className="rounded-2xl overflow-hidden shadow-lg bg-opacity-10 p-2">
            <Image
              source={require('@/assets/images/extra.png')}
              style={{ height: 400, width: 800, maxWidth: '100%', borderRadius: 12 }}
            />
          </View>
        </View>
      </ThemedView>
    </MultiLayerParallaxScrollView>
  );
}
