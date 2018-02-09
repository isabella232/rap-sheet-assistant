require 'spec_helper'
require 'treetop'

require_relative '../../app/parser/event_syntax_nodes'
require_relative '../../app/parser/count_syntax_nodes'

Treetop.load 'app/parser/common_grammar'
Treetop.load 'app/parser/count_grammar'

describe CountGrammarParser do
  describe '#parse' do
    it 'can parse convictions with semicolon instead of colon' do
      text = <<~TEXT
        blah
        DISPO;CONVICTED
      TEXT

      count = described_class.new.parse(text)

      expect(count.disposition_content).to be_a CountGrammar::Convicted
    end

    it 'parses when charge is in the comments' do
      text = <<~TEXT
         SEE COMMENT FOR CHARGE
        DISPO:CONVICTED
        count 3 text
      TEXT

      count = described_class.new.parse(text)
      expect(count.charge_line.text_value).to eq('SEE COMMENT FOR CHARGE')
      expect(count.disposition_content.text_value).to eq('DISPO:CONVICTED')
    end

    it 'parses code section when sentencing line exists' do
      text = <<~TEXT
         .-1170 (H) PC-SENTENCING
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      count = described_class.new.parse(text)
      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '496'
      expect(count.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"
    end

    it 'parses out punctuation around code section number' do
      text = <<~TEXT
          -496. PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      count = described_class.new.parse(text)
      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '496'
      expect(count.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"
    end
  end
end


