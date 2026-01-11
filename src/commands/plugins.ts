/**
 * ABOUTME: CLI commands for managing plugins.
 * Provides commands to list, inspect, and manage tracker and agent plugins.
 */

import {
  getTrackerRegistry,
  registerBuiltinTrackers,
} from '../plugins/trackers/index.js';

/**
 * Output format for CLI commands
 */
interface PluginInfo {
  id: string;
  name: string;
  description: string;
  version: string;
  builtin: boolean;
  features: {
    bidirectionalSync: boolean;
    hierarchy: boolean;
    dependencies: boolean;
  };
}

/**
 * List all available tracker plugins.
 * Called via: ralph-tui plugins trackers
 */
export async function listTrackerPlugins(): Promise<PluginInfo[]> {
  const registry = getTrackerRegistry();

  // Register built-in plugins if not already registered
  registerBuiltinTrackers();

  // Discover user plugins
  await registry.initialize();

  // Get all registered plugins
  const plugins = registry.getRegisteredPlugins();

  return plugins.map((meta) => ({
    id: meta.id,
    name: meta.name,
    description: meta.description,
    version: meta.version,
    builtin: registry.isBuiltin(meta.id),
    features: {
      bidirectionalSync: meta.supportsBidirectionalSync,
      hierarchy: meta.supportsHierarchy,
      dependencies: meta.supportsDependencies,
    },
  }));
}

/**
 * Print tracker plugins to console in a formatted table.
 */
export async function printTrackerPlugins(): Promise<void> {
  const plugins = await listTrackerPlugins();

  if (plugins.length === 0) {
    console.log('No tracker plugins found.');
    return;
  }

  console.log('\nAvailable Tracker Plugins:\n');
  console.log('─'.repeat(80));

  for (const plugin of plugins) {
    const typeLabel = plugin.builtin ? '(built-in)' : '(user)';
    console.log(`  ${plugin.id} ${typeLabel}`);
    console.log(`    Name:        ${plugin.name}`);
    console.log(`    Description: ${plugin.description}`);
    console.log(`    Version:     ${plugin.version}`);

    const features: string[] = [];
    if (plugin.features.bidirectionalSync) features.push('sync');
    if (plugin.features.hierarchy) features.push('hierarchy');
    if (plugin.features.dependencies) features.push('dependencies');
    console.log(`    Features:    ${features.join(', ') || 'none'}`);

    console.log('─'.repeat(80));
  }

  console.log(`\nTotal: ${plugins.length} plugin(s)\n`);
}
