/**
 * viz-engine.ts — 图算法可视化核心引擎（协调层）
 *
 * 职责:
 *   - 初始化 Cytoscape + VizRenderer
 *   - 生成步骤数组（调用算法的 generateSteps）
 *   - 播放控制（play/pause/step/jump/reset）
 *   - 事件绑定（键盘/进度条/速度）
 *   - UI 更新协调（从算法 getUIData 获取数据，写入 DOM）
 *
 * 不负责:
 *   - 直接操作 Cytoscape API → 委托给 VizRenderer
 *   - 颜色管理 → 委托给 ColorRegistry
 *   - 图例渲染 → 由 VizLayout 在构建时从 legendKeys 生成
 */

import cytoscape, { type Core } from 'cytoscape';
import cytoscapeDagre from 'cytoscape-dagre';
import VizRenderer from './viz-renderer';
import { resolveColors, type LegendSelector, type ColorMap } from './color-registry';
import type { RenderMode } from './viz-renderer';

// ── 注册 dagre 布局扩展 ──

cytoscape.use(cytoscapeDagre);

// ── 布局与交互常量 (P2#12) ──

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
  secondaryDelayFactor: 0.5,
  secondaryMinDuration: 100,
  fadeOutDelay: 320,
  focusDelay: 500,
} as const;

const SPEED_RANGE = { min: 60, max: 1100 } as const;

// ── Cytoscape 默认样式常量 (P1#6) ──

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
 * TStep: 步骤数据的类型参数，消除 unknown 泛型 (P1#4)
 */
export interface AlgoModule<TStep = unknown> {
  /** 本算法使用的颜色 key 列表 */
  legendKeys: LegendSelector[];
  /**
   * 生成步骤数组
   * 统一签名：(nodes, adjList, edgeWeights?, startNode?)
   * edgeWeights 仅 Dijkstra 等带权算法需要，其他算法忽略即可 (P1#5)
   */
  generateSteps(
    nodes: Array<{ data: { id: string; label: string } }>,
    adjList: Record<string, string[]>,
    edgeWeights?: Record<string, number>,
    startNode?: string,
  ): TStep[];
  /** 渲染单步（合并原 executeStep + rebuildTo） */
  renderStep(renderer: VizRenderer, step: TStep, mode: RenderMode, speed: number, colors: ColorMap): void;
  /** 返回 UI 状态数据（不操作 DOM） */
  getUIData(step: TStep | null, state: UIState): Record<string, string>;
}

interface VizConfig {
  title: string;
  subtitle?: string;
  nodes: Array<{ data: { id: string; label: string } }>;
  edges: Array<{ data: { id: string; source: string; target: string; weight?: number | string } }>;
  startNode?: string;
  directed?: boolean;
  /** 算法模块实例 */
  algoInstance: AlgoModule<unknown>;
}

interface UIState {
  isFinished: boolean;
  currentIdx: number;
  total: number;
  isPlaying: boolean;
}

/** DOM 元素引用缓存 (P2#10: 降低耦合) */
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
  currentIdx: number;
  isPlaying: boolean;
  isFinished: boolean;
  speed: number;
  timerId: ReturnType<typeof setTimeout> | null;
  steps: unknown[];
  config: VizConfig | null;
  dom: DOMRefs;
  boundHandlers: Array<{ el: EventTarget; event: string; handler: EventListener }>;
}

// ── 引擎实现 ──

class VizEngine {
  private _state: EngineState = {
    renderer: null,
    cy: null,
    colors: {},
    currentIdx: -1,
    isPlaying: false,
    isFinished: false,
    speed: ANIMATION.defaultSpeed,
    timerId: null,
    steps: [],
    config: null,
    dom: this._createEmptyDOMRefs(),
    boundHandlers: [],
  };

  /** 创建空的 DOM 引用（init 前的安全默认值） */
  private _createEmptyDOMRefs(): DOMRefs {
    return {
      progressFill: null, progressThumb: null, stepCounter: null,
      iconPlay: null, iconPause: null, btnPrimary: null,
      headerBadge: null, headerInfo: null,
      speedSlider: null, speedVal: null,
      progressTrack: null, wrapper: null,
    };
  }

  /** 缓存所有 DOM 元素引用 (P2#10) */
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

