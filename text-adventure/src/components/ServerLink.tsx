import { ExternalLink } from '@/src/components/ExternalLink';
import { ThemedText } from '@/src/components/ThemedText';

export function ServerLink() {
  return (
    <ExternalLink href="https://DavidJGrimsley.com/public-facing/api/quantum">
      <ThemedText type="defaultSemiBold" className="text-blue-500 underline">
        DavidJGrimsley.com/public-facing/api/quantum
      </ThemedText>
    </ExternalLink>
  );
}
