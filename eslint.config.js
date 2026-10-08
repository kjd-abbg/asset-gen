import nextPlugin from '@next/eslint-plugin-next';
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import globals from 'globals';
export default tseslint.config(
  { ignores: ['.next/**', '.next-dev/**', '.next-test/**', 'node_modules/**'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  { plugins: { '@next/next': nextPlugin }, rules: { ...nextPlugin.configs.recommended.rules, '@next/next/no-img-element': 'off' } },
  { files: ['src/**/*.{ts,tsx}'], languageOptions: { globals: { ...globals.browser } } },
);
