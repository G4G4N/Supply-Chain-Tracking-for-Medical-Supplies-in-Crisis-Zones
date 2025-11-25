# Internationalization Guide

## Overview

The application currently supports English. This guide outlines how to add multi-language support.

## Implementation Plan

### 1. Setup i18n Library
```bash
npm install i18next react-i18next
```

### 2. Translation Files
Create translation files in `src/locales/`:
- `en.json`
- `es.json`
- `fr.json`
- etc.

### 3. Configuration
Configure i18next with:
- Default language
- Fallback language
- Language detection
- Namespace management

### 4. Usage
```javascript
import { useTranslation } from 'react-i18next';

function Component() {
  const { t } = useTranslation();
  return <h1>{t('welcome')}</h1>;
}
```

## Supported Languages

Currently: English only

Future support:
- Spanish
- French
- Arabic
- Chinese

## RTL Support

For right-to-left languages (Arabic, Hebrew):
- CSS direction: rtl
- Layout mirroring
- Text alignment

## Date/Time Localization

- Use `Intl.DateTimeFormat`
- Format dates per locale
- Handle timezones

## Number Formatting

- Use `Intl.NumberFormat`
- Currency formatting
- Decimal separators

