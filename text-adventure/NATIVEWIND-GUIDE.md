# NativeWind Integration Guide

## What I've Applied

I've successfully integrated NativeWind throughout your React Native project. Here's what's been updated:

### 🎯 **Converted Components**

1. **HelloWave.tsx** - ✅ Fully converted to NativeWind classes
2. **ServerLink.tsx** - ✅ Using Tailwind colors and text decoration
3. **index.tsx** - ✅ Layout converted to flexbox classes
4. **Team.tsx** - ✅ Layout structure updated
5. **Button.tsx** - ✅ Complete styling overhaul with NativeWind

### 🎨 **Your Custom Quantum Theme**

I've extended your Tailwind config with quantum-themed colors:
```javascript
colors: {
  quantum: {
    primary: '#0a7ea4',    // Your app's primary color
    dark: '#1D3D47',       // Dark theme color
    light: '#A1CEDC',      // Light theme color
    glow: '#00ff88',       // Quantum glow effect
    electron: '#ff6b35',   // Electron color
  }
}
```

## 🚀 **How to Use NativeWind**

### **Basic Layout Classes**
```tsx
// Flexbox
<View className="flex-1 items-center justify-center">
<View className="flex-row gap-4">
<View className="flex-col space-y-2">

// Sizing
<View className="w-full h-96 max-w-md">
<View className="min-h-[100px]">  // Arbitrary values with []

// Padding & Margin
<View className="p-4 px-6 py-2">
<View className="m-2 mx-auto">
```

### **Text Styling**
```tsx
<Text className="text-lg font-bold text-blue-500">
<Text className="text-center opacity-80 italic">
<Text className="underline text-quantum-primary">  // Your custom colors!
```

### **Colors & Theming**
```tsx
// Built-in colors
<View className="bg-gray-800 text-white">
<Text className="text-red-500 bg-green-100">

// Your custom quantum colors
<View className="bg-quantum-dark text-quantum-glow">
<Text className="text-quantum-electron">
```

### **Responsive Design**
```tsx
// Screen size breakpoints
<View className="w-full md:w-1/2 lg:w-1/3">
<Text className="text-sm md:text-lg lg:text-xl">
```

### **Animations & Effects**
```tsx
<View className="animate-pulse">
<View className="shadow-lg rounded-xl">
<View className="opacity-60 hover:opacity-100 transition-opacity">
```

## 🔥 **Advanced Examples**

### **Quantum-Styled Card**
```tsx
<View className="bg-quantum-dark/20 p-6 rounded-2xl shadow-xl border border-quantum-glow/30">
  <Text className="text-quantum-glow font-bold text-xl mb-2">Quantum State</Text>
  <Text className="text-quantum-light opacity-80">Superposition active</Text>
</View>
```

### **Responsive Game Container**
```tsx
<View className="w-full max-w-4xl mx-auto p-4 md:p-8">
  <View className="aspect-video bg-black rounded-lg overflow-hidden shadow-2xl">
    {/* Game iframe */}
  </View>
</View>
```

### **Animated Button with Quantum Theme**
```tsx
<Pressable className="bg-quantum-primary px-6 py-3 rounded-full shadow-lg active:scale-95 transform transition-transform">
  <Text className="text-white font-semibold text-center">Launch Quantum</Text>
</Pressable>
```

## 🛠 **Working with Your Existing Hooks**

Your **hooks** and **constants** folders integrate perfectly:

### **Colors.ts Integration**
```tsx
// You can still use your Colors constant for dynamic theming
const backgroundColor = useThemeColor({ light: Colors.light.background, dark: Colors.dark.background }, 'background');

// Combined with NativeWind classes
<View className="p-4 rounded-lg" style={{ backgroundColor }}>
```

### **useColorScheme Hook**
```tsx
// Use with conditional classes
const colorScheme = useColorScheme();
<Text className={`text-base ${colorScheme === 'dark' ? 'text-white' : 'text-black'}`}>
```

## 🎨 **Best Practices for Your Quantum App**

1. **Keep custom colors in Tailwind config** for consistency
2. **Use your existing ThemedText/ThemedView** components - they work great with className
3. **Combine style prop for complex animations** with className for layout
4. **Use arbitrary values** `className="w-[800px]"` for exact measurements
5. **Leverage opacity modifiers** `className="bg-quantum-glow/30"` for glowing effects

## 🔧 **Quick Migration Tips**

**Old StyleSheet way:**
```tsx
const styles = StyleSheet.create({
  container: { padding: 16, backgroundColor: '#f0f0f0' }
});
<View style={styles.container}>
```

**New NativeWind way:**
```tsx
<View className="p-4 bg-gray-100">
```

**Combining both (when needed):**
```tsx
<View 
  className="p-4 rounded-lg" 
  style={{ backgroundColor: customDynamicColor }}
>
```

## 🚀 **Next Steps**

1. **Update remaining components** - Apply NativeWind to Collapsible, ParallaxScrollView, etc.
2. **Create quantum effect classes** - Use your custom colors for glowing, pulsing effects
3. **Responsive design** - Add breakpoints for different screen sizes
4. **Dark mode optimization** - Use `dark:` prefixes for better dark theme support

Your app now has a modern, maintainable styling system that's perfect for your quantum-themed game! The combination of NativeWind with your existing React Native architecture creates a powerful, flexible styling solution.
