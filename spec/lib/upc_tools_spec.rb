require 'spec_helper'

describe UpcTools do

  describe "UPC" do
    #verify UPC check digits with http://www.gs1.org/barcodes/support/check_digit_calculator/
    describe "#generate_upc_check_digit" do
      it { expect(UpcTools.generate_upc_check_digit(12345678901)).to eq(2) }
      it { expect(UpcTools.generate_upc_check_digit('98765432109')).to eq(8) }

      it { expect(UpcTools.generate_upc_check_digit(876543214587)).to eq(4) }
      it { expect(UpcTools.generate_upc_check_digit('000000456789')).to eq(9) }
      it { expect(UpcTools.generate_upc_check_digit(456789)).to eq(9) }

      it { expect(UpcTools.generate_upc_check_digit('0000004567898')).to eq(1) }
      it { expect(UpcTools.generate_upc_check_digit(4567898)).to eq(1) }
      it { expect(UpcTools.generate_upc_check_digit(5874139845602)).to eq(0) }

      it { expect(UpcTools.generate_upc_check_digit('37610425002123456')).to eq(9) }
    end
    describe "#valid_upc_check_digit" do
      it { expect(UpcTools.valid_upc_check_digit?(58741398456020)).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?('00000045678981')).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?('45678981')).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?(58741398456029)).to be_false }
      it { expect(UpcTools.valid_upc_check_digit?('0000004567898')).to be_false }
      it { expect(UpcTools.valid_upc_check_digit?(4567898)).to be_false }

      it { expect(UpcTools.valid_upc_check_digit?(8765432145874)).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?('0000004567899')).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?(4567899)).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?(876543214587)).to be_false }
      it { expect(UpcTools.valid_upc_check_digit?('0000004567898')).to be_false }
      it { expect(UpcTools.valid_upc_check_digit?('4567898')).to be_false }

      it { expect(UpcTools.valid_upc_check_digit?(123456789012)).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?('987654321098')).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?(323456789012)).to be_false }
      it { expect(UpcTools.valid_upc_check_digit?('7654321098')).to be_false }

      it { expect(UpcTools.valid_upc_check_digit?('376104250021234569')).to be_true }
      it { expect(UpcTools.valid_upc_check_digit?('376104250021234561')).to be_false }
    end
    describe "#extend_upc_with_check_digit" do
      it { expect(UpcTools.extend_upc_with_check_digit(12345678901)).to eq('123456789012') }
      it { expect(UpcTools.extend_upc_with_check_digit(12345678901, 13)).to eq('0123456789012') }
      it { expect(UpcTools.extend_upc_with_check_digit('98765432109')).to eq('987654321098') }
      it { expect(UpcTools.extend_upc_with_check_digit('98765432109', 14)).to eq('00987654321098') }

      it { expect(UpcTools.extend_upc_with_check_digit(876543214587)).to eq('8765432145874') }
      it { expect(UpcTools.extend_upc_with_check_digit('000000456789')).to eq('0000004567899') }
      it { expect(UpcTools.extend_upc_with_check_digit('456789', 12)).to eq('000004567899') }
      it { expect(UpcTools.extend_upc_with_check_digit('456789', 13)).to eq('0000004567899') }
      it { expect(UpcTools.extend_upc_with_check_digit('456789', 14)).to eq('00000004567899') }

      it { expect(UpcTools.extend_upc_with_check_digit('0000004567898')).to eq('00000045678981') }
      it { expect(UpcTools.extend_upc_with_check_digit('0000004567898', 13)).to eq('00000045678981') }
      it { expect(UpcTools.extend_upc_with_check_digit(5874139845602)).to eq('58741398456020') }
      it { expect(UpcTools.extend_upc_with_check_digit(5874139845602, 13)).to eq('58741398456020') }

      it { expect(UpcTools.extend_upc_with_check_digit('37610425002123456')).to eq('376104250021234569') }
    end
  end

  describe "Type 2 UPC" do
    describe "#trim_type2_upc" do
      it { expect(UpcTools.trim_type2_upc('00201234567890')).to eq('201234567890') }
      it { expect(UpcTools.trim_type2_upc('03201234567890')).to eq('3201234567890') }
      it { expect(UpcTools.trim_type2_upc('001234567890')).to eq('001234567890') }
    end
    describe "#type2_upc" do
      it { expect(UpcTools.type2_upc?('00201234567890')).to be_true }
      it { expect(UpcTools.type2_upc?('03201234567890')).to be_false}
      it { expect(UpcTools.type2_upc?('001234567890')).to be_false }
      it { expect(UpcTools.type2_upc?('2100123456789')).to be_true }
      it { expect(UpcTools.type2_upc?('02100123456789')).to be_true }
    end
    describe "#valid_type2_upc_check_digit" do
      it { expect(UpcTools.valid_type2_upc_check_digit?('203374803000')).to be_true }
      it { expect(UpcTools.valid_type2_upc_check_digit?('220812713657')).to be_true }
      it { expect(UpcTools.valid_type2_upc_check_digit?('2003493104857')).to be_true }

      describe "Exceptions" do
        pending
      end
    end
    describe "#item_price_to_type2" do
      it { expect(UpcTools.item_price_to_type2('03374', '0300')).to eq('203374803004') }
      it { expect(UpcTools.item_price_to_type2('03374', 300)).to eq('203374803004') }
      it { expect(UpcTools.item_price_to_type2('20812', 1365)).to eq('220812713657') }
      it { expect(UpcTools.item_price_to_type2(20812, '1365')).to eq('220812713657') }

      it { expect(UpcTools.item_price_to_type2('00349', '10485', upc_length: 13)).to eq('2003493104857') }

      it { expect(UpcTools.item_price_to_type2('00349', '10485', upc_length: 12)).to eq('200349104852') }

      it { expect(UpcTools.item_price_to_type2('00349', '0000')).to eq('200349000000') }
      it { expect(UpcTools.item_price_to_type2('20812', '0000')).to eq('220812000009') }

      describe "Exceptions" do
        pending
      end
    end
    describe "#split_type2_upc" do
      it { expect(UpcTools.split_type2_upc('203374803000')).to eq(['03374', '0300', '0', '8']) }
      it { expect(UpcTools.split_type2_upc('203374803000', true)).to eq(['03374', '80300', '0', nil]) }
      it { expect(UpcTools.split_type2_upc('220812713657')).to eq(['20812', '1365', '7', '7']) }
      it { expect(UpcTools.split_type2_upc('220812713657', true)).to eq(['20812', '71365', '7', nil]) }
      it { expect(UpcTools.split_type2_upc('257726012561')).to eq(['57726', '1256', '1', '0']) }

      it { expect(UpcTools.split_type2_upc('2003493104857')).to eq(['00349', '10485', '7', '3']) }
      it { expect(UpcTools.split_type2_upc('2003493104857', false)).to eq(['00349', '10485', '7', '3']) }
      it { expect(UpcTools.split_type2_upc('2057720112568')).to eq(['05772', '11256', '8', '0']) }
    end
    describe "#generate_type2_upc_price_check_digit_4" do
      it { expect(UpcTools.generate_type2_upc_price_check_digit_4(2875)).to eq(9) }
      it { expect(UpcTools.generate_type2_upc_price_check_digit_4('0300')).to eq(8) }
      it { expect(UpcTools.generate_type2_upc_price_check_digit_4('1365')).to eq(7) }
      it { expect(UpcTools.generate_type2_upc_price_check_digit_4('0512')).to eq(3) }
    end
    describe "#generate_type2_upc_price_check_digit_5" do
      it { expect(UpcTools.generate_type2_upc_price_check_digit_5(14685)).to eq(6) }
      it { expect(UpcTools.generate_type2_upc_price_check_digit_5('10485')).to eq(3) }
    end
  end

  describe "UPC E" do
    #verify conversion with http://www.morovia.com/education/utility/upc-ean.asp
    #verify conversion with http://www.barcodeisland.com/upce.phtml#Conversion
    describe "#convert_upce_to_upca" do
      it { expect(UpcTools.convert_upce_to_upca('01234500')).to eq('012000003450') }
      it { expect(UpcTools.convert_upce_to_upca('01234510')).to eq('012100003450') }
      it { expect(UpcTools.convert_upce_to_upca('01234520')).to eq('012200003450') }
      it { expect(UpcTools.convert_upce_to_upca('01234530')).to eq('012300000450') }
      it { expect(UpcTools.convert_upce_to_upca('01234540')).to eq('012340000050') }
      it { expect(UpcTools.convert_upce_to_upca('01234550')).to eq('012345000050') }
      it { expect(UpcTools.convert_upce_to_upca('01234560')).to eq('012345000060') }
      it { expect(UpcTools.convert_upce_to_upca('01234570')).to eq('012345000070') }
      it { expect(UpcTools.convert_upce_to_upca('01234580')).to eq('012345000080') }
      it { expect(UpcTools.convert_upce_to_upca('01234590')).to eq('012345000090') }

      describe "Exceptions" do
        pending
      end
    end
    describe "#convert_upca_to_upce" do
      it { expect(UpcTools.convert_upca_to_upce('042100005264')).to eq('04252614') }
      it { expect(UpcTools.convert_upca_to_upce('020200004417')).to eq('02044127') }
      it { expect(UpcTools.convert_upca_to_upce('020600000019')).to eq('02060139') }
      it { expect(UpcTools.convert_upca_to_upce('040350000077')).to eq('04035747') }
      it { expect(UpcTools.convert_upca_to_upce('020201000050')).to eq('02020150') }
      it { expect(UpcTools.convert_upca_to_upce('020204000064')).to eq('02020464') }
      it { expect(UpcTools.convert_upca_to_upce('023456000073')).to eq('02345673') }
      it { expect(UpcTools.convert_upca_to_upce('020204000088')).to eq('02020488') }
      it { expect(UpcTools.convert_upca_to_upce('020201000098')).to eq('02020198') }
      it { expect(UpcTools.convert_upca_to_upce('043000000854')).to eq('04308504') }
      it { expect(UpcTools.convert_upca_to_upce('127200002013')).to eq('12720123') }
      it { expect { UpcTools.convert_upca_to_upce('212345678992') }.to raise_error(ArgumentError) }

      describe "Exceptions" do
        pending
      end
    end
  end

end
