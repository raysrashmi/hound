require 'rubocop'
require 'fast_spec_helper'
require 'app/models/style_checker'
require 'app/models/file_violation'
require 'app/models/line_violation'
require 'active_support/core_ext/string/strip'

describe 'Default style guide' do
  describe 'inline comments' do
    it 'does not have a violation' do
      pending
      expect(violations_in('def foo # bad method')).to eq [
        'Avoid inline comments'
      ]
    end
  end

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
      expect(violations_in('ary.map { |a| a.something }')).to be_empty
    end

    it 'has violation' do
      expect(violations_in('ary.map{|a| a.something}')).to eq [
        'Space missing to the left of {.',
        'Space between { and | missing.',
        'Space missing inside }.'
      ]
    end
  end

  describe 'comma white space' do
    it 'does not have violation' do
      expect(violations_in('def foobar(a, b, c)')).to be_empty
    end

    it 'has violation' do
      expect(violations_in('def foobar(a,b,c)')).to eq [
        'Space missing after comma.'
      ]
    end
  end

  describe 'semicolon white space' do
    it 'does not have violation' do
      expect(violations_in('class foo; bar; end')).to be_empty
    end

    it 'has violation' do
      expect(violations_in('class foo;bar; end')).to eq [
        'Space missing after semicolon.'
      ]
    end
  end

  describe 'colon white space' do
    it 'does not have violation' do
      expect(violations_in('admin? ? true : false')).to be_empty
    end

    it 'has violation' do
      expect(violations_in('admin? ? true: false')).to eq [
        "Surrounding space missing for operator ':'."
      ]
    end
  end

  describe 'multiline method chaining' do
    it 'does not have violation' do
      content = strip_heredoc <<-CONTENT
        foo.
          bar.
          baz
      CONTENT
      expect(violations_in(content)).to be_empty
    end

    it 'has violation' do
      pending
      expect(violations_in("foo\n.bar\n.baz")).to eq [
        'For multiline method invocations, place the . at the end of each line'
      ]
    end
  end

  describe 'empty line between methods' do
    it 'does not have violation' do
      content = strip_heredoc <<-CONTENT
        def foo
          bar
        end

        def bar
          foo
        end
      CONTENT
      puts violations_in(content)
      expect(violations_in(content)).
        to be_empty
    end

    it 'has violation' do
      expect(violations_in("def foo\n  bar\nend\ndef bar\n  foo\nend")).
        to eq ['Use empty lines between defs.']
    end
  end

  describe 'use new lines around multiline blocks' do
    it 'does not have violation' do
      expect(violations_in('things.each do\n  stuff\nend\n\nmore code')).
        to be_empty
    end

    it 'has violation' do
      pending
      expect(violations_in('things.each do\n  stuff\nend\nmore code')).to eq [
        'Use newlines around multi-line blocks'
      ]
    end
  end

  describe 'case for SQL statements' do
    it 'does not have violation' do
      expect(violations_in("SELECT * FROM 'users'")).to be_empty
    end

    it 'has violation' do
      pending
      expect(violations_in("select * FROM 'users'")).to eq [
        'Use uppercase for SQL key words and lowercase for SQL identifiers.'
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

  def strip_heredoc(text)
    text.strip_heredoc.sub(/\n\Z/, '')
  end
end
