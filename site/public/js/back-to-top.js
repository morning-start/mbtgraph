/**
 * back-to-top.js — 返回顶部按钮
 *
 * 创建悬浮在页面右下角的返回顶部按钮，滚动超过 300px 时显示。
 * 点击平滑滚动到页面顶部。
 *
 * @note CSS 样式定义在 src/styles/global.css (.back-to-top)
 */
(function () {
  'use strict';

  var backToTop = document.createElement('button');
  backToTop.className = 'back-to-top';
  backToTop.innerHTML = '↑';
  backToTop.setAttribute('aria-label', '返回顶部');
  document.body.appendChild(backToTop);

  var toggleVisibility = function () {
    if (window.pageYOffset > 300) {
      backToTop.classList.add('visible');
    } else {
      backToTop.classList.remove('visible');
    }
  };

  window.addEventListener('scroll', toggleVisibility, { passive: true });

  backToTop.addEventListener('click', function () {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });
})();