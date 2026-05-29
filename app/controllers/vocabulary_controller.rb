class VocabularyController < ApplicationController
  before_action :authenticate_user!
  before_action :set_active_language

  def index
    base_scope = current_user.user_vocabularies
                             .where(language: @language)
                             .includes(word: [:word_translations])

    @user_added = base_scope.where(entry_source: "user_added")
                            .order(created_at: :desc)

    @curriculum = base_scope.where(entry_source: "curriculum")
                            .joins(:word)
                            .order("words.frequency_rank ASC NULLS LAST, words.lemma ASC")
  end

  def new
    @word = Word.new
  end

  def create
    @word = Word.new(
      language:       @language,
      owner_user:     current_user,
      word_type:      params.dig(:word, :word_type).presence || "word",
      lemma:          params.dig(:word, :lemma)&.strip,
      part_of_speech: params.dig(:word, :part_of_speech).presence,
      article:        params.dig(:word, :article).presence,
      gender:         gender_for(params.dig(:word, :article))
    )

    @word_translation = @word.word_translations.build(
      language: current_user.base_language,
      meaning:  params[:meaning]&.strip,
      notes:    params[:notes]&.strip.presence
    )

    if @word.valid? && @word_translation.valid?
      ActiveRecord::Base.transaction do
        @word.save!
        @word_translation.save!
        UserVocabulary.create!(
          user:          current_user,
          word:          @word,
          language:      @language,
          entry_source:  "user_added",
          introduced_on: Date.current
        )
      end
      redirect_to vocabulary_index_path, notice: "\"#{@word.lemma}\" added to your word bank."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    vocab = current_user.user_vocabularies
                        .find_by!(word_id: params[:id], entry_source: "user_added")
    word = vocab.word
    raise ActiveRecord::RecordNotFound unless word.owner_user_id == current_user.id

    lemma = word.lemma
    word.destroy!
    redirect_to vocabulary_index_path, notice: "\"#{lemma}\" removed from your word bank."
  end

  private

  def set_active_language
    @language = current_user.active_language
  end

  # Derive grammatical gender from German article.
  def gender_for(article)
    case article
    when "der" then "masculine"
    when "die" then "feminine"
    when "das" then "neuter"
    end
  end
end
