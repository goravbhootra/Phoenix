class PingController < ApplicationController
  skip_before_action :authenticate

  def show
    render text: "PONG"
  end
end
