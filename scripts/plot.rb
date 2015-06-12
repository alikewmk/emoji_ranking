require 'nyaplot'

x = []; y = []; theta = 0.6; a=1
File.open('2000_svm_result.txt').each_line do |line|
    item = line.split(" ")
    y << item[1].to_f/item[2].to_f
    theta += 0.1
end

# word_count/1000 in data base
x = [16.593, 8.016, 5.863, 4.959, 4.315, 3.477, 2.958, 2.86, 2.727, 2.344]

plot = Nyaplot::Plot.new
line = plot.add(:line, x, y)
sc = plot.add(:scatter, x, Array.new(10){0.005})
sc.shape(["triangle-up"])
sc.color('#00A37A')
sc.title('Emoji SVM Models')
line.title('Frequency in training data')
plot.legend(true)
plot.y_label("Precison")
plot.x_label("Frequency (*1000)")
plot.export_html("test.html")
