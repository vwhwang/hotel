
require 'date'

module Hotel 
  class Reservation
    attr_accessor :reservation_id, :date_range, :room_num, :block_tag, :room_rate
    def initialize(reservation_id:nil, date_range:, room_num:nil,block_tag:nil, room_rate:nil)

      @reservation_id = reservation_id
      @date_range = date_range
      @room_num = room_num
      @block_tag = block_tag
      @room_rate = room_rate

      if @room_num == nil 
        @room_num = rand(1..20)
      end 

      if @reservation_id == nil
        @reservation_id = rand(1000..9999).to_s
      end

      if @room_rate == nil
        @room_rate = 200.0
      end 


    end
  end 
end 

