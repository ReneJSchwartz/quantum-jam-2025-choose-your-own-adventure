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
  discordName: string;
  portfolioLink: string;
  linkedInProfile: string;
  artstationProfile: string;
  contribution: string;
}

export default function TabTwoScreen() {
  const renderTeamMember = ({ item }: { item: TeamMember }) => (
    <Collapsible title={`${item.name} - ${item.role}`}>
      <ThemedText>
        <ThemedText type="defaultSemiBold">Discord:</ThemedText> {item.discordName}
      </ThemedText>
      <ThemedText>
        <ThemedText type="defaultSemiBold">Contribution:</ThemedText> {item.contribution}
      </ThemedText>
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
    </Collapsible>
  );

  return (
    <ParallaxScrollView
      headerBackgroundColor={{ light: '#D0D0D0', dark: '#353636' }}
      headerImage={
        <IconSymbol
          size={310}
          color="#808080"
          name="chevron.left.forwardslash.chevron.right"
          style={styles.headerImage}
        />
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
      <Collapsible title="Godot">
        <ThemedText>
          This app has two screens:{' '}
        </ThemedText>
        <ThemedText>
          The layout file in <ThemedText type="defaultSemiBold">app/(tabs)/_layout.tsx</ThemedText>{' '}
          sets up the tab navigator.
        </ThemedText>
        <ExternalLink href="https://docs.expo.dev/router/introduction">
          <ThemedText type="link">Learn more</ThemedText>
        </ExternalLink>
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
});
