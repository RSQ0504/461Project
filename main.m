input = im2double(imread("original.jpg"));
%imshow(input)
 [color_model,seed_pixels] = estimate_color_model(input, 5);