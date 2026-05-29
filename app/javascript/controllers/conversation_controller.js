import { Controller } from "@hotwired/stimulus"

// Handles the speaking exercise chat:
// - fetch-based message exchange (no page reload)
// - microphone input via SpeechRecognition
// - optional TTS output for Greta's German sentence
export default class extends Controller {
  static targets = ["messages", "input", "sendBtn", "micBtn", "outputBtn", "doneBtn", "doneHint"]
  static values  = { exchangeUrl: String, exchangeCount: Number }

  connect() {
    this.speaking  = false
    this.ttsOn     = false
    this.recognition = null
    this.updateDoneVisibility()
    this.scrollToBottom()
  }

  // ── Send message via fetch ────────────────────────────────────────────────

  async send(event) {
    event.preventDefault()
    const message = this.inputTarget.value.trim()
    if (!message || this.sendBtnTarget.disabled) return

    this.inputTarget.value = ""
    this.sendBtnTarget.disabled = true
    this.appendMessage("user", message)
    this.scrollToBottom()

    try {
      const res = await fetch(this.exchangeUrlValue, {
        method: "POST",
        headers: {
          "Content-Type":  "application/json",
          "Accept":        "application/json",
          "X-CSRF-Token":  document.querySelector("meta[name='csrf-token']")?.content
        },
        body: JSON.stringify({ message })
      })

      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const data = await res.json()

      this.exchangeCountValue = data.exchange_count
      this.appendMessage("assistant", data.greta_reply)
      this.scrollToBottom()
      this.updateDoneVisibility()

      if (this.ttsOn) this.speakGerman(data.greta_reply)
    } catch (err) {
      console.error("Chat error:", err)
    } finally {
      this.sendBtnTarget.disabled = false
      this.inputTarget.focus()
    }
  }

  // ── Microphone ────────────────────────────────────────────────────────────

  toggleMic() {
    if (this.speaking) {
      this.recognition?.stop()
      return
    }

    const SR = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SR) {
      this.micBtnTarget.textContent = "🎤 (unsupported)"
      return
    }

    this.recognition = new SR()
    this.recognition.lang = "de-DE"
    this.recognition.interimResults = false
    this.recognition.maxAlternatives = 1

    this.recognition.onstart = () => {
      this.speaking = true
      this.micBtnTarget.innerHTML = "🔴 Listening…"
      this.micBtnTarget.style.background = "var(--meen-danger)"
    }

    this.recognition.onresult = (e) => {
      this.inputTarget.value = e.results[0][0].transcript
    }

    this.recognition.onend = () => {
      this.speaking = false
      this.micBtnTarget.innerHTML = "🎤"
      this.micBtnTarget.style.background = "var(--meen-haze)"
    }

    this.recognition.onerror = () => {
      this.speaking = false
      this.micBtnTarget.innerHTML = "🎤"
      this.micBtnTarget.style.background = "var(--meen-haze)"
    }

    this.recognition.start()
  }

  // ── TTS toggle ────────────────────────────────────────────────────────────

  toggleOutput() {
    this.ttsOn = !this.ttsOn
    this.outputBtnTarget.innerHTML = this.ttsOn ? "🔊 On" : "🔇 Off"
    this.outputBtnTarget.style.background = this.ttsOn
      ? "var(--meen-teal)"
      : "var(--meen-haze)"
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  speakGerman(text) {
    const m = text.match(/\*\*German:\*\*\s*(.+?)(?:\n|$)/i)
    const speech = m ? m[1].replace(/\*/g, "") : ""
    if (!speech) return

    window.speechSynthesis.cancel()
    const u = new SpeechSynthesisUtterance(speech)
    u.lang  = "de-DE"
    u.rate  = 0.85
    u.pitch = 1.05
    window.speechSynthesis.speak(u)
  }

  appendMessage(role, content) {
    const isGreta = role === "assistant"
    const wrapper = document.createElement("div")
    wrapper.className = `d-flex ${isGreta ? "align-items-start" : "align-items-end flex-row-reverse"} gap-3 mb-3`

    if (isGreta) {
      wrapper.innerHTML = `
        <div class="greta-avatar">🦊</div>
        <div class="chat-bubble chat-bubble-greta">
          ${this.formatGreta(content)}
        </div>
      `
    } else {
      wrapper.innerHTML = `
        <div class="chat-bubble chat-bubble-user">
          <p class="mb-0">${this.esc(content)}</p>
        </div>
      `
    }
    this.messagesTarget.appendChild(wrapper)
  }

  formatGreta(text) {
    const germanMatch  = text.match(/\*\*German:\*\*\s*(.+?)(?:\n|$)/i)
    const englishMatch = text.match(/\*\*English:\*\*\s*(.+?)(?:\n|$)/i)
    const coaching = text
      .replace(/\*\*(?:German|English):\*\*\s*.+?(?:\n|$)/gi, "")
      .trim()

    let html = ""
    if (germanMatch)  html += `<p class="greta-german">${this.esc(germanMatch[1].trim())}</p>`
    if (englishMatch) html += `<p class="greta-english">${this.esc(englishMatch[1].trim())}</p>`
    coaching.split("\n").filter(l => l.trim()).forEach(line => {
      const bolded = this.esc(line).replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
      html += `<p class="greta-coaching">${bolded}</p>`
    })
    return html || this.esc(text)
  }

  esc(text) {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
  }

  updateDoneVisibility() {
    const ready = this.exchangeCountValue >= 5
    if (this.hasDoneBtnTarget)  this.doneBtnTarget.classList.toggle("d-none", !ready)
    if (this.hasDoneHintTarget) this.doneHintTarget.classList.toggle("d-none", ready)
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
