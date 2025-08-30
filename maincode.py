#!/usr/bin/env python3
"""
Password Generator - Termux Edition
A comprehensive, secure password generator designed for Termux environments.

This application provides multiple password generation methods with a professional
terminal interface, implementing cryptographically secure random generation.

Author: Password Generator Project
License: MIT License
Version: 1.0.0
Platform: Termux (Android Terminal Emulator)
"""

import random
import string
import secrets
import os
import sys
import argparse

class PasswordGenerator:
    """
    A comprehensive password generator with customizable options.
    Uses the secrets module for cryptographically strong random generation.
    """
    
    def __init__(self):
        self.lowercase = string.ascii_lowercase
        self.uppercase = string.ascii_uppercase
        self.digits = string.digits
        self.special_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        
    def generate_password(self, 
                         length=12, 
                         use_lowercase=True, 
                         use_uppercase=True, 
                         use_digits=True, 
                         use_special=True,
                         exclude_similar=False):
        """
        Generate a random password with specified criteria.
        
        Args:
            length (int): Password length (default: 12)
            use_lowercase (bool): Include lowercase letters
            use_uppercase (bool): Include uppercase letters
            use_digits (bool): Include numbers
            use_special (bool): Include special characters
            exclude_similar (bool): Exclude similar-looking characters
        
        Returns:
            str: Generated password
            
        Raises:
            ValueError: If invalid parameters are provided
        """
        if length < 1:
            raise ValueError("Password length must be at least 1")
        
        char_pool = ""
        
        if use_lowercase:
            chars = self.lowercase
            if exclude_similar:
                chars = chars.replace('l', '').replace('o', '')
            char_pool += chars
            
        if use_uppercase:
            chars = self.uppercase
            if exclude_similar:
                chars = chars.replace('I', '').replace('O', '')
            char_pool += chars
            
        if use_digits:
            chars = self.digits
            if exclude_similar:
                chars = chars.replace('0', '').replace('1', '')
            char_pool += chars
            
        if use_special:
            char_pool += self.special_chars
        
        if not char_pool:
            raise ValueError("At least one character type must be selected")
        
        password = ''.join(secrets.choice(char_pool) for _ in range(length))
        return password
    
    def generate_memorable_password(self, num_words=4, separator='-', capitalize_words=True):
        """
        Generate a memorable password using common words.
        
        Args:
            num_words (int): Number of words to use
            separator (str): Character to separate words
            capitalize_words (bool): Capitalize first letter of each word
        
        Returns:
            str: Generated memorable password
        """
        words = [
            'apple', 'beach', 'cloud', 'dance', 'eagle', 'flame', 'green', 'house',
            'island', 'jungle', 'knight', 'lemon', 'music', 'night', 'ocean', 'peace',
            'quiet', 'river', 'stone', 'tiger', 'unity', 'voice', 'water', 'youth',
            'brave', 'charm', 'dream', 'fairy', 'giant', 'happy', 'magic', 'noble',
            'quick', 'smart', 'trust', 'vivid', 'wisdom', 'bright', 'calm', 'fresh',
            'storm', 'lunar', 'solar', 'crystal', 'golden', 'silver', 'forest', 'mountain'
        ]
        
        selected_words = [secrets.choice(words) for _ in range(num_words)]
        
        if capitalize_words:
            selected_words = [word.capitalize() for word in selected_words]
        
        random_num = secrets.randbelow(100)
        password = separator.join(selected_words) + str(random_num)
        return password
    
    def generate_pin(self, length=4):
        """
        Generate a random numeric PIN.
        
        Args:
            length (int): PIN length (default: 4)
        
        Returns:
            str: Generated PIN
        """
        return ''.join(secrets.choice(self.digits) for _ in range(length))
    
    def generate_alphabetic_password(self, length=8, use_uppercase=True, use_lowercase=True):
        """
        Generate a password with only alphabetic characters.
        
        Args:
            length (int): Password length
            use_uppercase (bool): Include uppercase letters
            use_lowercase (bool): Include lowercase letters
        
        Returns:
            str: Generated alphabetic password
        """
        char_pool = ""
        
        if use_lowercase:
            char_pool += self.lowercase
        if use_uppercase:
            char_pool += self.uppercase
            
        if not char_pool:
            char_pool = self.lowercase
            
        return ''.join(secrets.choice(char_pool) for _ in range(length))
    
    def check_password_strength(self, password):
        """
        Evaluate password strength and provide feedback.
        
        Args:
            password (str): Password to evaluate
        
        Returns:
            dict: Comprehensive strength analysis results
        """
        score = 0
        feedback = []
        
        if len(password) >= 16:
            score += 3
        elif len(password) >= 12:
            score += 2
        elif len(password) >= 8:
            score += 1
        else:
            feedback.append("Password should be at least 8 characters long")
        
        has_lower = any(c.islower() for c in password)
        has_upper = any(c.isupper() for c in password)
        has_digit = any(c.isdigit() for c in password)
        has_special = any(c in self.special_chars for c in password)
        
        char_types = sum([has_lower, has_upper, has_digit, has_special])
        score += char_types
        
        if char_types < 3:
            feedback.append("Use a mix of uppercase, lowercase, numbers, and special characters")
        
        # Check for common patterns
        if password.lower() in ['password', '123456', 'qwerty', 'abc123']:
            score = max(0, score - 3)
            feedback.append("Avoid common password patterns")
        
        # Determine strength level and color
        if score >= 7:
            strength = "Very Strong"
            color = "\033[92m"  # Green
        elif score >= 5:
            strength = "Strong"
            color = "\033[93m"  # Yellow
        elif score >= 3:
            strength = "Medium"
            color = "\033[94m"  # Blue
        else:
            strength = "Weak"
            color = "\033[91m"  # Red
        
        return {
            'strength': strength,
            'color': color,
            'score': score,
            'max_score': 8,
            'feedback': feedback,
            'has_lowercase': has_lower,
            'has_uppercase': has_upper,
            'has_digits': has_digit,
            'has_special': has_special,
            'length': len(password)
        }

