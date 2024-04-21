input_folder = "test_images/";
input_name = "radishes";
name_format = "results/" + input_name + "_%02d";

input = im2double(imread(input_folder + input_name + ".jpg"));
[color_model, seed_pixels, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2] = estimate_color_model(input, 5, 10);
[U_temp, Alpha_temp] = extract_layers2(input, color_model, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2);
[U_final, Alpha_final] = smoothing2(input, U_temp, Alpha_temp, color_model, name_format);
[num_layers, ~, ~, ~] = size(U_temp);
fprintf("Done\n");
new_alphas = alpha_add_to_overlay(Alpha_final);

for k = 1 : num_layers
        u = squeeze(U_final(k, : , : , : ));
        Alpha = squeeze(new_alphas(k, : , : , : ));
        imwrite(u, sprintf(name_format + "overlay.jpg", num_layers - k + 1), 'png', 'Alpha', Alpha);
end
fprintf("Done2\n");