function [layers, layers_alpha] = get_layers(name_format, num_pics)
    input = imread(sprintf(name_format, 1));
    [rows,cols,~] = size(input);
    layers = zeros(num_pics, rows, cols, 3);
    layers(1, :, :, :) = input;
    layers_alpha = zeros(1, rows, cols, 1);
    
    for i = 3 : num_pics
         [img, ~, alpha] = imread(sprintf(name_format, i));
         alpha = im2double(alpha);
         img = im2double(img);
         layers(i, :, :, :) = img(: , :, :);
         layers_alpha(i, :, : ,:) = alpha;
    end
end