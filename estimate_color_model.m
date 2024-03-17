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
        bin_pixels = [];
        [rows, cols, ~] = size(image);
        for r = 1:rows
            for c = 1:cols
                if mask(r,c) ~= 0 
                    bin_pixels = [temp image(r,c,:)];
                end
            end
        end
        new = [mean(bin_pixels) conv(bin_pixels)];

        color_model = [color_model; new];
        
        seed_pixel = select_seed_pixel(image, bin_pixels);
        seed_pixels = [seed_pixels seed_pixel];
        
        representation_score = weight_pixel(image,color_model);

    end
end

function [votes,bins_mask] = calculate_votes(image, bins_mask,representation_score,tau)
    votes = zeros(10, 10, 10);
    [rows, cols, ~] = size(image);
    for i = 1:rows
        for j = 1:cols
            if representation_score(i,j) < tau^2
                continue
            end
            rp = representation_score(i,j);
            pixel = image(i, j, :);
            r = pixel(1);
            g = pixel(2);
            b = pixel(3);
            bin_r = ceil(r / 25.6);
            bin_g = ceil(g / 25.6);
            bin_b = ceil(b / 25.6);
            index = sub2ind(size(votes), bin_r, bin_g, bin_b);
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
                    % TODO:
                end
            end
        end
    end
end

function seed_pixel = select_seed_pixel(image, seed_pixels)
    max_weight = 0;
    seed_pixel = 0;
    % TODO:
end
