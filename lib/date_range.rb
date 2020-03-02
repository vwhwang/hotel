require 'date'

module Hotel

  class DateRange
    attr_reader :start_date, :end_date
    def initialize(start_date:, end_date:)
      @start_date = Date.new(start_date[0],start_date[1],start_date[2])
      @end_date = Date.new(end_date[0],end_date[1],end_date[2])
    
      if @end_date - @start_date <= 0 
        raise ArgumentError, "#{@end_date} cannot be before or equal to #{@start_date}"
      end 
    end 

    #overlap method
    def overlap(date_range)
      if @start_date >= date_range.end_date || @end_date <= date_range.start_date
        return false 
      else 
        return true
      end 
    end 
    
  end 
end 