#!/bin/bash

# Auto Commit & Push Script
# Analyzes git changes, generates commit message, commits and pushes
#
# Usage:
#   ./auto-commit-push.sh [--force] [--message "custom message"]

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${CYAN}$1${NC}"
}

log_success() {
    echo -e "${GREEN}$1${NC}"
}

log_warn() {
    echo -e "${YELLOW}$1${NC}"
}

log_error() {
    echo -e "${RED}$1${NC}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Error: Not a git repository"
    exit 1
fi

# Parse command line arguments
CUSTOM_MESSAGE=""
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --message)
            CUSTOM_MESSAGE="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            log_warn "Unknown option: $1"
            shift
            ;;
    esac
done

log_info "\n🔍 Analyzing git changes..."

# Get git status
GIT_STATUS=$(git status --porcelain)

# Check if there are any changes
if [ -z "$GIT_STATUS" ]; then
    log_warn "✓ No changes to commit"
    exit 0
fi

log_info "\nChanged files:"
echo "$GIT_STATUS"

# Parse changes
ADDED_COUNT=$(echo "$GIT_STATUS" | grep -c "^A " || true)
MODIFIED_COUNT=$(echo "$GIT_STATUS" | grep -c "^M " || true)
DELETED_COUNT=$(echo "$GIT_STATUS" | grep -c "^D " || true)

log_info "\n📊 Analysis: $ADDED_COUNT added, $MODIFIED_COUNT modified, $DELETED_COUNT deleted"

# Generate commit message
if [ -n "$CUSTOM_MESSAGE" ]; then
    COMMIT_MESSAGE="$CUSTOM_MESSAGE"
    log_warn "\n⚠️  Using custom message: \"$COMMIT_MESSAGE\""
else
    # Determine commit type based on changes
    if [ $ADDED_COUNT -gt 0 ] && [ $MODIFIED_COUNT -eq 0 ] && [ $DELETED_COUNT -eq 0 ]; then
        COMMIT_TYPE="add"
    elif [ $MODIFIED_COUNT -gt 0 ] && [ $ADDED_COUNT -eq 0 ] && [ $DELETED_COUNT -eq 0 ]; then
        COMMIT_TYPE="update"
    elif [ $DELETED_COUNT -gt 0 ] && [ $ADDED_COUNT -eq 0 ] && [ $MODIFIED_COUNT -eq 0 ]; then
        COMMIT_TYPE="remove"
    else
        COMMIT_TYPE="refactor"
    fi

    # Generate message based on type
    case $COMMIT_TYPE in
        add)
            if echo "$GIT_STATUS" | grep -q "README"; then
                COMMIT_MESSAGE="Add README documentation"
            elif echo "$GIT_STATUS" | grep -q "CLAUDE.md"; then
                COMMIT_MESSAGE="Add CLAUDE.md project documentation"
            else
                COMMIT_MESSAGE="Add new files"
            fi
            ;;
        update)
            COMMIT_MESSAGE="Update project files"
            ;;
        remove)
            COMMIT_MESSAGE="Remove files"
            ;;
        refactor)
            COMMIT_MESSAGE="Refactor and update project files"
            ;;
        *)
            COMMIT_MESSAGE="Update repository"
            ;;
    esac

    # Add file count
    TOTAL_FILES=$((ADDED_COUNT + MODIFIED_COUNT + DELETED_COUNT))
    if [ $TOTAL_FILES -gt 1 ]; then
        COMMIT_MESSAGE="$COMMIT_MESSAGE ($TOTAL_FILES files)"
    fi
fi

log_success "\n📝 Generated commit message:\n   \"$COMMIT_MESSAGE\""

# Stage changes
log_info "\n📦 Staging changes..."
git add .
log_success "✓ Changes staged"

# Create commit
log_info "\n💾 Creating commit..."
git commit -m "$COMMIT_MESSAGE"
log_success "✓ Commit created successfully"

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
log_info "\n🌿 Current branch: $BRANCH"

# Push to remote
log_info "\n🚀 Pushing to remote..."
if [ "$FORCE" = true ]; then
    git push --force-with-lease origin "$BRANCH"
    log_success "✓ Force pushed successfully"
else
    git push -u origin "$BRANCH"
    log_success "✓ Push completed successfully"
fi

# Print summary
log_info "\n$(printf '=%.0s' {1..50})"
log_success "✓ Git workflow completed successfully!"
log_info "$(printf '=%.0s' {1..50})"
log_success "Commit: \"$COMMIT_MESSAGE\""
log_success "Branch: $BRANCH"
log_info "$(printf '=%.0s' {1..50})\n"
