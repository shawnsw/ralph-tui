/**
 * ABOUTME: JSON tracker plugin for prd.json task files.
 * The default tracker plugin that reads tasks from a local JSON file.
 * Full implementation in US-008.
 */

import { BaseTrackerPlugin } from '../base.js';
import type {
  TrackerPluginMeta,
  TrackerPluginFactory,
  TrackerTask,
  TrackerTaskStatus,
  TaskFilter,
  TaskCompletionResult,
  SetupQuestion,
} from '../types.js';

/**
 * JSON tracker plugin implementation.
 * Reads and writes tasks from a local prd.json file.
 */
export class JsonTrackerPlugin extends BaseTrackerPlugin {
  readonly meta: TrackerPluginMeta = {
    id: 'json',
    name: 'JSON File Tracker',
    description: 'Track tasks in a local prd.json file',
    version: '1.0.0',
    supportsBidirectionalSync: false,
    supportsHierarchy: true,
    supportsDependencies: true,
  };

  private filePath: string = '';

  override async initialize(config: Record<string, unknown>): Promise<void> {
    await super.initialize(config);

    if (typeof config.path === 'string') {
      this.filePath = config.path;
    }
  }

  getSetupQuestions(): SetupQuestion[] {
    return [
      {
        id: 'path',
        prompt: 'Path to prd.json file:',
        type: 'path',
        default: './prd.json',
        required: true,
        help: 'The JSON file containing your task definitions',
      },
    ];
  }

  override async validateSetup(
    answers: Record<string, unknown>
  ): Promise<string | null> {
    if (!answers.path || typeof answers.path !== 'string') {
      return 'File path is required';
    }
    return null;
  }

  async getTasks(_filter?: TaskFilter): Promise<TrackerTask[]> {
    // Stub: Full implementation in US-008
    void this.filePath;
    return [];
  }

  async completeTask(
    id: string,
    reason?: string
  ): Promise<TaskCompletionResult> {
    // Stub: Full implementation in US-008
    return {
      success: false,
      message: `JSON tracker not yet implemented for task ${id}`,
      error: reason ?? 'Not implemented',
    };
  }

  async updateTaskStatus(
    _id: string,
    _status: TrackerTaskStatus
  ): Promise<TrackerTask | undefined> {
    // Stub: Full implementation in US-008
    return undefined;
  }
}

/**
 * Factory function for the JSON tracker plugin.
 */
const createJsonTracker: TrackerPluginFactory = () => new JsonTrackerPlugin();

export default createJsonTracker;
