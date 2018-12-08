require_relative './test_helper'

require_relative '../lib/hash_digger'

# load fixtures consts from a separate file/module
require_relative './fixtures/hash_digger'

describe 'HashDigger::Digger class' do
  before do
    @direct_path = 'def.0.tr.0.ex.0.tr.0.text'
    @ex_path     = 'def.*.tr.*.ex.*.text'
    @tr_path     = 'def.*.tr.*.ex.*.tr.*.text'
    @wrong_path  = 'def.*.tr.*.ex.text'
    @multi_word  = 'such a sucker.with his text!'

    @tr_result = [
      'суровое испытание',
      'проверка на прочность',
      'различные тесты',
      'четкий критерий',
      'лабораторный анализ',
      'химическое исследование',
      'новая проба',
      'бесчисленные опыты',
      'предварительное тестирование',
      'серьезный экзамен',
      'испытательный полет',
      'пробное бурение',
      'тестовый прогон',
      'контрольный участок',
      'проверочный вопрос',
      'испытывать Бога',
      'испытать качество',
      'тестируемое устройство',
      'проверяющий тест',
      'проверить теорию'
    ]

    @ex_results = [
      'different tests',
      'chemical tests',
      'numerous tests'
    ]

    @data = HashDiggerFixtures::DICTIONARY_SAMPLE_HASH[:test]
  end

  it 'must provide dig class-method' do
    HashDigger::Digger.must_respond_to :dig
  end

  it 'must dig direct paths' do
    @data.dig(:def, 0, :tr, 0, :ex, 0, :tr, 0, :text)
    HashDigger::Digger.dig(
      data: @data,
      path: @direct_path
    ).must_equal @data[:def][0][:tr][0][:ex][0][:tr][0][:text]
  end

  it 'must act like a Hash.dig' do
    HashDigger::Digger.dig(
      data: @data,
      path: @direct_path
    ).must_equal @data.dig(:def, 0, :tr, 0, :ex, 0, :tr, 0, :text)
  end

  it 'must dig for a recursive path' do
    HashDigger::Digger.dig(
      data: @data,
      path: @tr_path
    ).must_equal @tr_result
  end

  it 'must dig with a multi-word symbols in the path' do
    @result = @data.dig(:"such a sucker", :"with his text!")
    HashDigger::Digger.dig(
      data: @data,
      path: @multi_word
    ).must_equal @result
  end

  it 'must dig must apply block to the final element' do
    HashDigger::Digger.dig(
      data: @data,
      path: @ex_path
    ) do |context, element|
      element[:text] =~ /tests$/
    end.must_equal @ex_results
  end

  it 'must raise IndexError on wrong path' do
    Proc.new{ HashDigger::Digger.dig(
      data: @data,
      path: @wrong_path
    )}.must_raise IndexError
  end
end
