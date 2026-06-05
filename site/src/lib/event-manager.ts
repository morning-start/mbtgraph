/**
 * event-manager.ts — 事件管理器
 *
 * 职责:
 *   - 注册和清理 DOM 事件监听
 *   - 键盘快捷键绑定
 *   - 进度条交互
 *   - 速度滑块控制
 *   - 控制按钮点击事件
 *
 * 设计原则:
 *   - 单一职责：只负责事件绑定和清理
 *   - 集中管理：所有事件处理器在这里定义
 *   - 自动清理：销毁时移除所有监听器
 */

import { SPEED_RANGE } from './viz-engine';

// ── 类型定义 ──

/** DOM 元素引用 */
export interface DOMRefs {
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

/** 事件处理器映射 */
export interface ActionHandlers {
  'toggle-play': () => void;
  'step-forward': () => void;
  'step-back': () => void;
  'skip-to-start': () => void;
  'skip-to-end': () => void;
  'reset': () => void;
  'jump-to': (idx: number) => void;
  'set-speed': (speed: number) => void;
}

/** 绑定的事件记录 */
interface BoundHandler {
  el: EventTarget;
  event: string;
  handler: EventListener;
}

// ── EventManager 实现 ──

export class EventManager {
  private _boundHandlers: BoundHandler[] = [];
  private _handlers: ActionHandlers;

  constructor(handlers: ActionHandlers) {
    this._handlers = handlers;
  }

  /**
   * 安全注册事件监听，记录以便销毁时清理
   */
  private _on(el: EventTarget | null, event: string, handler: EventListener): void {
    if (!el) return;
    el.addEventListener(event, handler);
    this._boundHandlers.push({ el, event, handler });
  }

  /**
   * 清理所有已注册的事件监听器
   */
  destroy(): void {
    for (const { el, event, handler } of this._boundHandlers) {
      el.removeEventListener(event, handler);
    }
    this._boundHandlers = [];
  }

  /**
   * 绑定所有控制事件
   */
  bindAll(dom: DOMRefs, stepsLength: () => number): void {
    this._bindControls();
    this._bindKeyboard(dom);
    this._bindProgress(dom, stepsLength);
    this._bindSpeed(dom);
  }

  /**
   * 绑定控制按钮点击事件
   */
  private _bindControls(): void {
    for (const [action, handler] of Object.entries(this._handlers)) {
      if (action === 'jump-to' || action === 'set-speed') continue;
      this._on(
        document.querySelector(`[data-action="${action}"]`),
        'click',
        handler as EventListener,
      );
    }
  }

  /**
   * 绑定键盘快捷键
   */
  private _bindKeyboard(dom: DOMRefs): void {
    const root = dom.wrapper;
    if (!root) return;

    this._on(root, 'keydown', (e: Event) => {
      const ke = e as KeyboardEvent;
      switch (ke.key) {
        case ' ':
          ke.preventDefault();
          this._handlers['toggle-play']();
          break;
        case 'ArrowRight':
          ke.preventDefault();
          this._handlers['step-forward']();
          break;
        case 'ArrowLeft':
          ke.preventDefault();
          this._handlers['step-back']();
          break;
        case 'Home':
          ke.preventDefault();
          this._handlers['skip-to-start']();
          break;
        case 'End':
          ke.preventDefault();
          this._handlers['skip-to-end']();
          break;
        case 'r':
        case 'R':
          if (!ke.ctrlKey && !ke.metaKey) {
            ke.preventDefault();
            this._handlers['reset']();
          }
          break;
      }
    });
  }

  /**
   * 绑定进度条点击事件
   */
  private _bindProgress(dom: DOMRefs, stepsLength: () => number): void {
    const track = dom.progressTrack;
    if (!track) return;

    this._on(track, 'click', (e: Event) => {
      const me = e as MouseEvent;
      const rect = track.getBoundingClientRect();
      const pct = (me.clientX - rect.left) / rect.width;
      const idx = Math.round(pct * (stepsLength() - 1));
      this._handlers['jump-to'](idx);
    });
  }

  /**
   * 绑定速度滑块事件
   */
  private _bindSpeed(dom: DOMRefs): void {
    const slider = dom.speedSlider;
    const valEl = dom.speedVal;
    if (!slider) return;

    this._on(slider, 'input', (e: Event) => {
      const v = parseInt((e.target as HTMLInputElement).value, 10);
      const speed = Math.max(SPEED_RANGE.min, SPEED_RANGE.max - v * 100);
      if (valEl) valEl.textContent = v + 'x';
      this._handlers['set-speed'](speed);
    });
  }
}
