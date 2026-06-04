/**
 * Cytoscape 依赖加载器
 * 加载顺序: 本地 vendor（有序）→ CDN 回退（有序）
 *
 * 关键: cytoscape-dagre 依赖 dagre，必须串行加载
 */

var CytoscapeLoader = {
  loaded: false,
  loading: false,
  callbacks: [],

  load: function(onSuccess, onError) {
    var self = this;

    if (this.loaded) {
      onSuccess && onSuccess();
      return;
    }

    if (this.loading) {
      this.callbacks.push({ success: onSuccess, error: onError });
      return;
    }

    this.loading = true;
    this.callbacks.push({ success: onSuccess, error: onError });

    // 本地依赖路径（按依赖顺序排列）
    var localDeps = [
      '/visualizations/js/vendor/cytoscape.min.js',
      '/visualizations/js/vendor/dagre.min.js',
      '/visualizations/js/vendor/cytoscape-dagre.min.js'
    ];

    // CDN 回退依赖（按依赖顺序排列）
    var cdnDeps = [
      { url: 'https://cdn.jsdelivr.net/npm/cytoscape@3.30.2/dist/cytoscape.min.js' },
      { url: 'https://cdn.jsdelivr.net/npm/dagre@0.8.5/dist/dagre.min.js' },
      { url: 'https://cdn.jsdelivr.net/npm/cytoscape-dagre@2.5.0/cytoscape-dagre.min.js' }
    ];

    // 策略 1：尝试本地有序加载
    loadSequential(localDeps, function() {
      console.log('[CytoscapeLoader] Local deps loaded successfully');
      self._onComplete();
    }, function(err) {
      console.warn('[CytoscapeLoader] Local load failed:', err && err.message);
      // 策略 2：回退到 CDN 有序加载
      loadSequential(cdnDeps.map(function(d) { return d.url; }), function() {
        console.log('[CytoscapeLoader] CDN deps loaded successfully');
        self._onComplete();
      }, function(err2) {
        self._onError(err2 || new Error('Failed to load Cytoscape dependencies from all sources'));
      });
    });
  },

  _onComplete: function() {
    this.loaded = true;
    this.loading = false;
    var cbs = this.callbacks;
    this.callbacks = [];
    cbs.forEach(function(cb) {
      cb.success && cb.success();
    });
  },

  _onError: function(err) {
    this.loading = false;
    var cbs = this.callbacks;
    this.callbacks = [];
    cbs.forEach(function(cb) {
      cb.error && cb.error(err);
    });
  }
};

/**
 * 顺序加载脚本列表（前一个完成后才加载下一个）
 * 避免依赖项之间的竞态条件
 */
function loadSequential(urls, onComplete, onError) {
  var index = 0;

  function next() {
    if (index >= urls.length) {
      onComplete && onComplete();
      return;
    }

    var url = urls[index];
    index++;

    var script = document.createElement('script');
    script.src = url;
    script.onload = function() {
      next();
    };
    script.onerror = function() {
      onError && onError(new Error('Failed to load: ' + url));
    };
    document.head.appendChild(script);
  }

  next();
}
