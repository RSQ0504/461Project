function color_layers = extract_layers(image, color_model, min_F_hat_layers, alphas_1, alphas_2)
    [rows, cols, ~] = size(image);
    color_layers = zeros(rows, cols, size(color_model,1));
    for r = 1:rows
        for c = 1:cols
            model_info = min_F_hat_layers(r,c,:);
            model1 = color_model(model_info(1):model_info(1)+2,:);
            mean1 = model1(:,1);
            model2 = color_model(model_info(2):model_info(2)+2,:);
            mean2 = model2(:,1);

            color_layers(r,c,model_info(1):model_info(1)+2) = alphas_1(r,c) * mean1;
            color_layers(r,c,model_info(2):model_info(2)+2) = alphas_2(r,c) * mean2;
        end
    end
end