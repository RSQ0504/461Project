function [representation_score, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2] = weight_pixel(image,color_model)
    [rows, cols, ~] = size(image);
    num_layers_times_3 = size(color_model,1);
    min_F_hat_layers = zeros(rows, cols, 2);
    representation_score = Inf * ones(rows, cols);
    alphas_1 = zeros(rows, cols);
    alphas_2 = zeros(rows, cols);
    u_hat_1 = zeros(rows, cols, 3);
    u_hat_2 = zeros(rows, cols, 3);

    for r = 1 : rows
        for c = 1 : cols
            pixel = image(r, c, :);
            pixel = reshape(pixel , [3, 1]);
            if num_layers_times_3 == 3
                model1 = color_model;
                ui = model1(:, 1);
                covi = model1(:, 2 : end);
                cost = layer_color_cost(pixel, ui, covi);
                representation_score(r, c) = cost;
                min_F_hat_layers(r, c,:) = [1, 1];
                alphas_1(r, c) = 1;
                alphas_2(r, c) = 0;
                u_hat_1(r,c,:) = pixel;
                % u_hat_2(r,c,:) = pixel;
            else
                for i = 1 : 3 : num_layers_times_3
                    model1 = color_model(i : i + 2, :);
                    ui = model1( : , 1);
                    covi = model1( : , 2 : end);
                    cost = layer_color_cost(pixel, ui, covi);
                    for j = i + 3 : 3 : num_layers_times_3
                        model2 = color_model(j : j + 2, :);
                        uj= model2( : , 1);
                        covj = model2( : , 2 : end);
                        [project_score, alpha_i, alpha_j, u_hat1, u_hat2] = projected_unmix(ui, covi, uj, covj, pixel);
                        if cost <= min(project_score, representation_score(r, c))
                            % fprintf("layer %d in case 1\n", i)
                            min_F_hat_layers(r, c, 1) = i;
                            min_F_hat_layers(r, c, 2) = i;
                            alphas_1(r, c) = 1;
                            alphas_2(r, c) = 0;
                            u_hat_1(r,c,:) = pixel;
                            representation_score(r, c) = cost;
                            % u_hat_2(r,c,:) = pixel;
                        elseif representation_score(r, c) >= project_score 
                            fprintf("layer %d in case 2 with %d\n", i, j)
                            min_F_hat_layers(r, c, 1) = i;
                            min_F_hat_layers(r, c, 2) = j;
                            alphas_1(r, c) = alpha_i;
                            alphas_2(r, c) = alpha_j;
                            u_hat_1(r,c,:) = u_hat1;
                            u_hat_2(r,c,:) = u_hat2;
                            representation_score(r, c) = project_score;
                        end
                        representation_score(r, c) = min([representation_score(r, c), cost, project_score]);
                    end
                end
            end
        end
    end
end