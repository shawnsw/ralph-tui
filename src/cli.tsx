#!/usr/bin/env node
/**
 * ABOUTME: CLI entry point for the Ralph TUI application.
 * Handles subcommands (plugins, etc.) and launches the TUI when no subcommand given.
 */

import { createCliRenderer } from '@opentui/core';
import { createRoot } from '@opentui/react';
import { App } from './tui/index.js';
import { printTrackerPlugins } from './commands/index.js';

/**
 * Show CLI help message.
 */
function showHelp(): void {
  console.log(`
Ralph TUI - AI Agent Loop Orchestrator

Usage: ralph-tui [command]

Commands:
  (none)              Launch the interactive TUI
  plugins trackers    List available tracker plugins
  help, --help, -h    Show this help message

Examples:
  ralph-tui                  # Start the TUI
  ralph-tui plugins trackers # List tracker plugins
`);
}

/**
 * Handle subcommands before launching TUI.
 * @returns true if a subcommand was handled and we should exit
 */
async function handleSubcommand(args: string[]): Promise<boolean> {
  const command = args[0];

  // Help command
  if (command === 'help' || command === '--help' || command === '-h') {
    showHelp();
    return true;
  }

  // Plugins commands
  if (command === 'plugins') {
    const subcommand = args[1];

    if (subcommand === 'trackers') {
      await printTrackerPlugins();
      return true;
    }

    // Unknown plugins subcommand
    console.error(`Unknown plugins subcommand: ${subcommand || '(none)'}`);
    console.log('Available: plugins trackers');
    return true;
  }

  // Unknown command
  if (command && !command.startsWith('-')) {
    console.error(`Unknown command: ${command}`);
    showHelp();
    process.exit(1);
  }

  return false;
}

/**
 * Launch the interactive TUI.
 */
async function launchTui(): Promise<void> {
  // Create the OpenTUI CLI renderer
  const renderer = await createCliRenderer({
    // Exit on Ctrl+C (we also handle 'q' and Escape in the App)
    exitOnCtrlC: true,
  });

  // Create the React root and render the App
  const root = createRoot(renderer);
  root.render(<App />);
}

/**
 * Main entry point
 */
async function main(): Promise<void> {
  // Get command-line arguments (skip node and script path)
  const args = process.argv.slice(2);

  // Handle subcommands
  const handled = await handleSubcommand(args);
  if (handled) {
    return;
  }

  // No subcommand - launch the TUI
  await launchTui();
}

// Run the main function
main().catch((error: unknown) => {
  console.error('Failed to start Ralph TUI:', error);
  process.exit(1);
});