  /** 安全注册事件监听，记录以便销毁时清理 (P2#9) */
  private _on(el: EventTarget | null, event: string, handler: EventListener): void {
    if (!el) return;
    el.addEventListener(event, handler);
    this._state.boundHandlers.push({ el, event, handler });
  }

  /** 清理所有已注册的事件监听器 */
  private _unbindAll(): void {
    for (const { el, event, handler } of this._state.boundHandlers) {
      el.removeEventListener(event, handler);
    }
    this._state.boundHandlers = [];
  }

  /**
   * 初始化可视化引擎
   */
  init(config: VizConfig): void {
    const state = this._state;

    // 防止重复初始化 (P2#11)
    if (state.cy) {
      console.warn('[VizEngine] Already initialized. Call destroy() first.');
      return;
    }

    try {
      state.config = config;
      state.currentIdx = -1;
      state.isPlaying = false;
      state.isFinished = false;
      state.speed = ANIMATION.defaultSpeed;
      state.timerId = null;

      // 缓存 DOM 引用
      state.dom = this._cacheDOMRefs();

      // 从算法的 legendKeys 解析颜色映射
      state.colors = resolveColors(config.algoInstance.legendKeys);

      // 构建邻接表 + 边权重映射
      const { adjList, edgeWeights } = this._buildGraphData(config);

      // 生成步骤数组 (P1#5: 统一签名)
      const algo = config.algoInstance;
      const hasWeights = Object.keys(edgeWeights).length > 0;
      state.steps = algo.generateSteps(
        config.nodes, adjList,
        hasWeights ? edgeWeights : undefined,
        config.startNode,
      );

      // 初始化 Cytoscape (P2#7: 移除 as any)
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
          { selector: 'node', style: CYTOSCAPE_NODE_STYLE},
          { selector: 'edge', style: CYTOSCAPE_EDGE_STYLE },
          {
            selector: '.highlighted',
            style: {
              'background-color': '#fef3c7',
              'border-color': '#f59e0b',
              'border-width': 3.5,
              'z-index': 10,
            },
          },
        ],
        userZoomingEnabled: true,
        userPanningEnabled: true,
        boxSelectionEnabled: false,
        minZoom: LAYOUT.minZoom,
        maxZoom: LAYOUT.maxZoom,
        wheelSensitivity: LAYOUT.wheelSensitivity,
      }) as Core; // P2#7: 用类型断言替代 any

      state.cy = cy;
      state.renderer = new VizRenderer(cy);

      // 隐藏加载状态
      const loadingEl = document.getElementById('loading-overlay');
      if (loadingEl) {
        loadingEl.classList.add('fade-out');
        setTimeout(() => { loadingEl.style.display = 'none'; }, ANIMATION.fadeOutDelay);
      }

      // 更新头部信息
      this._updateHeader(config.title, config.subtitle);

      // 绑定控制事件
      this._bindControls();
      this._bindKeyboard();
      this._bindProgress();
      this._bindSpeed();

      // 自动聚焦
      setTimeout(() => {
        if (state.dom.wrapper) state.dom.wrapper.focus();
      }, ANIMATION.focusDelay);

    } catch (err) {
      console.error('[VizEngine] Initialization failed:', err);
      this.destroy(); // P2#9: 初始化失败时清理部分资源
    }
  }

  /**
   * 销毁引擎，释放所有资源 (P2#9)
   *
   * - 停止播放定时器
   * - 销毁 Cytoscape 实例
   * - 移除所有事件监听
   * - 重置状态
   */
  destroy(): void {
    const state = this._state;

    // 停止定时器
    if (state.timerId) {
      clearTimeout(state.timerId);
      state.timerId = null;
    }
    state.isPlaying = false;

    // 销毁 Cytoscape
    if (state.cy) {
      state.cy.destroy();
      state.cy = null;
    }
    state.renderer = null;

    // 移除事件监听
    this._unbindAll();

    // 重置状态
    state.steps = [];
    state.config = null;
    state.colors = {};
    state.currentIdx = -1;
    state.isFinished = false;
    state.dom = this._createEmptyDOMRefs();
  }

  // ==================== 内部方法 ====================

  /** 构建邻接表和边权重映射 */
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

  private executeStep(step: unknown, animate: boolean): void {
    const state = this._state;
    const config = state.config;
    if (!config || !state.renderer) return; // P2#11: 防御性检查
    const algo = config.algoInstance;
    const mode: RenderMode = animate ? 'animate' : 'instant';
    const dur = animate ? Math.max(ANIMATION.minDuration, state.speed * ANIMATION.speedFactor) : 0;

    try {
      algo.renderStep(state.renderer, step, mode, dur, state.colors);
    } catch (err) {
      console.error('[VizEngine] renderStep error:', err); // P2#11: 错误捕获
    }
  }

  private resetVisuals(): void {
    if (this._state.renderer) {
      this._state.renderer.resetAll();
    }
  }

  /** 使用缓存的 DOMRefs 更新 UI (P2#10) */
  private updateUI(): void {
    const state = this._state;
    const config = state.config;
    if (!config) return;
    const { dom } = state;
    const steps = state.steps;
    const currentIdx = state.currentIdx;

    // 更新进度条
    const total = steps.length;
    if (total > 0) {
      const pct = total > 1 ? (currentIdx / (total - 1)) * 100 : 0;
      if (dom.progressFill) dom.progressFill.style.width = pct + '%';
      if (dom.progressThumb) dom.progressThumb.style.left = pct + '%';
      if (dom.stepCounter) dom.stepCounter.textContent = Math.max(0, currentIdx) + ' / ' + (total - 1);
    }

    // 更新图标状态
    if (dom.iconPlay) dom.iconPlay.classList.toggle('hidden', state.isPlaying);
    if (dom.iconPause) dom.iconPause.classList.toggle('hidden', !state.isPlaying);

    if (state.isFinished) {
      if (dom.iconPlay) { dom.iconPlay.textContent = '\u21BB'; dom.iconPlay.classList.remove('hidden'); }
      if (dom.iconPause) dom.iconPause.classList.add('hidden');
      if (dom.btnPrimary) dom.btnPrimary.classList.add('replay-pulse');
      if (!dom.iconPlay && dom.btnPrimary) dom.btnPrimary.textContent = '\u21BB';
    } else {
      if (dom.iconPlay) dom.iconPlay.textContent = '\u25B6';
      if (dom.btnPrimary) dom.btnPrimary.classList.remove('replay-pulse');
      if (!dom.iconPlay && dom.btnPrimary) dom.btnPrimary.textContent = state.isPlaying ? '\u23F8' : '\u25B6';
    }

    // 调用算法的 getUIData 并写入 DOM
    const algo = config.algoInstance;
    const step = currentIdx >= 0 ? steps[currentIdx] : null;
    const uiState: UIState = {
      isFinished: state.isFinished,
      currentIdx: currentIdx,
      total: total - 1,
      isPlaying: state.isPlaying,
    };

    try {
      const uiData = algo.getUIData(step, uiState);
      for (const [elementId, value] of Object.entries(uiData)) {
        const el = document.getElementById(elementId);
        if (el) el.textContent = value;
      }
    } catch (err) {
      console.error('[VizEngine] getUIData error:', err); // P2#11
    }
  }

  /** 使用缓存的 DOMRefs 更新头部 (P2#10) */
  private _updateHeader(title: string, subtitle?: string): void {
    const { dom } = this._state;
    if (dom.headerBadge && title) dom.headerBadge.textContent = title;
    if (dom.headerInfo && subtitle) dom.headerInfo.textContent = subtitle;
  }

  // ==================== 控制函数 ====================

  togglePlay(): void {
    if (this._state.isFinished) { this.doReset(); this.play(); }
    else { this._state.isPlaying ? this.pause() : this.play(); }
  }

  play(): void {
    const state = this._state;
    if (state.currentIdx >= state.steps.length - 1) this.jumpTo(0);
    state.isFinished = false;
    state.isPlaying = true;
    this.updateUI();
    this.tick();
  }

  pause(): void {
    const state = this._state;
    state.isPlaying = false;
    if (state.timerId) { clearTimeout(state.timerId); state.timerId = null; }
    this.updateUI();
  }

  tick(): void {
    const state = this._state;
    if (!state.isPlaying) return;
    if (state.currentIdx < state.steps.length - 1) {
      this.stepForward();
      state.timerId = setTimeout(() => this.tick(), state.speed);
    } else {
      this.pause();
      state.isFinished = true;
      this.updateUI();
    }
  }

  stepForward(): void {
    const state = this._state;
    if (state.currentIdx < state.steps.length - 1) {
      state.isFinished = false;
      state.currentIdx++;
      this.executeStep(state.steps[state.currentIdx], true);
      this.updateUI();
    }
  }

  stepBack(): void {
    const state = this._state;
    if (state.currentIdx > 0) {
      state.isFinished = false;
      state.currentIdx--;
      this._rebuildTo(state.currentIdx);
      this.updateUI();
    }
  }

  skipToStart(): void { this.pause(); this.jumpTo(0); }
  skipToEnd(): void { const s = this._state; this.pause(); s.isFinished = true; this.jumpTo(s.steps.length - 1); }

  jumpTo(idx: number): void {
    const state = this._state;
    idx = Math.max(0, Math.min(idx, state.steps.length - 1));
    state.currentIdx = idx;
    this._rebuildTo(idx);
    this.updateUI();
  }

  doReset(): void {
    const state = this._state;
    this.pause();
    state.isFinished = false;
    state.currentIdx = -1;
    if (state.dom.progressFill) state.dom.progressFill.style.width = '0%';
    if (state.dom.progressThumb) state.dom.progressThumb.style.left = '0%';
    this.resetVisuals();
    this.updateUI();
  }

  /** 内部：重建到指定步骤（使用 instant 模式） */
  private _rebuildTo(idx: number): void {
    const state = this._state;
    const config = state.config;
    if (!config || !state.renderer) return; // P2#11
    this.resetVisuals();
    for (let i = 0; i <= idx; i++) {
      const step = state.steps[i];
      if (!step) continue;
      try {
        config.algoInstance.renderStep(state.renderer, step, 'instant', 0, state.colors);
      } catch (err) {
        console.error(`[VizEngine] _rebuildTo step ${i} error:`, err); // P2#11
      }
    }
  }

  // ==================== 事件绑定 (P2#10: 使用 DOMRefs + _on) ====================

  private _bindControls(): void {
    const actionMap: Record<string, () => void> = {
      'toggle-play': () => this.togglePlay(),
      'step-forward': () => this.stepForward(),
      'step-back': () => this.stepBack(),
      'skip-to-start': () => this.skipToStart(),
      'skip-to-end': () => this.skipToEnd(),
      'reset': () => this.doReset(),
    };
    for (const [action, handler] of Object.entries(actionMap)) {
      this._on(document.querySelector(`[data-action="${action}"]`), 'click', handler);
    }
  }

  private _bindKeyboard(): void {
    const root = this._state.dom.wrapper;
    if (!root) return;
    this._on(root, 'keydown', (e: Event) => {
      const ke = e as KeyboardEvent;
      switch (ke.key) {
        case ' ': ke.preventDefault(); this.togglePlay(); break;
        case 'ArrowRight': ke.preventDefault(); this.stepForward(); break;
        case 'ArrowLeft': ke.preventDefault(); this.stepBack(); break;
        case 'Home': ke.preventDefault(); this.skipToStart(); break;
        case 'End': ke.preventDefault(); this.skipToEnd(); break;
        case 'r': case 'R':
          if (!ke.ctrlKey && !ke.metaKey) { ke.preventDefault(); this.doReset(); }
          break;
      }
    });
  }

  private _bindProgress(): void {
    const track = this._state.dom.progressTrack;
    if (!track) return;
    this._on(track, 'click', (e: Event) => {
      const me = e as MouseEvent;
      const rect = track.getBoundingClientRect();
      const pct = (me.clientX - rect.left) / rect.width;
      this.jumpTo(Math.round(pct * (this._state.steps.length - 1)));
    });
  }

  private _bindSpeed(): void {
    const state = this._state;
    const slider = state.dom.speedSlider;
    const valEl = state.dom.speedVal;
    if (!slider) return;
    this._on(slider, 'input', (e: Event) => {
      const v = parseInt((e.target as HTMLInputElement).value, 10);
      state.speed = Math.max(SPEED_RANGE.min, SPEED_RANGE.max - v * 100);
      if (valEl) valEl.textContent = v + 'x';
    });
  }

  // ==================== 公开 API ====================

  getState() {
    return {
      currentIdx: this._state.currentIdx,
      isPlaying: this._state.isPlaying,
      isFinished: this._state.isFinished,
      totalSteps: this._state.steps.length,
    };
  }
}

export const VizApp = new VizEngine();
export default VizApp;
