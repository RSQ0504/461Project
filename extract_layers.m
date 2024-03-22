function color_layers = extract_layers(image, color_model, min_F_hat_layers, alphas_1, alphas_2)
    [rows, cols, ~] = size(image);
    color_layers = zeros(size(color_model,1), rows, cols);
    fuck = color_layers(1:3,:,:);
end