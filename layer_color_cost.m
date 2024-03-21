function mahal_dist = layer_color_cost(ui, mu_i, std_i)
    d_normalized = (ui-mu_i) ./ std_i;
    mahal_dist = norm(d_normalized);;

end