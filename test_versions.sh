#!/bin/bash
# Test script to verify all installed AI coding assistants

set -e

echo "========================================="
echo "Testing AI Coding Assistants Installation"
echo "========================================="
echo ""

# Function to check command version
check_version() {
    local cmd=$1
    local version_flag=${2:---version}
    
    echo "Testing: $cmd"
    if command -v "$cmd" &> /dev/null; then
        echo "✓ $cmd is installed"
        if "$cmd" $version_flag 2>&1; then
            echo "  Version check successful"
        else
            echo "  Version check failed (command exists but version flag may not be supported)"
        fi
    else
        echo "✗ $cmd is NOT installed"
        return 1
    fi
    echo ""
}

# Track results
failed_tools=()
successful_tools=()

# Test each tool
tools=("codex" "gemini" "opencode" "crush")

for tool in "${tools[@]}"; do
    if check_version "$tool" "--version" || check_version "$tool" "-v" || check_version "$tool" "version"; then
        successful_tools+=("$tool")
    else
        failed_tools+=("$tool")
    fi
done

# Alternative command names to try
echo "========================================="
echo "Trying alternative command names..."
echo "========================================="
echo ""

alt_commands=("codex-cli" "gemini-cli" "opencode-cli" "crush-cli")
for cmd in "${alt_commands[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        echo "✓ Found alternative: $cmd"
        "$cmd" --version 2>&1 || "$cmd" -v 2>&1 || echo "  (version check not available)"
        echo ""
    fi
done

# Summary
echo "========================================="
echo "Summary"
echo "========================================="
echo "Successful tools: ${#successful_tools[@]}"
for tool in "${successful_tools[@]}"; do
    echo "  ✓ $tool"
done
echo ""
echo "Failed tools: ${#failed_tools[@]}"
for tool in "${failed_tools[@]}"; do
    echo "  ✗ $tool"
done
echo ""

# Check Node.js version
echo "Node.js version:"
node --version
echo ""

echo "npm version:"
npm --version
echo ""

# List globally installed npm packages
echo "Globally installed npm packages:"
npm list -g --depth=0
echo ""

if [ ${#failed_tools[@]} -eq ${#tools[@]} ]; then
    echo "WARNING: All primary tools failed to install"
    exit 1
fi

echo "Container test completed!"
