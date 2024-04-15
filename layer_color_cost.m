function mahal_dist = layer_color_cost(ui, mu_i, cov_i)
    diff = ui - mu_i;
    temp = inv(cov_i) * diff;
    temp = temp .* diff;
    mahal_dist = sum(temp, 1);
end