function test_hsv(name_format, num_layers)
    [layers, layers_alpha] = get_layers(name_format, num_layers);
    shifted_layer2 = hsv_shift(layers, 2, 1);
    shifted_layer3 = hsv_shift(layers, 3, -0.2);
    [rows, cols, ~] = size(shifted_layer2);
    layers(2, :, :, :) = shifted_layer2;
    layers(3, :, :, :) = shifted_layer3;
    entire_img = zeros(rows, cols, 3);
    for i = 1 : num_layers
        curr_layer = squeeze(layers(i, :, :, :));
        curr_alpha = repmat(squeeze(layers_alpha(i, :, :)), [1, 1, 3]);
        entire_img = entire_img + (curr_layer .* curr_alpha);
    end
    imwrite(entire_img, name_format + "testhsv.jpg");
end

function shifted_img = hsv_shift(layers, index, shift)
    shifted_img = squeeze(layers(index,:,:,:));
    shifted_img = rgb2hsv(shifted_img);
    shifted_hue = shifted_img(:, :, 1);
    shifted_hue = shifted_hue + shift;
    shifted_hue(shifted_hue > 1) = 1;
    shifted_hue(shifted_hue < 0) = 0;
    shifted_img(:, :, 1) = shifted_hue;
    shifted_img = hsv2rgb(shifted_img);
end



