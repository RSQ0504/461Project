function [F_hat, alpha_hat1, alpha_hat2, u_hat1, u_hat2] = projected_unmix(mu1, cov1, mu2, cov2, V)
    n = mu1 - mu2;
    u_hat1 = V - repmat(sum(((V - mu1) .* n),1) ./ sum((n .* n),1),[3,1]) .* n; % Projection for layer 1
    u_hat2 = V - repmat(sum(((V - mu2) .* n),1) ./ sum((n .* n),1),[3,1]) .* n; % Projection for layer 2

    temp1 =  V - u_hat2;
    temp2 = u_hat1 - u_hat2;
    alpha_hat1 = sqrt(sum(temp1.^2, 1)) ./ sqrt(sum(temp2.^2, 1));
    alpha_hat2 = 1 - alpha_hat1;

    cost1 = layer_color_cost(u_hat1, mu1, cov1);
    cost2 = layer_color_cost(u_hat2, mu2, cov2);

    F_hat = alpha_hat1 .* cost1 + alpha_hat2 .* cost2;
    filter = alpha_hat1 >= 1 | alpha_hat1 <= 0;
    F_hat(filter) = Inf;
end

% mu1 = [mean_value_1_R, mean_value_1_G, mean_value_1_B];
% cov1 = cov_matrix_1; 
% mu2 = [mean_value_2_R, mean_value_2_G, mean_value_2_B]; 
% cov2 = cov_matrix_2; 
% observed_color = [observed_color_R, observed_color_G, observed_color_B]; 

% F_hat = compute_color_mixture_cost(mu1, cov1, mu2, cov2, observed_color);
