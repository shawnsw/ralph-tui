#!/usr/bin/env bash
# ABOUTME: Reset script for idempotent Ralph-TUI manual testing.
# Resets all state to allow re-running the same test from scratch.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_WORKSPACE="${1:-$SCRIPT_DIR/test-workspace}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Ralph-TUI Test Reset ===${NC}"
echo ""

# 1. Reset the PRD file to initial state (all passes: false)
echo -e "${YELLOW}[1/5] Resetting test-prd.json...${NC}"
if [ -f "$SCRIPT_DIR/test-prd.json" ]; then
    # Use jq if available, otherwise use sed
    if command -v jq &> /dev/null; then
        jq '.userStories |= map(.passes = false)' "$SCRIPT_DIR/test-prd.json" > "$SCRIPT_DIR/test-prd.json.tmp"
        mv "$SCRIPT_DIR/test-prd.json.tmp" "$SCRIPT_DIR/test-prd.json"
        echo -e "${GREEN}  PRD reset: all tasks set to passes: false${NC}"
    else
        # Fallback: use sed (less reliable but works)
        sed -i 's/"passes": true/"passes": false/g' "$SCRIPT_DIR/test-prd.json"
        echo -e "${GREEN}  PRD reset (via sed): all tasks set to passes: false${NC}"
    fi
else
    echo -e "${RED}  Warning: test-prd.json not found${NC}"
fi

# 2. Clean up test workspace outputs
echo -e "${YELLOW}[2/5] Cleaning test workspace outputs...${NC}"
if [ -d "$TEST_WORKSPACE" ]; then
    rm -f "$TEST_WORKSPACE"/output-*.txt
    rm -f "$TEST_WORKSPACE"/merged-*.txt
    rm -f "$TEST_WORKSPACE"/summary.txt
    echo -e "${GREEN}  Removed generated output files${NC}"
else
    echo -e "${BLUE}  Test workspace doesn't exist yet (will be created on first run)${NC}"
fi

# 3. Clean up .ralph-tui session state
echo -e "${YELLOW}[3/5] Cleaning Ralph-TUI session state...${NC}"
RALPH_DIR="$TEST_WORKSPACE/.ralph-tui"
if [ -d "$RALPH_DIR" ]; then
    rm -f "$RALPH_DIR/session.json"
    rm -f "$RALPH_DIR/lock.json"
    rm -f "$RALPH_DIR/progress.md"
    rm -rf "$RALPH_DIR/iterations"
    echo -e "${GREEN}  Removed session.json, lock.json, progress.md, and iterations/${NC}"
else
    echo -e "${BLUE}  No .ralph-tui directory found (clean state)${NC}"
fi

# 4. Optional: Reset git state in test workspace
echo -e "${YELLOW}[4/5] Checking git state...${NC}"
if [ -d "$TEST_WORKSPACE/.git" ]; then
    echo -e "${BLUE}  Git repo found. To fully reset git state, run:${NC}"
    echo -e "    cd $TEST_WORKSPACE && git checkout . && git clean -fd"
    echo -e "${BLUE}  (Not done automatically to preserve any work you want to keep)${NC}"
else
    echo -e "${BLUE}  No git repo in test workspace${NC}"
fi

# 5. Summary
echo ""
echo -e "${YELLOW}[5/5] Summary...${NC}"
echo -e "${GREEN}Test environment reset complete!${NC}"
echo ""
echo -e "To run the test:"
echo -e "  ${BLUE}cd $TEST_WORKSPACE${NC}"
echo -e "  ${BLUE}ralph-tui run --prd $SCRIPT_DIR/test-prd.json${NC}"
echo ""
echo -e "Or from ralph-tui directory:"
echo -e "  ${BLUE}cd $(dirname "$SCRIPT_DIR")${NC}"
echo -e "  ${BLUE}bun run dev -- run --prd testing/test-prd.json${NC}"
