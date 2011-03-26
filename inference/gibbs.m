function gibbs()
    L = 1;

    B1_true = 0.5403;
    B2_true = -0.8415;
    w_true = 0.3;
    sigma_true = 0.01;
    X = (-256:256)';
    N = size(X, 1);
    Y = B1_true*cos(w_true*X) + B2_true*sin(w_true*X) ...
        + sigma_true*randn(N, 1);

    B1_samples = [];
    B2_samples = [];
    w_samples = [];

    for i = 1:10
        [B1, B2, w] = gibbs_sample(X, Y, 100);
        B1_samples = [B1_samples B1];
        B2_samples = [B2_samples B2];
        w_samples = [w_samples w];
    end

    B1 = mean(B1_samples)
    B2 = mean(B2_samples)
    w = mean(w_samples)

    hist([B1_samples' B2_samples' w_samples']);
    legend('B1', 'B2', 'w');

    nu = N-L;
    Y_hat = B1*cos(w*X) + B2*sin(w*X);
    s_sq = (Y-Y_hat)'*(Y-Y_hat)/nu;

    chi2_mean = nu/2;
    chi2_samples = chi2rnd(nu, 1000, 1);
    sigma_samples = sqrt(nu*s_sq./chi2_samples);
    sigma = mean(sigma_samples)
    sigma_accuracy = 2*std(sigma_samples)
end

function [B1, B2, w] = gibbs_sample(X, Y, K)
    [N, L] = size(X);

    B1 = randn();
    B2 = randn();
    w = abs(randn());

    B1 = 0.5403;
    B2 = -0.8415;
    w = 0.3;

    B1s = [B1];
    B2s = [B2];
    ws = [w];

    for k = 1:K
        keyboard
        resid = Y - B2 * sin(w * X);
        Xi = cos(w * X);
        m = (resid' * Xi) / (Xi' * Xi);
        resid_hat = m * Xi;
        sigma_est_sq = (resid-resid_hat)' * (resid-resid_hat) / (N-1);
        s = sqrt(sigma_est_sq / (Xi' * Xi));
        B1 = m + s * trnd(N-1);

        resid = Y - B1 * cos(w * X);
        Xi = sin(w * X);
        m = (resid' * Xi) / (Xi' * Xi);
        resid_hat = m * Xi;
        sigma_est_sq = (resid-resid_hat)' * (resid-resid_hat) / (N-1);
        s = sqrt(sigma_est_sq / (Xi' * Xi));
        B2 = m + s * trnd(N-1);

        w_hat = fminbnd(@(w_est) sum((Y-B1*cos(w_est*X)-B2*sin(w_est*X)).^2), 0, 10);
        resid = Y - B1 * cos(w_hat*X) - B2 * sin(w_hat*X);
        Xi = -B1*X.*sin(w_hat*X) + B2*X.*cos(w_hat*X);
        sigma_est_sq = resid' * resid / (N-1);
        s = sqrt(sigma_est_sq / (Xi' * Xi));
        w = w_hat + s * trnd(N-1);


        B1s = [B1s B1];
        B2s = [B2s B2];
        ws = [ws w];

    end

    %plot([B1s' B2s' ws'])
end
