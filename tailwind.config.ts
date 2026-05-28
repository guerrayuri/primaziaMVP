import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        gold: {
          50:  '#FDF6E3',
          100: '#FAE9B4',
          200: '#F5D880',
          300: '#F0C84C',
          400: '#C9A84C',
          500: '#B8922A',
          600: '#8F6E1A',
          700: '#664E0F',
        },
        navy: {
          50:  '#E8ECF5',
          100: '#C5D0E6',
          200: '#94A8CF',
          300: '#6381B8',
          400: '#3A5AA0',
          500: '#2F4270',
          600: '#243354',
          700: '#1B2B4B',
          800: '#121D33',
          900: '#090E1C',
        },
      },
      fontFamily: {
        sans: ['DM Sans', 'system-ui', 'sans-serif'],
        serif: ['Crimson Pro', 'Georgia', 'serif'],
      },
      screens: {
        xs: '375px',
      },
    },
  },
  plugins: [],
}

export default config
