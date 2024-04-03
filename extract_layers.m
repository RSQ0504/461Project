function color_layers = extract_layers(image, color_model, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2)
    [rows, cols, ~] = size(image);
    color_layers = zeros(rows, cols, size(color_model,1)*(4/3));
    for r = 1:rows
        for c = 1:cols
            model_info = min_F_hat_layers(r,c,:);
            model_info(1) = (model_info(1)-1)/3*4+1;
            model_info(2) = (model_info(2)-1)/3*4+1;
            % mean1 = model1(:,1);
            if model_info(1) ~= model_info(2)
                color_layers(r,c,model_info(2):model_info(2)+2) = u_hat_2(r,c,:);
                color_layers(r,c,model_info(2)+3) = alphas_2(r,c);
                % mean2 = model2(:,1);
            end
            color_layers(r,c,model_info(1):model_info(1)+2) = u_hat_1(r,c,:);
            color_layers(r,c,model_info(1)+3) = alphas_1(r,c);
        end
    end

    for i = 1:4:size(color_model,1)*(4/3)
        temp = color_layers(:,:,i:i+3);
        %imshow(temp);
        %imwrite(temp,sprintf('result_self%02d.png',i),'jpg','Quality',95);
        imwrite(temp(:,:,1:3), sprintf('1_result_self%02d.png',i), 'png', 'Alpha', temp(:,:,4))
    end
end

    