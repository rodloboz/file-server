require 'securerandom'
one_megabyte = 1024 * 1024

name = 'large_1G'
size = 1000

File.open("./#{name}.txt", 'wb') do |file|
  size.times do
    file.write(SecureRandom.random_bytes(one_megabyte))
  end
end
