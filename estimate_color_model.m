function color_model = estimate_color_model(image, tau)
    color_model = [];
    seed_pixels = [];
    [rows, cols, ~] = size(image);
    bins_mask = zeros(1000, rows,cols);
    representation_score = ones(rows, cols) * (2*tau^2);
    
    while true
        [votes,bins_mask] = calculate_votes(image, bins_mask,representation_score,tau);
        
        [max_votes, max_bin] = max(votes(:));
        if max_votes <= 0
            break;
        end


        mask = bins_mask(max_bin,:,:);
        
        [seed_pixel_x,seed_pixel_y] = select_seed_pixel(image, mask);
        seed_pixel = image(seed_pixel_x,seed_pixel_y);
        seed_pixels = [seed_pixels seed_pixel];
        
        % The paper is saying that after they select the color bin they want to add to the color model, they select the seed pixel using Eq. 11. After they have the seed pixel, they compute the weights of a guided filter centered at that pixel and use that to fit the normal distribution. The guided filter will have higher weights for pixels that are close in color and proximity to the center pixel. So basically they are determining the parameters of the normal distribution based on a local neighborhood of similar pixels around the seed pixel if that makes sense. (edited) 
        
        new = get_new_layer(image,seed_pixel_x,seed_pixel_y);
        color_model = [color_model; new];
        
        representation_score = weight_pixel(image,color_model);

    end
end


function [weighted_mean,weighted_std] = get_new_layer(image,seed_pixel_x,seed_pixel_y)
    neighborhood = image(max(1, seed_pixel_x - 10) : min(size(image, 1), seed_pixel_x + 10), ...
                    max(1, seed_pixel_y - 10) : min(size(image, 2), seed_pixel_y + 10));
    guided_weights = guidedfilter(rgb2gray(image), neighborhood);
    weighted_mean = sum(sum(neighborhood .* guided_weights)) / sum(sum(guided_weights));
    weighted_variance = sum(sum((neighborhood - weighted_mean).^2 .* guided_weights)) / sum(sum(guided_weights));
    weighted_std = sqrt(weighted_variance);

end

function [votes,bins_mask] = calculate_votes(image, bins_mask,representation_score,tau)
    votes = zeros(10, 10, 10);
    [rows, cols, ~] = size(image);
    for i = 1:rows
        for j = 1:cols
            rp = representation_score(i,j);
            pixel = image(i, j, :);
            r = pixel(1);
            g = pixel(2);
            b = pixel(3);
            bin_r = ceil(r / 25.6);
            bin_g = ceil(g / 25.6);
            bin_b = ceil(b / 25.6);
            index = sub2ind(size(votes), bin_r, bin_g, bin_b);
            if rp < tau^2
                bins_mask(index,i,j) = 0;
                continue
            end
            bins_mask(index,i,j) = 1;
            grad_image = 4 * image(i, j) - image(max(i-1,1), j) - image(min(i+1,rows), j) - image(i, max(j-1,1)) - image(i, min(j+1,cols));
            votes(bin_r, bin_g, bin_b) = votes(bin_r, bin_g, bin_b) + exp(-norm(grad_image)) * (1 - exp(rp));
        end
    end
end

function representation_score_map = weight_pixel(image,color_model)
    [rows, cols, ~] = size(image);
    representation_score_map = zeros(rows, cols);
    for r = 1:rows
        for c = 1: cols 
            pixel = image(r,c,:);
            for i = 1: len(color_model)
                for j = i+1 : len(color_mode)
                    representation_score_map(r,c) = min(representation_score_map(r,c),min)
                    % TODO: 完成式子
                end
            end
        end
    end
end

function [seed_pixel_x,seed_pixel_y] = select_seed_pixel(image, mask)
    seed_pixel = 0;
    % TODO: 返回 pixel的 xy坐标
end
