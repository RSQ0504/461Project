function new_alphas = alpha_add_to_overlay(alphas)
    [num_layers, rows, cols, ~] = size(alphas);
    new_alphas = zeros(num_layers, rows, cols, 1);
    sum_alphas = zeros(rows, cols);
    for layer = 1 : num_layers
        alpha_temp = squeeze(alphas(layer, :, :, :));
        alpha_is_zero = (alpha_temp == 0);
        sum_alphas = sum_alphas + alpha_temp;
        alpha_temp = alpha_temp ./ squeeze(sum_alphas);
        alpha_temp(alpha_is_zero) = 0;
        new_alphas(layer, : , : , : ) = alpha_temp;
    end
    new_alphas(new_alphas > 1) = 1;
    new_alphas(new_alphas < 0) = 0;
end