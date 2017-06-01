#!/usr/bin/env ruby
require "csv"
require "logger"

class PlanCalculator
  LOGGER = Logger.new("output.log", File::CREAT)

  def rate_area_lookup
    @rate_area_lookup ||= load_rate_area_lookup
  end

  def rates
    @rates ||= load_rates
  end

  def write_slcsp
    LOGGER.info "Writing modified SLCSP file"

    CSV.open("modified_slcsp.csv", "wb") do |csv| #open up writer
      csv << ["zipcode","rate"] # add headers
      CSV.foreach("slcsp.csv", headers: true) do |row| #open up reader
        zipcode   = row["zipcode"]
        rate_area = rate_area_lookup[zipcode]
        
        if rate_area.count > 1
          LOGGER.info "--#{zipcode} is in #{rate_area.count} rate areas, therefore the answer is ambiguous"
          csv << [zipcode, nil]
        else
          zipcode_rates = rates[rate_area.first]
          if zipcode_rates && zipcode_rates.count >= 2
            # This is the happy path
            slcsp = zipcode_rates[1]
            LOGGER.info "--#{zipcode} has at least two silver rates (#{zipcode_rates.join(", ")})"
            csv << [zipcode, slcsp]
          else
            LOGGER.info "--#{zipcode} has no rates: #{rates[rate_area.first]}"
            csv << [zipcode, nil]
          end
        end
      end
    end
  end

  private

  def load_rates
    LOGGER.info "Loading rates from plans.csv"
    rates = {}
    CSV.foreach("plans.csv", headers: true) do |row|
      state       = row["state"]
      metal_level = row["metal_level"]
      rate        = row["rate"].to_f
      rate_area   = row["rate_area"]
      rate_tuple  = "#{state}_#{rate_area}"
      
      if metal_level.downcase == "silver"
        rates[rate_tuple] = [] unless rates.key?(rate_tuple)
        rates[rate_tuple] << rate
      end
    end
    rates.inject({}) { |mem, var|  
      mem[var[0]] = var[1].uniq.sort
      mem
    }
  end

  def load_rate_area_lookup
    LOGGER.info "Loading rate areas from zips.csv"
    rate_area_lookup = {}
    CSV.foreach("zips.csv", headers: true) do |row|
      zipcode    = row["zipcode"]
      state      = row["state"]
      rate_area  = row["rate_area"]
      rate_tuple = "#{state}_#{rate_area}"

      rate_area_lookup[zipcode] = [] unless rate_area_lookup.key?(zipcode)
      rate_area_lookup[zipcode] << rate_tuple unless rate_area_lookup[zipcode].include?(rate_tuple)
    end
    rate_area_lookup
  end
end

calc = PlanCalculator.new
calc.write_slcsp
puts "modified slcsp written"