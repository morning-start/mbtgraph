import VizRenderer from './viz-renderer';
import type { RenderMode } from './viz-renderer';
import type { ColorMap, LegendSelector } from './color-registry';
import { darken } from './color-registry';

export type { VizRenderer, RenderMode, ColorMap, LegendSelector };
export { darken };

export interface UIState {
  isFinished: boolean;
  currentIdx: number;
  total: number;
  isPlaying: boolean;
}

export interface AlgoModule<TStep = unknown> {
  legendKeys: LegendSelector[];
  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights?: Record<string, number>,
    startNode?: string,
  ): TStep[];
  renderStep(renderer: VizRenderer, step: TStep, mode: RenderMode, speed: number, colors: ColorMap): void;
  getUIData(step: TStep | null, state: UIState): Record<string, string>;
}

export function createAlgo<TStep>(impl: AlgoModule<TStep>): AlgoModule<TStep> {
  return impl;
}

export function snapshot<T extends Record<string, unknown>>(obj: T): T {
  const copy = {} as T;
  for (const k in obj) copy[k] = obj[k];
  return copy;
}
