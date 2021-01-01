require 'csv'
require 'json'

File.open('./test.sql', 'r') do |f|
  in_create_statement = false
  columns = []
  f.each_line do |line|
    if line.index('CREATE') == 0
      in_create_statement = true
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
        puts JSON.generate(Hash[columns.zip(CSV.parse(values_csv, converters: :numeric)[0])])
      end

      columns = []
    end
  end
end
