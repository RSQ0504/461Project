function hi = showResult(image,seed_pixel_x, seed_pixel_y)
        imshow(image);
        hold on;
        scatter(seed_pixel_x, seed_pixel_y, 100, 'blue', 'filled');
        hold off;
end