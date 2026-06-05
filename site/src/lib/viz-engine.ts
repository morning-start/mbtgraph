/**
 * viz-engine.ts — 图算法可视化核心引擎（协调层）
 *
 * 职责:
 *   - 初始化 Cytoscape + VizRenderer
 *   - 生成步骤数组（调用算法的 generateSteps）
 *   - 协调 PlayerController、EventManager、VizRenderer
 *   - UI 更新协调（从算法 getUIData 获取数据，写入 DOM）
 *
 * 不负责:
 *   - 直接操作 Cytoscape API → 委托给 VizRenderer
 *   - 颜色管理 → 委托给 ColorRegistry
 *   - 播放控制 → 委托给 PlayerController
 *   - 事件绑定 → 委托给 EventManager
 */

import cytoscape, { type Core } from 'cytoscape';
import cytoscapeDagre from 'cytoscape-dagre';
import VizRenderer from './viz-renderer';
import { resolveColors, type LegendSelector, type ColorMap } from './color-registry';
import type { RenderMode } from './viz-renderer';
import { EventManager } from './event-manager';
import { PlayerController, type PlayerState } from './player-controller';

// ── 注册 dagre 布局扩展 ──

cytoscape.use(cytoscapeDagre);

// ── 布局与交互常量 ──

const LAYOUT = {
  nodeSep: 80,
  rankSep: 90,
  padding: 40,
  minZoom: 0.3,
  maxZoom: 3,
  wheelSensitivity: 0.35,
} as const;

const ANIMATION = {
  defaultSpeed: 500,
  minDuration: 200,
  speedFactor: 0.6,
  fadeOutDelay: 320,
  focusDelay: 500,
} as const;

const SPEED_RANGE = { min: 60, max: 1100 } as const;
export { SPEED_RANGE };

// ── Cytoscape 默认样式常量 ──

/** eslint-disable @typescript-eslint/no-explicit-any -- Cytoscape CSS 类型过于严格，使用 any 绕过 */
const CYTOSCAPE_NODE_STYLE = {
  'label': 'data(label)',
  'text-valign': 'center',
  'text-halign': 'center',
  'background-color': '#1e293b',
  'background-blacken': 0.15,
  'border-color': '#334155',
  'border-width': 2.5,
  'color': '#e2e8f0',
  'font-family': '"DM Sans", -apple-system, system-ui, sans-serif',
  'font-size': 14,
  'font-weight': 700,
  'width': 48,
  'height': 48,
  'shape': 'ellipse' as const,
  'text-outline-width': 2,
  'text-outline-color': '#1e293b',
  'transition-property': 'background-color,border-color,border-width,width,height,color,text-background-color,text-outline-color',
  'transition-duration': 0.35,
} as const;

const CYTOSCAPE_EDGE_STYLE = {
  'width': 2,
  'line-color': '#475569',
  'target-arrow-color': '#475569',
  'source-arrow-color': '#475569',
  'arrow-scale': 0.8,
  'curve-style': 'bezier' as const,
  'opacity': 0.85,
  'label': 'data(weight)',
  'text-background-color': '#0f172a',
  'text-background-opacity': 0.95,
  'text-background-padding': '4px 6px',
  'text-border-width': 1,
  'text-border-color': 'rgba(71,85,105,0.4)',
  'text-border-style': 'solid',
  'font-size': 10.5,
  'font-weight': 600,
  'color': '#94a3b8',
  'font-family': '"JetBrains Mono", ui-monospace, monospace',
  'transition-property': 'line-color,target-arrow-color,source-arrow-color,width,opacity,line-style',
  'transition-duration': 0.35,
} as const;

// ── 类型定义 ──

/**
 * 算法模块接口 — 所有算法必须实现
 */
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

interface VizConfig {
  title: string;
  subtitle?: string;
  nodes: Array<{ data: { id: string; label: string } }>;
  edges: Array<{ data: { id: string; source: string; target: string; weight?: number | string } }>;
  startNode?: string;
  directed?: boolean;
  algoInstance: AlgoModule<unknown>;
}

export interface UIState {
  isFinished: boolean;
  currentIdx: number;
  total: number;
  isPlaying: boolean;
}

/** DOM 元素引用缓存 */
interface DOMRefs {
  progressFill: HTMLElement | null;
  progressThumb: HTMLElement | null;
  stepCounter: HTMLElement | null;
  iconPlay: HTMLElement | null;
  iconPause: HTMLElement | null;
  btnPrimary: HTMLElement | null;
  headerBadge: HTMLElement | null;
  headerInfo: HTMLElement | null;
  speedSlider: HTMLInputElement | null;
  speedVal: HTMLElement | null;
  progressTrack: HTMLElement | null;
  wrapper: HTMLElement | null;
}

interface EngineState {
  renderer: VizRenderer | null;
  cy: Core | null;
  colors: ColorMap;
  steps: unknown[];
  config: VizConfig | null;
  dom: DOMRefs;
  eventManager: EventManager | null;
  player: PlayerController | null;
}

