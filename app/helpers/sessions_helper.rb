module SessionsHelper
  # Render Greta's response with structured formatting:
  #   **German:** sentence  → bold display text
  #   **English:** meaning  → italic muted
  #   remaining lines      → normal coaching text
  def format_greta(text)
    t = text.to_s
    german  = t[/\*\*German:\*\*\s*(.+?)(?:\n|$)/i,  1]&.strip
    english = t[/\*\*English:\*\*\s*(.+?)(?:\n|$)/i, 1]&.strip
    coaching = t
      .gsub(/\*\*(?:German|English):\*\*\s*.+?(?:\n|$)/i, "")
      .strip

    html = "".html_safe
    html += content_tag(:p, german,  class: "greta-german")  if german.present?
    html += content_tag(:p, english, class: "greta-english") if english.present?
    if coaching.present?
      coaching.split("\n").reject(&:blank?).each do |line|
        html += content_tag(:p, html_escape(line).gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>').html_safe,
                            class: "greta-coaching")
      end
    end
    html
  end
end
