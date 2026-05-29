require "http"
require "json"

# Live AI conversation with Greta (German companion).
# Conversation history is passed in and out — never persisted to the DB.
# Caller stores history in the Rails session between requests.
class CompanionChat
  API_URL = "https://api.anthropic.com/v1/messages"
  MODEL   = "claude-sonnet-4-6"

  def initialize(user, language)
    @user     = user
    @language = language
    @companion = language.companion
  end

  # Returns Greta's reply string.
  # history is an array of { "role" => "user"/"assistant", "content" => "..." } hashes.
  # The user_message is appended before calling the API.
  def chat(user_message, history = [])
    messages = history + [{ "role" => "user", "content" => user_message }]
    call_api(messages)
  end

  # Greta's opening line — called once at the start of the speaking exercise.
  def opening
    call_api([{ "role" => "user", "content" => "[Start conversation]" }])
  end

  private

  def call_api(messages)
    response = HTTP
      .headers(
        "x-api-key"         => ENV.fetch("ANTHROPIC_API_KEY"),
        "anthropic-version" => "2023-06-01",
        "content-type"      => "application/json"
      )
      .post(API_URL, json: {
        model:      MODEL,
        max_tokens: 500,
        system:     system_prompt,
        messages:   messages
      })

    JSON.parse(response.body.to_s).dig("content", 0, "text")
  end

  def vocab_list
    @user.user_vocabularies
      .includes(word: :word_translations)
      .where(language: @language)
      .map { |uv|
        word        = uv.word
        translation = word.word_translations.find { |t| t.language_id == @user.base_language_id }
        label       = word.article ? "#{word.article} #{word.lemma}" : word.lemma
        translation ? "#{label} (#{translation.meaning})" : label
      }
      .join(", ")
  end

  def system_prompt
    <<~PROMPT
      You are #{@companion.name}, a warm and playful German tutor for a complete beginner.

      The student's COMPLETE known vocabulary — they know NO other German words:
      #{vocab_list}

      STRICT RULES:
      1. Every German word you use must come from the list above. Conjugating/declining naturally is fine (e.g. "Hund" → "den Hund").
      2. Keep German sentences to 3–8 words.
      3. Format EVERY response exactly like this (use these exact bold labels):

      **German:** [your German sentence]
      **English:** [exact translation]
      [1–2 sentences in English: correct the student's last message if needed, then a clear prompt for what to say next]

      4. Ask questions the student can realistically answer with known words.
      5. If the student uses an unknown German word, gently say so and suggest the right known alternative.
      6. Vary topics naturally: greetings, descriptions, simple actions, daily life — using only the known vocab.
      7. Be warm, patient, encouraging. Celebrate every correct response!
      8. If the user sends "[Start conversation]", greet the student warmly and ask a simple opening question.
    PROMPT
  end
end
