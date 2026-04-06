import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { podId: Number, active: Boolean }
  static targets = [
    "messageList", "form", "input", "submit", "counter",
    "spinner", "history", "scrollTrigger", "paginationSpinner"
  ]

  connect() {
    this.loading = false
    this.channel = createConsumer().subscriptions.create(
      { channel: "PodChannel", pod_id: this.podIdValue },
      {
        received: (data) => this.handleBroadcast(data),
        rejected: () => this.markAllPendingFailed()
      }
    )
    this.connectScrollObserver()
  }

  disconnect() {
    this.channel?.unsubscribe()
    this.observer?.disconnect()
  }

  // 9.1 — Broadcast receive
  handleBroadcast(data) {
    const currentUserId = document.querySelector('meta[name="current-user-id"]')?.content
    if (String(data.sender_id) === String(currentUserId)) return

    this.messageListTarget.insertAdjacentHTML("beforeend", data.html)
    this.scrollToBottom()
  }

  // 9.2 — Счётчик символов
  updateCounter() {
    const len = this.inputTarget.value.length
    this.counterTarget.textContent = `${len} / 1000`
    const over = len > 1000
    this.counterTarget.classList.toggle("text-red-500", over)
    this.counterTarget.classList.toggle("text-gray-400", !over)
    this.submitTarget.disabled = len === 0 || over
  }

  // 9.3 — Enter/Shift+Enter
  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.send(event)
    }
  }

  // 9.4 — Optimistic update + fetch
  async send(event) {
    event.preventDefault()
    const body = this.inputTarget.value.trim()
    if (!body || body.length > 1000) return

    const pendingId = `pending-${Date.now()}`
    this.appendOptimistic(pendingId, body)
    this.inputTarget.value = ""
    this.updateCounter()

    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), 10_000)

    try {
      const response = await fetch(`/pods/${this.podIdValue}/messages`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ message: { body } }),
        signal: controller.signal
      })
      clearTimeout(timeout)

      if (response.ok) {
        const data = await response.json()
        const pending = document.getElementById(pendingId)
        if (pending && data.html) {
          pending.outerHTML = data.html
        }
      } else if (response.status === 403 || response.status === 422) {
        const data = await response.json()
        this.markFailed(pendingId, data.error, false)
      } else {
        this.markFailed(pendingId, null, true)
      }
    } catch {
      clearTimeout(timeout)
      this.markFailed(pendingId, null, true)
    }
  }

  appendOptimistic(pendingId, body) {
    const html = `
      <div id="${pendingId}" class="message--pending flex flex-col gap-1 px-4 py-2 opacity-50">
        <p class="text-sm text-gray-700 whitespace-pre-wrap break-words">${this.escapeHtml(body)}</p>
      </div>
    `
    this.messageListTarget.insertAdjacentHTML("beforeend", html)
    this.scrollToBottom()
  }

  markFailed(pendingId, errorText, showRetry) {
    const el = document.getElementById(pendingId)
    if (!el) return
    el.classList.add("text-red-500")
    el.classList.remove("opacity-50")
    if (errorText) {
      el.insertAdjacentHTML("beforeend", `<span class="text-xs text-red-400">${this.escapeHtml(errorText)}</span>`)
    }
    if (showRetry) {
      el.insertAdjacentHTML("beforeend", `<span class="text-xs text-red-400">Ошибка отправки</span>`)
    }
  }

  markAllPendingFailed() {
    this.messageListTarget.querySelectorAll(".message--pending").forEach(el => {
      el.classList.add("text-red-500")
      el.classList.remove("opacity-50")
    })
  }

  // 9.5 — Infinite scroll
  connectScrollObserver() {
    if (!this.hasScrollTriggerTarget) return
    this.observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !this.loading) this.loadMore()
      },
      { threshold: 0.1 }
    )
    this.observer.observe(this.scrollTriggerTarget)
  }

  async loadMore() {
    this.loading = true
    this.paginationSpinnerTarget.classList.remove("hidden")
    const oldestId = this.historyTarget.querySelector("[id^='message-']")?.id.replace("message-", "")

    try {
      const response = await fetch(`/pods/${this.podIdValue}/chat?before_id=${oldestId}`, {
        headers: { "Accept": "text/html" }
      })
      if (!response.ok) throw new Error()
      const html = await response.text()
      const prevHeight = this.messageListTarget.scrollHeight
      this.historyTarget.insertAdjacentHTML("afterbegin", html)
      this.messageListTarget.scrollTop += this.messageListTarget.scrollHeight - prevHeight
    } catch {
      // показать inline-сообщение об ошибке
    } finally {
      this.paginationSpinnerTarget.classList.add("hidden")
      this.loading = false
    }
  }

  scrollToBottom() {
    this.messageListTarget.scrollTop = this.messageListTarget.scrollHeight
  }

  escapeHtml(str) {
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }
}
