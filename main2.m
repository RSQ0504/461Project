input_folder = "test_images/";
input_name = "85";
name_format = "results/" + input_name + "_%02d";
input = im2double(imread(input_folder + input_name + ".png"));
if exist("results/", "dir")
    rmdir("results/", "s");
end
mkdir("results/")
mkdir("results/alpha_add/")

begin_estimate_color_model = tic;
[color_model, seed_pixels, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2] = estimate_color_model(input, 15, 30);
finish_estimate_color_model = toc(begin_estimate_color_model);
fprintf("estimate color model took %4.4f seconds\n", finish_estimate_color_model);

begin_extract_layers = tic;
[U_temp, Alpha_temp] = extract_layers(input, color_model, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2);
finish_extract_layers = toc(begin_extract_layers);
fprintf("extract layers took %4.4f seconds\n", finish_extract_layers);

begin_smoothing = tic;
[U_final, Alpha_final] = smoothing(input, U_temp, Alpha_temp, color_model);
finish_smoothing = toc(begin_smoothing);
fprintf("smoothing took %4.4f seconds\n", finish_smoothing);

begin_save = tic;
[num_layers, ~, ~, ~] = size(U_temp);
new_alphas = alpha_add_to_overlay(Alpha_final);

for k = 1 : num_layers
        u = squeeze(U_final(k, : , : , : ));
        alpha_alpha_add = squeeze(Alpha_final(k, : , : , : ));
        alpha_overlay = squeeze(new_alphas(k, : , : , : ));
        imwrite(u, sprintf("results/alpha_add/" + input_name + "_%02d.png", num_layers - k + 1), 'png', 'Alpha', alpha_alpha_add);
        imwrite(u, sprintf(name_format + "overlay.png", num_layers - k + 1), 'png', 'Alpha', alpha_overlay);
end
finish_save = toc(begin_save);
fprintf("outputting results took %4.4f seconds\n", finish_save);
