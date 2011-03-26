function gibbs()
    L = 2;
    N = 500;

    theta_true = [2;-1];
    sigma_true = 0.1;
    X = 10*randn(N, L);
    Y = X * theta_true + sigma_true * randn(N, 1);

    theta_guesses = [];

    for i = 1:1000
        theta = gibbs_sample(X, Y, sigma_true, 5);
        theta_guesses = [theta_guesses theta];
    end

    hist(theta_guesses(1,:));
    mean(theta_guesses, 2)
end

function theta = gibbs_sample(X, Y, sigma_true, K)
    [N, L] = size(X);
    
    theta = randn(L, 1);
    
    thetas = [];
    
    for k = 1:K
        for i = 1:L
            theta_masked = theta;
            theta_masked(i) = 0;
            resid = Y - X * theta_masked;
            
            Xi = X(:,i);
            
            m = (resid' * Xi) / (Xi' * Xi);
            s = sigma_true / (Xi' * Xi);
            
            theta(i) = m + s * randn();
            
            thetas = [thetas theta];
        end
    end
    
    %plot(thetas');
end
            
    
    
