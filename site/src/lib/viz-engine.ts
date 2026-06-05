/**
 * viz-engine.ts — 图算法可视化核心引擎（协调层）
 *
 * 重构后职责:
 *   - 初始化 Cytoscape + VizRenderer
 *   - 生成步骤数组（调用算法的 generateSteps）
 *   - 播放控制（play/pause/step/jump/reset）
 *   - 事件绑定（键盘/进度条/速度）
 *   - UI 更新协调（从算法 getUIData 获取数据，写入 DOM）
 *   - 从 color-registry 自动生成图例
 *
 * 不再负责:
 *   - 直接操作 Cytoscape API → 委托给 VizRenderer
 *   - 颜色管理 → 委托给 ColorRegistry
 */

import cytoscape from 'cytoscape';
import cytoscapeDagre from 'cytoscape-dagre';
import VizRenderer from './viz-renderer';
import { resolveLegendItems, resolveColors, type LegendSelector, type ColorMap } from './color-registry';
import type { RenderMode } from './viz-renderer';

// ── 类型定义 ──

/** 算法模块接口 — 所有算法必须实现 */
export interface AlgoModule {
  /** 本算法使用的颜色 key 列表 */
  legendKeys: LegendSelector[];
  /** 生成步骤数组 */
  generateSteps(...args: unknown[]): unknown[];
  /** 渲染单步（合并原 executeStep + rebuildTo） */
  renderStep(renderer: VizRenderer, step: unknown, mode: RenderMode, speed: number, colors: ColorMap): void;
  /** 返回 UI 状态数据（不操作 DOM） */
  getUIData(step: unknown | null, state: UIState): Record<string, string>;
}

interface VizConfig {
  title: string;
  subtitle?: string;
  nodes: Array<{ data: { id: string; label: string } }>;
  edges: Array<{ data: { id: string; source: string; target: string; weight?: number | string } }>;
  startNode: string;
  directed?: boolean;
  /** 算法模块实例 */
  algoInstance: AlgoModule;
}

interface UIState {
  isFinished: boolean;
  currentIdx: number;
  total: number;
  isPlaying: boolean;
}

interface EngineState {
  renderer: VizRenderer | null;
  colors: ColorMap;
  currentIdx: number;
  isPlaying: boolean;
  isFinished: boolean;
  speed: number;
  timerId: ReturnType<typeof setTimeout> | null;
  steps: unknown[];
  adjList: Record<string, string[]>;
  config: VizConfig | null;
}

// ── 注册 dagre 布局扩展 ──

cytoscape.use(cytoscapeDagre);

// ── 引擎实现 ──

class VizEngine {
  private _state: EngineState = {
    renderer: null,
    colors: {},
    currentIdx: -1,
    isPlaying: false,
    isFinished: false,
    speed: 500,
    timerId: null,
    steps: [],
    adjList: {},
    config: null,
  };

  /**
   * 初始化可视化引擎
   */
  init(config: VizConfig): void {
    const state = this._state;

    // 保存配置
    state.config = config;
    state.currentIdx = -1;
    state.isPlaying = false;
    state.isFinished = false;
    state.speed = 500;
    state.timerId = null;

    // 从算法的 legendKeys 解析颜色映射和图例数据
    state.colors = resolveColors(config.algoInstance.legendKeys);
    const legendItems = resolveLegendItems(config.algoInstance.legendKeys);
    this._applyLegendItems(legendItems);

    // 构建邻接表
    state.adjList = {};
    config.nodes.forEach((n) => {
      state.adjList[n.data.id] = [];
    });

    // 构建边权重映射
    const edgeWeights: Record<string, number> = {};
    config.edges.forEach((e) => {
      if (config.directed) {
        state.adjList[e.data.source].push(e.data.target);
      } else {
        state.adjList[e.data.source].push(e.data.target);
        state.adjList[e.data.target].push(e.data.source);
      }
      if (e.data.weight !== undefined) {
        edgeWeights[e.data.source + '-' + e.data.target] = parseFloat(String(e.data.weight));
      }
    });

    // 生成步骤数组
    const algo = config.algoInstance;
    if (algo.generateSteps.length >= 4) {
      state.steps = algo.generateSteps(config.nodes, state.adjList, edgeWeights, config.startNode) as unknown[];
    } else {
      const result = algo.generateSteps(config.nodes, state.adjList, config.startNode);
      state.steps = Array.isArray(result) ? result : ((result as any).steps || []);
    }

    // 初始化 Cytoscape
    const container = document.getElementById('viz-canvas');
    if (!container) {
      console.error('Canvas container not found');
      return;
    }

    const cy = cytoscape({
      container: container,
      elements: config.nodes.concat(config.edges),

      layout: {
        name: 'dagre',
        rankDir: 'LR',
        nodeSep: 80,
        rankSep: 90,
        animate: false,
        fit: true,
        padding: 40,
      },

      style: [
        {
          selector: 'node',
          style: {
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
            'shape': 'ellipse',
            'text-outline-width': 2,
            'text-outline-color': '#1e293b',
            'transition-property': 'background-color,border-color,border-width,width,height,color,text-background-color,text-outline-color',
            'transition-duration': '0.35s',
          },
        },
        {
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#475569',
            'target-arrow-color': '#475569',
            'source-arrow-color': '#475569',
            'arrow-scale': 0.8,
            'curve-style': 'bezier',
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
            'transition-duration': '0.35s',
          },
        },
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

      userZoomEnabled: true,
      userPanningEnabled: true,
      boxSelectionEnabled: false,
      minZoom: 0.3,
      maxZoom: 3,
      wheelSensitivity: 0.35,
    });

    // 创建渲染器实例
    state.renderer = new VizRenderer(cy as any);

    // 隐藏加载状态
    const loadingEl = document.getElementById('loading-overlay');
    if (loadingEl) {
      loadingEl.classList.add('fade-out');
      setTimeout(() => { (loadingEl as HTMLElement).style.display = 'none'; }, 320);
    }

    // 更新头部信息
    this.updateHeader(config.title, config.subtitle);

    // 绑定控制事件
    this.bindControls();
    this.bindKeyboard();
    this.bindProgress();
    this.bindSpeed();

    // 自动聚焦
    setTimeout(() => {
      const root = document.querySelector('.viz-wrapper');
      if (root) (root as HTMLElement).focus();
    }, 500);
  }

