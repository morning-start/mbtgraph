/**
 * Cytoscape 依赖加载器
 * 加载顺序: cytoscape → dagre → cytoscape-dagre
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

    var cdnIndex = 0;
    var cdns = [
      'https://cdn.jsdelivr.net/npm',
      'https://unpkg.com'
    ];

    var dependencies = [
      { name: 'cytoscape', version: '3.30.2', file: 'cytoscape.min.js' },
      { name: 'dagre', version: '0.8.5', file: 'dist/dagre.min.js' },
      { name: 'cytoscape-dagre', version: '2.5.0', file: 'cytoscape-dagre.min.js' }
    ];

    function tryLoadWithCdn() {
      if (cdnIndex >= cdns.length) {
        var allCallbacks = self.callbacks;
        self.callbacks = [];
        self.loading = false;
        allCallbacks.forEach(function(cb) {
          cb.error && cb.error(new Error('Failed to load Cytoscape dependencies from all CDNs'));
        });
        return;
      }

      var baseUrl = cdns[cdnIndex];
      loadDependencies(baseUrl, function() {
        self.loaded = true;
        self.loading = false;
        var allCallbacks = self.callbacks;
        self.callbacks = [];
        allCallbacks.forEach(function(cb) {
          cb.success && cb.success();
        });
      }, function() {
        cdnIndex++;
        tryLoadWithCdn();
      });
    }

    function loadDependencies(baseUrl, onComplete, onError) {
      var loadedCount = 0;
      var hasError = false;

      function checkComplete() {
        if (hasError) return;
        loadedCount++;
        if (loadedCount === dependencies.length) {
          onComplete && onComplete();
        }
      }

      dependencies.forEach(function(dep) {
        if (hasError) return;
        var script = document.createElement('script');
        script.src = baseUrl + '/' + dep.name + '@' + dep.version + '/' + dep.file;
        script.onload = checkComplete;
        script.onerror = function() {
          if (!hasError) {
            hasError = true;
            onError && onError();
          }
        };
        document.head.appendChild(script);
      });
    }

    tryLoadWithCdn();
  }
};
