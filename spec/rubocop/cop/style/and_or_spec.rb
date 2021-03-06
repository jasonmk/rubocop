# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::AndOr, :config do
  context 'when style is conditionals' do
    cop_config = {
      'EnforcedStyle' => 'conditionals'
    }

    subject(:cop) { described_class.new(config) }
    let(:cop_config) { cop_config }

    it 'does not warn on short-circuit (and)' do
      inspect_source(cop,
                     ['x = a + b and return x'])
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not warn on short-circuit (or)' do
      inspect_source(cop,
                     ['x = a + b or return x'])
      expect(cop.offenses.size).to eq(0)
    end

    it 'does warn on non short-circuit (and)' do
      inspect_source(cop,
                     ['x = a + b if a and b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'does warn on non short-circuit (or)' do
      inspect_source(cop,
                     ['x = a + b if a or b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'does warn on non short-circuit (and) (unless)' do
      inspect_source(cop,
                     ['x = a + b unless a and b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'does warn on non short-circuit (or) (unless)' do
      inspect_source(cop,
                     ['x = a + b unless a or b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'should handle boolean returning methods correctly' do
      inspect_source(cop,
                     ['1 if (not true) or false'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'should handle recursion' do
      inspect_source(cop,
                     ['1 if (true and false) || (false or true)'])
      expect(cop.offenses.size).to eq(2)
    end

    it 'should handle recursion' do
      inspect_source(cop,
                     ['1 if (true or false) && (false and true)'])
      expect(cop.offenses.size).to eq(2)
    end

  end

  context 'when style is always' do
    cop_config = {
      'EnforcedStyle' => 'always'
    }

    subject(:cop) { described_class.new(config) }
    let(:cop_config) { cop_config }

    it 'registers an offense for OR' do
      inspect_source(cop,
                     ['test if a or b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'registers an offense for AND' do
      inspect_source(cop,
                     ['test if a and b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'accepts ||' do
      inspect_source(cop,
                     ['test if a || b'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts &&' do
      inspect_source(cop,
                     ['test if a && b'])
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects "and" with &&' do
      new_source = autocorrect_source(cop, 'true and false')
      expect(new_source).to eq('true && false')
    end

    it 'auto-corrects "or" with ||' do
      new_source = autocorrect_source(cop, ['x = 12345',
                                            'true or false'])
      expect(new_source).to eq(['x = 12345',
                                'true || false'].join("\n"))
    end

    it 'leaves *or* as is if auto-correction changes the meaning' do
      src = "teststring.include? 'a' or teststring.include? 'b'"
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(src)
    end

    it 'leaves *and* as is if auto-correction changes the meaning' do
      src = 'x = a + b and return x'
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(src)
    end

    it 'warns on short-circuit (and)' do
      inspect_source(cop,
                     ['x = a + b and return x'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'also warns on non short-circuit (and)' do
      inspect_source(cop,
                     ['x = a + b if a and b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'also warns on non short-circuit (and) (unless)' do
      inspect_source(cop,
                     ['x = a + b unless a and b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'warns on short-circuit (or)' do
      inspect_source(cop,
                     ['x = a + b or return x'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'also warns on non short-circuit (or)' do
      inspect_source(cop,
                     ['x = a + b if a or b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'also warns on non short-circuit (or) (unless)' do
      inspect_source(cop,
                     ['x = a + b unless a or b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'also warns on while (or)' do
      inspect_source(cop,
                     ['x = a + b while a or b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'also warns on until (or)' do
      inspect_source(cop,
                     ['x = a + b until a or b'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

  end
end
