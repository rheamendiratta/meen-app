namespace :db do
  namespace :seed do
    desc "Seed sample data for testing the full daily session flow end to end (idempotent)"
    task sample: :environment do
      # ── Languages ────────────────────────────────────────────────────────────
      english = Language.find_or_create_by!(code: "en") { |l| l.name = "English"; l.is_learnable = false }
      german  = Language.find_or_create_by!(code: "de") { |l| l.name = "German";  l.is_learnable = true }
      puts "Languages: EN, DE ready"

      # ── Test user ─────────────────────────────────────────────────────────────
      user = User.find_by(email: "test@meen.com")
      if user.nil?
        user = User.create!(
          email:                 "test@meen.com",
          password:              "password123",
          password_confirmation: "password123",
          base_language:         english,
          active_language:       german
        )
        puts "User: created test@meen.com (id #{user.id})"
      else
        user.update!(base_language: english, active_language: german)
        puts "User: found test@meen.com (id #{user.id})"
      end

      # ── UserLanguage enrollment ───────────────────────────────────────────────
      UserLanguage.find_or_create_by!(user: user, language: german) do |ul|
        ul.started_at = Time.current
      end
      puts "UserLanguage: enrolled in German"

      # ── Companion: Greta the fox ──────────────────────────────────────────────
      Companion.find_or_create_by!(language: german) do |c|
        c.name    = "Greta"
        c.species = "fox"
        c.persona = <<~PERSONA.strip
          You are Greta, a warm and playful German tutor for a complete beginner.
          You speak in short, simple German sentences and always follow this format:

          **German:** <your German sentence>
          **English:** <the English translation>

          Then add a brief coaching note if helpful. Keep it encouraging and fun.
          Only use vocabulary the learner already knows unless you are introducing
          something new and immediately explaining it.
        PERSONA
      end
      puts "Companion: Greta the fox ready"

      # ── Curriculum words ──────────────────────────────────────────────────────
      # Grab the 20 lowest-ranked German curriculum words.
      curriculum = Word
        .where(language: german, owner_user_id: nil)
        .where.not(frequency_rank: nil)
        .order(:frequency_rank)
        .limit(20)
        .to_a

      abort "ERROR: fewer than 20 German curriculum words. Run `rails db:seed:starter` first." if curriculum.size < 20

      # Words at ranks 1–5 are held back so the introduce step always has 5 fresh words.
      # On re-run, delete them from vocabulary so the flow is fully retestable.
      introduce_words = curriculum.first(5)
      review_words    = curriculum.drop(5)   # ranks 6–20 → 15 words for flashcard review

      stale_vocab = UserVocabulary.where(user: user, word_id: introduce_words.map(&:id))
      stale_cards = FsrsCard.where(user: user, word_id: introduce_words.map(&:id))
      if stale_vocab.any?
        puts "Clearing #{stale_cards.count} FSRS cards and #{stale_vocab.count} vocab rows for introduce words (ranks 1–5)"
        stale_cards.delete_all
        stale_vocab.delete_all
      end

      # Ensure 15 review words are in vocabulary, introduced 7 days ago.
      review_words.each do |word|
        UserVocabulary.find_or_create_by!(user: user, word: word, language: german) do |uv|
          uv.entry_source  = "curriculum"
          uv.introduced_on = 7.days.ago.to_date
        end
      end

      # The after_create callback on UserVocabulary creates FSRS cards as "new".
      # Ensure all review-word cards are in "review" state and due so they appear
      # in the flashcard deck. On re-run, reset any that were previously reviewed
      # and pushed to a future date.
      review_words.each do |word|
        %w[recognition production].each do |card_type|
          card = FsrsCard.find_or_create_by!(user: user, word: word, card_type: card_type) do |c|
            c.state          = "review"
            c.stability      = 7.0
            c.difficulty     = 5.0
            c.reps           = 3
            c.lapses         = 0
            c.scheduled_days = 7
            c.due_at         = 1.day.ago
          end
          # Reset if not already in a due-review state (covers re-run after real reviews).
          unless card.state_review? && card.due_at <= Time.current
            card.update!(state: "review", due_at: 1.day.ago, stability: 7.0,
                         difficulty: 5.0, reps: 3, scheduled_days: 7)
          end
        end
      end

      puts "Vocabulary: #{review_words.size} review words ready (ranks 6–20, due now)"
      puts "Vocabulary: #{introduce_words.size} new words held back (ranks 1–5)"

      # ── Reset today's session ─────────────────────────────────────────────────
      # Delete today's DailyActivity so the full session flow can be retested each run.
      deleted = DailyActivity.where(user: user, language: german, activity_date: Date.current).delete_all
      puts "DailyActivity: reset today's session (#{deleted} row#{"s" if deleted != 1} deleted)"

      # ── Grammar references ─────────────────────────────────────────────────────
      grammar = [
        {
          category:      "basics",
          title:         "Definite Articles (der, die, das)",
          display_order: 1,
          content: <<~TEXT.strip
            German nouns have one of three genders: masculine, feminine, or neuter.
            The definite article ("the") changes with gender.

            Masculine  →  der   e.g. der Mann    — the man
            Feminine   →  die   e.g. die Frau    — the woman
            Neuter     →  das   e.g. das Kind    — the child
            Plural     →  die   (always, regardless of gender)

            Tip: always learn the article together with the noun.
            Not just "Hund" — learn "der Hund".
          TEXT
        },
        {
          category:      "basics",
          title:         "Indefinite Articles (ein, eine, ein)",
          display_order: 2,
          content: <<~TEXT.strip
            Masculine  →  ein    e.g. ein Mann   — a man
            Feminine   →  eine   e.g. eine Frau  — a woman
            Neuter     →  ein    e.g. ein Kind   — a child

            There is no plural indefinite article in German.
            Use the noun alone, or add "einige" (some):
              Kinder spielen.       — Children play.
              Einige Kinder spielen. — Some children play.
          TEXT
        },
        {
          category:      "basics",
          title:         "Verb Second Rule (V2)",
          display_order: 3,
          content: <<~TEXT.strip
            In a German statement, the conjugated verb is always the second element —
            not necessarily the second word.

            Subject first (normal order):
              Ich  gehe  heute  nach Hause.
              I    go    today  home.

            Time expression first (subject and verb swap — "inversion"):
              Heute  gehe  ich  nach Hause.
              Today  go    I    home.

            The verb stays locked in second position no matter what comes first.
          TEXT
        },
        {
          category:      "verbs",
          title:         "sein — to be (Präsens)",
          display_order: 4,
          content: <<~TEXT.strip
            ich        bin    — I am
            du         bist   — you are  (informal singular)
            er/sie/es  ist    — he / she / it is
            wir        sind   — we are
            ihr        seid   — you are  (informal plural)
            sie / Sie  sind   — they are / you are (formal)

            Examples:
              Ich bin müde.      — I am tired.
              Das ist schön.     — That is nice.
              Wir sind hier.     — We are here.
          TEXT
        },
        {
          category:      "verbs",
          title:         "haben — to have (Präsens)",
          display_order: 5,
          content: <<~TEXT.strip
            ich        habe   — I have
            du         hast   — you have  (informal singular)
            er/sie/es  hat    — he / she / it has
            wir        haben  — we have
            ihr        habt   — you have  (informal plural)
            sie / Sie  haben  — they have / you have (formal)

            Examples:
              Ich habe Hunger.   — I am hungry.  (lit. I have hunger.)
              Sie hat Zeit.      — She has time.
              Hast du Fragen?    — Do you have questions?
          TEXT
        },
        {
          category:      "cases",
          title:         "The Four Cases — Overview",
          display_order: 6,
          content: <<~TEXT.strip
            German uses four cases to show a noun's role in the sentence.
            The article changes depending on the case.

            NOMINATIV — the subject (who performs the action)
              Der Hund bellt.                 — The dog barks.

            AKKUSATIV — the direct object (what receives the action)
              Ich sehe den Hund.              — I see the dog.
              Note: masculine "der" → "den" in accusative.

            DATIV — the indirect object (for/to whom)
              Ich gebe dem Hund Futter.       — I give the dog food.

            GENITIV — possession
              Das Futter des Hundes.          — The dog's food.

            Beginner priority: master Nominativ and Akkusativ first.
          TEXT
        },
      ]

      grammar.each do |attrs|
        GrammarReference.find_or_create_by!(language: german, title: attrs[:title]) do |gr|
          gr.category      = attrs[:category]
          gr.display_order = attrs[:display_order]
          gr.content       = attrs[:content]
        end
      end
      puts "GrammarReferences: #{grammar.size} entries across 3 categories (basics, verbs, cases)"

      # ── Summary ───────────────────────────────────────────────────────────────
      puts ""
      puts "=== db:seed:sample complete ==="
      puts "  Login:     test@meen.com / password123"
      puts "  Introduce: /session/introduce → 5 new words (#{introduce_words.map(&:lemma).join(', ')})"
      puts "  Flashcards: 20 cards (5 new recognition + 15 due review)"
      puts "  Grammar:   /grammar_references → #{GrammarReference.where(language: german).count} entries"
    end
  end
end
