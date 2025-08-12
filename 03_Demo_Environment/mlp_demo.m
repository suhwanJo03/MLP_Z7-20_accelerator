
s = serialport("COM7",115200, "DataBits", 8, "Timeout",90);

configureTerminator(s,"CR/LF"); 

% because of serial port bandwidht is just 8-bit , so to get a 32-bit data,
% we have to transfer 4 times per one data element.
t_data = read(s, 4*100, "int8");
num_data = double(typecast(int8(t_data), 'uint32'));
test = reshape(num_data, [10, 10]);

%relu
relu_data = max(num_data, 0);
receive_data = reshape(relu_data, [10, 10]);

tmp = receive_data;

%normlaize & softmax
for y = 1 : 10  %
    col_data = tmp(:, y); 

    if all(col_data == 0)  
        prob_matrix(:, y) = col_data; 
    else
        col_data = normalize(col_data);  
        col_data = col_data - max(col_data);  
        exp_col_data = exp(col_data);  
        sum_exp_col_data = sum(exp_col_data);  
        if sum_exp_col_data ~= 0 
            for x = 1 : 10 
                data = col_data(x);  
                exp_data = exp(data);  
                prob_matrix(x, y) = exp_data / sum_exp_col_data; 
            end
        end
    end
end
disp(prob_matrix);

predict = zeros(1, 10);
for col = 1 : 10
    max_value = max(prob_matrix(:,col));
    max_index = find(prob_matrix(:,col) == max_value);

    if ~isempty(max_index)
        predict(col) = max_index(1);  % assign the first index from max_index
    else
        warning('No max index found for column %d', col);
    end
end


% display predict index number
disp(predict)

% Calculate probabilities in percentage
prob_percent = prob_matrix * 100;

% display predict index number along with percentage 추가
disp(['Predicted index number with probabilities (%):']);
for col = 1:10
    fprintf('Index %d: %d%%\n', predict(col)-1, round(prob_percent(predict(col), col)));
end

img0 = imread('0.bmp');
img1 = imread('1.bmp');
img2 = imread('2.bmp');
img3 = imread('3.bmp');
img4 = imread('4.bmp');
img5 = imread('5.bmp');
img6 = imread('6.bmp');
img7 = imread('7.bmp');
img8 = imread('8.bmp');
img9 = imread('9.bmp');

f = figure;
f.Position(1:4) = [50 150 1800 720];

empty = ones(28, 28);
subplot(1, 11, 1), imshow(empty);
annotation('textbox',[.127 .41 .1 .1], ...
    'String','input image','EdgeColor','none', 'fontsize',14)
title('predict label', 'fontsize',15) 

%subplot(1, 11, 2), imshow(img0)
%title(predict(1)-1, fontsize=20) 변경
subplot(1, 11, 2), imshow(img0)
title({['Predicted: ', num2str(predict(1)-1)], ['Probability: ', num2str(round(prob_percent(predict(1), 1))), '%']}, 'fontsize', 12)
subplot(1, 11, 3), imshow(img1)
title({['Predicted: ', num2str(predict(2)-1)], ['Probability: ', num2str(round(prob_percent(predict(2), 2))), '%']}, 'fontsize', 12)
subplot(1, 11, 4), imshow(img2)
title({['Predicted: ', num2str(predict(3)-1)], ['Probability: ', num2str(round(prob_percent(predict(3), 3))), '%']}, 'fontsize', 12)
subplot(1, 11, 5), imshow(img3)
title({['Predicted: ', num2str(predict(4)-1)], ['Probability: ', num2str(round(prob_percent(predict(4), 4))), '%']}, 'fontsize', 12)
subplot(1, 11, 6), imshow(img4)
title({['Predicted: ', num2str(predict(5)-1)], ['Probability: ', num2str(round(prob_percent(predict(5), 5))), '%']}, 'fontsize', 12)
subplot(1, 11, 7), imshow(img5)
title({['Predicted: ', num2str(predict(6)-1)], ['Probability: ', num2str(round(prob_percent(predict(6), 6))), '%']}, 'fontsize', 12)
subplot(1, 11, 8), imshow(img6)
title({['Predicted: ', num2str(predict(7)-1)], ['Probability: ', num2str(round(prob_percent(predict(7), 7))), '%']}, 'fontsize', 12)
subplot(1, 11, 9), imshow(img7)
title({['Predicted: ', num2str(predict(8)-1)], ['Probability: ', num2str(round(prob_percent(predict(8), 8))), '%']}, 'fontsize', 12)
subplot(1, 11, 10), imshow(img8)
title({['Predicted: ', num2str(predict(9)-1)], ['Probability: ', num2str(round(prob_percent(predict(9), 9))), '%']}, 'fontsize', 12)
subplot(1, 11, 11), imshow(img9)
title({['Predicted: ', num2str(predict(10)-1)], ['Probability: ', num2str(round(prob_percent(predict(10), 10))), '%']}, 'fontsize', 12)

sgtitle('2025 DSD Term Project (MLP)', 'fontsize', 50);