// ── 引擎实现 ──

class VizEngine {
  private _state: EngineState = {
    renderer: null,
    cy: null,
    colors: {},
    steps: [],
    config: null,
    dom: this._createEmptyDOMRefs(),
    eventManager: null,
    player: null,
  };

  private _createEmptyDOMRefs(): DOMRefs {
    return {
      progressFill: null, progressThumb: null, stepCounter: null,
      iconPlay: null, iconPause: null, btnPrimary: null,
      headerBadge: null, headerInfo: null,
      speedSlider: null, speedVal: null,
      progressTrack: null, wrapper: null,
    };
  }

  private _cacheDOMRefs(): DOMRefs {
    const $ = (id: string) => document.getElementById(id);
    const qs = (sel: string) => document.querySelector(sel);
    return {
      progressFill: $('progress-fill'),
      progressThumb: $('progress-thumb'),
      stepCounter: $('step-counter'),
      iconPlay: $('icon-play'),
      iconPause: $('icon-pause'),
      btnPrimary: qs('.play-hero') as HTMLElement | null,
      headerBadge: qs('.viz-header .badge') as HTMLElement | null,
      headerInfo: qs('.viz-header .graph-info') as HTMLElement | null,
      speedSlider: $('speed') as HTMLInputElement | null,
      speedVal: $('speed-val'),
      progressTrack: $('progress-track'),
      wrapper: qs('.viz-wrapper') as HTMLElement | null,
    };
  }

  init(config: VizConfig): void {
    const state = this._state;

    if (state.cy) {
      console.warn('[VizEngine] Already initialized. Call destroy() first.');
      return;
    }

    try {
      state.config = config;
      state.dom = this._cacheDOMRefs();
      state.colors = resolveColors(config.algoInstance.legendKeys);

      const { adjList, edgeWeights } = this._buildGraphData(config);
      const algo = config.algoInstance;
      const hasWeights = Object.keys(edgeWeights).length > 0;
      state.steps = algo.generateSteps(
        config.nodes, adjList,
        hasWeights ? edgeWeights : undefined,
        config.startNode,
      );

      const container = document.getElementById('viz-canvas');
      if (!container) {
        console.error('[VizEngine] Canvas container #viz-canvas not found');
        return;
      }

      const cy = cytoscape({
        container,
        elements: [...config.nodes, ...config.edges],
        layout: {
          name: 'dagre',
          rankDir: 'LR',
          nodeSep: LAYOUT.nodeSep,
          rankSep: LAYOUT.rankSep,
          animate: false,
          fit: true,
          padding: LAYOUT.padding,
        } as cytoscape.LayoutOptions,
        style: [
          { selector: 'node', style: CYTOSCAPE_NODE_STYLE },
          { selector: 'edge', style: CYTOSCAPE_EDGE_STYLE },
        ],
        userZoomingEnabled: true,
        userPanningEnabled: true,
        boxSelectionEnabled: false,
        minZoom: LAYOUT.minZoom,
        maxZoom: LAYOUT.maxZoom,
        wheelSensitivity: LAYOUT.wheelSensitivity,
      }) as Core;

      state.cy = cy;
      state.renderer = new VizRenderer(cy);

      state.player = new PlayerController({
        onStateChange: (playerState: PlayerState) => {
          this._updateUIFromPlayerState(playerState);
        },
        onExecuteStep: (idx: number, animate: boolean) => {
          this._executeStep(state.steps[idx], animate);
        },
        onRebuildTo: (idx: number) => {
          this._rebuildTo(idx);
        },
        onResetVisuals: () => {
          if (state.renderer) state.renderer.resetAll();
        },
      });
      state.player.init(state.steps.length);

      const loadingEl = document.getElementById('loading-overlay');
      if (loadingEl) {
        loadingEl.classList.add('fade-out');
        setTimeout(() => { loadingEl.style.display = 'none'; }, ANIMATION.fadeOutDelay);
      }

      this._updateHeader(config.title, config.subtitle);

      state.eventManager = new EventManager({
        'toggle-play': () => state.player?.togglePlay(),
        'step-forward': () => state.player?.stepForward(),
        'step-back': () => state.player?.stepBack(),
        'skip-to-start': () => state.player?.skipToStart(),
        'skip-to-end': () => state.player?.skipToEnd(),
        'reset': () => state.player?.reset(),
        'jump-to': (idx: number) => state.player?.jumpTo(idx),
        'set-speed': (speed: number) => { state.player?.setSpeed(speed); },
      });
      state.eventManager.bindAll(state.dom, () => state.steps.length);

      setTimeout(() => {
        if (state.dom.wrapper) state.dom.wrapper.focus();
      }, ANIMATION.focusDelay);

    } catch (err) {
      console.error('[VizEngine] Initialization failed:', err);
      this.destroy();
    }
  }

