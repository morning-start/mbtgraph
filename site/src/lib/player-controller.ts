/**
 * player-controller.ts — 播放控制器
 *
 * 职责:
 *   - 管理播放状态（play/pause/stop）
 *   - 控制步骤前进/后退
 *   - 跳转到指定步骤
 *   - 定时器管理
 *
 * 设计原则:
 *   - 状态机模式：清晰的状态转换
 *   - 单一职责：只负责播放控制逻辑
 *   - 回调机制：通过回调通知外部状态变化
 */

// ── 类型定义 ──

/** 播放器状态 */
export interface PlayerState {
  currentIdx: number;
  isPlaying: boolean;
  isFinished: boolean;
  speed: number;
  totalSteps: number;
}

/** 播放器回调 */
export interface PlayerCallbacks {
  /** 状态变化回调 */
  onStateChange: (state: PlayerState) => void;
  /** 执行步骤回调 */
  onExecuteStep: (idx: number, animate: boolean) => void;
  /** 重建到指定步骤回调 */
  onRebuildTo: (idx: number) => void;
  /** 重置可视化回调 */
  onResetVisuals: () => void;
}

// ── 常量 ──

const ANIMATION = {
  defaultSpeed: 500,
} as const;

// ── PlayerController 实现 ──

export class PlayerController {
  private _state: PlayerState = {
    currentIdx: -1,
    isPlaying: false,
    isFinished: false,
    speed: ANIMATION.defaultSpeed,
    totalSteps: 0,
  };

  private _timerId: ReturnType<typeof setTimeout> | null = null;
  private _callbacks: PlayerCallbacks;

  constructor(callbacks: PlayerCallbacks) {
    this._callbacks = callbacks;
  }

  // ── 状态查询 ──

  getState(): PlayerState {
    return { ...this._state };
  }

  // ── 初始化 ──

  /**
   * 初始化播放器
   */
  init(totalSteps: number, speed: number = ANIMATION.defaultSpeed): void {
    this._state.totalSteps = totalSteps;
    this._state.speed = speed;
    this._state.currentIdx = -1;
    this._state.isPlaying = false;
    this._state.isFinished = false;
  }

  /**
   * 销毁播放器，清理定时器
   */
  destroy(): void {
    this._stopTimer();
    this._state.currentIdx = -1;
    this._state.isPlaying = false;
    this._state.isFinished = false;
  }

  // ── 播放控制 ──

  /**
   * 切换播放/暂停
   */
  togglePlay(): void {
    if (this._state.isFinished) {
      this.reset();
      this.play();
    } else {
      this._state.isPlaying ? this.pause() : this.play();
    }
  }

  /**
   * 开始播放
   */
  play(): void {
    if (this._state.currentIdx >= this._state.totalSteps - 1) {
      this.jumpTo(0);
    }
    this._state.isFinished = false;
    this._state.isPlaying = true;
    this._notifyStateChange();
    this._tick();
  }

  /**
   * 暂停播放
   */
  pause(): void {
    this._state.isPlaying = false;
    this._stopTimer();
    this._notifyStateChange();
  }

  /**
   * 前进一步
   */
  stepForward(): void {
    if (this._state.currentIdx < this._state.totalSteps - 1) {
      this._state.isFinished = false;
      this._state.currentIdx++;
      this._callbacks.onExecuteStep(this._state.currentIdx, true);
      this._notifyStateChange();
    }
  }

  /**
   * 后退一步
   */
  stepBack(): void {
    if (this._state.currentIdx > 0) {
      this._state.isFinished = false;
      this._state.currentIdx--;
      this._callbacks.onRebuildTo(this._state.currentIdx);
      this._notifyStateChange();
    }
  }

  /**
   * 跳到开头
   */
  skipToStart(): void {
    this.pause();
    this.jumpTo(0);
  }

  /**
   * 跳到末尾
   */
  skipToEnd(): void {
    this.pause();
    this._state.isFinished = true;
    this.jumpTo(this._state.totalSteps - 1);
  }

  /**
   * 跳转到指定步骤
   */
  jumpTo(idx: number): void {
    idx = Math.max(0, Math.min(idx, this._state.totalSteps - 1));
    this._state.currentIdx = idx;
    this._callbacks.onRebuildTo(idx);
    this._notifyStateChange();
  }

  /**
   * 重置播放器
   */
  reset(): void {
    this.pause();
    this._state.isFinished = false;
    this._state.currentIdx = -1;
    this._callbacks.onResetVisuals();
    this._notifyStateChange();
  }

  /**
   * 设置播放速度
   */
  setSpeed(speed: number): void {
    this._state.speed = speed;
  }

  // ── 内部方法 ──

  /**
   * 定时器 tick
   */
  private _tick(): void {
    if (!this._state.isPlaying) return;

    if (this._state.currentIdx < this._state.totalSteps - 1) {
      this.stepForward();
      this._timerId = setTimeout(() => this._tick(), this._state.speed);
    } else {
      this.pause();
      this._state.isFinished = true;
      this._notifyStateChange();
    }
  }

  /**
   * 停止定时器
   */
  private _stopTimer(): void {
    if (this._timerId) {
      clearTimeout(this._timerId);
      this._timerId = null;
    }
  }

  /**
   * 通知状态变化
   */
  private _notifyStateChange(): void {
    this._callbacks.onStateChange(this.getState());
  }
}
