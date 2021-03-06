require_relative 'test_helper'
describe "front_desk" do 
  def hotel_manager 
    return Hotel::FrontDesk.new()
  end 
  describe "#reservation_cost" do 
    it "calculate cost for a reservation" do 
      manager = hotel_manager
      reservation_1 = Hotel::Reservation.new(
        date_range: Hotel::DateRange.new(
          start_date:[2020,3,2],end_date:[2020,3,5]
        )
      )
      reservation_2 = Hotel::Reservation.new(
        date_range: Hotel::DateRange.new(
          start_date:[2020,4,1],end_date:[2020,4,8]
        )
      )
  
      manager.reservations << reservation_1
      manager.reservations << reservation_2
      cost = manager.reservation_cost(reservation_1)
      expect(cost).must_equal 600
      cost2 = manager.reservation_cost(reservation_2)
      expect(cost2).must_equal 1400
    end
    it "calculate cost for block individual room as well" do 
      manager = hotel_manager
      start_date = [2020,4,9]
      end_date = [2020,4,11]
      manager.create_block(start_date,end_date,5,180)
      block_id = manager.reservations[0].reservation_id.to_s[0..4]
      reservation = manager.book_room_of_block(block_id)

      cost_of_block_room = manager.reservation_cost(reservation)
      expect(cost_of_block_room).must_equal 360
    end 

  end  

  describe "#list_all" do
    it "return a list of all reservations" do 
      manager = hotel_manager
      reservation_1 = Hotel::Reservation.new(
        reservation_id:1234,
        date_range: Hotel::DateRange.new(
          start_date:[2020,3,2],end_date:[2020,3,5]
        )
      )
      reservation_2 = Hotel::Reservation.new(
        reservation_id:1235,
        date_range: Hotel::DateRange.new(
          start_date:[2020,4,1],end_date:[2020,4,8]
        )
      )
      manager.reservations << reservation_1
      manager.reservations << reservation_2
      result = manager.list_all
      expect(result).must_match (/2020-03-02/)
      expect(result).must_match (/2020-03-05/)
      expect(result).must_match (/2020-04-01/)
      expect(result).must_match (/2020-04-08/)
      expect(result).wont_match (/1999-04-08/)
      expect(result).must_match (/1234/)
      expect(result).must_match (/1235/)
    end
    it "will return block reservations as well" do 
      manager = hotel_manager
      start_date = [2020,3,1]
      end_date = [2020,3,9]
      manager.create_block(start_date,end_date,3,180)
      block_id = manager.reservations[0].reservation_id.to_s[0..4]
      reservation = manager.book_room_of_block(block_id)
      manager.request_reservation([2020,4,9],[2020,4,10])

      result = manager.list_all
      expect(result).must_match (/2020-03-01/)
      expect(result).must_match (/2020-03-09/)
      expect(result).must_match (/2020-04-09/)
      expect(result).must_match (/2020-04-10/)
      expect(result).wont_match (/2020-04-11/)

    end  
  end
  
  describe "#check_date_reservations" do 
    it "return a list of all reservations under a specific date 2020-03-05" do 
      manager = hotel_manager
      reservation_1 = Hotel::Reservation.new(
        reservation_id:1234,
        date_range: Hotel::DateRange.new(
          start_date:[2020,3,2],end_date:[2020,3,10]
        )
      )
      reservation_2 = Hotel::Reservation.new(
        reservation_id:1000,
        date_range: Hotel::DateRange.new(
          start_date:[2020,4,1],end_date:[2020,4,8]
        )
      )
      reservation_3 = Hotel::Reservation.new(
        reservation_id:1001,
        date_range: Hotel::DateRange.new(
          start_date:[2020,3,3],end_date:[2020,3,7]
        )
      )
      reservation_4 = Hotel::Reservation.new(
        reservation_id:2000,
        date_range: Hotel::DateRange.new(
          start_date:[2020,3,4],end_date:[2020,3,5]
        )
      )
      manager.reservations << reservation_1
      manager.reservations << reservation_2
      manager.reservations << reservation_3
      manager.reservations << reservation_4

      date_to_check = [2020,3,5]
      result = manager.check_date_reservations(date_to_check)

      expect(result).must_match (/2020-03-02/)
      expect(result).must_match (/2020-03-10/)
      expect(result).must_match (/2020-03-03/)
      expect(result).must_match (/2020-03-07/)
      expect(result).must_match (/1234/)
      expect(result).must_match (/1001/)
      expect(result).wont_match (/2020-03-04/)
      expect(result).wont_match (/2020-03-05/)
      expect(result).wont_match (/2020-04-01/)
      expect(result).wont_match (/2020-04-08/)
      expect(result).wont_match (/1000/)
      expect(result).wont_match (/2000/)

    end 
    it "return list including block reservations under a date" do 
      manager = hotel_manager
      start_date = [2020,2,1]
      end_date = [2020,2,9]
      manager.create_block(start_date,end_date,3,180)
      block_id = manager.reservations[0].reservation_id.to_s[0..4]
      reservation = manager.book_room_of_block(block_id)
      manager.request_reservation([2020,2,7],[2020,2,11])
      date_to_check = [2020,2,8]
      result = manager.check_date_reservations(date_to_check)

      expect(result).must_match (/2020-02-01/)
      expect(result).must_match (/2020-02-09/)
      expect(result).must_match (/2020-02-07/)
      expect(result).must_match (/2020-02-11/)
      expect(result).wont_match (/2020-03-11/)
      
    end 
  end 
  
  describe "#room_reservations_and_date" do 
    
    it "return a list of reservations under a room and within date_range Room 2 between 03/4 to 03/20" do 
      manager = hotel_manager
      reservation_1 = Hotel::Reservation.new(
        reservation_id:1000,
        date_range: Hotel::DateRange.new(
          start_date:[2020,3,2],end_date:[2020,3,10]
        ),
        room_num:1
      )
      reservation_2 = Hotel::Reservation.new(
        reservation_id:1111,
        date_range: Hotel::DateRange.new(
          start_date:[2020,4,1],end_date:[2020,4,8]
        ),
        room_num:2
      )
      reservation_3 = Hotel::Reservation.new(
        reservation_id:2121,
        date_range: Hotel::DateRange.new(
          start_date:[2020,3,3],end_date:[2020,3,7]
        ),
        room_num:2
      )
      reservation_4 = Hotel::Reservation.new(
        reservation_id:3000,
        date_range: Hotel::DateRange.new(
          start_date:[2020,3,7],end_date:[2020,3,9]
        ),
        room_num:2
      )
      manager.reservations << reservation_1
      manager.reservations << reservation_2
      manager.reservations << reservation_3
      manager.reservations << reservation_4
    
      date_range = Hotel::DateRange.new(
        start_date:[2020,3,4],end_date:[2020,3,20]
      )
      result = manager.room_reservations_and_date(2,date_range)
      expect(result).must_match (/2020-03-03/)
      expect(result).must_match (/2020-03-07/)
      expect(result).must_match (/2020-03-07/)
      expect(result).must_match (/2020-03-09/)
      expect(result).must_match (/2121/)
      expect(result).must_match (/3000/)

      expect(result).wont_match (/2020-04-01/)
      expect(result).wont_match (/2020-04-08/)
      expect(result).wont_match (/2020-03-10/)
      expect(result).wont_match (/1000/)
      expect(result).wont_match (/1111/)
    end 
  end
  describe "#request_reservation_wave1" do
    before do 
      manager = hotel_manager
      start_date = [2020,3,4]
      end_date = [2020,3,5]
      @new_reservation = manager.request_reservation(start_date,end_date)
    end 
    it "return an instance of reservation" do
        expect(@new_reservation).must_be_kind_of Hotel::Reservation
    end  
    it "return room number 1 to 20" do 
      expect(@new_reservation.room_num).must_be_kind_of Integer
      expect(@new_reservation.room_num).must_be :>, 0
      expect(@new_reservation.room_num).must_be :<, 21
    end 
    it "return reservation_id" do 
      expect(@new_reservation.reservation_id).must_be_kind_of String
    end 
    it "return correct start/end date" do 
      expect(@new_reservation.date_range.start_date).must_equal Date.new(2020,3,4)
    end 
  end 

  describe "#request_reservation for wave 2 Check if room added to reservations pool" do 
    it "new reservation is an instance of reservation" do 
      manager = hotel_manager
      reservation_2 = manager.request_reservation([2020,3,6],[2020,3,8])
      expect(reservation_2).must_be_kind_of Hotel::Reservation
    end 
    it "reservation pool will have new reservation" do 
      manager = hotel_manager
      reservation_1 = manager.request_reservation([2020,4,9],[2020,4,10])
      reservation_2 = manager.request_reservation([2020,3,6],[2020,3,8])
      expect(manager.reservations.include?(reservation_1)).must_equal true
      expect(manager.reservations.include?(reservation_2)).must_equal true
    end 
    it "will raise ArgumentError if all rooms are already booked for that date" do 
      manager = hotel_manager
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:1)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:2)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:3)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:4)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:5)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:6)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:7)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:8)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:9)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:10)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:11)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:12)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:13)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:14)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:15)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:16)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:17)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:18)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:19)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:20)  
      expect{manager.request_reservation([2020,3,3],[2020,3,7])}.must_raise ArgumentError
    end 
    it "will not randomly assign same room same dates" do
      manager = hotel_manager
      20.times do 
        manager.request_reservation([2020,4,9],[2020,4,10])
      end
      room_num_array = manager.reservations.map {|bookings|bookings.room_num.to_i}
      expect(room_num_array.sum).must_equal 210
    end 
  end 

  describe "#room_available" do 
    it "will show rooms that are availabe for a given date range" do 
      manager = hotel_manager
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:1)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:2)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:3)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:4)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:5)
      
      room_availabe = [6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
      date_range = Hotel::DateRange.new(start_date:[2020,3,7],end_date:[2020,3,8])
      expect(manager.room_available(date_range)).must_equal room_availabe
    end 
    it "will show rooms that are availabe for a given date range" do 
      manager = hotel_manager
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:1)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:20)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:13)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:4)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:5)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,10]),room_num:6)

      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,4,2],end_date:[2020,4,10]),room_num:7)
      manager.reservations << Hotel::Reservation.new(date_range: Hotel::DateRange.new(start_date:[2020,4,10],end_date:[2020,4,11]),room_num:7)
      room_availabe = [2,3,7,8,9,10,11,12,14,15,16,17,18,19]
      date_range = Hotel::DateRange.new(start_date:[2020,3,2],end_date:[2020,3,12])
      expect(manager.room_available(date_range)).must_equal room_availabe
    end 
  end 

  describe "Hotel Block" do 
    describe "#create_block" do 
      it "create an array of reservations with block_tag = block-available" do 
        manager = hotel_manager
        start_date = [2020,3,2]
        end_date = [2020,3,4]
        a_block = manager.create_block(start_date,end_date,2,180)

        expect(a_block).must_be_kind_of Array
        expect(a_block.length).must_equal 2 
        expect(manager.reservations.length).must_equal 2
        expect(manager.reservations[0].room_rate).must_equal 180
        expect(manager.reservations[0].block_tag).must_equal "block-available"
      end 
      it "raise ArgumentError if try block more than 5 rooms" do 
        manager = hotel_manager
        start_date = [2020,3,2]
        end_date = [2020,3,4]
        expect{ manager.create_block(start_date,end_date,6,180)}.must_raise ArgumentError
      end 
      it "raise ArgumentError if no rooms available for block" do 
        manager = hotel_manager
        start_date = [2020,4,9]
        end_date = [2020,4,10]

        16.times do 
          manager.request_reservation([2020,4,9],[2020,4,10])
        end 
        expect{ manager.create_block(start_date,end_date,6,180)}.must_raise ArgumentError
      end 
    end 
    describe "#book_room_of_block" do 
      it "will change one room's block_tag to block-booked" do 
        manager = hotel_manager
        start_date = [2020,4,9]
        end_date = [2020,4,15]
        manager.create_block(start_date,end_date,5,180)
        block_id = manager.reservations[0].reservation_id.to_s[0..4]
        manager.book_room_of_block(block_id)
        
        num_reservations = manager.reservations.length
        count_rooms_booked = manager.reservations.count{|room|room.block_tag == "block-booked"}
        count_rooms_available = manager.reservations.count{|room|room.block_tag == "block-available"}

        expect(num_reservations).must_equal 5
        expect(count_rooms_booked).must_equal 1
        expect(count_rooms_available).must_equal 4
      end 
      it "will raise ArgumentError if all rooms within block are booked" do 
        manager = hotel_manager
        start_date = [2020,4,9]
        end_date = [2020,4,10]
        manager.create_block(start_date,end_date,5,180)
        block_id = manager.reservations[0].reservation_id.to_s[0..4]
        5.times do 
          manager.book_room_of_block(block_id)
        end 
        expect{manager.book_room_of_block(block_id)}.must_raise ArgumentError
      end 

    end 

  end 

end 