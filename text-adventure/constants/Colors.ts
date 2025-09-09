/**
 * Colors for the quantum adventure game UI, based on the game interface aesthetic.
 * Includes both app interface colors and character-specific dialogue colors.
 */

// Character colors from the game interface
const avaAqua = '#00eeff';          // Ava.AI (Aqua/Cyan)
const kaelaGreen = '#76c578';       // Kaela (Green)
const theoPurple = '#b079e6';       // Theo (Purple)
const rivalOrange = '#fca355';      // Rival Leader (Orange)
const miraPink = '#ef6fde';         // DR Mira (Pink)
const memoryBlue = '#aac7fe';       // Memory color

// UI Colors from the game interface
const gridBackground = '#0a1428';   // Dark blue background
const gridLines = '#1a3050';        // Slightly lighter grid lines
const novaCore = '#00c8ff';         // NovaCore branding color
const uiAccent = '#00eeff';         // UI element highlights
const barGraphPink = '#ff33cc';     // Bar graph colors
const tabActive = '#00eeff';        // Active tab indicator
const tabInactive = '#076672';      // Inactive tab color

// Light mode variants (slightly muted for light backgrounds)
const avaAquaLight = '#00c8dd';
const tabActiveLight = '#0a7ea4';
const uiAccentLight = '#0a7ea4';

export const Colors = {
  light: {
    // App UI colors - light mode
    text: '#11181C',
    background: '#f7f9fc',
    tint: uiAccentLight,
    icon: '#687076',
    tabIconDefault: '#687076',
    tabIconSelected: tabActiveLight,
    
    // UI Elements
    gridBackground: '#e0f0ff',
    gridLines: '#c0d8e8', 
    uiAccent: uiAccentLight,
    tabActive: tabActiveLight,
    tabInactive: '#a5c6d1',
    accent: barGraphPink,
    
    // Character colors - light mode
    ava: avaAquaLight,
    kaela: kaelaGreen,
    theo: theoPurple,
    rival: rivalOrange,
    mira: miraPink,
    memory: memoryBlue,
    novaCore: uiAccentLight,
  },
  dark: {
    // App UI colors - dark mode (from the game interface)
    text: '#ECEDEE',
    background: gridBackground,
    tint: uiAccent,
    icon: '#9BA1A6',
    tabIconDefault: '#9BA1A6',
    tabIconSelected: tabActive,
    
    // UI Elements - dark mode
    gridBackground: gridBackground,
    gridLines: gridLines,
    uiAccent: uiAccent,
    tabActive: tabActive,
    tabInactive: tabInactive,
    accent: barGraphPink,
    
    // Character colors - dark mode (direct from game interface)
    ava: avaAqua,
    kaela: kaelaGreen,
    theo: theoPurple,
    rival: rivalOrange,
    mira: miraPink,
    memory: memoryBlue,
    novaCore: novaCore,
  },
};
