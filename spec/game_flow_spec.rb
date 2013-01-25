# encoding: UTF-8

require 'spec_helper'
require 'game_flow'

describe GameFlow do
  let(:ui) { double("ui").as_null_object }
  let(:game) { double("game", state: :initial).as_null_object }

  subject(:game_flow) { GameFlow.new(game, ui) }

  describe "#start" do
    it "prints the initial message" do
      initial_message = "Bem vindo ao jogo da forca!"
      ui.should_receive(:write).with(initial_message)

      game_flow.start
    end
  end

  describe "#next_step" do
    context "when the game is in the 'initial' state" do
      it "asks the user for the length of the word to be raffled" do
        question = "Qual o tamanho da palavra a ser sorteada?"
        ui.should_receive(:write).with(question)

        word_length = "3"
        ui.should_receive(:read).and_return(word_length)

        game_flow.next_step
      end

      context "and the user asks to raffle a word" do
        it "raffles a word with the given length" do
          word_length = "3"
          ui.stub(read: word_length)

          game.should_receive(:raffle).with(word_length.to_i)

          game_flow.next_step
        end

        it "prints a '_' for each letter in the raffled word" do
          word_length = "3"
          ui.stub(read: word_length)
          game.stub(raffle: "mom", raffled_word: "mom")

          ui.should_receive(:write).with("_ _ _")

          game_flow.next_step
        end

        it "tells if it's not possible to raffle with the given length" do
          word_length = "20"
          ui.stub(read: word_length)
          game.stub(raffle: nil)

          error_message = "Não temos uma palavra com o tamanho " <<
                         "desejado,\n" <<
                         "é necessário escolher outro tamanho."

          ui.should_receive(:write).with(error_message)

          game_flow.next_step
        end
      end
    end

    context "when the game is in the 'word raffled' state" do
      context "and the user guess a letter with success" do
        it "prints a success message" do
          game.stub(state: :word_raffled, guess_letter: true)

          letter_guess = "f"
          ui.stub(read: letter_guess)

          success_message = "Você adivinhou uma letra com sucesso."
          ui.should_receive(:write).with(success_message)

          game_flow.next_step
        end
      end
    end


    it "finishes the game when the user asks to" do
      user_input = "fim"
      ui.stub(read: user_input)

      game.should_receive(:finish)

      game_flow.next_step
    end
  end
end
