module Scrapers
  class RubyRelevance
    LANGUAGE = /\bruby\b|\brails\b/i
    ROLE = /\b(engineer|developer|programmer|architect)\b/i
    CONTEXT = /\b(stack|systems?|experience|proficien\w*|expert\w*|develop\w*|build\w*|code|coding|backend|back.end|required|requirements?|skills?)\b/i
    NEGATED = /\bno\s+(?:prior\s+)?(?:ruby|rails)\b.{0,50}\b(?:required|needed|necessary)\b|\b(?:ruby|rails)\b.{0,30}\b(?:not|isn't)\b.{0,20}\b(?:required|needed|used)\b/i
    REPLACED = /\b(?:migrat\w*|moving|switch\w*|replac\w*)\b.{0,40}\b(?:ruby|rails)\b.{0,30}\b(?:to|with)\b/i

    def self.call(title:, description:)
      return true if title.to_s.match?(LANGUAGE) && title.to_s.match?(ROLE)
      return false unless title.to_s.match?(ROLE)

      # Recruiting marketplaces advertise unrelated stacks after this heading.
      fragment = Nokogiri::HTML.fragment(description.to_s)
      fragment.css("br, p, div, li, h1, h2, h3, h4").each { |node| node.add_next_sibling(Nokogiri::XML::Text.new("\n", fragment.document)) }
      text = fragment.text.split(/not your tech stack/i, 2).first.to_s
      text.split(/[\n.!?]+/).any? do |sentence|
        sentence.match?(LANGUAGE) && sentence.match?(CONTEXT) && !sentence.match?(NEGATED) && !sentence.match?(REPLACED)
      end
    end
  end
end
