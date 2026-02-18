#!/bin/bash
# Test script to verify all installed AI coding assistants

set -u  # Exit on undefined variables

echo "========================================="
echo "Testing AI Coding Assistants Installation"
echo "========================================="
echo ""

# Function to check command version
check_version() {
    local cmd=$1
    
    echo "Testing: $cmd"
    if command -v "$cmd" &> /dev/null; then
        echo "✓ $cmd is installed"
        # Try multiple version flags
        if "$cmd" --version >/dev/null 2>&1; then
            "$cmd" --version 2>&1 | head -1
            return 0
        elif "$cmd" -v >/dev/null 2>&1; then
            "$cmd" -v 2>&1 | head -1
            return 0
        elif "$cmd" version >/dev/null 2>&1; then
            "$cmd" version 2>&1 | head -1
            return 0
        else
            echo "  (version command not available)"
            return 0
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
    if check_version "$tool"; then
        successful_tools+=("$tool")
    else
        failed_tools+=("$tool")
    fi
    echo ""
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

echo "Python version:"
python3 --version 2>&1 || echo "Python not available"
echo ""

# List globally installed npm packages
echo "Globally installed npm packages:"
npm list -g --depth=0
echo ""

# Note about missing tools
if [ ${#failed_tools[@]} -gt 0 ]; then
    echo "ERROR: One or more expected tools are missing."
    echo ""
    exit 1
fi

echo "Container test completed!"
echo "Container is functional and ready for use."
exit 0
