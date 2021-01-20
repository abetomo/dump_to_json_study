require 'csv'
require 'json'

File.open('./test.sql', 'r') do |f|
  in_create_statement = false
  columns = []
  f.each_line do |line|
    if line.index('CREATE') == 0
      in_create_statement = true
      columns = []
      next
    end

    if in_create_statement
      start_quote_index = line.index('`')
      if !start_quote_index || start_quote_index > 3
        in_create_statement = false
        next
      end

      end_quote_index = line.index('`', start_quote_index + 1)
      columns.push(line[start_quote_index + 1 .. end_quote_index - 1])

      if line.index(')') == 0
        in_create_statement = false
      end
    end


    if line.index('INSERT') == 0
      line = line[line.index('(') + 1 .. line.length - 4]
      line.split('),(').each do |values_csv|
        values = CSV.parse(
          values_csv.gsub("\\'", "''"),
          quote_char: "'",
          converters: :numeric
        )[0]
        puts JSON.generate(Hash[columns.zip(values)])
      end
    end
  end
end
