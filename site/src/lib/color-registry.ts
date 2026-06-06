/**
 * color-registry.ts — 全局颜色注册表
 *
 * 三层架构 Layer 0: 语义 key → 固定颜色值（单一数据源）
 *
 * 使用方式:
 *   - 页面通过 legendKeys 声明本算法需要的颜色
 *   - 引擎从注册表过滤 + 自动生成图例
 *   - 算法通过 colors 参数接收过滤后的映射
 */

// ── 颜色条目类型 ──

export interface ColorEntry {
  /** CSS 颜色值 */
  value: string;
  /** 图例显示文本 */
  label: string;
  /** 图例样式: dot(圆点) 或 bar(横条) */
  type?: 'dot' | 'bar';
}

// ── 注册表定义 ──

export const ColorRegistry = {
  /** 节点状态 */
  node: {
    start:     { value: '#B45309', label: '起点' },
    default:   { value: '#374151', label: '未访问' },
    active:    { value: '#F97316', label: '处理中' },
    visited:   { value: '#22C55E', label: '已完成' },
    relaxed:   { value: '#FBBF24', label: '松弛成功' },
    ready:     { value: '#8B5CF6', label: '就绪' },
    sorted:    { value: '#06B6D4', label: '已排序' },
    cycle:     { value: '#EF4444', label: '环节点' },
  } as const satisfies Record<string, ColorEntry>,

  /** 边状态 */
  edge: {
    default:   { value: '#6B7280', label: '默认边' },
    active:    { value: '#EF4444', label: '活跃边', type: 'bar' as const },
    tree:      { value: '#3B82F6', label: '树边', type: 'bar' as const },
    back:      { value: '#A855F7', label: '回边', type: 'bar' as const },
    mst:       { value: '#10B981', label: 'MST 边' },
    rejected:  { value: '#94A3B8', label: '拒绝边', type: 'bar' as const },
  } as const satisfies Record<string, ColorEntry>,
} as const;

// ── Key 类型 ──

export type NodeColorKey = keyof typeof ColorRegistry.node;
export type EdgeColorKey = keyof typeof ColorRegistry.edge;
export type ColorKey = NodeColorKey | EdgeColorKey;

/** 图例选择器：算法声明自己需要哪些颜色 */
export interface LegendSelector {
  domain: 'node' | 'edge';
  key: string;
}

// ── 查询函数 ──

/**
 * 从注册表中按 selectors 过滤，生成图例数据（给 VizLayout 渲染用）
 */
export function resolveLegendItems(selectors: LegendSelector[]): Array<{
  color: string;
  label: string;
  type?: 'dot' | 'bar';
}> {
  return selectors.map(({ domain, key }) => {
    const entry = (ColorRegistry[domain] as Record<string, ColorEntry>)[key];
    if (!entry) return { color: '#94A3B8', label: key, type: 'dot' };
    return {
      color: entry.value,
      label: entry.label,
      type: entry.type ?? 'dot',
    };
  });
}

/**
 * 从注册表中提取颜色映射（给算法 renderStep 用）
 * 返回 { start: {value:'#B45309',label:'起点'}, ... }
 */
export function resolveColors(selectors: LegendSelector[]): Record<string, ColorEntry> {
  const map: Record<string, ColorEntry> = {};
  for (const { domain, key } of selectors) {
    const entry = (ColorRegistry[domain] as Record<string, ColorEntry>)[key];
    if (entry) {
      // 使用短键名（向后兼容）
      map[key] = entry;
      // 使用领域前缀键名（避免 node.active vs edge.active 冲突）
      map[`${domain}_${key}`] = entry;
    }
  }
  return map;
}

/** 颜色映射的类型别名（算法文件中使用） */
export type ColorMap = Record<string, ColorEntry>;

// ── 颜色工具函数 ──

/**
 * 加深颜色值，用于生成 border-color 等辅助色
 * 取 RGB 各分量 * 0.75
 */
export function darken(hex: string): string {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `#${Math.round(r * 0.75).toString(16).padStart(2, '0')}${Math.round(g * 0.75).toString(16).padStart(2, '0')}${Math.round(b * 0.75).toString(16).padStart(2, '0')}`;
}
