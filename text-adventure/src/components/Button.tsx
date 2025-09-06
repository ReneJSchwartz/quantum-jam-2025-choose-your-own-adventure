import { forwardRef } from 'react';
import { StyleSheet, Text, TouchableOpacity, TouchableOpacityProps, Pressable, PressableProps, View, ViewStyle } from 'react-native';
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

  const buttonStyle = [styles.button, { backgroundColor }];
  const textStyle = [styles.buttonText, { color: textColor }];

  if (variant === 'press') {
    return (
      <Pressable 
        ref={ref} 
        {...touchableProps as PressableProps} 
        style={({ pressed }) => [
          ...buttonStyle,
          pressed && styles.pressed,
          typeof style === 'function' ? (style as (state: { pressed: boolean }) => ViewStyle | ViewStyle[])({ pressed }) : style
        ]}
      >
        <Text style={textStyle}>{title}</Text>
      </Pressable>
    );
  }
  
  return (
    <TouchableOpacity 
      ref={ref} 
      {...touchableProps as TouchableOpacityProps} 
      style={[
        ...buttonStyle,
        typeof style === 'function' ? undefined : style
      ]}
    >
      <Text style={textStyle}>{title}</Text>
    </TouchableOpacity>
  );
});

Button.displayName = 'Button';

const styles = StyleSheet.create({
  button: {
    alignItems: 'center',
    borderRadius: 8,
    flexDirection: 'row',
    justifyContent: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  pressed: {
    opacity: 0.8,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
});
