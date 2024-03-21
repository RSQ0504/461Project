function F_hat = projected_unmix(mu1, std1, mu2, std2, c)
    n = mu1 - mu2;

    u_hat1 = c - ((c - mu1) * n') * n / norm(n)^2; % Projection for layer 1
    u_hat2 = c - ((c - mu2) * n') * n / norm(n)^2; % Projection for layer 2

    alpha_hat1 = norm(c - mu2) / norm(mu1 - mu2);
    alpha_hat2 = 1 - alpha_hat1;

    cost1 = layer_color_cost(u_hat1, mu1, std1);
    cost2 = layer_color_cost(u_hat2, mu2, std2);

    F_hat = alpha_hat1 * cost1 + alpha_hat2 * cost2;
end




% mu1 = [mean_value_1_R, mean_value_1_G, mean_value_1_B];
% cov1 = cov_matrix_1; 
% mu2 = [mean_value_2_R, mean_value_2_G, mean_value_2_B]; 
% cov2 = cov_matrix_2; 
% observed_color = [observed_color_R, observed_color_G, observed_color_B]; 

% F_hat = compute_color_mixture_cost(mu1, cov1, mu2, cov2, observed_color);