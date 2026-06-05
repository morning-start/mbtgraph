/**
 * viz-renderer.ts — 图渲染适配层（Layer 1）
 *
 * 封装 Cytoscape API，提供类型安全的渲染原语。
 * 算法不再直接操作 cy 对象，通过此层间接渲染。
 *
 * 核心价值:
 *   - 消除 executeStep / rebuildTo 的 DRY 违反
 *   - 统一 animate / instant 两种模式
 *   - 隔离 Cytoscape API，未来可替换渲染库
 */

import type { Core, ElementSingular } from 'cytoscape';

// ── 类型定义 ──

/** 渲染模式 */
export type RenderMode = 'animate' | 'instant';

/** 节点视觉状态 */
export interface NodeStyle {
  backgroundColor: string;
  borderColor?: string;
  borderWidth?: number;
  width?: number;
  height?: number;
}

/** 边视觉状态 */
export interface EdgeStyle {
  lineColor: string;
  width?: number;
  opacity?: number;
  lineStyle?: 'solid' | 'dashed';
}

// ── 默认样式常量 ──

export const DEFAULT_NODE_STYLE: NodeStyle = {
  backgroundColor: '#374151',
  borderColor: '#4B5563',
  borderWidth: 2,
  width: 46,
  height: 46,
};

export const DEFAULT_EDGE_STYLE: EdgeStyle = {
  lineColor: '#6B7280',
  width: 2.5,
  opacity: 1,
  lineStyle: 'solid',
};

// ── Renderer 实现 ──

class VizRenderer {
  private cy: Core;

  constructor(cy: Core) {
    this.cy = cy;
  }

  /**
   * 设置单个节点样式
   * @param mode - 'animate' 带动画过渡, 'instant' 即时生效
   * @param duration - 动画时长(ms), 仅 animate 模式有效
   */
  setNode(nodeId: string, style: NodeStyle, mode: RenderMode, duration?: number): void {
    const ele = this.cy.getElementById(nodeId);
    if (!ele.length) return;

    const css: Record<string, string | number> = {
      'background-color': style.backgroundColor,
      ...(style.borderColor !== undefined && { 'border-color': style.borderColor }),
      ...(style.borderWidth !== undefined && { 'border-width': style.borderWidth }),
      ...(style.width !== undefined && { width: style.width }),
      ...(style.height !== undefined && { height: style.height }),
    };

    if (mode === 'animate') {
      ele.animate({ style: css }, { duration: duration ?? 200 });
    } else {
      ele.style(css);
    }
  }

  /**
   * 设置单条边样式
   * @param directed - 是否有向图（影响边选择器方向性）
   */
  setEdge(source: string, target: string, style: EdgeStyle, mode: RenderMode, directed?: boolean, duration?: number): void {
    const selector = directed
      ? `[source="${source}"][target="${target}"]`
      : `[source="${source}"][target="${target}"], [source="${target}"][target="${source}"]`;

    const ele = this.cy.edges(selector);
    if (!ele.length) return;

    const css: Record<string, string | number> = {
      'line-color': style.lineColor,
      'target-arrow-color': style.lineColor,
      'source-arrow-color': style.lineColor,
      ...(style.width !== undefined && { width: style.width }),
      ...(style.opacity !== undefined && { opacity: style.opacity }),
      ...(style.lineStyle === 'dashed' && { 'line-style': 'dashed' }),
      ...(style.lineStyle === 'solid' && { 'line-style': 'solid' }),
    };

    if (mode === 'animate') {
      ele.animate({ style: css }, { duration: duration ?? 200 });
    } else {
      ele.style(css);
    }
  }

  /**
   * 批量设置节点样式（用于 finish 状态的函数式着色）
   */
  setNodesByFn(fn: (id: string) => NodeStyle | null, mode: RenderMode): void {
    const nodes = this.cy.nodes();
    const colorMapper = (ele: ElementSingular): string => {
      const s = fn(ele.data('id'));
      return s ? s.backgroundColor : DEFAULT_NODE_STYLE.backgroundColor;
    };
    if (mode === 'animate') {
      nodes.animate({ style: { 'background-color': colorMapper } }, { duration: 200 });
    } else {
      nodes.style({ 'background-color': colorMapper });
    }
  }

  /**
   * 重置所有元素到默认状态（用于 reset 操作）
   */
  resetAll(): void {
    this.cy.nodes().style({
      'background-color': DEFAULT_NODE_STYLE.backgroundColor,
      'border-color': DEFAULT_NODE_STYLE.borderColor,
      'border-width': DEFAULT_NODE_STYLE.borderWidth,
      'width': DEFAULT_NODE_STYLE.width,
      'height': DEFAULT_NODE_STYLE.height,
      'transition-duration': '0s',
    });

    this.cy.edges().style({
      'line-color': DEFAULT_EDGE_STYLE.lineColor,
      'target-arrow-color': DEFAULT_EDGE_STYLE.lineColor,
      'source-arrow-color': DEFAULT_EDGE_STYLE.lineColor,
      'width': DEFAULT_EDGE_STYLE.width,
      'opacity': DEFAULT_EDGE_STYLE.opacity,
      'line-style': DEFAULT_EDGE_STYLE.lineStyle,
      'transition-duration': '0s',
    });
  }
}

export default VizRenderer;
export type { VizRenderer as VizRendererType };
