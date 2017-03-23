require 'nkf'

module StringNormalizer
  extend ActiveSupport::Concern

  def normalize_as_string(text)
    text = NKF.nkf('-W -w -Z1 --katakana', text).strip.gsub(" ", "")
      .gsub(/[－―‐ー−]/, '-').downcase if text
  end
end