import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input", "model"]

  connect() {
    this.conversationMessages = []
  }

  async send(event) {
    event.preventDefault()

    const message = this.inputTarget.value.trim()
    if (!message) return

    const model = this.modelTarget.value
    if (!model) {
      alert("Please select a model first.")
      return
    }

    // Add user message to UI
    this.appendMessage("user", message)
    this.inputTarget.value = ""

    // Track conversation
    this.conversationMessages.push({ role: "user", content: message })

    // Send to server
    try {
      const response = await fetch("/inference/chat", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
        body: JSON.stringify({
          model: model,
          messages: this.conversationMessages,
        }),
      })

      const data = await response.json()

      if (data.error) {
        this.appendMessage("system", `Error: ${data.error}`)
      } else {
        const content = data.choices?.[0]?.message?.content || "No response"
        this.appendMessage("assistant", content)
        this.conversationMessages.push({ role: "assistant", content: content })
      }
    } catch (error) {
      this.appendMessage("system", `Error: ${error.message}`)
    }
  }

  appendMessage(role, content) {
    // Clear placeholder
    const placeholder = this.messagesTarget.querySelector("p.text-gray-400")
    if (placeholder) placeholder.remove()

    const wrapper = document.createElement("div")
    wrapper.className = `flex gap-3 ${role === "user" ? "flex-row-reverse" : ""}`

    const avatar = document.createElement("div")
    const colors = { user: "bg-blue-500", assistant: "bg-green-500", system: "bg-gray-500" }
    avatar.className = `shrink-0 w-8 h-8 rounded-full flex items-center justify-center text-xs font-medium text-white ${colors[role] || "bg-gray-500"}`
    avatar.textContent = role[0].toUpperCase()

    const bubble = document.createElement("div")
    bubble.className = `max-w-xl rounded-lg p-3 text-sm ${role === "user" ? "bg-blue-50" : "bg-gray-50"}`
    bubble.textContent = content

    wrapper.appendChild(avatar)
    wrapper.appendChild(bubble)
    this.messagesTarget.appendChild(wrapper)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
}
