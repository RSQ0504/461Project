function mahal_dist = layer_color_cost(ui, mu_i, cov_i)
    diff = ui - mu_i;
    mahal_dist = diff' * inv(cov_i) * diff;
end