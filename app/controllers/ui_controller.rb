# frozen_string_literal: true

class UiController < ApplicationController
  def v1
    render layout: 'derivativo_ui_v1'
  end
end
