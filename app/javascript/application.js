// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

document.addEventListener("DOMContentLoaded", function () {
    const container = document.querySelector(".container-center");
    if (container) {
      container.classList.add("slide-up-active");
    }
  });