class TerminalGUI:
    """Terminal-based graphical user interface for the password generator."""
    
    def __init__(self):
        self.generator = PasswordGenerator()
        self.reset_color = "\033[0m"
        self.title_color = "\033[96m"
        self.menu_color = "\033[95m"
        self.input_color = "\033[94m"
        self.success_color = "\033[92m"
        self.error_color = "\033[91m"
        self.warning_color = "\033[93m"
        
    def clear_screen(self):
        """Clear the terminal screen."""
        os.system('clear')
        
    def print_logo(self):
        """Print the ASCII art logo with branding."""
        logo = f"""{self.title_color}
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  ██████╗  █████╗ ███████╗███████╗██╗    ██╗ ██████╗ ██████╗  ║
║  ██╔══██╗██╔══██╗██╔════╝██╔════╝██║    ██║██╔═══██╗██╔══██╗ ║
║  ██████╔╝███████║███████╗███████╗██║ █╗ ██║██║   ██║██████╔╝ ║
║  ██╔═══╝ ██╔══██║╚════██║╚════██║██║███╗██║██║   ██║██╔══██╗ ║
║  ██║     ██║  ██║███████║███████║╚███╔███╔╝╚██████╔╝██║  ██║ ║
║  ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝ ║
║                                                               ║
║            ██████╗ ███████╗███╗   ██╗███████╗██████╗          ║
║           ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗         ║
║           ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝         ║
║           ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗         ║
║           ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║         ║
║            ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝         ║
║                                                               ║
║                   Secure Password Generator                   ║
║                        Termux Edition                        ║
║                          v1.0.0                              ║
╚═══════════════════════════════════════════════════════════════╝
{self.reset_color}"""
        print(logo)
        
    def print_menu(self):
        """Print the main menu options."""
        menu = f"""
{self.menu_color}═══════════════════════════════════════════════════════════════
                            MAIN MENU
═══════════════════════════════════════════════════════════════{self.reset_color}

{self.input_color}[1]{self.reset_color} Generate Strong Password (Mixed Characters)
{self.input_color}[2]{self.reset_color} Generate PIN (Numbers Only)
{self.input_color}[3]{self.reset_color} Generate Alphabetic Password (Letters Only)
{self.input_color}[4]{self.reset_color} Generate Memorable Password (Word-based)
{self.input_color}[5]{self.reset_color} Check Password Strength
{self.input_color}[6]{self.reset_color} About & Information
{self.input_color}[7]{self.reset_color} Exit Application

{self.menu_color}═══════════════════════════════════════════════════════════════{self.reset_color}
        """
        print(menu)
        
    def get_input(self, prompt, input_type=str, default=None, valid_range=None):
        """
        Get user input with comprehensive validation.
        
        Args:
            prompt (str): Input prompt message
            input_type (type): Expected input type
            default: Default value if input is empty
            valid_range (tuple): Valid range for numeric inputs
        
        Returns:
            User input converted to specified type
        """
        while True:
            try:
                user_input = input(f"{self.input_color}{prompt}{self.reset_color}").strip()
                
                if not user_input and default is not None:
                    return default
                
                if input_type == int:
                    value = int(user_input)
                    if valid_range and not (valid_range[0] <= value <= valid_range[1]):
                        print(f"{self.error_color}Value must be between {valid_range[0]} and {valid_range[1]}{self.reset_color}")
                        continue
                    return value
                elif input_type == bool:
                    return user_input.lower() in ['y', 'yes', '1', 'true']
                
                return user_input
                
            except ValueError:
                print(f"{self.error_color}Invalid input. Please try again.{self.reset_color}")
            except KeyboardInterrupt:
                print(f"\n{self.warning_color}Operation cancelled by user.{self.reset_color}")
                return None
                
    def display_password_result(self, password, title="Generated Password"):
        """Display password result with professional formatting."""
        if not password:
            return
            
        print(f"\n{self.success_color}{title}:{self.reset_color}")
        print(f"┌{'─' * (len(password) + 2)}┐")
        print(f"│ {password} │")
        print(f"└{'─' * (len(password) + 2)}┘")
        
        # Show strength analysis for non-PIN passwords
        if not title.lower().startswith("generated pin"):
            strength = self.generator.check_password_strength(password)
            print(f"\nStrength Assessment: {strength['color']}{strength['strength']}{self.reset_color} ({strength['score']}/{strength['max_score']})")
            
    def generate_strong_password(self):
        """Handle strong password generation with comprehensive options."""
        print(f"\n{self.menu_color}Strong Password Generator{self.reset_color}")
        print("─" * 50)
        
        length = self.get_input("Password length (8-128, default 16): ", int, 16, (8, 128))
        if length is None:
            return
            
        use_lowercase = self.get_input("Include lowercase letters? (Y/n): ", bool, True)
        use_uppercase = self.get_input("Include uppercase letters? (Y/n): ", bool, True)
        use_digits = self.get_input("Include numbers? (Y/n): ", bool, True)
        use_special = self.get_input("Include special characters? (Y/n): ", bool, True)
        exclude_similar = self.get_input("Exclude similar characters (0,O,l,1)? (y/N): ", bool, False)
        
        try:
            password = self.generator.generate_password(
                length=length,
                use_lowercase=use_lowercase,
                use_uppercase=use_uppercase,
                use_digits=use_digits,
                use_special=use_special,
                exclude_similar=exclude_similar
            )
            
            self.display_password_result(password, "Generated Strong Password")
            
        except ValueError as e:
            print(f"{self.error_color}Error: {e}{self.reset_color}")
            
    def generate_pin(self):
        """Handle PIN generation with validation."""
        print(f"\n{self.menu_color}PIN Generator{self.reset_color}")
        print("─" * 50)
        
        length = self.get_input("PIN length (4-10, default 4): ", int, 4, (4, 10))
        if length is None:
            return
            
        pin = self.generator.generate_pin(length)
        self.display_password_result(pin, "Generated PIN")
        
    def generate_alphabetic_password(self):
        """Handle alphabetic password generation."""
        print(f"\n{self.menu_color}Alphabetic Password Generator{self.reset_color}")
        print("─" * 50)
        
        length = self.get_input("Password length (6-50, default 12): ", int, 12, (6, 50))
        if length is None:
            return
            
        use_uppercase = self.get_input("Include uppercase letters? (Y/n): ", bool, True)
        use_lowercase = self.get_input("Include lowercase letters? (Y/n): ", bool, True)
        
        if not use_uppercase and not use_lowercase:
            print(f"{self.error_color}At least one letter case must be selected{self.reset_color}")
            return
            
        password = self.generator.generate_alphabetic_password(
            length=length,
            use_uppercase=use_uppercase,
            use_lowercase=use_lowercase
        )
        
        self.display_password_result(password, "Generated Alphabetic Password")
        
    def generate_memorable_password(self):
        """Handle memorable password generation."""
        print(f"\n{self.menu_color}Memorable Password Generator{self.reset_color}")
        print("─" * 50)
        
        num_words = self.get_input("Number of words (3-6, default 4): ", int, 4, (3, 6))
        if num_words is None:
            return
            
        separator = self.get_input("Word separator (default '-'): ", str, "-")
        capitalize = self.get_input("Capitalize words? (Y/n): ", bool, True)
        
        password = self.generator.generate_memorable_password(
            num_words=num_words,
            separator=separator,
            capitalize_words=capitalize
        )
        
        self.display_password_result(password, "Generated Memorable Password")
        
    def check_password_strength(self):
        """Handle comprehensive password strength checking."""
        print(f"\n{self.menu_color}Password Strength Analyzer{self.reset_color}")
        print("─" * 50)
        
        password = self.get_input("Enter password to analyze: ", str)
        if not password:
            print(f"{self.error_color}Password cannot be empty{self.reset_color}")
            return
            
        analysis = self.generator.check_password_strength(password)
        
        print(f"\n{self.success_color}Password Analysis Results{self.reset_color}")
        print("═" * 40)
        print(f"Password Length: {analysis['length']} characters")
        print(f"Strength Level: {analysis['color']}{analysis['strength']}{self.reset_color}")
        print(f"Security Score: {analysis['score']}/{analysis['max_score']}")
        
        print(f"\n{self.menu_color}Character Composition Analysis{self.reset_color}")
        print("─" * 30)
        print(f"Lowercase letters: {'✓' if analysis['has_lowercase'] else '✗'}")
        print(f"Uppercase letters: {'✓' if analysis['has_uppercase'] else '✗'}")
        print(f"Numeric digits: {'✓' if analysis['has_digits'] else '✗'}")
        print(f"Special characters: {'✓' if analysis['has_special'] else '✗'}")
        
        if analysis['feedback']:
            print(f"\n{self.menu_color}Security Recommendations{self.reset_color}")
            print("─" * 25)
            for suggestion in analysis['feedback']:
                print(f"• {suggestion}")
    
    def show_about_information(self):
        """Display application information and credits."""
        print(f"\n{self.menu_color}About Password Generator{self.reset_color}")
        print("═" * 50)
        
        info = f"""
{self.title_color}Password Generator - Termux Edition{self.reset_color}
Version: 1.0.0
Platform: Termux (Android Terminal Emulator)

{self.menu_color}Security Features:{self.reset_color}
• Cryptographically secure random generation using Python secrets module
• Multiple password generation methods for diverse requirements
• Comprehensive password strength analysis with detailed feedback
• Professional terminal interface with color-coded output

{self.menu_color}Supported Password Types:{self.reset_color}
• Strong passwords with customizable character sets
• Numeric PINs for identification purposes
• Alphabetic passwords for restricted environments
• Memorable word-based passwords for enhanced usability

{self.menu_color}Technical Information:{self.reset_color}
• No network connectivity required - operates entirely offline
• No data storage - passwords are generated in memory only
• Compliant with industry security standards for password generation
• Open source software distributed under MIT License

{self.menu_color}Project Information:{self.reset_color}
• GitHub Repository: Available for contributions and issue reporting
• Documentation: Comprehensive guides included with installation
• Support: Community-driven development and maintenance

{self.success_color}Thank you for using Password Generator!{self.reset_color}
        """
        print(info)
                
    def run(self):
        """Main application execution loop with comprehensive error handling."""
        while True:
            try:
                self.clear_screen()
                self.print_logo()
                self.print_menu()
                
                choice = self.get_input("Select an option (1-7): ", str)
                
                if choice == '1':
                    self.generate_strong_password()
                elif choice == '2':
                    self.generate_pin()
                elif choice == '3':
                    self.generate_alphabetic_password()
                elif choice == '4':
                    self.generate_memorable_password()
                elif choice == '5':
                    self.check_password_strength()
                elif choice == '6':
                    self.show_about_information()
                elif choice == '7':
                    print(f"\n{self.success_color}Thank you for using Password Generator!{self.reset_color}")
                    print("Your security is our priority. Stay safe! 🔐")
                    sys.exit(0)
                else:
                    print(f"{self.error_color}Invalid option. Please select 1-7.{self.reset_color}")
                    
            except KeyboardInterrupt:
                print(f"\n\n{self.success_color}Application terminated by user. Goodbye!{self.reset_color}")
                sys.exit(0)
            except Exception as e:
                print(f"{self.error_color}An unexpected error occurred: {e}{self.reset_color}")
                print(f"{self.warning_color}Please report this issue if it persists.{self.reset_color}")
                
            input(f"\n{self.input_color}Press Enter to continue...{self.reset_color}")

