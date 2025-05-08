require "net/http"

class AlertsPreviewController < ApplicationController
  def index
    today = Time.now

    threshold = allowed_params[:threshold].to_f
    # TODO: Check if this is a valid threshold for instance non-negative or at least a number
    if threshold.nil?
      render json: "I need a threshold", status: 421
      return
    end

    unless [ :gt.to_s, :lt.to_s ].include? allowed_params[:comparator]
      render json: "I need a comparator and needs to be lt or gt", status: 422
      return
    end

    origin_currency = allowed_params[:origin_currency].downcase
    target_currency = allowed_params[:target_currency].downcase

    if origin_currency.nil? or target_currency.nil?
      render json: "Error will come later to this", status: 421
      return
    end

    ## TODO: Need to check if the currency code exist for both origin and target

    alerts = []
    for i in 1..7
      request_date = Date.today-i.day
      exchange_api = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@#{request_date}/v1/currencies/#{origin_currency}.json"
      alerts.append(build_alert(exchange_api, origin_currency, target_currency, threshold, request_date))
    end

    @result = {
      origin_currency: origin_currency,
      target_currency: target_currency,
      alerts: alerts
    }
    render json: @result
  end

  def build_alert(url, origin_currency, target_currency, threshold, request_date)
    # Return an alert
    res = Net::HTTP.get(URI(url))
    json = JSON.parse(res)
    rate = json[origin_currency][target_currency]
    { rate: rate, alert_trigger: rate.to_f > threshold, alert_time: request_date }
  end

  class AlertPreview
    def init(origin_currency, target_currency)
      self.origin_currency = origin_currency
      self.target_currency = target_currency
      self.alerts = []
    end
  end

  private
  def allowed_params
    params.permit(:origin_currency, :target_currency, :threshold, :comparator)
  end
end
