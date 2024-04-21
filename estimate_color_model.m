function [color_model,seed_pixels, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2] = estimate_color_model(image, tau, window_size)
    color_model = [];
    seed_pixels = [];
    [rows, cols, ~] = size(image);
    extended_img = padarray(image, [1, 1], 'replicate');

    gradient = 4 * extended_img(2:end-1, 2:end-1,:) - ...
                   extended_img(1:end-2, 2:end-1,:) - ...
                   extended_img(3:end, 2:end-1,:) - ...
                   extended_img(2:end-1, 1:end-2,:) - ...
                   extended_img(2:end-1, 3:end,:);
    representation_score = ones(rows, cols) * Inf;
    has_vote = true;
    V = zeros(3, rows * cols);
    for r = 1 : rows
        for c = 1 : cols
            pixel = image(r, c, :);
            pixel = reshape(pixel , [3, 1]);
            V(:,sub2ind([rows,cols],r,c)) = pixel;
        end
    end
    while has_vote
        [votes,bins_mask] = calculate_votes(image, representation_score,tau, gradient);
        [max_votes, max_bin] = max(votes(:));

        if max_votes <= 0
            has_vote = false;
            continue;
        end


        color_bin_mask = bins_mask(max_bin,:,:);
        [seed_pixel_r,seed_pixel_c] = select_seed_pixel(image, color_bin_mask, window_size, gradient);
        seed_pixel = reshape(image(seed_pixel_r,seed_pixel_c,:),[3,1]); % ?
        seed_pixels = [seed_pixels seed_pixel];

        % The paper is saying that after they select the color bin they want to add to the color model, they select the seed pixel using Eq. 11. After they have the seed pixel, they compute the weights of a guided filter centered at that pixel and use that to fit the normal distribution. The guided filter will have higher weights for pixels that are close in color and proximity to the center pixel. So basically they are determining the parameters of the normal distribution based on a local neighborhood of similar pixels around the seed pixel if that makes sense. (edited) 
        epsilon = 0.1;
        new = get_new_layer(image,seed_pixel_r,seed_pixel_c, epsilon, window_size);
        if isempty(new)
            break
        end
        color_model = [color_model; new];
        % showResult(image,seed_pixel_r,seed_pixel_c);
        % saveas(gcf, sprintf('radishes_point__self%02d.jpg',size(color_model,1)-2));
        [representation_score, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2] = weight_pixel(image, V,color_model);
    end
end


function new = get_new_layer(image,seed_pixel_x,seed_pixel_y, epsilon, window_size)
    neighborhood = image(max(1, seed_pixel_x - window_size) : min(size(image, 1), seed_pixel_x + window_size), ...
                   max(1, seed_pixel_y - window_size) : min(size(image, 2), seed_pixel_y + window_size),:);
    center = reshape(image(seed_pixel_x, seed_pixel_y,:),[3,1]);
    center_colors = [];
    for color = 1 : 3
       center_colors(:,:,color) = ones(size(neighborhood(: , :, color))) .* center(color);
    end
    diff = sum((center_colors - neighborhood).^2, 3);
    mask = (diff < epsilon);
    [rows,cols] = size(mask);
    pixels = zeros(3, 100);
    pixels_size = 0;
    % center = zeros(size(neighborhood)) .* center;
    for r = 1:rows
        for c = 1:cols
            if mask(r,c) ==0
                continue
            end
            pixels_size = pixels_size + 1;
            pixels(:, pixels_size) = reshape(neighborhood(r, c, :),[3,1]);
        end
    end
    pixels = pixels(:, 1 : pixels_size);
    [~,num] = size(pixels);
    if num < 9 
        new = [];
    else
        weighted_mean = mean(pixels, 2);
        weighted_cov = cov(pixels');
        cov_norm = norm(weighted_cov);
        cov_inv = inv(weighted_cov);
        cov_inv_norm = norm(cov_inv);
        if cov_norm < 1e-4 
            weighted_cov = 0.0001 * eye(size(weighted_cov));
        end
        if cov_inv_norm < 1e-4 
            weighted_cov = 0.0001 * eye(size(weighted_cov));
        end
        eigenvalues = eig(weighted_cov);
        if any(eigenvalues < 0)
            weighted_cov = 0.0001 * eye(size(weighted_cov));
        end
    
        new = [weighted_mean,weighted_cov];
    end


end

function [votes,bins_mask] = calculate_votes(image, representation_score,tau,gradient)
    votes = zeros(10, 10, 10);
    [img_rows, img_cols, ~] = size(image);
    bins_mask = zeros(1000, img_rows,img_cols);
    [rows, cols] = find(representation_score>tau^2);
    for i = 1 : length(rows)
           pixel = image(rows(i), cols(i), :);
           r = pixel(1);
           g = pixel(2);
           b = pixel(3);
           bin_r = max(ceil(r / 0.1),1);
           bin_g = max(ceil(g / 0.1),1);
           bin_b = max(ceil(b / 0.1),1);
           index = sub2ind(size(votes), bin_r, bin_g, bin_b);
           bins_mask(index,rows(i), cols(i)) = 1;
           grad_image = squeeze(gradient(rows(i), cols(i),:));
           votes(bin_r, bin_g, bin_b) = votes(bin_r, bin_g, bin_b) + exp(-norm(grad_image)) * (1 - exp(-representation_score(rows(i), cols(i))));
    end
end



function [seed_pixel_r,seed_pixel_c] = select_seed_pixel(image, color_bin_mask,window_size, gradient)
    [~,tar_x,tar_y] = size(color_bin_mask);
    color_bin_mask = reshape(color_bin_mask, [tar_x, tar_y]);
    [rows, cols, ~] = size(image);
    best_score = -inf;
    for r = 1:rows
        for c = 1: cols 
            if color_bin_mask(r,c) == 0
                continue
            end
            grad_image = gradient(r,c);
            neighbor = color_bin_mask( ...
                max(r-window_size,1):min(rows,r+window_size), ...
                max(c-window_size,1):min(cols,c+window_size));
            Sp = sum(neighbor(:) == 1);
            score = Sp + exp(-norm(grad_image));
            if score > best_score
                best_score = score;
                seed_pixel_r = r;
                seed_pixel_c = c;
            end
        end
    end
end