function [U_temp,Alpha_temp] = extract_layers(image, color_model, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2)
    [rows, cols, ~] = size(image);
    U_temp = zeros([size(color_model,1)/3,rows,cols,3]);
    Alpha_temp = zeros([size(color_model,1)/3,rows,cols,1]);
    for r = 1:rows
        for c = 1:cols
            model_info = min_F_hat_layers(r,c,:);
            model_info(1) = (model_info(1)-1)/3+1;
            model_info(2) = (model_info(2)-1)/3+1;
            % mean1 = model1(:,1);
            if model_info(1) ~= model_info(2)
                U_temp(model_info(2),r,c,:) = u_hat_2(r,c,:);
                Alpha_temp(model_info(2),r,c,1) = alphas_2(r,c);
                % mean2 = model2(:,1);
            end
            U_temp(model_info(1),r,c,:) = u_hat_1(r,c,:);
            Alpha_temp(model_info(1),r,c,1) = alphas_1(r,c);
        end
    end
end