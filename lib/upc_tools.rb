require "upc_tools/version"

#UPC Tools
module UpcTools

  #Generate one UPC check digit
  # @see http://www.gs1.org/barcodes/support/check_digit_calculator/
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf section 3.A.1.1
  # @param num [Integer|String] base number to generate check digit for
  # @return [Integer] check digit (always between 0-9)
  def self.generate_upc_check_digit(num)
    even = odd = 0
    #pad everything to max (13)
    num.to_s.rjust(13, '0').split('').each_with_index do |item, index|
      item = item.to_i
      even += item if index.odd? #opposite because of 0 indexing
      odd += item if index.even?
    end
    chk_total = (odd * 3) + even
    (10 - (chk_total % 10)) % 10
  end

  #Validate UPC check digit
  # @see http://www.gs1.org/barcodes/support/check_digit_calculator/
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf section 3.A.1.1
  # @param upc [Integer|String] UPC with check digit to check
  # @return [Boolean] truth of valid check digit
  def self.valid_upc_check_digit?(upc)
    full_upc = upc.to_s.rjust(14, '0') #extend to full 14 digits first
    gen_check = generate_upc_check_digit(full_upc[0, full_upc.size - 1])
    full_upc[-1] == gen_check.to_s
  end

  #Add check digit and properly pad
  # @param num [Integer|String] base number to extend
  # @param extended_length [Integer] resulting target to pad number to
  # @return [String] resulting UPC with check digit
  def self.extend_upc_with_check_digit(num, extended_length=12)
    upc = num.to_s << generate_upc_check_digit(num).to_s
    upc.rjust(extended_length, '0') #extend to at least the given length
  end

  #Type 2 format 2 | ID3456 | X | 000P | C (Check X is optional, price can overflow in some cases)
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf section 3.A.1.2

  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf Figure 3.A.1.2 – 1 Weight Factor 2-
  WEIGHT_FACTOR_2 = [0,2,4,6,8,9,1,3,5,7]
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf Figure 3.A.1.2 – 2 Weight Factor 3
  WEIGHT_FACTOR_3 = [0,3,6,9,2,5,8,1,4,7]
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf Figure 3.A.1.2 – 2 Weight Factor 5+
  WEIGHT_FACTOR_5plus = [0,5,1,6,2,7,3,8,4,9]
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf Figure 3.A.1.2 – 4 Weight Factor 5-
  WEIGHT_FACTOR_5mins = [0,5,9,4,8,3,7,2,6,1]
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf Figure 3.A.1.2 – 4 inverse Weight Factor 5-
  WEIGHT_FACTOR_5mins_opposite = [0,9,7,5,3,1,8,6,4,2]

  #Trim UPC to proper length for type2 checking
  # @param upc [Integer|String] UPC
  # @return [String] trimmed string
  def self.trim_type2_upc(upc)
    #if length is > 12, strip leading 0
    upc = upc.to_s
    upc = upc.gsub(/^0+/, '') if upc.size > 12
    upc
  end

  #Is this a type2 UPC?
  # @param upc [Integer|String] upc to check
  # @return [Boolean] is UPC a type-2?
  def self.type2_upc?(upc)
    upc = trim_type2_upc(upc)
    return false if upc.size > 13 || upc.size < 12 #length is wrong
    upc.start_with?('2')
  end

  #Validate UPC and Price check digit for a type 2 upc. Does NOT also check the UPC itself
  # @param upc [Integer|String] Type 2 UPC to check with check digit(s)
  # @return [Boolean] matching check digit(s)?
  def self.valid_type2_upc_check_digit?(upc)
    upc = trim_type2_upc(upc)
    return false unless type2_upc?(upc)
    plu, price, chk, price_chk = split_type2_upc(upc)
    price_chk_calc = if price.size == 4
      generate_type2_upc_price_check_digit_4(price)
    elsif price.size == 5
      generate_type2_upc_price_check_digit_5(price)
    else
      raise ArgumentError, "Price is an unknown size"
    end
    price_chk == price_chk_calc.to_s
  end

  #Convert item ID (PLU) and price to type2 UPC string
  # @param plu [Integer|String] item identifier (not including leading 2)
  # @param price [Integer|String] price as integer (in cents). Will be 0 padded if necessary
  # @param opts [Hash] options hash
  # @option opts [Integer] :price_length (4) price length (4 or 5). Will override given price length.
  # @option opts [Integer] :upc_length (12) price length (12 or 13)
  def self.item_price_to_type2(plu, price, opts={})
    upc_length = opts[:upc_length] || 12
    price_length = opts[:price_length] || 4
    raise ArgumentError, "opts[:upc_length] must be 12 or 13" if upc_length != 12 && upc_length != 13

    if upc_length == 13
      raise ArgumentError, "Price length cannot be 4 if UPC length is 13" if opts[:price_length] == 4
      price_length = 5
      raise ArgumentError, "opts[:price_length] must be 4 or 5" if price_length != 4 && price_length != 5
    end

    plu = plu.to_s
    raise ArgumentError, "plu must be 5 digits long" if plu.size != 5

    price = price.to_s.rjust(price_length, '0')
    raise ArgumentError, "price must be less than or equal to 5 digits long" if price.size > 5

    price_chk_calc = if price.size == 4
      generate_type2_upc_price_check_digit_4(price)
    elsif price.size == 5 && upc_length == 13
      generate_type2_upc_price_check_digit_5(price)
    else
      ''
    end

    upc = "2#{plu}#{price_chk_calc}#{price}"
    upc << generate_upc_check_digit(upc).to_s
  end

  #Split a Type2 UPC into its component parts
  # @see http://www.meattrack.com/Background/UPC.php
  # @see http://www.iddba.org/upccharacter2.aspx
  # @param upc [String|Integer] UPC to split up
  # @param skip_price_check [Boolean] Ignore price check digit (include digit in price field)
  # @return [Array(String,String,String,String)] elements of array: ItemID/PLU (not including leading 2), Price, UPC Check Digit, Price Check Digit
  def self.split_type2_upc(upc, skip_price_check=false)
    upc = trim_type2_upc(upc)
    plu = upc[1,5]
    chk = upc[-1]
    if upc.size == 13 || skip_price_check
      price = upc[-6, 5]
      price_chk = upc[-7] unless skip_price_check
    else
      price = upc[-5,4]
      price_chk = upc[-6] unless skip_price_check
    end
    [plu, price, chk, price_chk]
  end

  #Get the float price from a Type2 UPC
  # @param upc [String|Integer] UPC to get price from
  # @param skip_price_check [Boolean] Ignore price check digit (include digit in price field)
  # @return [Float] calculated price (rounded to nearest cent)
  def self.get_price_from_type2_upc(upc, skip_price_check=false)
    _, price = UpcTools.split_type2_upc(upc, skip_price_check)
    (price.to_f / 100.0).round(2)
  end

  #Generate price check digit for type 2 upc price of 4 digits
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf section 3.A.1.3
  # @see http://barcodes.gs1us.org/GS1%20US%20BarCodes%20and%20eCom%20-%20The%20Global%20Language%20of%20Business.htm
  # @param price [Integer|String] price as integer (in cents)
  # @return [Integer] calculated price check digit
  def self.generate_type2_upc_price_check_digit_4(price)
    #digit weighting factors 2-, 2-, 3, 5-
    digits = price.to_s.rjust(4, '0').split('').map(&:to_i)
    sum = 0
    sum += WEIGHT_FACTOR_2[digits[0]]
    sum += WEIGHT_FACTOR_2[digits[1]]
    sum += WEIGHT_FACTOR_3[digits[2]]
    sum += WEIGHT_FACTOR_5mins[digits[3]]
    (sum * 3) % 10
  end

  #Generate price check digit for type 2 upc price of 5 digits
  # @see http://www.gs1tw.org/twct/web/BarCode/GS1_Section3V6-0.pdf section 3.A.1.4
  # @param price [Integer|String] price as integer (in cents)
  # @return [Integer] calculated price check digit
  def self.generate_type2_upc_price_check_digit_5(price)
    #digit weighting factors 5+, 2-, 5-, 5+, 2- => opposite of 5-
    digits = price.to_s.rjust(5, '0').split('').map(&:to_i)
    sum = 0
    sum += WEIGHT_FACTOR_5plus[digits[0]]
    sum += WEIGHT_FACTOR_2[digits[1]]
    sum += WEIGHT_FACTOR_5mins[digits[2]]
    sum += WEIGHT_FACTOR_5plus[digits[3]]
    sum += WEIGHT_FACTOR_2[digits[4]]
    sum = (10 - (sum % 10)) % 10
    WEIGHT_FACTOR_5mins_opposite[sum]
  end

  # UPC-E = ABCDEFGH
  # seen as 0  123456  7
  # maps as A  BCDEFG  H
  # ABC and H never change

  #position conversions
  # G =  0  XXNNN0  A + BC000-00DEF + H
  # G =  1  XXNNN1  A + BC100-00DEF + H
  # G =  2  XXNNN2  A + BC200-00DEF + H
  # G =  3  XXXNN3  A + BCD00-000EF + H
  # G =  4  XXXXN4  A + BCDE0-0000F + H
  # G =  5  XXXXX5  A + BCDEF-00005 + H
  # G =  6  XXXXX6  A + BCDEF-00006 + H
  # G =  7  XXXXX7  A + BCDEF-00007 + H
  # G =  8  XXXXX8  A + BCDEF-00008 + H
  # G =  9  XXXXX9  A + BCDEF-00009 + H

  #Convert short (8 digit) UPC-E to 12 digit UPC-A
  # @see http://www.taltech.com/barcodesoftware/symbologies/upc
  # @see http://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E
  # @param upc_e [String|Integer] 8 digit UPC-E to convert
  # @return [String] 12 digit UPC-A
  def self.convert_upce_to_upca(upc_e)
    #todo should i zero pad upc_e?
    #todo allow without check digit?
    upc_e = upc_e.to_s
    raise ArgumentError, "UPC-E must be 8 digits" unless upc_e.size == 8

    map_id = upc_e[-2].to_i #G
    chk = upc_e[-1] #H
    prefix = upc_e[0,3] #ABC
    prefix_next = upc_e[3,3] #DEF

    if map_id >= 5
      "#{prefix}#{prefix_next}0000#{map_id}#{chk}"
    elsif map_id <= 2
      "#{prefix}#{map_id}0000#{prefix_next}#{chk}"
    elsif map_id == 3
      "#{prefix}#{upc_e[3]}00000#{upc_e[4,2]}#{chk}"
    elsif map_id == 4
      "#{prefix}#{upc_e[3,2]}00000#{upc_e[5]}#{chk}"
    end
  end

  #Convert (zero-suppress) 12 digit UPC-A to 8 digit UPC-E
  # @see http://www.taltech.com/barcodesoftware/symbologies/upc
  # @see http://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E
  # @see http://www.barcodeisland.com/upce.phtml#Conversion
  # @param upc_a [String|Integer] 12 digit UPC-A to convert
  # @return [String] 8 digit UPC-E
  def self.convert_upca_to_upce(upc_a)
    #todo should i zero pad upc_a?
    #todo allow without check digit?
    upc_a = upc_a.to_s
    raise ArgumentError, "Must be 12 characters long" unless upc_a.size == 12
    start = upc_a[0] #first char
    raise ArgumentError, "Must be type 0 or 1" unless ["0", "1"].include?(start)

    chk = upc_a[-1] #last char
    mfr = upc_a[1...6] #next 5 characters
    prod = upc_a[6...11] #last 4 characters w/o chk

    upc_e = if ["000", "100", "200"].include?(mfr[-3,3])
      "#{mfr[0,2]}#{prod[-3,3]}#{mfr[2]}"
    elsif mfr[-2,2] == '00' && prod.to_i <= 99
      "#{mfr[0,3]}#{prod[-2,2]}3"
    elsif mfr[-1] == '0' && prod.to_i <= 9
      "#{mfr[0,4]}#{prod[-1]}4"
    elsif mfr[-1] != '0' && [5,6,7,8,9].include?(prod.to_i)
      "#{mfr}#{prod[-1]}"
    end
    raise ArgumentError, "Must meet formatting requirements" unless upc_e

    "#{start}#{upc_e}#{chk}"
  end


  # Split a type2 UPC into the UPC itself and the price contained therein. If the value passed in is a type2 UPC, the return value will
  # @param number [Integer|String] upc to check
  # @return [Array(String,Float)] elements of array: type2 UPC string, Price. The UPC ends up with a 0 price if it is type2. The Price will be nil if the number passed in is not type2.
  def self.type2_number_price(number)
    if type2_upc?(number) && valid_type2_upc_check_digit?(number)
      #looks like a type-2 and the price chk is valid
      item_code, price = split_type2_upc(number)
      price = (price.to_f / 100.0).round(2)

      upc = item_price_to_type2(item_code, 0).rjust(14, '0')
      [upc, price]
    else
      [number, nil]
    end
  end
end
