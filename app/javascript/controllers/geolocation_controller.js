import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lat", "lng", "status"]

  detect() {
    if (!navigator.geolocation) {
      this.statusTarget.textContent = "Браузер не поддерживает геолокацию"
      this.statusTarget.classList.remove("hidden")
      return
    }

    this.statusTarget.textContent = "Определяем местоположение..."
    this.statusTarget.classList.remove("hidden")

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.latTarget.value = position.coords.latitude
        this.lngTarget.value = position.coords.longitude
        this.statusTarget.textContent = `✓ Местоположение определено (${position.coords.latitude.toFixed(4)}, ${position.coords.longitude.toFixed(4)})`
      },
      () => {
        this.statusTarget.textContent = "Не удалось определить — введите район вручную"
      }
    )
  }
}
