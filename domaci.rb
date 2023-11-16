require "google_drive"
session = GoogleDrive::Session.from_config("config.json")

class Read
    include Enumerable
    attr_accessor :spreadsheet, :worksheet, :matrix 
    def initialize(key,session)
        @spreadsheet = session.spreadsheet_by_key(key)
        @worksheet = @spreadsheet.worksheets[0] #prvi worksheet predstavljeni su u nizovima
    end

    def worksheet_to_matrix(worksheet)
        matrix = Array.new
        (1..worksheet.num_cols).each do |col|
            column = Array.new
            (1..worksheet.num_rows).each do |row|
                column << worksheet[row, col]
            end

            matrix << column
        end
        @matrix = matrix
    end

    def row(i)
        matrix.transpose[i]
    end

    def each 
      @matrix.transpose.each do |row|
        row.each do |col|
            yield col
        end
      end
    end

    def [](rec)
        Kolona.new(matrix.find { |col| col[0] == rec},matrix) #find vraca kolonu koja zadovoljava uslov
    end

    def method_missing(method_name)
        column_name = " Kolona"
        name=method_name[0..method_name.to_s.index('K')-1].capitalize
        name << column_name
        if @matrix.transpose[0].include?(name)
          return Kolona.new(matrix.find { |row| row[0] == name},matrix)
        end
    end


end

class Kolona
    include Enumerable
    attr_accessor :kolona, :matrix
    def initialize(kolona,matrix)
        @kolona = kolona
        @matrix = matrix
    end

    def [](ind)
        kolona[ind]
    end

    def []=(ind,v)
        kolona[ind]=v
    end

    def sum
        suma = 0
        @kolona[1..-1].each do |value|
            suma += value.to_i
        end
        suma
    end

    def avg
        suma = 0.0
        br = 0
        @kolona[1..-1].each do |value|
            suma += value.to_f
            br+=1
        end
        suma/br
    end

    def to_s
        @kolona.to_s
    end
    
    def method_missing(method_name)
        matrix.transpose.each do |row|
            return row if row.include?(method_name.to_s)
        end
    end

    def respond_to_missing?(method_name, f=false)
        method_name.to_s == to_ary ? true : false
    end

    def each
        @kolona.each do |value|
            yield value
        end
    end
end

read = Read.new("11jwpXCfHKUXsXkJlCK_6s0uF8XpA6jOrOBJODPZ2CUI",session)

read.worksheet_to_matrix(read.worksheet)

p "1)", read.matrix
puts

p "2)", read.row(2)
#p read.matrix[2]  isto ko iznad
p read.row(2)[0]
puts

p "3)"
read.each do |item|
p item
end
puts

puts "5)a)", read["Prva Kolona"]
puts

p "5)b)", read["Prva Kolona"][2]
puts

read["Prva Kolona"][2] = "2557"
puts "5)c)", read["Prva Kolona"]
puts

p "6)a)"
puts read.prvaKolona
puts

p "6)a)i)", read.prvaKolona.sum, read.prvaKolona.avg
puts

p "6)a)ii)", read.trecaKolona.abba
puts

p "6)a)iii)"
p read.prvaKolona.map {|x| x=x.to_i + 1}
p read.prvaKolona.select { |x| x.to_i.odd?}
p read.prvaKolona.reduce &:+
