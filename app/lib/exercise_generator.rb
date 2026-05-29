require "http"
require "json"

# Generates listening and reading comprehension exercises via the Anthropic API.
# Results are never stored in the DB — callers cache them in the Rails session.
class ExerciseGenerator
  API_URL = "https://api.anthropic.com/v1/messages"
  MODEL   = "claude-sonnet-4-6"

  def initialize(user, language)
    @user     = user
    @language = language
  end

  # Returns:
  # { "transcript" => "Klaus: ...\nMaria: ...",
  #   "questions"  => [{ "question" => "...", "options" => [...], "correct_index" => 0 }, ...] }
  def listening
    parse_json(call_api(listening_prompt))
  end

  # Returns:
  # { "passage"   => "...",
  #   "questions" => [{ "question" => "...", "options" => [...], "correct_index" => 0 }, ...] }
  def reading
    parse_json(call_api(reading_prompt))
  end

  private

  def call_api(prompt)
    response = HTTP
      .headers(
        "x-api-key"         => ENV.fetch("ANTHROPIC_API_KEY"),
        "anthropic-version" => "2023-06-01",
        "content-type"      => "application/json"
      )
      .post(API_URL, json: {
        model:      MODEL,
        max_tokens: 1200,
        messages:   [{ "role" => "user", "content" => prompt }]
      })

    JSON.parse(response.body.to_s).dig("content", 0, "text")
  end

  def parse_json(text)
    clean = text.gsub(/```(?:json)?\n?/, "").strip
    JSON.parse(clean)
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

  def listening_prompt
    <<~PROMPT
      You are a German language exercise generator for absolute beginners.

      The student's COMPLETE German vocabulary (they know NO other German words):
      #{vocab_list}

      Create a realistic 3–4 line dialogue between two people named Klaus and Maria.
      Use ONLY vocabulary from the list above; natural conjugation and declension is fine.
      Format every line as "Klaus: text" or "Maria: text" on its own line.

      Then write exactly 3 multiple-choice comprehension questions in English about the dialogue.

      Return ONLY a JSON object with these exact keys — no other text, no markdown fences:
      {
        "transcript": "Klaus: ...\nMaria: ...\nKlaus: ...\nMaria: ...",
        "questions": [
          { "question": "...", "options": ["A...", "B...", "C...", "D..."], "correct_index": 0 },
          { "question": "...", "options": ["A...", "B...", "C...", "D..."], "correct_index": 1 },
          { "question": "...", "options": ["A...", "B...", "C...", "D..."], "correct_index": 2 }
        ]
      }
    PROMPT
  end

  def reading_prompt
    <<~PROMPT
      You are a German language exercise generator for absolute beginners.

      The student's COMPLETE German vocabulary (they know NO other German words):
      #{vocab_list}

      Write a short passage of 4–6 German sentences forming a simple narrative or description.
      Use ONLY vocabulary from the list above; natural conjugation and declension is fine.

      Then write exactly 3 multiple-choice comprehension questions in English about the passage.

      Return ONLY a JSON object with these exact keys — no other text, no markdown fences:
      {
        "passage": "...",
        "questions": [
          { "question": "...", "options": ["A...", "B...", "C...", "D..."], "correct_index": 0 },
          { "question": "...", "options": ["A...", "B...", "C...", "D..."], "correct_index": 1 },
          { "question": "...", "options": ["A...", "B...", "C...", "D..."], "correct_index": 2 }
        ]
      }
    PROMPT
  end
end
