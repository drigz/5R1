function gibbs()
    L = 2;
    N = 500;

    theta_true = [2;-1];
    sigma_true = 0.1;
    X = randn(N, L);
    Y = X * theta_true + sigma_true * randn(N, 1);

    theta_guesses = [];

    for i = 1:1000
        theta = gibbs_sample(X, Y, 5);
        theta_guesses = [theta_guesses theta];
    end

    hist(theta_guesses(1,:));
    theta = mean(theta_guesses, 2)
    theta_accuracy = 2*std(theta_guesses, 0, 2)

    nu = N-L;
    theta_hat = inv(X'*X)*X'*Y;
    Y_hat = X*theta_hat;
    s_sq = (Y-Y_hat)'*(Y-Y_hat)/nu;

    chi2_mean = nu/2;
    chi2_samples = chi2rnd(nu, 1000, 1);
    sigma_samples = sqrt(nu*s_sq./chi2_samples);
    sigma = mean(sigma_samples)
    sigma_accuracy = 2*std(sigma_samples)
end

function theta = gibbs_sample(X, Y, K)
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
            resid_hat = Xi * m;
            sigma_est_sq = (resid-resid_hat)' * (resid-resid_hat) / (N-1);
            s = sqrt(sigma_est_sq / (Xi' * Xi));

            theta(i) = m + s * trnd(N-1);

            thetas = [thetas theta];
        end
    end

    %plot(thetas');
end
