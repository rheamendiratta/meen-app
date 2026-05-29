import { Controller } from "@hotwired/stimulus"

// Single-voice TTS (word pronunciation, single-speaker text).
// For multi-speaker dialogue use the dialogue value.
export default class extends Controller {
  static targets = ["button"]
  static values  = { text: String, dialogue: Boolean }

  connect() {
    if (!window.speechSynthesis) {
      if (this.hasButtonTarget) {
        this.buttonTarget.disabled = true
        this.buttonTarget.title = "Text-to-speech not supported in this browser"
      }
    }
  }

  speak() {
    if (!window.speechSynthesis) return
    window.speechSynthesis.cancel()

    if (this.dialogueValue) {
      this.speakDialogue()
    } else {
      this.speakSingle(this.textValue, 1.0)
    }
  }

  // ── Single utterance (word/phrase pronunciation) ──────────────────────────

  speakSingle(text, pitch = 1.0) {
    const u = new SpeechSynthesisUtterance(text)
    u.lang  = "de-DE"
    u.rate  = 0.82
    u.pitch = pitch

    if (this.hasButtonTarget) {
      const btn = this.buttonTarget
      const original = btn.innerHTML
      u.onstart = () => { btn.innerHTML = "🔊…" }
      u.onend   = () => { btn.innerHTML = original }
      u.onerror = () => { btn.innerHTML = original }
    }

    window.speechSynthesis.speak(u)
  }

  // ── Multi-speaker dialogue (listening exercise) ───────────────────────────
  // Parses "SpeakerName: text" lines and alternates pitch per speaker.

  speakDialogue() {
    const lines = this.textValue
      .split("\n")
      .map(l => l.trim())
      .filter(l => l.length > 0)

    // Map speakers to pitches; first speaker slightly lower, second higher.
    const speakerPitch = {}
    const pitches = [0.85, 1.2]
    let pitchIdx = 0

    const parts = lines.map(line => {
      const m = line.match(/^([^:]+):\s*(.+)$/)
      if (!m) return { text: line, pitch: 1.0 }

      const speaker = m[1].trim()
      const text    = m[2].trim()
      if (!(speaker in speakerPitch)) {
        speakerPitch[speaker] = pitches[pitchIdx % pitches.length]
        pitchIdx++
      }
      return { text, pitch: speakerPitch[speaker] }
    })

    this.speakQueue(parts, 0)
  }

  speakQueue(parts, index) {
    if (index >= parts.length) {
      if (this.hasButtonTarget) {
        this.buttonTarget.innerHTML = '<span style="font-size:1.3rem">🔊</span> <span>Listen again</span>'
      }
      return
    }

    const { text, pitch } = parts[index]
    const u = new SpeechSynthesisUtterance(text)
    u.lang  = "de-DE"
    u.rate  = 0.88
    u.pitch = pitch

    u.onend   = () => this.speakQueue(parts, index + 1)
    u.onerror = () => this.speakQueue(parts, index + 1)

    window.speechSynthesis.speak(u)
  }
}
