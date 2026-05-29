require "fsrs_ruby"

# Thin adapter between our FsrsCard AR model and the fsrs_ruby gem.
# Uses the LongTermScheduler (enable_short_term: false) — day-based intervals only,
# no intra-session minute steps. This matches our once-a-day session model.
class FsrsScheduler
  FSRS = FsrsRuby.new(enable_short_term: false)

  RATINGS = {
    "again" => FsrsRuby::Rating::AGAIN,
    "hard"  => FsrsRuby::Rating::HARD,
    "good"  => FsrsRuby::Rating::GOOD,
    "easy"  => FsrsRuby::Rating::EASY
  }.freeze

  STATE_TO_INT = {
    "new"        => FsrsRuby::State::NEW,
    "learning"   => FsrsRuby::State::LEARNING,
    "review"     => FsrsRuby::State::REVIEW,
    "relearning" => FsrsRuby::State::RELEARNING
  }.freeze

  INT_TO_STATE = STATE_TO_INT.invert.freeze

  # Apply a rating to an FsrsCard and persist the updated FSRS state.
  # rating is one of "again", "hard", "good", "easy".
  def self.rate(fsrs_card, rating)
    gem_card = to_gem_card(fsrs_card)
    result   = FSRS.next(gem_card, Time.current, RATINGS.fetch(rating))
    from_gem_card(fsrs_card, result.card)
  end

  private_class_method def self.to_gem_card(card)
    elapsed = card.last_reviewed_at ? [(Time.current - card.last_reviewed_at) / 86400.0, 0].max : 0

    FsrsRuby::Card.new(
      due:            card.due_at || Time.current,
      stability:      card.stability.to_f,
      difficulty:     card.difficulty.to_f,
      elapsed_days:   elapsed.to_i,
      scheduled_days: card.scheduled_days,
      reps:           card.reps,
      lapses:         card.lapses,
      state:          STATE_TO_INT.fetch(card.state),
      last_review:    card.last_reviewed_at
    )
  end

  private_class_method def self.from_gem_card(ar_card, gem_card)
    ar_card.update!(
      stability:      gem_card.stability,
      difficulty:     gem_card.difficulty,
      state:          INT_TO_STATE.fetch(gem_card.state),
      reps:           gem_card.reps,
      lapses:         gem_card.lapses,
      scheduled_days: gem_card.scheduled_days,
      due_at:         gem_card.due,
      last_reviewed_at: Time.current
    )
  end
end
