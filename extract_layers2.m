function [U_temp, Alpha_temp] = extract_layers2(image, color_model, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2)
    [rows, cols, ~] = size(image);
    U_temp = zeros([size(color_model,1)/3,rows,cols,3]);
    Alpha_temp = zeros([size(color_model,1)/3,rows,cols,1]);
    for r = 1:rows
        for c = 1:cols
            model_info = min_F_hat_layers(r, c, :);
            model_info(1) = (model_info(1) - 1) / 3 + 1;
            model_info(2) = (model_info(2) - 1) / 3 + 1;
            % mean1 = model1(:,1);
            if model_info(1) ~= model_info(2)
                U_temp(model_info(2), r, c, : ) = u_hat_2(r, c, : );
                Alpha_temp(model_info(2), r, c, 1) = alphas_2(r, c);
                % mean2 = model2(:,1);
            end
            U_temp(model_info(1),r,c,:) = u_hat_1(r, c, : );
            U_temp(model_info(1),r,c,1) = alphas_1(r, c);
        end
    end

    temp = zeros(size(squeeze(U_temp(1,:,:,:))));
    for i = 1 : size(color_model, 1) / 3
        u = squeeze(U_temp(i,:,:,:));
        alpha = squeeze(Alpha_temp(i, : , : , : ));
        temp = temp + (u .* alpha);
        %imshow(temp);
        
        % imwrite(u, sprintf('result_self%02d.png',i), 'png', 'Alpha', alpha)
    end
    imwrite(temp,sprintf('after_extract_layers.png'),'jpg','Quality',95);
end

    