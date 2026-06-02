// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://mbtgraph.moonbit.dev',
	markdown: {
		// 启用 GitHub Flavored Markdown（支持表格、删除线、任务列表等）
		shikiConfig: {
			theme: 'github-dark',
			wrap: true,
		},
	},
	integrations: [
		// 注意：Starlight 0.39 与 @astrojs/mdx 有 astroExpressiveCode 集成冲突
		// 暂不启用 MDX 集成，改用 .md 文件 + Table 组件方案
		starlight({
			title: 'mbtgraph - MoonBit 图算法库',
			description: '生产级图算法库：8种存储 · 49个算法 · 6层Trait。为 MoonBit 生态系统提供专业级的图数据结构与算法解决方案。',
			// 暂时移除 logo 图片配置（避免 favicon 路径问题）
			// 后续可恢复: logo: { src: '/favicon.svg', replacesTitle: false },
			title: 'mbtgraph - MoonBit 图算法库',
			// 注意：Starlight 已内置 GFM 支持，无需额外配置 remark-gfm
			// 如果表格不显示，可能是格式问题而非插件问题
			// SEO 配置
			head: [
				// Favicon 配置（浏览器标签页图标）
				{ tag: 'link', attrs: { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' } },
				{ tag: 'link', attrs: { rel: 'apple-touch-icon', href: '/favicon.svg' } },

				// 预连接关键域名以提升性能
				{ tag: 'link', attrs: { rel: 'preconnect', href: 'https://fonts.googleapis.com' } },
				{ tag: 'link', attrs: { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' } },

				// 预加载字体文件
				{
					tag: 'link',
					attrs: {
						rel: 'preload',
						href: '/fonts/plus-jakarta-sans-variable.woff2',
						as: 'font',
						type: 'font/woff2',
						crossorigin: '',
					},
				},

				// Open Graph 标签（社交分享优化）
				{ tag: 'meta', attrs: { property: 'og:type', content: 'website' } },
				{ tag: 'meta', attrs: { property: 'og:locale', content: 'zh_CN' } },
				{ tag: 'meta', attrs: { property: 'og:site_name', content: 'mbtgraph' } },

				// Twitter Card 标签
				{ tag: 'meta', attrs: { name: 'twitter:card', content: 'summary_large_image' } },
				{ tag: 'meta', attrs: { name: 'twitter:creator', content: '@moonbitlang' } },

				// 结构化数据 - WebSite Schema
				{
					tag: 'script',
					attrs: {
						type: 'application/ld+json',
					},
					content: JSON.stringify({
						'@context': 'https://schema.org',
						'@type': 'WebSite',
						name: 'mbtgraph - MoonBit 图算法库',
						description: '生产级图算法库：8种存储 · 49个算法 · 6层Trait',
						url: 'https://mbtgraph.moonbit.dev',
						potentialAction: {
							'@type': 'SearchAction',
							target: 'https://mbtgraph.moonbit.dev/search?q={search_term_string}',
							'query-input': 'required name=search_term_string',
						},
					}),
				},

				// 主题色（移动端浏览器地址栏颜色）
				{ tag: 'meta', attrs: { name: 'theme-color', content: '#6366f1' } },
				{ tag: 'meta', attrs: { name: 'msapplication-TileColor', content: '#6366f1' } },

				// 返回顶部按钮脚本注入
				{
					tag: 'script',
					attrs: {},
					content: `
						document.addEventListener('DOMContentLoaded', function() {
							var backToTop = document.createElement('button');
							backToTop.className = 'back-to-top';
							backToTop.innerHTML = '↑';
							backToTop.setAttribute('aria-label', '返回顶部');
							document.body.appendChild(backToTop);

							window.addEventListener('scroll', function() {
								if (window.pageYOffset > 300) {
									backToTop.classList.add('visible');
								} else {
									backToTop.classList.remove('visible');
								}
							});

							backToTop.addEventListener('click', function() {
								window.scrollTo({ top: 0, behavior: 'smooth' });
							});
						});
					`,
				},
			],
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/moonbit/mbtgraph',
				},
			],
			sidebar: [
				{ label: '首页', link: '/' },
				{
					label: '入门指南',
					items: [
						{ label: '安装与环境配置', link: '/getting-started/installation' },
						{ label: '第一个图程序', link: '/getting-started/first-graph' },
						{ label: '核心概念速查', link: '/getting-started/concepts' },
					],
				},
				{
					label: '基础教程',
					badge: '重点',
					items: [
						{ label: '概述', link: '/core-concepts/index' },
						{
							label: '图的数据结构',
							items: [
								{ label: '节点与边的表示', link: '/core-concepts/data-types' },
								{ label: '6 层 Trait 详解', link: '/core-concepts/traits' },
								{ label: '错误处理机制', link: '/core-concepts/error-handling' },
							],
						},
						{
							label: '存储结构选型指南',
							items: [
								{ label: '8 种存储对比表', link: '/core-concepts/storage-guide' },
								{ label: '场景化选型决策树', link: '/core-concepts/storage-decision' },
								{ label: '性能基准测试', link: '/core-concepts/benchmarks' },
								{ label: '存储转换器使用', link: '/core-concepts/storage-converter' },
							],
						},
						{
							label: '图的构建与操作',
							items: [
								{ label: '创建节点和边', link: '/core-concepts/building-graphs' },
								{ label: '图的读写操作', link: '/core-concepts/graph-operations' },
								{ label: '序列化与反序列化', link: '/core-concepts/serialization' },
							],
						},
					],
				},
				{
					label: '算法原理与实践',
					badge: { text: '核心', variant: 'success' },
					collapsed: false,
					items: [
						{ label: '算法总览', link: '/algorithms/index' },
						{
							label: '图遍历算法',
							collapsed: false,
							items: [
								{
									label: '广度优先搜索 (BFS)',
									link: '/algorithms/traversal/bfs/index',
								},
								{
									label: '深度优先搜索 (DFS)',
									link: '/algorithms/traversal/dfs/index',
								},
								{
									label: '高级遍历技巧',
									link: '/algorithms/traversal/advanced/index',
								},
							],
						},
						{
							label: '最短路径算法',
							items: [
								{ label: 'Dijkstra 算法', link: '/algorithms/shortest-path/dijkstra/index' },
								{ label: 'Bellman-Ford 算法', link: '/algorithms/shortest-path/bellman-ford/index' },
								{ label: 'Floyd-Warshall 算法', link: '/algorithms/shortest-path/floyd-warshall/index' },
								{ label: 'A* 启发式搜索', link: '/algorithms/shortest-path/a-star/index' },
							],
						},
						{
					label: '最小生成树 (MST)',
					items: [
						{ label: 'Kruskal & Prim 对比详解', link: '/algorithms/mst/kruskal-prim/index' },
						{ label: 'Kruskal 算法 (独立版)', link: '/algorithms/mst/kruskal/index' },
						{ label: 'Prim 算法 (独立版)', link: '/algorithms/mst/prim/index' },
					],
				},
						{
							label: '连通性算法',
							items: [
								{ label: '连通分量 (CC)', link: '/algorithms/connectivity/connected-components/index' },
								{
									label: '强连通分量 (SCC)',
									items: [
										{ label: 'Tarjan 算法', link: '/algorithms/connectivity/scc/tarjan' },
										{ label: 'Kosaraju 算法', link: '/algorithms/connectivity/scc/kosaraju' },
									],
								},
								{ label: '割点与桥', link: '/algorithms/connectivity/articulation-points/index' },
							],
						},
						{
							label: '网络流算法',
							items: [
								{ label: '流网络基础概念', link: '/algorithms/flow/basics/index' },
								{
									label: '最大流问题',
									items: [
										{ label: 'Ford-Fulkerson 方法', link: '/algorithms/flow/max-flow/ford-fulkerson' },
										{ label: 'Edmonds-Karp 实现', link: '/algorithms/flow/max-flow/edmonds-karp' },
										{ label: 'Dinic 优化算法', link: '/algorithms/flow/max-flow/dinic' },
									],
								},
								{ label: '最小费用最大流', link: '/algorithms/flow/min-cost-max-flow/index' },
							],
						},
						{
							label: '图匹配算法',
							items: [
								{
									label: '二分图匹配',
									items: [
										{ label: '匈牙利算法', link: '/algorithms/matching/bipartite/hungarian' },
										{ label: 'Hopcroft-Karp 优化', link: '/algorithms/matching/bipartite/hopcroft-karp' },
									],
								},
								{ label: '一般图匹配', link: '/algorithms/matching/general/edmonds' },
							],
						},
						{ label: '图着色算法', link: '/algorithms/coloring/index' },
						{ label: '社区检测算法', link: '/algorithms/community/index' },
						{ label: '中心性指标', link: '/algorithms/centrality/index' },
						{ label: '其他重要算法', link: '/algorithms/other/index' },
					],
				},
				{
					label: '实战案例',
					items: [
						{
							label: '社交网络分析',
							items: [
								{ label: '构建关注关系图', link: '/use-cases/social-network/build-graph' },
								{ label: '关键人物识别', link: '/use-cases/social-network/influencers' },
								{ label: '社群发现', link: '/use-cases/social-network/community-detection' },
							],
						},
						{
							label: '推荐系统基础',
							items: [
								{ label: '用户-物品二分图', link: '/use-cases/recommendation-system/bipartite' },
								{ label: '协同过滤实现', link: '/use-cases/recommendation-system/collaborative-filtering' },
								{ label: '图嵌入入门', link: '/use-cases/recommendation-system/embedding' },
							],
						},
						{
							label: '知识图谱构建',
							items: [
								{ label: '实体关系抽取', link: '/use-cases/knowledge-graph/extraction' },
								{ label: '图谱查询与分析', link: '/use-cases/knowledge-graph/query' },
								{ label: '可视化展示', link: '/use-cases/knowledge-graph/visualization' },
							],
						},
					],
				},
				{
					label: 'API 参考',
					items: [
						{ label: 'Core 模块接口', link: '/api/core' },
						{ label: 'Storage 模块接口', link: '/api/storage' },
						{ label: '各算法模块 API', link: '/api/algorithms' },
						{ label: 'IO 模块接口', link: '/api/io' },
					],
				},
				{
					label: '贡献指南',
					items: [
						{ label: '开发环境搭建', link: '/contributing/setup' },
						{ label: '编码规范', link: '/contributing/coding-standards' },
						{ label: '测试规范', link: '/contributing/testing' },
						{ label: '文档更新流程', link: '/contributing/documentation' },
					],
				},
			],
			lastUpdated: true,
			editLink: {
				baseUrl: 'https://github.com/moonbit/mbtgraph/edit/main/site/',
			},
			// 自定义配置（暂时禁用 CSS 以排查问题）
			// customCss: ['/styles/global.css'],
		}),
	],
	// 性能优化配置
	build: {
		inlineStylesheets: 'auto', // 自动内联关键 CSS
	},
	// 图片处理配置（使用 Sharp 进行优化）
	image: {
		domains: [],
	},
	// 压缩配置
	vite: {
		css: {
			transformer: 'lightningcss', // 使用更快的 CSS 处理器
		},
		build: {
			cssMinify: true,
			minify: 'esbuild',
		},
	},
});
