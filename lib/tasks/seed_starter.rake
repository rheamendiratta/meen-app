require "csv"

namespace :db do
  namespace :seed do
    desc "Seed starter curriculum (DE + FR) and German OpenSubtitles curriculum from de_enriched.csv / de_word_forms.csv"
    task starter: :environment do
      # ── Languages ───────────────────────────────────────────────────────────
      english = Language.find_or_create_by!(code: "en") { |l| l.name = "English"; l.is_learnable = false }
      german  = Language.find_or_create_by!(code: "de") { |l| l.name = "German";  l.is_learnable = true }
      french  = Language.find_or_create_by!(code: "fr") { |l| l.name = "French";  l.is_learnable = true }

      puts "Languages ready: EN, DE, FR"

      # ── Essentials themes (one per language) ────────────────────────────────
      de_essentials = Theme.find_or_create_by!(language: german, name: "essentials") { |t| t.display_order = 0 }
      fr_essentials = Theme.find_or_create_by!(language: french, name: "essentials") { |t| t.display_order = 0 }

      puts "Themes: essentials ready for DE and FR"

      # ── Word seeding helper ─────────────────────────────────────────────────
      # primary_form: override the form_text of the primary WordForm (default: lemma).
      # extra_forms:  array of { form_text:, morphology: } hashes for additional forms.
      seed_word = lambda do |language:, theme:, rank:, lemma:, word_type:, part_of_speech:,
                              translation:, notes: nil, primary_form: nil, extra_forms: []|
        word = Word.find_or_create_by!(language: language, lemma: lemma, frequency_rank: rank) do |w|
          w.word_type      = word_type
          w.part_of_speech = part_of_speech
          w.level          = "A1"
          w.theme          = theme
        end

        WordForm.find_or_create_by!(word: word, form_text: primary_form || lemma) do |f|
          f.morphology = "lemma"
          f.is_primary = true
        end

        extra_forms.each do |ef|
          WordForm.find_or_create_by!(word: word, form_text: ef[:form_text]) do |f|
            f.morphology = ef[:morphology]
            f.is_primary = false
          end
        end

        WordTranslation.find_or_create_by!(word: word, language: english) do |t|
          t.meaning = translation
          t.notes   = notes
        end
      end

      # ── German starter curriculum (ranks 1–51) ──────────────────────────────
      # Caveat 3: gehen/aller at rank 18; werden/devenir at rank 23/24.
      # Numbers expand ranks 24–33 (one row each).
      de_starter = [
        # Group 1 — Greetings & basics
        { rank: 1,  lemma: "Hallo",           word_type: "phrase", part_of_speech: "interjection", translation: "Hello" },
        { rank: 2,  lemma: "Tschüss",         word_type: "phrase", part_of_speech: "interjection", translation: "Goodbye" },
        { rank: 3,  lemma: "Bitte",           word_type: "phrase", part_of_speech: "interjection", translation: "Please" },
        { rank: 4,  lemma: "Danke",           word_type: "phrase", part_of_speech: "interjection", translation: "Thank you" },
        { rank: 5,  lemma: "ja",              word_type: "word",   part_of_speech: "adverb",       translation: "yes" },
        { rank: 6,  lemma: "nein",            word_type: "word",   part_of_speech: "adverb",       translation: "no" },
        { rank: 7,  lemma: "Entschuldigung",  word_type: "phrase", part_of_speech: "interjection", translation: "Excuse me" },
        { rank: 8,  lemma: "Es tut mir leid", word_type: "phrase", part_of_speech: "phrase",       translation: "I'm sorry" },
        # Group 2 — Pronouns (caveat 1: du/Sie on separate rows; sie plural = row 15)
        { rank: 9,  lemma: "ich", word_type: "word", part_of_speech: "pronoun", translation: "I" },
        { rank: 10, lemma: "du",  word_type: "word", part_of_speech: "pronoun", translation: "you (informal)" },
        { rank: 11, lemma: "Sie", word_type: "word", part_of_speech: "pronoun", translation: "you (formal)" },
        { rank: 12, lemma: "er",  word_type: "word", part_of_speech: "pronoun", translation: "he" },
        { rank: 13, lemma: "sie", word_type: "word", part_of_speech: "pronoun", translation: "she",  notes: "feminine singular" },
        { rank: 14, lemma: "wir", word_type: "word", part_of_speech: "pronoun", translation: "we" },
        { rank: 15, lemma: "sie", word_type: "word", part_of_speech: "pronoun", translation: "they", notes: "plural" },
        # Group 3 — Core verbs (caveat 3: gehen at 18, werden at 23)
        { rank: 16, lemma: "sein",   word_type: "word", part_of_speech: "verb", translation: "to be" },
        { rank: 17, lemma: "haben",  word_type: "word", part_of_speech: "verb", translation: "to have" },
        { rank: 18, lemma: "gehen",  word_type: "word", part_of_speech: "verb", translation: "to go" },
        { rank: 19, lemma: "können", word_type: "word", part_of_speech: "verb", translation: "can / to be able to" },
        { rank: 20, lemma: "wollen", word_type: "word", part_of_speech: "verb", translation: "to want" },
        { rank: 21, lemma: "müssen", word_type: "word", part_of_speech: "verb", translation: "must / to have to" },
        { rank: 22, lemma: "machen", word_type: "word", part_of_speech: "verb", translation: "to do / to make" },
        { rank: 23, lemma: "werden", word_type: "word", part_of_speech: "verb", translation: "will / to become" },
        # Group 4 — Numbers 1–10 (caveat 2: one row each, ranks 24–33)
        { rank: 24, lemma: "eins",   word_type: "word", part_of_speech: "numeral", translation: "one" },
        { rank: 25, lemma: "zwei",   word_type: "word", part_of_speech: "numeral", translation: "two" },
        { rank: 26, lemma: "drei",   word_type: "word", part_of_speech: "numeral", translation: "three" },
        { rank: 27, lemma: "vier",   word_type: "word", part_of_speech: "numeral", translation: "four" },
        { rank: 28, lemma: "fünf",   word_type: "word", part_of_speech: "numeral", translation: "five" },
        { rank: 29, lemma: "sechs",  word_type: "word", part_of_speech: "numeral", translation: "six" },
        { rank: 30, lemma: "sieben", word_type: "word", part_of_speech: "numeral", translation: "seven" },
        { rank: 31, lemma: "acht",   word_type: "word", part_of_speech: "numeral", translation: "eight" },
        { rank: 32, lemma: "neun",   word_type: "word", part_of_speech: "numeral", translation: "nine" },
        { rank: 33, lemma: "zehn",   word_type: "word", part_of_speech: "numeral", translation: "ten" },
        # Group 5 — Time words
        { rank: 34, lemma: "heute",  word_type: "word", part_of_speech: "adverb", translation: "today" },
        { rank: 35, lemma: "morgen", word_type: "word", part_of_speech: "adverb", translation: "tomorrow" },
        { rank: 36, lemma: "jetzt",  word_type: "word", part_of_speech: "adverb", translation: "now" },
        # Group 6 — Survival phrases
        { rank: 37, lemma: "Wo ist…?",              word_type: "phrase", part_of_speech: "phrase", translation: "Where is…?" },
        { rank: 38, lemma: "Ich verstehe nicht",     word_type: "phrase", part_of_speech: "phrase", translation: "I don't understand" },
        { rank: 39, lemma: "Sprechen Sie Englisch?", word_type: "phrase", part_of_speech: "phrase", translation: "Do you speak English?" },
        { rank: 40, lemma: "Wie viel kostet das?",   word_type: "phrase", part_of_speech: "phrase", translation: "How much does that cost?" },
        { rank: 41, lemma: "Ich hätte gern…",        word_type: "phrase", part_of_speech: "phrase", translation: "I would like…" },
        # Group 7 — Connectors & question words
        { rank: 42, lemma: "und",   word_type: "word", part_of_speech: "conjunction", translation: "and" },
        { rank: 43, lemma: "aber",  word_type: "word", part_of_speech: "conjunction", translation: "but" },
        { rank: 44, lemma: "oder",  word_type: "word", part_of_speech: "conjunction", translation: "or" },
        { rank: 45, lemma: "weil",  word_type: "word", part_of_speech: "conjunction", translation: "because" },
        { rank: 46, lemma: "was",   word_type: "word", part_of_speech: "pronoun",     translation: "what" },
        { rank: 47, lemma: "wo",    word_type: "word", part_of_speech: "adverb",      translation: "where" },
        { rank: 48, lemma: "wann",  word_type: "word", part_of_speech: "adverb",      translation: "when" },
        { rank: 49, lemma: "wie",   word_type: "word", part_of_speech: "adverb",      translation: "how" },
        { rank: 50, lemma: "wer",   word_type: "word", part_of_speech: "pronoun",     translation: "who" },
        { rank: 51, lemma: "warum", word_type: "word", part_of_speech: "adverb",      translation: "why" },
      ]

      de_starter.each { |attrs| seed_word.call(language: german, theme: de_essentials, **attrs) }
      puts "German starter: #{de_starter.size} words seeded (ranks 1–51)"

      # ── French starter curriculum (ranks 1–52) ──────────────────────────────
      # Caveat 1: ils/elles split into rows 15 and 16; all subsequent ranks shift +1.
      # Caveat 3: aller at 19, devenir at 24.
      # Numbers: ranks 25–34.
      fr_starter = [
        # Group 1 — Greetings & basics
        { rank: 1, lemma: "Bonjour",         word_type: "phrase", part_of_speech: "interjection", translation: "Hello" },
        { rank: 2, lemma: "Au revoir",        word_type: "phrase", part_of_speech: "interjection", translation: "Goodbye" },
        { rank: 3, lemma: "S'il vous plaît",  word_type: "phrase", part_of_speech: "interjection", translation: "Please" },
        { rank: 4, lemma: "Merci",            word_type: "phrase", part_of_speech: "interjection", translation: "Thank you" },
        { rank: 5, lemma: "oui",              word_type: "word",   part_of_speech: "adverb",       translation: "yes" },
        { rank: 6, lemma: "non",              word_type: "word",   part_of_speech: "adverb",       translation: "no" },
        { rank: 7, lemma: "Excusez-moi",     word_type: "phrase", part_of_speech: "interjection", translation: "Excuse me" },
        # Caveat 4: désolé(e) — lemma is the adjective stem; primary form is the full phrase.
        { rank: 8, lemma: "désolé",           word_type: "phrase", part_of_speech: "phrase",
          translation: "I'm sorry",
          notes:       "Feminine speaker: Je suis désolée",
          primary_form: "Je suis désolé",
          extra_forms:  [{ form_text: "Je suis désolée", morphology: "feminine" }] },
        # Group 2 — Pronouns (caveat 1: ils/elles as two rows at 15 and 16)
        { rank: 9,  lemma: "je",    word_type: "word", part_of_speech: "pronoun", translation: "I" },
        { rank: 10, lemma: "tu",    word_type: "word", part_of_speech: "pronoun", translation: "you (informal)" },
        { rank: 11, lemma: "vous",  word_type: "word", part_of_speech: "pronoun", translation: "you (formal/plural)" },
        { rank: 12, lemma: "il",    word_type: "word", part_of_speech: "pronoun", translation: "he" },
        { rank: 13, lemma: "elle",  word_type: "word", part_of_speech: "pronoun", translation: "she" },
        { rank: 14, lemma: "nous",  word_type: "word", part_of_speech: "pronoun", translation: "we" },
        { rank: 15, lemma: "ils",   word_type: "word", part_of_speech: "pronoun", translation: "they (masculine)" },
        { rank: 16, lemma: "elles", word_type: "word", part_of_speech: "pronoun", translation: "they (feminine)" },
        # Group 3 — Core verbs (shifted +1; caveat 3: aller at 19, devenir at 24)
        { rank: 17, lemma: "être",    word_type: "word", part_of_speech: "verb", translation: "to be" },
        { rank: 18, lemma: "avoir",   word_type: "word", part_of_speech: "verb", translation: "to have" },
        { rank: 19, lemma: "aller",   word_type: "word", part_of_speech: "verb", translation: "to go" },
        { rank: 20, lemma: "pouvoir", word_type: "word", part_of_speech: "verb", translation: "can / to be able to" },
        { rank: 21, lemma: "vouloir", word_type: "word", part_of_speech: "verb", translation: "to want" },
        { rank: 22, lemma: "devoir",  word_type: "word", part_of_speech: "verb", translation: "must / to have to" },
        { rank: 23, lemma: "faire",   word_type: "word", part_of_speech: "verb", translation: "to do / to make" },
        { rank: 24, lemma: "devenir", word_type: "word", part_of_speech: "verb", translation: "to become" },
        # Group 4 — Numbers 1–10 (ranks 25–34, caveat 2)
        { rank: 25, lemma: "un",     word_type: "word", part_of_speech: "numeral", translation: "one" },
        { rank: 26, lemma: "deux",   word_type: "word", part_of_speech: "numeral", translation: "two" },
        { rank: 27, lemma: "trois",  word_type: "word", part_of_speech: "numeral", translation: "three" },
        { rank: 28, lemma: "quatre", word_type: "word", part_of_speech: "numeral", translation: "four" },
        { rank: 29, lemma: "cinq",   word_type: "word", part_of_speech: "numeral", translation: "five" },
        { rank: 30, lemma: "six",    word_type: "word", part_of_speech: "numeral", translation: "six" },
        { rank: 31, lemma: "sept",   word_type: "word", part_of_speech: "numeral", translation: "seven" },
        { rank: 32, lemma: "huit",   word_type: "word", part_of_speech: "numeral", translation: "eight" },
        { rank: 33, lemma: "neuf",   word_type: "word", part_of_speech: "numeral", translation: "nine" },
        { rank: 34, lemma: "dix",    word_type: "word", part_of_speech: "numeral", translation: "ten" },
        # Group 5 — Time words
        { rank: 35, lemma: "aujourd'hui", word_type: "word", part_of_speech: "adverb", translation: "today" },
        { rank: 36, lemma: "demain",      word_type: "word", part_of_speech: "adverb", translation: "tomorrow" },
        { rank: 37, lemma: "maintenant",  word_type: "word", part_of_speech: "adverb", translation: "now" },
        # Group 6 — Survival phrases
        { rank: 38, lemma: "Où est…?",             word_type: "phrase", part_of_speech: "phrase", translation: "Where is…?" },
        { rank: 39, lemma: "Je ne comprends pas",  word_type: "phrase", part_of_speech: "phrase", translation: "I don't understand" },
        { rank: 40, lemma: "Parlez-vous anglais?", word_type: "phrase", part_of_speech: "phrase", translation: "Do you speak English?" },
        { rank: 41, lemma: "Combien ça coûte?",    word_type: "phrase", part_of_speech: "phrase", translation: "How much does that cost?" },
        { rank: 42, lemma: "Je voudrais…",         word_type: "phrase", part_of_speech: "phrase", translation: "I would like…" },
        # Group 7 — Connectors & question words
        { rank: 43, lemma: "et",        word_type: "word", part_of_speech: "conjunction", translation: "and" },
        { rank: 44, lemma: "mais",      word_type: "word", part_of_speech: "conjunction", translation: "but" },
        { rank: 45, lemma: "ou",        word_type: "word", part_of_speech: "conjunction", translation: "or" },
        { rank: 46, lemma: "parce que", word_type: "word", part_of_speech: "conjunction", translation: "because" },
        { rank: 47, lemma: "quoi",      word_type: "word", part_of_speech: "pronoun",     translation: "what", notes: "also: que" },
        { rank: 48, lemma: "où",        word_type: "word", part_of_speech: "adverb",      translation: "where" },
        { rank: 49, lemma: "quand",     word_type: "word", part_of_speech: "adverb",      translation: "when" },
        { rank: 50, lemma: "comment",   word_type: "word", part_of_speech: "adverb",      translation: "how" },
        { rank: 51, lemma: "qui",       word_type: "word", part_of_speech: "pronoun",     translation: "who" },
        { rank: 52, lemma: "pourquoi",  word_type: "word", part_of_speech: "adverb",      translation: "why" },
      ]

      fr_starter.each { |attrs| seed_word.call(language: french, theme: fr_essentials, **attrs) }
      puts "French starter: #{fr_starter.size} words seeded (ranks 1–52)"

      # ── German OpenSubtitles curriculum (de_enriched.csv) ───────────────────
      # German starter occupies ranks 1–51, so the OpenSubtitles CSV words begin at rank 52.
      RANK_OFFSET = 51

      pos_map = {
        "AUX"   => "verb",        "VERB"  => "verb",      "NOUN"  => "noun",
        "PRON"  => "pronoun",     "ADJ"   => "adjective", "ADV"   => "adverb",
        "ADP"   => "preposition", "CCONJ" => "conjunction", "SCONJ" => "conjunction",
        "CONJ"  => "conjunction", "DET"   => "determiner",  "PART"  => "particle",
        "INTJ"  => "interjection","NUM"   => "numeral",    "PROPN" => "proper noun",
        "PUNCT" => "punctuation", "SYM"   => "symbol",    "X"     => "other"
      }.freeze

      # Collect all existing German lemmas upfront to skip CSV duplicates of the starter set.
      existing_de_lemmas = Word.where(language: german).pluck(:lemma).to_set

      # Cache German themes created on demand from the CSV "theme" column.
      de_theme_cache = { "essentials" => de_essentials }
      find_de_theme = lambda do |name|
        de_theme_cache[name] ||= Theme.find_or_create_by!(language: german, name: name) { |t| t.display_order = 99 }
      end

      csv_path    = Rails.root.join("de_enriched.csv")
      words_new   = 0
      words_skip  = 0

      puts "Loading de_enriched.csv…"
      CSV.foreach(csv_path, headers: true) do |row|
        lemma = row["lemma"]

        if existing_de_lemmas.include?(lemma)
          words_skip += 1
          next
        end

        db_rank = row["rank"].to_i + RANK_OFFSET
        theme   = row["theme"].presence ? find_de_theme.call(row["theme"]) : nil

        word = Word.find_or_create_by!(language: german, lemma: lemma, frequency_rank: db_rank) do |w|
          w.word_type      = "word"
          w.part_of_speech = pos_map.fetch(row["pos"], row["pos"].to_s.downcase)
          w.article        = row["article"].presence
          w.gender         = row["gender"].presence
          w.level          = row["cefr"].presence
          w.theme          = theme
        end

        WordForm.find_or_create_by!(word: word, form_text: lemma) do |f|
          f.morphology = "lemma"
          f.is_primary = true
        end

        WordTranslation.find_or_create_by!(word: word, language: english) do |t|
          t.meaning = row["translation"]
        end

        existing_de_lemmas << lemma
        words_new += 1
        print "." if (words_new % 100).zero?
      end

      puts "\nde_enriched.csv: #{words_new} loaded, #{words_skip} skipped (starter duplicates)"

      # ── German word forms (de_word_forms.csv) ───────────────────────────────
      # Build rank→id index for CSV-sourced words only (frequency_rank > RANK_OFFSET).
      de_rank_to_id = Word.where(language: german)
                          .where("frequency_rank > ?", RANK_OFFSET)
                          .pluck(:frequency_rank, :id)
                          .to_h

      forms_path   = Rails.root.join("de_word_forms.csv")
      forms_new    = 0
      forms_skip   = 0

      puts "Loading de_word_forms.csv…"
      CSV.foreach(forms_path, headers: true) do |row|
        db_rank = row["rank"].to_i + RANK_OFFSET
        word_id = de_rank_to_id[db_rank]

        unless word_id
          forms_skip += 1
          next
        end

        is_primary = row["is_primary"].to_s.casecmp("true").zero?

        unless WordForm.exists?(word_id: word_id, form_text: row["form_text"])
          WordForm.create!(
            word_id:    word_id,
            form_text:  row["form_text"],
            morphology: row["morphology"],
            is_primary: is_primary
          )
          forms_new += 1
        end

        print "." if (forms_new % 500).zero?
      end

      puts "\nde_word_forms.csv: #{forms_new} forms loaded, #{forms_skip} skipped (lemma in starter / not in words table)"
      puts "=== db:seed:starter complete ==="
    end
  end
end
