input = im2double(imread("1.jpg"));
%imshow(input)
[color_model,seed_pixels, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2] = estimate_color_model(input, 5);
color_layers = extract_layers(input, color_model, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2);