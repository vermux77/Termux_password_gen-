# Password Generator Usage Guide

This comprehensive guide provides detailed instructions for utilizing all features of the Password Generator application in both interactive and command-line modes.

## Application Launch

After successful installation, the Password Generator becomes accessible through the system-wide command. Execute the following command from any terminal location to launch the interactive interface:

```bash
passgen
```

The application initializes with a professional ASCII art banner and presents the main menu interface with color-coded options for enhanced usability.

## Interactive Mode Operations

The interactive mode provides access to all password generation features through an intuitive menu system. Each option includes comprehensive input validation and detailed feedback to ensure optimal user experience.

### Strong Password Generation

The strong password generation feature creates passwords with customizable character combinations suitable for high-security applications. Users can specify password length ranging from 8 to 128 characters while selecting from multiple character set options including uppercase letters, lowercase letters, numeric digits, and special characters.

The system provides an option to exclude visually similar characters such as zero, capital O, lowercase L, and the number one to prevent confusion during manual password entry. This feature proves particularly valuable for passwords that users may need to type manually on different devices or systems.

### PIN Generation

The PIN generation functionality creates secure numeric passwords optimized for personal identification number requirements. The system supports PIN lengths from 4 to 10 digits while maintaining cryptographic security standards through the use of secure random number generation.

Generated PINs avoid predictable patterns and utilize the full range of available digits to maximize entropy within the specified length constraints. The system ensures each digit position receives equal probability distribution during the generation process.

### Alphabetic Password Generation

The alphabetic password generation feature produces passwords containing exclusively alphabetic characters, making them suitable for systems with character set restrictions or specific compliance requirements. Users can customize the output by selecting uppercase letters, lowercase letters, or a combination of both cases.

This functionality proves particularly useful for legacy systems that may not support special characters or for situations where password complexity requirements focus primarily on length and case variation rather than character diversity.

### Memorable Password Generation

The memorable password generation system creates word-based passwords that balance security requirements with human memorability factors. The system combines randomly selected common words with numeric suffixes to produce passwords that users can more easily remember while maintaining appropriate security levels.

Users can customize the number of words included in the password, typically