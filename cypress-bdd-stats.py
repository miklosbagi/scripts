#!/opt/homebrew/bin/python3

import os
import re
import argparse

def count_disabled_tests(feature_directory='./'):
    total_tests = 0
    disabled_tests = 0

    for root, _, files in os.walk(feature_directory):
        for file in files:
            if file.endswith(".feature"):
                with open(os.path.join(root, file), "r") as f:
                    content = f.read()

                    # Use regular expression to find scenarios that are disabled
                    disabled_scenarios = re.findall(r"@disabled\s*(?:\n\s*@.*?)*\n\s*(Scenario\sOutline:|Scenario:)", content)

                    # Count the total number of scenarios in the feature file
                    total_tests += len(re.findall(r"Scenario\sOutline:|Scenario:", content))

                    # Count the number of disabled scenarios
                    disabled_tests += len(disabled_scenarios)

    enabled_tests = total_tests - disabled_tests

    disabled_percentage = (disabled_tests / total_tests) * 100 if total_tests > 0 else 0
    enabled_percentage = (enabled_tests / total_tests) * 100 if total_tests > 0 else 0

    return total_tests, disabled_tests, enabled_tests, disabled_percentage, enabled_percentage

def main():
    parser = argparse.ArgumentParser(description="Count disabled and enabled tests in BDD feature files.")
    parser.add_argument("directories", nargs="*", default=["./"], help="List of directories to search for feature files.")
    args = parser.parse_args()

    total_total = 0
    total_disabled = 0
    total_enabled = 0

    for directory in args.directories:
        total, disabled, enabled, disabled_percentage, enabled_percentage = count_disabled_tests(directory)
        total_total += total
        total_disabled += disabled
        total_enabled += enabled

        print(f"Directory: {directory}")
        print(f"Disabled: {disabled} ({disabled_percentage:.2f}%)")
        print(f"Enabled: {enabled} ({enabled_percentage:.2f}%)")
        print(f"Total: {total}")
        print()

    print("Overall Total:")
    print(f"Disabled: {total_disabled} ({(total_disabled / total_total * 100):.2f}%)")
    print(f"Enabled: {total_enabled} ({(total_enabled / total_total * 100):.2f}%)")
    print(f"Total: {total_total}")

if __name__ == "__main__":
    main()

