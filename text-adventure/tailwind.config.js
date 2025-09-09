/** @type {import('tailwindcss').Config} */
module.exports = {
  // NOTE: Update this to include the paths to all files that contain Nativewind classes.
  content: [
    "./src/app/**/*.{js,jsx,ts,tsx}",
    "./src/components/**/*.{js,jsx,ts,tsx}",
    "./src/**/*.{js,jsx,ts,tsx}"
  ],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        // Quantum UI color palette from the game interface
        quantum: {
          // Primary UI colors
          primary: '#00eeff',       // Primary accent color (cyan from AVA)
          dark: '#0a1428',          // Dark blue background from grid
          light: '#A1CEDC',         // Light blue for light mode
          glow: '#00eeff',          // Cyan glow effect
          electron: '#ff33cc',      // Pink from the bar graph
          
          // Grid and UI elements
          grid: '#1a3050',          // Grid lines color
          novacore: '#00c8ff',      // NovaCore branding
          
          // Tab navigation colors
          'tab-active': '#00eeff',  // Active tab
          'tab-inactive': '#076672', // Inactive tab
          
          // Light mode variants
          'primary-light': '#0a7ea4',
          'grid-light': '#c0d8e8',
        },
        
        // Character color palette (from game dialogue)
        character: {
          // Character colors (from the game interface)
          ava: '#00eeff',     // Ava.AI (Aqua/Cyan)
          kaela: '#76c578',   // Kaela (Green)
          theo: '#b079e6',    // Theo (Purple)
          rival: '#fca355',   // Rival Leader (Orange)
          mira: '#ef6fde',    // DR Mira (Pink)
          memory: '#aac7fe',  // Memory text blue
          
          // Light mode variants
          'ava-light': '#00c8dd',     
          'kaela-light': '#76c578',   
          'theo-light': '#b079e6',    
          'rival-light': '#fca355',  
          'mira-light': '#ef6fde',    
          'memory-light': '#aac7fe',  
        }
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },
      animation: {
        'quantum-pulse': 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'quantum-spin': 'spin 3s linear infinite',
      },
      backgroundImage: {
        'quantum-grid': 'linear-gradient(to right, #1a3050 1px, transparent 1px), linear-gradient(to bottom, #1a3050 1px, transparent 1px)',
        'quantum-grid-light': 'linear-gradient(to right, #c0d8e8 1px, transparent 1px), linear-gradient(to bottom, #c0d8e8 1px, transparent 1px)',
      }
    },
  },
  plugins: [],
}