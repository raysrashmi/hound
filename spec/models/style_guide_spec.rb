require 'rubocop'
require 'fast_spec_helper'
require 'app/models/style_checker'
require 'app/models/file_violation'
require 'app/models/line_violation'

describe 'Default style guide' do
  describe 'line character limit' do
    it 'does not have violation' do
      expect(violations_in('a' * 80)).to be_empty
    end

    it 'has violation' do
      expect(violations_in('a' * 81)).to eq ['Line is too long. [81/80]']
    end
  end

  describe 'trailing white space' do
    it 'does not have violation' do
      expect(violations_in('def some_method')).to be_empty
    end

    it 'has violation' do
      expect(violations_in('def some_method   ')).
        to eq ['Trailing whitespace detected.']
    end
  end

  describe 'parentheses white space' do
    it 'does not have violation' do
      expect(violations_in('some_method(1)')).to be_empty
    end

    it 'has violation' do
      expect(violations_in('some_method( 1 )')).
        to eq ['Space inside parentheses detected.']
    end
  end

  describe 'square brackets white space' do
    it 'does not have violation' do
      expect(violations_in('[1, 2]')).to be_empty
    end

    it 'has violation' do
      expect(violations_in('[ 1, 2 ]')).
        to eq ['Space inside square brackets detected.']
    end
  end

  describe 'curly brackets white space' do
    it 'does not have violation' do
      expect(violations_in('{ a: 1, b: 2 }')).to be_empty
    end

    it 'has violation' do
      expect(violations_in('{a: 1, b: 2}')).
        to eq ['Space inside { missing.', 'Space inside } missing.']
    end
  end

  describe 'curly brackets and pipe white space' do
    it 'does not have violation' do
      expect(violations_in('ary.map { |a| a.something }')).to  be_empty
    end

    it 'has violation' do
      expect(violations_in('ary.map{|a| a.something}')).  to eq [
        'Space missing to the left of {.',
        'Space between { and | missing.',
        'Space missing inside }.'
      ]
    end
  end

  private

  def violations_in(content)
    modified_file = double(
      contents: "#{content}\n",
      filename: 'foo.rb',
      modified_line_at: double,
      relevant_line?: true
    )

    violations = StyleChecker.new([modified_file]).violations

    violations.flat_map(&:line_violations).flat_map(&:messages)
  end
end
