function [representation_score, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2] = weight_pixel(image, V,color_model)
    [rows, cols, ~] = size(image);
    num_layers_times_3 = size(color_model,1);
    min_F_hat_layers = zeros(rows, cols, 2);
    rp = Inf * ones(1,rows* cols);
    alphas_1 = zeros(rows, cols);
    alphas_2 = zeros(rows, cols);
    u_hat_1 = zeros(rows, cols, 3);
    u_hat_2 = zeros(rows, cols, 3);

    if num_layers_times_3 == 3
        model1 = color_model;
        ui = model1(:, 1);
        covi = model1(:, 2 : end);
        ui_mat = repmat(ui, [1, rows*cols]);
        cost = layer_color_cost(V, ui_mat, covi);
        rp = cost;
        min_F_hat_layers = ones(rows, cols, 2);
        alphas_1 = ones(rows, cols);
        alphas_2 = zeros(rows, cols);
        u_hat_1 = image;
        % u_hat_2(r,c,:) = pixel;
    else
        for i = 1 : 3 : num_layers_times_3
            model1 = color_model(i : i + 2, :);
            ui = model1( : , 1);
            covi = model1( : , 2 : end);
            ui_mat = repmat(ui, [1, rows*cols]);
            cost = layer_color_cost(V, ui_mat, covi);
            for j = i + 3 : 3 : num_layers_times_3
                model2 = color_model(j : j + 2, :);
                uj= model2( : , 1);
                uj_mat = repmat(uj, [1, rows*cols]);
                covj = model2( : , 2 : end);
                [project_score, alpha_i, alpha_j, u_hat1, u_hat2] = projected_unmix(ui_mat, covi, uj_mat, covj, V);
                % TODO:
                temp = min(project_score, rp);
                filter = find(cost <= temp);
                for idx = 1:length(filter)
                    [r, c] = ind2sub([rows, cols], filter(idx));
                    min_F_hat_layers(r, c, 1) = i;
                    min_F_hat_layers(r, c, 2) = i;
                    alphas_1(r, c) = 1;
                    alphas_2(r, c) = 0;
                    u_hat_1(r,c,:) = image(r,c,:);
                end
                rp(filter) = cost(filter);
                filter = find(rp >= project_score);
                for idx = 1:length(filter)
                    [r, c] = ind2sub([rows, cols], filter(idx));
                    % fprintf("layer %d in case 2 with %d\n", i, j)
                    min_F_hat_layers(r, c, 1) = i;
                    min_F_hat_layers(r, c, 2) = j;
                    alphas_1(r, c) = alpha_i(idx);
                    alphas_2(r, c) = alpha_j(idx);
                    u_hat_1(r,c,:) = u_hat1(idx);
                    u_hat_2(r,c,:) = u_hat2(idx);
                end
                rp = min(min(rp, cost), project_score);
            end
        end
    end
    representation_score = reshape(rp,[rows,cols]);

end