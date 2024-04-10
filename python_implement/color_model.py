import numpy as np
def estimate_color_model(image,tau):
    color_model = []
    seed_pixels = []
    size = image.shape
    bins_mask = np.zeros((1000, size[0],size[1]))
    rp = np.ones((size[0],size[1])) * np.Inf
    has_vote = True
    
    while has_vote:
        votes,bins_mask = calculate_votes(image,bins_mask,rp,tau)
        max_votes = np.max(votes)
        max_bin = np.argmax(votes)
        if max_votes <= 0:
            has_vote = False
            continue
        
        color_bin_mask = bins_mask[max_bin,:,:]
        y,x = select_seed_pixel(image,color_bin_mask)
        seed_pixel = image[y,x,:]
        seed_pixels.append(seed_pixel)  
        
        epsilon = 0.1
        new = get_new_layer(image,y,x,epsilon)
        color_model.append(new)
        rp,min_F_hat_layers,alphas_1,alphas_2,u_hat_1,u_hat_2 = weight_pixel(image,color_model)
    return color_model,seed_pixels, min_F_hat_layers, alphas_1, alphas_2, u_hat_1, u_hat_2

def get_new_layer(image,x,y,epsilon):
    new = None
    return new

def weight_pixel(image,color_model):
    # TODO:
    rp,min_F_hat_layers,alphas_1,alphas_2,u_hat_1,u_hat_2 = None
    return rp,min_F_hat_layers,alphas_1,alphas_2,u_hat_1,u_hat_2

def calculate_votes(image,bins_mask,rp,tau):
    votes = None
    # TODO:
    return votes,bins_mask

def select_seed_pixel(image,color_bin_mask):
    x,y = None
    return x,y