function MCMs_grapher(x_dimensions, X, fx_integral_exact, fx)
    for i = 1:x_dimensions
        fx_integral_exact = int(fx_integral_exact, X(i), 0, 1);
    end
    fx_integral_exact = double(fx_integral_exact); % analytical solution
    
    exponent_cap = 14; % tweak this, recommend at least 15
    iterations = 100; % tweak this, recommend 100
    sample_exponents = 0:exponent_cap;
    sample_sizes = 2.^sample_exponents;
    
    sobol_sequence = sobolset(x_dimensions);
    
    % pre-allocations
    MCM_RMSE_error = ones(exponent_cap+1, 1);
    QMCM_RMSE_error = ones(exponent_cap+1, 1);
    RQMCM_RMSE_error = ones(exponent_cap+1, 1);
    MCM_estimates = zeros(iterations, 1);
    RQMCM_estimates = zeros(iterations, 1);
    for i = 1:exponent_cap+1
        sample_size = sample_sizes(i);
        QMCM_points = net(sobol_sequence, sample_size); % deterministic
        QMCM_estimates = sum(fx(QMCM_points))/sample_size;
        for iteration = 1:iterations
            MCM_points = rand(sample_size, x_dimensions);
            MCM_estimates(iteration) = sum(fx(MCM_points))/sample_size;
    
            scrambled_sobol = scramble(sobol_sequence, "MatousekAffineOwen");
            RQMCM_points = net(scrambled_sobol, sample_size);
            RQMCM_estimates(iteration) = sum(fx(RQMCM_points))/sample_size;
        end
        MCM_RMSE_error(i) = rmse(MCM_estimates, fx_integral_exact);
        QMCM_RMSE_error(i) = rmse(QMCM_estimates, fx_integral_exact);
        RQMCM_RMSE_error(i) = rmse(RQMCM_estimates, fx_integral_exact);
    end
    % print into console
    normal_MCM_RMSE_error = transpose(MCM_RMSE_error./MCM_RMSE_error(1))
    normal_QMCM_RMSE_error = transpose(QMCM_RMSE_error./QMCM_RMSE_error(1))
    normal_RQMCM_RMSE_error = transpose(RQMCM_RMSE_error./RQMCM_RMSE_error(1))
    
    figure('WindowStyle', 'normal');
    hold off;
    loglog(sample_sizes, (sample_sizes.^-0.5), 'DisplayName', '\mathcal{O}(N^{-0.5})')
    hold on;
    loglog(sample_sizes, normal_MCM_RMSE_error, 'DisplayName', 'MCM')
    
    loglog(sample_sizes, (sample_sizes.^-1.0), 'DisplayName', '\mathcal{O}(N^{-1.0})') % trial and error
    loglog(sample_sizes, normal_QMCM_RMSE_error, 'DisplayName', 'Deterministic QMCM')
    
    loglog(sample_sizes, (sample_sizes.^-1.3), 'DisplayName', '\mathcal{O}(N^{-1.3})') % trial and error
    loglog(sample_sizes, normal_RQMCM_RMSE_error, 'DisplayName', 'Randomised QMCM')
    
    xlabel('Sample Size (to the power of 2)');
    ylabel({'Root Mean Square Error', '(normalised to start at 1)'});
    legend('Interpreter', 'latex', 'Location', 'southwest');
end

% f1 case
x_dimensions = 100;
X = sym("x", [1, x_dimensions], "real");
f1_integral_exact = sin(1).^x_dimensions;
f1 = @(xs) prod(cos(xs), 2);
MCMs_grapher(x_dimensions, X, f1_integral_exact, f1)

% f2 case
x_dimensions = 5;
X = sym("x", [1, x_dimensions], "real");
f2_integral_exact = cos(sum(X));
f2 = @(xs) cos(sum(xs, 2));
MCMs_grapher(x_dimensions, X, f2_integral_exact, f2)