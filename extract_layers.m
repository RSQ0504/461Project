function [U_temp,Alpha_temp] = extract_layers(image, color_model, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2)
    % The size of color_model is [N*3, 4]. N is the number of color layers. 
    % The information of different color layers is superimposed vertically.

    % The size of min_F_hat_layers is [rows, cols, 2], which stores index values in color_model matrix of 2 best representative color layers for each pixel

    % The size of alphas_1, alphas_2 is [rows,cols], which stores alpha values of 2 best representative color layers for each pixel
    % The size of  u_hat_1, u_hat_2 is [rows,cols], which stores color values of 2 best representative color layers for each pixel

    [rows, cols, ~] = size(image);
    U_temp = zeros([size(color_model,1)/3,rows,cols,3]);
    Alpha_temp = zeros([size(color_model,1)/3,rows,cols,1]);
    for r = 1:rows
        for c = 1:cols
            model_info = min_F_hat_layers(r,c,:);
            % 2 index values in color_model matrix of 2 best representative color layers for pixel r,c
            % Calculate actual index of color layer list
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