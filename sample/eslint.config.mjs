import { defineConfig } from 'eslint/config';
import globals from 'globals';
import pluginVue from 'eslint-plugin-vue';
import eslintConfigPrettier from 'eslint-config-prettier/flat';

/**
 * @see https://eslint.org/docs/latest/use/configure/
 */
export default defineConfig([
  {
    ignores: ['dist/**/*', '.venv/**/*', 'sample/dist/**/*'],
    languageOptions: {
      ecmaVersion: 'latest',
      globals: {
        ...globals.browser,
        ...globals.es6,
      },
    },
    rules: {
      'consistent-return': 'error',
      'no-sequences': 'error',
      'no-unused-vars': [
        'warn',
        {
          argsIgnorePattern: '^_',
          varsIgnorePattern: '^_',
          caughtErrorsIgnorePattern: '^_',
          destructuredArrayIgnorePattern: '^_',
        },
      ],
    },
  },
  ...pluginVue.configs['flat/recommended'],
  eslintConfigPrettier,
]);
