require "jekyll/timeago/version"

module Jekyll
  module Timeago

    DAYS_PER = {
      :days => 1,
      :weeks => 7,
      :months => 31,
      :years => 365,
    }

    # Max level of detail
    # years > months > weeks > days
    # 1 year and 7 months and 2 weeks and 6 days
    MAX_DEPTH_LEVEL = 4

    # Default level of detail
    # 1 month and 5 days, 3 weeks and 2 days, 2 years and 6 months
    DEFAULT_DEPTH_LEVEL = 2

    def timeago(input, depth = DEFAULT_DEPTH_LEVEL)
      unless depth_allowed?(depth)
        raise "Invalid depth level: #{depth.inspect}"
      end

      unless input.is_a?(Date) || input.is_a?(Time)
        raise "Invalid input type: #{input.inspect}"
      end

      days_passed = (Date.today - Date.parse(input.to_s)).to_i
      time_ago_to_now(days_passed, depth)
    end

    private

    def time_ago_to_now(days_passed, depth)
      return "today"     if days_passed == 0
      return "yesterday" if days_passed == 1
      return "tomorrow"  if days_passed == -1

      future     = days_passed < 0
      slots      = build_time_ago_slots(days_passed, depth)

      if future
        "in #{slots.join(' and ')}"
      else
        "#{slots.join(' and ')} ago"
      end
    end

    # Builds time ranges: ['1 month', '5 days']
    def build_time_ago_slots(days_passed, depth, current_slots = [])
      return current_slots if depth == 0 || days_passed == 0

      time_range = days_to_time_range(days_passed)
      days       = DAYS_PER[time_range]
      num_elems  = days_passed.abs / days
      range_type = if num_elems == 1
        time_range.to_s[0...-1] # singularize
      else
        time_range.to_s
      end

      current_slots << "#{num_elems} #{range_type}"
      pending_days  = days_passed - (num_elems*days)
      build_time_ago_slots(pending_days, depth - 1, current_slots)
    end

    def days_to_time_range(days_passed)
      case days_passed.abs
      when 0...7
        :days
      when 7...31
        :weeks
      when 31...365
        :months
      else
        :years
      end
    end

    def depth_allowed?(depth)
      (1..MAX_DEPTH_LEVEL).include?(depth)
    end
  end
end

Liquid::Template.register_filter(Jekyll::Timeago)
