import { ExternalLink } from '@/src/components/ExternalLink';
import { ThemedText } from '@/src/components/ThemedText';

export function ServerLink() {
  return (
    <ExternalLink href="http://108.175.12.95:8000">
      <ThemedText type="defaultSemiBold" style={{ color: '#007AFF', textDecorationLine: 'underline' }}>
        108.175.12.95:8000
      </ThemedText>
    </ExternalLink>
  );
}
