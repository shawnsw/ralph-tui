#!/usr/bin/env bash
# ABOUTME: Sets up a clean test workspace for Ralph-TUI manual testing.
# Creates a git repo with initial state that can be reset and re-tested.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_WORKSPACE="${1:-$SCRIPT_DIR/test-workspace}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Ralph-TUI Test Workspace Setup ===${NC}"
echo ""

# Check if workspace already exists
if [ -d "$TEST_WORKSPACE" ]; then
    echo -e "${YELLOW}Test workspace already exists at: $TEST_WORKSPACE${NC}"
    read -p "Delete and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$TEST_WORKSPACE"
        echo -e "${GREEN}Removed existing workspace${NC}"
    else
        echo -e "${BLUE}Keeping existing workspace. Use reset-test.sh to reset state.${NC}"
        exit 0
    fi
fi

# Create workspace directory
echo -e "${YELLOW}[1/4] Creating test workspace...${NC}"
mkdir -p "$TEST_WORKSPACE"
echo -e "${GREEN}  Created: $TEST_WORKSPACE${NC}"

# Initialize git repo
echo -e "${YELLOW}[2/4] Initializing git repository...${NC}"
cd "$TEST_WORKSPACE"
git init --initial-branch=main
echo -e "${GREEN}  Git repo initialized${NC}"

# Create initial files
echo -e "${YELLOW}[3/4] Creating initial files...${NC}"

# Create a simple README
cat > README.md << 'EOF'
# Ralph-TUI Test Workspace

This is a test workspace for manually testing Ralph-TUI end-to-end workflow.

## Purpose

This workspace is used to test:
- Task selection and execution
- Parallel task execution (TEST-001, TEST-002, TEST-003 can run in parallel)
- Dependency resolution (TEST-004 depends on TEST-001 and TEST-002)
- Final aggregation (TEST-005 depends on TEST-003 and TEST-004)

## Files Created by Tests

- `output-a.txt` - Created by TEST-001
- `output-b.txt` - Created by TEST-002
- `output-c.txt` - Created by TEST-003
- `merged-ab.txt` - Created by TEST-004 (combines A and B)
- `summary.txt` - Created by TEST-005 (final summary)

## Reset

To reset this workspace:
```bash
../reset-test.sh
```
EOF

# Create a .gitignore
cat > .gitignore << 'EOF'
# Ralph-TUI session state (reset between tests)
.ralph-tui/

# Test outputs (generated during test runs)
output-*.txt
merged-*.txt
summary.txt
EOF

# Create .ralph-tui directory structure
mkdir -p .ralph-tui/iterations

# Create initial commit
git add .
git commit -m "Initial test workspace setup"

echo -e "${GREEN}  Created README.md, .gitignore${NC}"

# Create a git tag for easy reset
echo -e "${YELLOW}[4/4] Creating reset point...${NC}"
git tag -a "test-start" -m "Initial state for testing"
echo -e "${GREEN}  Created git tag 'test-start' for easy reset${NC}"

# Final summary
echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "Test workspace created at: ${BLUE}$TEST_WORKSPACE${NC}"
echo ""
echo -e "To run the test:"
echo -e "  ${BLUE}cd $TEST_WORKSPACE${NC}"
echo -e "  ${BLUE}ralph-tui run --prd $SCRIPT_DIR/test-prd.json${NC}"
echo ""
echo -e "To reset everything:"
echo -e "  ${BLUE}$SCRIPT_DIR/reset-test.sh${NC}"
echo ""
echo -e "To fully reset git (hard reset to initial state):"
echo -e "  ${BLUE}cd $TEST_WORKSPACE && git reset --hard test-start && git clean -fd${NC}"