  // ==================== 内部方法 ====================

  private executeStep(step: unknown, animate: boolean): void {
    const state = this._state;
    const config = state.config!;
    const algo = config.algoInstance;
    const mode: RenderMode = animate ? 'animate' : 'instant';
    const dur = animate ? Math.max(200, state.speed * 0.6) : 0;

    algo.renderStep(state.renderer!, step, mode, dur, state.colors);
  }

  private resetVisuals(): void {
    const state = this._state;
    if (state.renderer) {
      state.renderer.resetAll();
    }
  }

  private updateUI(): void {
    const state = this._state;
    const config = state.config!;
    const steps = state.steps;
    const currentIdx = state.currentIdx;

    // 更新进度条
    const total = steps.length;
    const progressFill = document.getElementById('progress-fill');
    const progressThumb = document.getElementById('progress-thumb');
    const stepCounter = document.getElementById('step-counter');

    if (total > 0) {
      const pct = total > 1 ? (currentIdx / (total - 1)) * 100 : 0;
      if (progressFill) progressFill.style.width = pct + '%';
      if (progressThumb) progressThumb.style.left = pct + '%';
      if (stepCounter) stepCounter.textContent = Math.max(0, currentIdx) + ' / ' + (total - 1);
    }

    // 更新图标状态
    const iconPlay = document.getElementById('icon-play');
    const iconPause = document.getElementById('icon-pause');
    const btnPrimary = document.querySelector('.play-hero');

    if (iconPlay) {
      iconPlay.classList.toggle('hidden', state.isPlaying);
    }
    if (iconPause) {
      iconPause.classList.toggle('hidden', !state.isPlaying);
    }

    // 完成状态：显示重播图标
    if (state.isFinished) {
      if (iconPlay) {
        iconPlay.textContent = '\u21BB';
        iconPlay.classList.remove('hidden');
      }
      if (iconPause) iconPause.classList.add('hidden');
      if (btnPrimary) btnPrimary.classList.add('replay-pulse');
      if (!iconPlay && btnPrimary) btnPrimary.textContent = '\u21BB';
    } else {
      if (iconPlay) {
        iconPlay.textContent = '\u25B6';
      }
      if (btnPrimary) btnPrimary.classList.remove('replay-pulse');
      if (!iconPlay && btnPrimary) {
        btnPrimary.textContent = state.isPlaying ? '\u23F8' : '\u25B6';
      }
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
    const uiData = algo.getUIData(step, uiState);

    for (const [elementId, value] of Object.entries(uiData)) {
      const el = document.getElementById(elementId);
      if (el) el.textContent = value;
    }
  }

  /**
   * 将图例数据写入页面（供 VizLayout 渲染）
   * 通过查找 .viz-legend 容器并填充
   */
  private _applyLegendItems(items: Array<{ color: string; label: string; type?: 'dot' | 'bar' }>): void {
    const legendContainer = document.querySelector('.viz-legend');
    if (!legendContainer || items.length === 0) return;

    // 清空已有内容并重新生成
    legendContainer.innerHTML = items.map(item => `
      <div class="legend-chip">
        <i class="legend-${item.type ?? 'dot'}" style="background:${item.color}"></i>
        ${item.label}
      </div>
    `).join('');
  }

  private updateHeader(title: string, subtitle?: string): void {
    const badge = document.querySelector('.viz-header .badge');
    const info = document.querySelector('.viz-header .graph-info');

    if (badge && title) badge.textContent = title;
    if (info && subtitle) info.textContent = subtitle;
  }

  // ==================== 控制函数 ====================

  togglePlay(): void {
    const state = this._state;
    if (state.isFinished) {
      this.doReset();
      this.play();
    } else {
      state.isPlaying ? this.pause() : this.play();
    }
  }

  play(): void {
    const state = this._state;

    if (state.currentIdx >= state.steps.length - 1) {
      this.jumpTo(0);
    }
    state.isFinished = false;
    state.isPlaying = true;
    this.updateUI();
    this.tick();
  }

  pause(): void {
    const state = this._state;
    state.isPlaying = false;
    if (state.timerId) {
      clearTimeout(state.timerId);
      state.timerId = null;
    }
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

  skipToStart(): void {
    this.pause();
    this.jumpTo(0);
  }

  skipToEnd(): void {
    const state = this._state;
    this.pause();
    state.isFinished = true;
    this.jumpTo(state.steps.length - 1);
  }

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
    const progressFill = document.getElementById('progress-fill');
    const progressThumb = document.getElementById('progress-thumb');
    if (progressFill) progressFill.style.width = '0%';
    if (progressThumb) progressThumb.style.left = '0%';
    this.resetVisuals();
    this.updateUI();
  }

  /** 内部：重建到指定步骤（使用 instant 模式） */
  private _rebuildTo(idx: number): void {
    const state = this._state;
    const config = state.config!;

    // 先重置所有元素
    this.resetVisuals();

    // 逐步 instant 渲染到目标位置
    for (let i = 0; i <= idx; i++) {
      const step = state.steps[i];
      if (!step) continue;
      config.algoInstance.renderStep(state.renderer!, step, 'instant', 0, state.colors);
    }
  }

  // ==================== 事件绑定 ====================

  bindControls(): void {
    const actionMap: Record<string, () => void> = {
      'toggle-play': () => this.togglePlay(),
      'step-forward': () => this.stepForward(),
      'step-back': () => this.stepBack(),
      'skip-to-start': () => this.skipToStart(),
      'skip-to-end': () => this.skipToEnd(),
      'reset': () => this.doReset(),
    };

    for (const [action, handler] of Object.entries(actionMap)) {
      const btn = document.querySelector(`[data-action="${action}"]`);
      if (btn) btn.addEventListener('click', handler);
    }
  }

  bindKeyboard(): void {
    const root = document.querySelector('.viz-wrapper');
    if (!root) return;

    root.addEventListener('keydown', (e: Event) => {
      const ke = e as KeyboardEvent;
      switch (ke.key) {
        case ' ':
          ke.preventDefault();
          this.togglePlay();
          break;
        case 'ArrowRight':
          ke.preventDefault();
          this.stepForward();
          break;
        case 'ArrowLeft':
          ke.preventDefault();
          this.stepBack();
          break;
        case 'Home':
          ke.preventDefault();
          this.skipToStart();
          break;
        case 'End':
          ke.preventDefault();
          this.skipToEnd();
          break;
        case 'r':
        case 'R':
          if (!ke.ctrlKey && !ke.metaKey) {
            ke.preventDefault();
            this.doReset();
          }
          break;
      }
    });
  }

  bindProgress(): void {
    const state = this._state;
    const progressTrack = document.getElementById('progress-track');
    if (!progressTrack) return;

    progressTrack.addEventListener('click', (e: MouseEvent) => {
      const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
      const pct = (e.clientX - rect.left) / rect.width;
      const idx = Math.round(pct * (state.steps.length - 1));
      this.jumpTo(idx);
    });
  }

  bindSpeed(): void {
    const state = this._state;
    const speedSlider = document.getElementById('speed') as HTMLInputElement | null;
    const speedVal = document.getElementById('speed-val');
    if (!speedSlider) return;

    speedSlider.addEventListener('input', (e: Event) => {
      const v = parseInt((e.target as HTMLInputElement).value, 10);
      state.speed = Math.max(60, 1100 - v * 100);
      if (speedVal) speedVal.textContent = v + 'x';
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

// 导出单例实例
export const VizApp = new VizEngine();
export default VizApp;
