class SessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_active_language
  before_action :load_today

  DECK_SIZE      = 20
  NEW_WORD_COUNT = 5

  # ── Step 1: Introduce new words ───────────────────────────────────────────────

  def introduce
    redirect_to flashcards_session_path and return if @today.new_words_introduced > 0

    @words = Word.next_for_user(current_user, @language, count: NEW_WORD_COUNT)
                 .includes(:word_translations, :word_forms)
    @translations = translations_by_word_id(@words)
  end

  def create_introduce
    redirect_to flashcards_session_path and return if @today.new_words_introduced > 0

    words = Word.next_for_user(current_user, @language, count: NEW_WORD_COUNT)
    words.each { |word| introduce_word(word) }

    @today.update!(new_words_introduced: words.size)
    session.delete(:flashcard_deck)
    redirect_to flashcards_session_path
  end

  # ── Step 2: Flashcard practice ────────────────────────────────────────────────

  def flashcards
    redirect_to speaking_session_path and return if @today.flashcards_done > 0

    session[:flashcard_deck] ||= build_deck
    @deck_ids = session[:flashcard_deck]

    if @deck_ids.empty?
      @today.update!(flashcards_done: 1)
      redirect_to speaking_session_path and return
    end

    @card     = FsrsCard.find(@deck_ids.first)
    @word     = @card.word
    @translation = @word.word_translations.find_by(language_id: current_user.base_language_id)
    @position = DECK_SIZE - @deck_ids.size + 1
    @total    = DECK_SIZE
  end

  def rate_flashcard
    deck = session[:flashcard_deck] || []
    card_id = deck.shift

    if card_id
      card = FsrsCard.find(card_id)
      FsrsScheduler.rate(card, params[:rating])
      @today.increment!(:cards_reviewed)
      session[:flashcard_deck] = deck
    end

    if deck.empty?
      @today.update!(flashcards_done: 1)
      redirect_to speaking_session_path
    else
      redirect_to flashcards_session_path
    end
  end

  # ── Step 3: Speaking / conversation ───────────────────────────────────────────

  def speaking
    redirect_to listening_session_path and return if @today.speaking_done > 0

    session[:speaking_history] ||= []

    if session[:speaking_history].empty?
      greta_reply = CompanionChat.new(current_user, @language).opening
      session[:speaking_history] = [{ "role" => "assistant", "content" => greta_reply }]
    end

    @history = session[:speaking_history]
  end

  def speaking_exchange
    history      = session[:speaking_history] || []
    user_message = params[:message].to_s.strip
    greta_reply  = nil

    unless user_message.blank?
      greta_reply = CompanionChat.new(current_user, @language).chat(user_message, history)
      history << { "role" => "user",      "content" => user_message }
      history << { "role" => "assistant", "content" => greta_reply }
      session[:speaking_history] = history
    end

    exchange_count = history.count { |m| m["role"] == "user" }

    respond_to do |format|
      format.json { render json: { greta_reply: greta_reply, exchange_count: exchange_count } }
      format.html { redirect_to speaking_session_path }
    end
  end

  def speaking_complete
    @today.update!(speaking_done: 1)
    session.delete(:speaking_history)
    redirect_to listening_session_path
  end

  # ── Step 4: Listening comprehension ──────────────────────────────────────────

  def listening
    if session[:listening_answered]
      @result   = session.delete(:listening_answered)
      @exercise = session.delete(:listening_exercise)
    elsif @today.listening_done > 0
      redirect_to reading_session_path and return
    else
      session[:listening_exercise] ||= ExerciseGenerator.new(current_user, @language).listening
      @exercise = session[:listening_exercise]
    end
  end

  def answer_listening
    exercise  = session[:listening_exercise]
    questions = exercise["questions"]
    answers   = params[:option] || {}

    results = questions.each_with_index.map do |q, i|
      sel = answers[i.to_s].to_i
      { "selected" => sel, "correct" => q["correct_index"], "is_correct" => sel == q["correct_index"] }
    end

    @today.update!(listening_done: 1)
    session[:listening_answered] = {
      "results" => results,
      "score"   => results.count { |r| r["is_correct"] },
      "total"   => questions.size
    }
    redirect_to listening_session_path
  end

  # ── Step 5: Reading comprehension ─────────────────────────────────────────────

  def reading
    if session[:reading_answered]
      @result   = session.delete(:reading_answered)
      @exercise = session.delete(:reading_exercise)
    elsif @today.reading_done > 0
      redirect_to complete_session_path and return
    else
      session[:reading_exercise] ||= ExerciseGenerator.new(current_user, @language).reading
      @exercise = session[:reading_exercise]
    end
  end

  def answer_reading
    exercise  = session[:reading_exercise]
    questions = exercise["questions"]
    answers   = params[:option] || {}

    results = questions.each_with_index.map do |q, i|
      sel = answers[i.to_s].to_i
      { "selected" => sel, "correct" => q["correct_index"], "is_correct" => sel == q["correct_index"] }
    end

    @today.update!(reading_done: 1)
    session[:reading_answered] = {
      "results" => results,
      "score"   => results.count { |r| r["is_correct"] },
      "total"   => questions.size
    }
    redirect_to reading_session_path
  end

  # ── Step 6: Completion ────────────────────────────────────────────────────────

  def complete
    @today.finalize!
    @language_streak = current_user.user_languages.find_by(language: @language)&.current_streak || 0
  end

  private

  def ensure_active_language
    redirect_to onboarding_path unless current_user.active_language_id?
    @language = current_user.active_language
  end

  def load_today
    @today = DailyActivity.find_or_create_by!(
      user:          current_user,
      language:      @language,
      activity_date: Date.current
    )
  end

  # Add word to user's vocabulary; FSRS cards created by UserVocabulary after_create callback.
  def introduce_word(word)
    UserVocabulary.find_or_create_by!(user: current_user, word: word, language: @language) do |rec|
      rec.entry_source  = "curriculum"
      rec.introduced_on = Date.current
    end
  end

  # Build the ordered deck of card IDs: recognition cards for today's new words
  # (up to 5) + due/review cards (up to 15), total capped at DECK_SIZE.
  def build_deck
    today_word_ids = UserVocabulary
      .where(user: current_user, language: @language, introduced_on: Date.current)
      .pluck(:word_id)

    new_cards = FsrsCard
      .where(user: current_user, word_id: today_word_ids, card_type: "recognition")
      .order(:id)
      .limit(NEW_WORD_COUNT)

    remaining = DECK_SIZE - new_cards.size
    due_cards = FsrsCard
      .joins(:word)
      .where(user: current_user, words: { language_id: @language.id })
      .where.not(id: new_cards.select(:id))
      .for_review
      .due
      .order(:due_at)
      .limit(remaining)

    (new_cards.to_a + due_cards.to_a).map(&:id)
  end

  def translations_by_word_id(words)
    WordTranslation
      .where(word_id: words.map(&:id), language_id: current_user.base_language_id)
      .index_by(&:word_id)
  end
end
