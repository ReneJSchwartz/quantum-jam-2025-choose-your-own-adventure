import { forwardRef } from 'react';
import { Text, TouchableOpacity, TouchableOpacityProps, Pressable, PressableProps, View, ViewStyle } from 'react-native';
import { useThemeColor } from '@/hooks/useThemeColor';

export type ButtonProps = {
  title?: string;
  variant?: 'touch' | 'press';
  style?: ViewStyle | ViewStyle[] | ((state: { pressed: boolean }) => ViewStyle | ViewStyle[]);
  lightColor?: string;
  darkColor?: string;
  textLightColor?: string;
  textDarkColor?: string;
} & Omit<(TouchableOpacityProps | PressableProps), 'style'>;

export const Button = forwardRef<View, ButtonProps>(({ 
  title, 
  variant = 'touch', 
  style, 
  lightColor,
  darkColor,
  textLightColor,
  textDarkColor,
  ...touchableProps 
}, ref) => {
  const backgroundColor = useThemeColor({ light: lightColor, dark: darkColor }, 'tint');
  const textColor = useThemeColor({ light: textLightColor, dark: textDarkColor }, 'background');

  if (variant === 'press') {
    return (
      <Pressable 
        ref={ref} 
        {...touchableProps as PressableProps} 
        className="items-center rounded-lg flex-row justify-center px-4 py-3 shadow-lg"
        style={[
          { backgroundColor },
          typeof style === 'function' ? undefined : style
        ]}
      >
        {({ pressed }) => (
          <Text className={`text-base font-semibold text-center ${pressed ? 'opacity-80' : ''}`} style={{ color: textColor }}>
            {title}
          </Text>
        )}
      </Pressable>
    );
  }
  
  return (
    <TouchableOpacity 
      ref={ref} 
      {...touchableProps as TouchableOpacityProps} 
      className="items-center rounded-lg flex-row justify-center px-4 py-3 shadow-lg"
      style={[
        { backgroundColor },
        typeof style === 'function' ? undefined : style
      ]}
    >
      <Text className="text-base font-semibold text-center" style={{ color: textColor }}>
        {title}
      </Text>
    </TouchableOpacity>
  );
});

Button.displayName = 'Button';
