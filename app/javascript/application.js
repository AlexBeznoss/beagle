// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.startClerk = async () => {
  try {
    await window.Clerk.load();
  } catch(e) {
    console.error('Clerk: ', err);
  }
}