  destroy(): void {
    const state = this._state;

    if (state.player) {
      state.player.destroy();
      state.player = null;
    }

    if (state.cy) {
      state.cy.destroy();
      state.cy = null;
    }
    state.renderer = null;

    if (state.eventManager) {
      state.eventManager.destroy();
      state.eventManager = null;
    }

    state.steps = [];
    state.config = null;
    state.colors = {};
    state.dom = this._createEmptyDOMRefs();
  }

  private _buildGraphData(config: VizConfig): { adjList: Record<string, string[]>; edgeWeights: Record<string, number> } {
    const adjList: Record<string, string[]> = {};
    const edgeWeights: Record<string, number> = {};

    config.nodes.forEach((n) => { adjList[n.data.id] = []; });

    config.edges.forEach((e) => {
      if (config.directed) {
        adjList[e.data.source].push(e.data.target);
      } else {
        adjList[e.data.source].push(e.data.target);
        adjList[e.data.target].push(e.data.source);
      }
      if (e.data.weight !== undefined) {
        edgeWeights[e.data.source + '-' + e.data.target] = parseFloat(String(e.data.weight));
      }
    });

    return { adjList, edgeWeights };
  }

  private _executeStep(step: unknown, animate: boolean): void {
    const state = this._state;
    const config = state.config;
    if (!config || !state.renderer) return;
    const algo = config.algoInstance;
    const mode: RenderMode = animate ? 'animate' : 'instant';
    const playerState = state.player?.getState();
    const speed = playerState?.speed ?? ANIMATION.defaultSpeed;
    const dur = animate ? Math.max(ANIMATION.minDuration, speed * ANIMATION.speedFactor) : 0;

    try {
      algo.renderStep(state.renderer, step, mode, dur, state.colors);
    } catch (err) {
      console.error('[VizEngine] renderStep error:', err);
    }
  }

  private _rebuildTo(idx: number): void {
    const state = this._state;
    const config = state.config;
    if (!config || !state.renderer) return;
    if (state.renderer) state.renderer.resetAll();
    for (let i = 0; i <= idx; i++) {
      const step = state.steps[i];
      if (!step) continue;
      try {
        config.algoInstance.renderStep(state.renderer, step, 'instant', 0, state.colors);
      } catch (err) {
        console.error(`[VizEngine] _rebuildTo step ${i} error:`, err);
      }
    }
  }

  private _updateUIFromPlayerState(playerState: PlayerState): void {
    const state = this._state;
    const config = state.config;
    if (!config) return;
    const { dom } = state;
    const steps = state.steps;
    const currentIdx = playerState.currentIdx;

    const total = steps.length;
    if (total > 0) {
      const pct = total > 1 ? (currentIdx / (total - 1)) * 100 : 0;
      if (dom.progressFill) dom.progressFill.style.width = pct + '%';
      if (dom.progressThumb) dom.progressThumb.style.left = pct + '%';
      if (dom.stepCounter) dom.stepCounter.textContent = Math.max(0, currentIdx) + ' / ' + (total - 1);
    }

    if (dom.iconPlay) dom.iconPlay.classList.toggle('hidden', playerState.isPlaying);
    if (dom.iconPause) dom.iconPause.classList.toggle('hidden', !playerState.isPlaying);

    if (playerState.isFinished) {
      if (dom.iconPlay) { dom.iconPlay.textContent = '↻'; dom.iconPlay.classList.remove('hidden'); }
      if (dom.iconPause) dom.iconPause.classList.add('hidden');
      if (dom.btnPrimary) dom.btnPrimary.classList.add('replay-pulse');
      if (!dom.iconPlay && dom.btnPrimary) dom.btnPrimary.textContent = '↻';
    } else {
      if (dom.iconPlay) dom.iconPlay.textContent = '▶';
      if (dom.btnPrimary) dom.btnPrimary.classList.remove('replay-pulse');
      if (!dom.iconPlay && dom.btnPrimary) dom.btnPrimary.textContent = playerState.isPlaying ? '⏸' : '▶';
    }

    const algo = config.algoInstance;
    const step = currentIdx >= 0 ? steps[currentIdx] : null;
    const uiState: UIState = {
      isFinished: playerState.isFinished,
      currentIdx: currentIdx,
      total: total - 1,
      isPlaying: playerState.isPlaying,
    };

    try {
      const uiData = algo.getUIData(step, uiState);
      for (const [elementId, value] of Object.entries(uiData)) {
        const el = document.getElementById(elementId);
        if (el) el.textContent = value;
      }
    } catch (err) {
      console.error('[VizEngine] getUIData error:', err);
    }
  }

  private _updateHeader(title: string, subtitle?: string): void {
    const { dom } = this._state;
    if (dom.headerBadge && title) dom.headerBadge.textContent = title;
    if (dom.headerInfo && subtitle) dom.headerInfo.textContent = subtitle;
  }

  getState() {
    const playerState = this._state.player?.getState();
    return {
      currentIdx: playerState?.currentIdx ?? -1,
      isPlaying: playerState?.isPlaying ?? false,
      isFinished: playerState?.isFinished ?? false,
      totalSteps: this._state.steps.length,
    };
  }
}

export const VizApp = new VizEngine();
export default VizApp;
