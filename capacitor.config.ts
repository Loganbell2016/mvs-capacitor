import type { CapacitorConfig } from '@capacitor/cli';

const type config: CapacitorConfig = {
  appId: 'com.munfordvillesports.app',
  appName: 'Munfordville Sports',
  webDir: 'www',
  server: {
    url: 'https://munfordvillesports.com/app',
    cleartext: false,
    allowNavigation: ['munfordvillesports.com', '*.munfordvillesports.com']
  },
  ios: {
    contentInset: 'automatic',
    backgroundColor: '#1a73e8',
    preferredContentMode: 'mobile'
  }
};

export default config;