def main():
    """
    Application entry point with argument parsing support.
    Provides both interactive and command-line interfaces.
    """
    parser = argparse.ArgumentParser(
        description='Password Generator - Secure password generation for Termux',
        epilog='For interactive mode, run without arguments.'
    )
    
    parser.add_argument('--version', action='version', version='Password Generator 1.0.0')
    parser.add_argument('--generate', '-g', choices=['strong', 'pin', 'alpha', 'memorable'],
                       help='Generate password of specified type')
    parser.add_argument('--length', '-l', type=int, default=16,
                       help='Password length (default: 16)')
    parser.add_argument('--check', '-c', metavar='PASSWORD',
                       help='Check strength of provided password')
    
    args = parser.parse_args()
    
    # Command line mode
    if args.generate or args.check:
        generator = PasswordGenerator()
        
        if args.check:
            analysis = generator.check_password_strength(args.check)
            print(f"Password Strength: {analysis['strength']} ({analysis['score']}/{analysis['max_score']})")
            if analysis['feedback']:
                print("Recommendations:")
                for suggestion in analysis['feedback']:
                    print(f"• {suggestion}")
            return
        
        if args.generate == 'strong':
            password = generator.generate_password(length=args.length)
        elif args.generate == 'pin':
            password = generator.generate_pin(length=min(args.length, 10))
        elif args.generate == 'alpha':
            password = generator.generate_alphabetic_password(length=args.length)
        elif args.generate == 'memorable':
            password = generator.generate_memorable_password()
        
        print(password)
        return
    
    # Interactive mode
    try:
        gui = TerminalGUI()
        gui.run()
    except KeyboardInterrupt:
        print("\n\nGoodbye!")
        sys.exit(0)
    except Exception as e:
        print(f"Fatal error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()