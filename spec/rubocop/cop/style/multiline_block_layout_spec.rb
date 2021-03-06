# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineBlockLayout do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing newline in do/end block w/o params' do
    inspect_source(cop,
                   ['test do foo',
                    'end'
                   ])
    expect(cop.messages)
      .to eq(['Expression at 1, 9 is on the same line as the block start.'])
  end

  it 'registers an offense for missing newline in {} block w/o params' do
    inspect_source(cop,
                   ['test { foo',
                    '}'
                   ])
    expect(cop.messages)
      .to eq(['Expression at 1, 8 is on the same line as the block start.'])
  end

  it 'registers an offense for missing newline in do/end block with params' do
    inspect_source(cop,
                   ['test do |x| foo',
                    'end'
                   ])
    expect(cop.messages)
      .to eq(['Expression at 1, 13 is on the same line as the block start.'])
  end

  it 'registers an offense for missing newline in {} block with params' do
    inspect_source(cop,
                   ['test { |x| foo',
                    '}'
                   ])
    expect(cop.messages)
      .to eq(['Expression at 1, 12 is on the same line as the block start.'])
  end

  it 'does not register an offense for one-line do/end blocks' do
    inspect_source(cop, 'test do foo end')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for one-line {} blocks' do
    inspect_source(cop, 'test { foo }')
    expect(cop.offenses).to be_empty
  end

  it 'does not register offenses when there is a newline for do/end block' do
    inspect_source(cop,
                   ['test do',
                    '  foo',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'does not error out when the block is empty' do
    inspect_source(cop,
                   ['test do |x|',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'does not register offenses when there is a newline for {} block' do
    inspect_source(cop,
                   ['test {',
                    '  foo',
                    '}'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'registers offenses for lambdas as expected' do
    inspect_source(cop,
                   ['-> (x) do foo',
                    '  bar',
                    'end'
                   ])
    expect(cop.messages)
      .to eq(['Expression at 1, 11 is on the same line as the block start.'])
  end

  it 'auto-corrects a do/end block with params that is missing newlines' do
    src = ['test do |foo| bar',
           'end']

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test do |foo| ',
                              '  bar',
                              'end'].join("\n"))
  end

  it 'auto-corrects a {} block with params that is missing newlines' do
    src = ['test { |foo| bar',
           '}']

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test { |foo| ',
                              '  bar',
                              '}'].join("\n"))
  end

  it 'autocorrects in more complex case with lambda and assignment, and '\
     'aligns the next line two spaces out from the start of the block' do
    src = ['x = -> (y) { foo',
           '  bar',
           '}']

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['x = -> (y) { ',
                              '      foo',
                              '  bar',
                              '}'].join("\n"))
  end
end
