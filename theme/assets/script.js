document.querySelectorAll('.add-cart').forEach(btn => {
  btn.addEventListener('click', (e) => {
    const product = e.target.closest('.product');
    const img = product.querySelector('img');
    const clone = img.cloneNode(true);
    clone.style.position = 'fixed';
    clone.style.top = img.getBoundingClientRect().top + 'px';
    clone.style.left = img.getBoundingClientRect().left + 'px';
    clone.style.width = img.offsetWidth + 'px';
    clone.style.height = img.offsetHeight + 'px';
    clone.style.transition = 'all 1s ease';
    document.body.appendChild(clone);
    setTimeout(() => {
      clone.style.transform = 'translate(300px,-600px) scale(0.1)';
      clone.style.opacity = '0';
    }, 50);
    setTimeout(() => clone.remove(), 1050);
  });
});