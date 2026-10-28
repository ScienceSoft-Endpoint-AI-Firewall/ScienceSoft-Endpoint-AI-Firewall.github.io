/* Thin reading-progress bar under the header. */
(function () {
  var bar = document.createElement("div");
  bar.className = "read-progress";
  document.body.appendChild(bar);
  function update() {
    var h = document.documentElement;
    var max = h.scrollHeight - h.clientHeight;
    bar.style.transform = "scaleX(" + (max > 0 ? Math.min(h.scrollTop / max, 1) : 0) + ")";
  }
  window.addEventListener("scroll", update, { passive: true });
  window.addEventListener("resize", update);
  update();
})();
