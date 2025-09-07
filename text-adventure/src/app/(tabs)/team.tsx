import { Image } from 'expo-image';
import { Platform, StyleSheet } from 'react-native';
import { LegendList } from '@legendapp/list';

import { Collapsible } from '@/src/components/Collapsible';
import { ExternalLink } from '@/src/components/ExternalLink';
import ParallaxScrollView from '@/src/components/ParallaxScrollView';
import { ThemedText } from '@/src/components/ThemedText';
import { ThemedView } from '@/src/components/ThemedView';
import { IconSymbol } from '@/src/components/ui/IconSymbol';

import teamData from '@/assets/data/team.json';

interface TeamMember {
  id: number;
  name: string;
  role: string;
  discordName?: string;
  portfolioLink?: string;
  linkedInProfile?: string;
  artstationProfile?: string;
  instagramProfile?: string;
  contribution: string;
}

export default function TabTwoScreen() {
  const renderTeamMember = ({ item }: { item: TeamMember }) => (
    <Collapsible title={`${item.name}${item.role ? ` - ${item.role}` : ''}`}>
      <ThemedText>
        <ThemedText type="defaultSemiBold">Discord:</ThemedText> {item.discordName}
      </ThemedText>
      {item.contribution && (
        <ThemedText>
          <ThemedText type="defaultSemiBold">Contribution:</ThemedText> {item.contribution}
        </ThemedText>
      )}
      {item.portfolioLink && (
        <ExternalLink href={item.portfolioLink as any}>
          <ThemedText type="link">Portfolio</ThemedText>
        </ExternalLink>
      )}
      {item.linkedInProfile && (
        <ExternalLink href={item.linkedInProfile as any}>
          <ThemedText type="link">LinkedIn</ThemedText>
        </ExternalLink>
      )}
      {item.artstationProfile && (
        <ExternalLink href={item.artstationProfile as any}>
          <ThemedText type="link">ArtStation</ThemedText>
        </ExternalLink>
      )}
      {item.instagramProfile && (
        <ExternalLink href={item.instagramProfile as any}>
          <ThemedText type="link">Instagram</ThemedText>
        </ExternalLink>
      )}
    </Collapsible>
  );

  return (
    <ParallaxScrollView
      headerBackgroundColor={{ light: '#a1cedc2f', dark: '#e8eaea3b' }}
      headerImage={
        <>
                  <Image
                    source={require('@/assets/images/HUD_Qubit.png')}
                    style={styles.qubit}
                  />
                  <Image
                    source={require('@/assets/images/echo.png')}
                    style={styles.novacore}
                  />
                </>
      }>
      <ThemedView style={styles.titleContainer}>
        <ThemedText type="title">Team</ThemedText>
      </ThemedView>
      <ThemedView style={{ flex: 1, minHeight: 100 }}>
        <LegendList
          data={teamData}
          renderItem={renderTeamMember}
          keyExtractor={(item: TeamMember) => item.id.toString()}
        />
      </ThemedView>
      <ThemedView style={styles.titleContainer}>
        <ThemedText type="title">How it works</ThemedText>
      </ThemedView>
      <Collapsible title="Quantum Computing Integration">
        <ThemedText>
          This game features <ThemedText type="defaultSemiBold">real quantum computing</ThemedText> powered by IBM&apos;s Qiskit library running on a custom VPS server.{' '}
          The story branches based on actual quantum gate operations - bit-flip, phase-flip, and rotation gates applied to qubits in superposition.
        </ThemedText>
        <ThemedText>
          When players make choices, the game sends HTTP requests to our quantum server at{' '}
          <ThemedText type="defaultSemiBold">108.175.12.95:8000</ThemedText>, which creates quantum circuits,{' '}
          applies gates, and measures the results to determine success or failure. True quantum randomness drives the narrative!
        </ThemedText>
        <ExternalLink href="https://github.com/ReneJSchwartz/quantum-jam-2025-choose-your-own-adventure">
          <ThemedText type="link">View the source code on GitHub</ThemedText>
        </ExternalLink>
      </Collapsible>
      <Collapsible title="Quantum-Enhanced React Native">
        <ThemedText>
          This project demonstrates the <ThemedText type="defaultSemiBold">first known integration</ThemedText> of real quantum computing{' '}
          within an Expo React Native application. Using HTTP requests from React Native components,{' '}
          we connect directly to quantum circuits running IBM Qiskit on our VPS.
        </ThemedText>
        <ThemedText>
          The <ThemedText type="defaultSemiBold">HelloWave component</ThemedText> itself is quantum-controlled - its animation timing,{' '}
          icon selection (⚛️⭐🌌), and rotation intensity are determined by real quantum measurements.{' '}
          Each app launch triggers a quantum circuit with random rotation angles, creating genuinely unpredictable user experiences{' '}
          powered by quantum superposition and measurement collapse.
        </ThemedText>
        <ThemedText>
          This bridges the gap between <ThemedText type="defaultSemiBold">quantum computing research</ThemedText> and{' '}
          <ThemedText type="defaultSemiBold">consumer mobile applications</ThemedText>, showing how quantum APIs{' '}
          can enhance traditional React Native development with authentic quantum randomness and quantum state visualization.
        </ThemedText>
      </Collapsible>
      <Collapsible title="Multi-Platform Architecture">
        <ThemedText>
          Built with <ThemedText type="defaultSemiBold">Godot 4.x</ThemedText> for the main game engine, exported to web and embedded in a{' '}
          <ThemedText type="defaultSemiBold">React Native/Expo</ThemedText> wrapper for cross-platform deployment.
        </ThemedText>
        <ThemedText>
          The game is hosted on a custom VPS and can be deployed to web, Android, and iOS from the same codebase.{' '}
          The React Native wrapper provides native mobile features while preserving the Godot game experience.
        </ThemedText>
      </Collapsible>
      <Collapsible title="Quantum Text Processing">
        <ThemedText>
          Beyond quantum gates, the game includes <ThemedText type="defaultSemiBold">quantum text transformation</ThemedText> that{' '}
          categorizes words using a quantum dictionary and applies different quantum effects:
        </ThemedText>
        <ThemedText>
          • <ThemedText type="defaultSemiBold">Quantum Gates</ThemedText>: Technical words get circuit transformations{'\n'}
          • <ThemedText type="defaultSemiBold">Quantum Entanglement</ThemedText>: Emotional words get multi-qubit processing{'\n'}
          • <ThemedText type="defaultSemiBold">Ghost Echo</ThemedText>: Narrative words become ethereal with special characters{'\n'}
          • <ThemedText type="defaultSemiBold">Scramble</ThemedText>: Action words get quantum interference effects
        </ThemedText>
      </Collapsible>
      <Collapsible title="Game Engine & Dialogue System">
        <ThemedText>
          Custom dialogue manager built in <ThemedText type="defaultSemiBold">GDScript</ThemedText> with dynamic branching,{' '}
          quantum gate integration, and fallback systems. The game maintains story state while{' '}
          making real-time quantum API calls during critical decision points.
        </ThemedText>
        <ThemedText>
          Features include: Progressive story unlocking, quantum memory restoration mechanics,{' '}
          and multiple endings determined by quantum measurement outcomes.
        </ThemedText>
      </Collapsible>
      <Collapsible title="Creative & Narrative Design">
        <ThemedText>
          The story explores <ThemedText type="defaultSemiBold">quantum echoes</ThemedText> - a phenomenon where{' '}
          lost quantum information can be recovered from the past. Players navigate corporate intrigue,{' '}
          scientific ethics, and reality-bending quantum experiments.
        </ThemedText>
        <ThemedText>
          Original artwork, custom UI elements, and atmospheric music create an immersive sci-fi experience{' '}
          that makes quantum physics accessible through interactive storytelling.
        </ThemedText>
      </Collapsible>
      <Collapsible title="Technical Infrastructure">
        <ThemedText>
          <ThemedText type="defaultSemiBold">Backend:</ThemedText> Flask server with Qiskit quantum circuits, CORS-enabled API endpoints{'\n'}
          <ThemedText type="defaultSemiBold">Frontend:</ThemedText> Godot game engine with HTTP request handling and quantum response processing{'\n'}
          <ThemedText type="defaultSemiBold">Deployment:</ThemedText> VPS hosting with HTTP API, cross-platform mobile/web distribution{'\n'}
          <ThemedText type="defaultSemiBold">Quantum:</ThemedText> Real qubits, superposition states, measurement collapse, and fallback randomization
        </ThemedText>
      </Collapsible>
      <Collapsible title="Android, iOS, and web support">
        <ThemedText>
          This game is live on the web. It will be on Google Play soon and then iOS after that!
        </ThemedText>
      </Collapsible>
      <Collapsible title="Quantum Jam 2025">
        <ThemedText>
          This was part of the Quantum Game Jam 2025, a game development event focused on creating games
          that explore quantum computing concepts. This year the theme was{' '}
          <ThemedText type="subtitle">quantum echo</ThemedText> -{' '}
          <ThemedText type="defaultSemiBold">a phenomenon where an initially lost or dephased quantum signal can be made to reappear at a later time.</ThemedText>
        </ThemedText>
        <Image source={require('@/assets/images/react-logo.png')} style={{ alignSelf: 'center' }} />
        <ExternalLink href="https://www.quantumgamejam.org/">
          <ThemedText type="link">Learn more</ThemedText>
        </ExternalLink>
      </Collapsible>
      <Collapsible title="Team collaboration">
        <ThemedText>
          We used several techniques to stay connected and share ideas quickly:{' '}
          <ThemedText style={{ fontFamily: 'SpaceMono' }}>
            Google Drive, Miro, Github,
          </ThemedText> and{' '}
          <ThemedText style={{ fontFamily: 'SpaceMono' }}>
            Discord.
          </ThemedText>
        </ThemedText>
        {/* <ExternalLink href="https://drive.google.com/drive/folders/1emfqneF1mKtWMKE_rY4drc3jZCyUr12t">
          <ThemedText type="link">Learn more</ThemedText>
        </ExternalLink> */}
      </Collapsible>
      {/* <Collapsible title="Light and dark mode components">
        <ThemedText>
          This template has light and dark mode support. The{' '}
          <ThemedText type="defaultSemiBold">useColorScheme()</ThemedText> hook lets you inspect
          what the user&apos;s current color scheme is, and so you can adjust UI colors accordingly.
        </ThemedText>
        <ExternalLink href="https://docs.expo.dev/develop/user-interface/color-themes/">
          <ThemedText type="link">Learn more</ThemedText>
        </ExternalLink>
      </Collapsible>
      <Collapsible title="Animations">
        <ThemedText>
          This template includes an example of an animated component. The{' '}
          <ThemedText type="defaultSemiBold">components/HelloWave.tsx</ThemedText> component uses
          the powerful <ThemedText type="defaultSemiBold">react-native-reanimated</ThemedText>{' '}
          library to create a waving hand animation.
        </ThemedText>
        {Platform.select({
          ios: (
            <ThemedText>
              The <ThemedText type="defaultSemiBold">components/ParallaxScrollView.tsx</ThemedText>{' '}
              component provides a parallax effect for the header image.
            </ThemedText>
          ),
        })}
      </Collapsible> */}
    </ParallaxScrollView>
  );
}

const styles = StyleSheet.create({
  headerImage: {
    color: '#808080',
    bottom: -90,
    left: -35,
    position: 'absolute',
  },
  titleContainer: {
    flexDirection: 'row',
    gap: 8,
  },
  qubit: {
    height: 290,
    width: 290,
    top: 25,
    bottom: 0,
    left: 400,
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
