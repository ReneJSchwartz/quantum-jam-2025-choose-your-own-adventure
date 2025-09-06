import { Image } from 'expo-image';
import { Platform, StyleSheet } from 'react-native';

import { HelloWave } from '@/src/components/HelloWave';
import ParallaxScrollView from '@/src/components/ParallaxScrollView';
import { ThemedText } from '@/src/components/ThemedText';
import { ThemedView } from '@/src/components/ThemedView';
import { Button } from '@/src/components/Button';

export default function HomeScreen() {
  return (
    <ParallaxScrollView
      headerBackgroundColor={{ light: '#A1CEDC', dark: '#1D3D47' }}
      headerImage={
        <>
          <Image
            source={require('@/assets/images/HUD_Qubit.png')}
            style={styles.qubit}
          />
          <Image
            source={require('@/assets/images/HUD_GridBackground.png')}
            style={styles.novacore}
          />
        </>
      }>
      <ThemedView style={styles.titleContainer}>
        <ThemedText type="title">Welcome!</ThemedText>
        <HelloWave />
      </ThemedView>
      <ThemedView style={styles.playContainer}>
        <ThemedText type="subtitle">Play our game here</ThemedText>
        <Button
          title="Start Playing"
          onPress={() => {
            // Handle button press
            if (Platform.OS === 'web') {
              window.location.href = '/godot_web/index.html';
            } else {
              // TODO: Handle mobile - could show WebView or message
              console.log('Mobile support coming soon!');
            }
          }}
        />
        <ThemedText type="subtitle">hit the back butt</ThemedText>
      </ThemedView>

    </ParallaxScrollView>
  );
}

const styles = StyleSheet.create({
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  playContainer: {
    gap: 8,
    marginBottom: 8,
  },
  qubit: {
    height: 290,
    width: 290,
    top: 25,
    bottom: 0,
    left: 500,
  },
  novacore: {
    height: '100%',
    width: '100%',
    zIndex: -1,
    // height: 290,
    // width: 290,
    // top: 25,
    // bottom: 0,
    // left: 100,
    position: 'absolute',
  },
});
