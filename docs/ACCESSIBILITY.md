# Accessibility Guide

## WCAG Compliance

Target: WCAG 2.1 Level AA

### Perceivable
- Alt text for images
- Captions for videos
- Color contrast ratios
- Text resizing

### Operable
- Keyboard navigation
- Focus indicators
- No keyboard traps
- Sufficient time limits

### Understandable
- Clear language
- Consistent navigation
- Error identification
- Help text

### Robust
- Valid HTML
- ARIA labels
- Screen reader support
- Semantic HTML

## Testing

### Automated Testing
- axe-core
- Lighthouse a11y
- ESLint a11y rules

### Manual Testing
- Screen readers (NVDA, JAWS, VoiceOver)
- Keyboard-only navigation
- Color contrast checkers

## Implementation

### ARIA Labels
- Use semantic HTML first
- Add ARIA when needed
- Test with screen readers

### Keyboard Navigation
- Tab order
- Focus management
- Keyboard shortcuts

### Color and Contrast
- Minimum 4.5:1 for text
- Don't rely on color alone
- Test in grayscale

## Resources

- WCAG 2.1 Guidelines
- WAI-ARIA Authoring Practices
- WebAIM Contrast Checker

