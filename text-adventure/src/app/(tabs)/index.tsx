import { Image } from 'expo-image';
import { Platform, StyleSheet, View } from 'react-native';
import { useState, useEffect, useRef } from 'react';

import { HelloWave } from '@/src/components/HelloWave';
import MultiLayerParallaxScrollView from '@/src/components/MultiLayerParallaxScrollView';
import { ThemedView } from '@/src/components/ThemedView';

export default function HomeScreen() {
  const [allowScroll, setAllowScroll] = useState(true); // Start with scroll enabled
  const hoverTimeoutRef = useRef<number | null>(null);
  const unhoverTimeoutRef = useRef<number | null>(null);

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
      <ThemedView style={styles.titleContainer}>
        <HelloWave />
      </ThemedView>
      <ThemedView style={styles.playContainer}>
        <div
          onMouseEnter={handleIframeMouseEnter}
          onMouseLeave={handleIframeMouseLeave}
          onClick={handleIframeClick}
          style={{ position: 'relative', width: '100%', cursor: allowScroll ? 'pointer' : 'default' }}
        >
          <iframe
            title="Echoes of Light Game"
            src="/godot_web/index.html"
            style={{
              width: '100%',
              height: 600,
              borderRadius: 12,
              overflow: 'auto',
              backgroundColor: '#000',
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
              top: 10,
              left: 10,
              background: 'rgba(0, 0, 0, 0.8)',
              color: 'white',
              padding: '8px 12px',
              borderRadius: '6px',
              fontSize: '12px',
              pointerEvents: 'none',
              zIndex: 10,
            }}>
              🖱️ Click game to play • Hover for 1s • Press ESC to scroll
            </div>
          )}
          {!allowScroll && (
            <div style={{
              position: 'absolute',
              top: 10,
              right: 10,
              background: 'rgba(0, 128, 0, 0.8)',
              color: 'white',
              padding: '8px 12px',
              borderRadius: '6px',
              fontSize: '12px',
              pointerEvents: 'none',
              zIndex: 10,
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
          style={{
            margin: '8px auto',
            display: 'block',
            padding: '8px 16px',
            fontSize: '16px',
            borderRadius: '6px',
            background: '#222',
            color: '#fff',
            border: 'none',
            cursor: 'pointer',
          }}
        >
          🖥️ Fullscreen Game
        </button>
        {/* <View style={{ height: 600, width: '100%', borderRadius: 12, overflow: 'hidden', marginVertical: 12 }}>
          <WebView
              source={{ uri: '/godot_web/index.html' }}
              style={{ flex: 1, backgroundColor: '#000' }}
              originWhitelist={['*']}
              allowsFullscreenVideo
              javaScriptEnabled
              domStorageEnabled
            />
        </View> */}
        <View style={styles.echoContainer}>
          <Image
            source={require('@/assets/images/definition.png')}
            style={styles.echo}
          />
          <Image
            source={require('@/assets/images/extra.png')}
            style={styles.echo}
          />
        </View>
      </ThemedView>
    </MultiLayerParallaxScrollView>
  );
}

const styles = StyleSheet.create({
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  playContainer: {
    flexDirection: 'column',
    alignItems: 'center',
    gap: 12,
    paddingVertical: 20,
  },
  playButton: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  playButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  iframeContainer: {
    height: 400,
    width: '100%',
    borderRadius: 12,
    overflow: 'hidden',
    marginVertical: 12,
    position: 'relative',
  },
  gameIframe: {
    flex: 1,
    backgroundColor: '#000',
    borderRadius: 12,
  },
  gameOverlay: {
    position: 'absolute',
    top: 10,
    right: 10,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    padding: 8,
    borderRadius: 6,
    zIndex: 10,
  },
  overlayText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
  echoContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 16,
    paddingHorizontal: 16,
    flexWrap: 'wrap',
  },
  echo: {
    height: 400,
    width: 800, // Actually make them significantly wider
    maxWidth: '90%', // Ensure they don't overflow on small screens
    borderRadius: 8,
    marginTop: 16,
  },
});
