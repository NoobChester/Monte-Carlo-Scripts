% runs for too long using QMCM
function MCMs_grapher(x_dimensions, X, fx_integral_exact, fx)
    for i = 1:x_dimensions
        fx_integral_exact = int(fx_integral_exact, X(i), 0, 1);
    end
    fx_integral_exact = double(fx_integral_exact); % analytical solution
    
    exponent_cap = 14; % tweak this, recommend at least 15
    iterations = 100; % tweak this, recommend 100
    sample_exponents = 0:exponent_cap;
    sample_sizes = 2.^sample_exponents;
    % pre-allocations
    MCM_RMSE_error = ones(exponent_cap+1, 1);
    MCM_estimates = zeros(iterations, 1);
    for i = 1:exponent_cap+1
        sample_size = sample_sizes(i);
        for iteration = 1:iterations
            MCM_points = rand(sample_size, x_dimensions);
            MCM_estimates(iteration) = sum(fx(MCM_points))/sample_size;
        end
        MCM_RMSE_error(i) = rmse(MCM_estimates, fx_integral_exact);
    end
    % print into console
    normal_MCM_RMSE_error = transpose(MCM_RMSE_error./MCM_RMSE_error(1))
    
    figure('WindowStyle', 'normal');
    hold off;
    loglog(sample_sizes, (sample_sizes.^-0.5), 'DisplayName', '\mathcal{O}(N^{-0.5})')
    hold on;
    loglog(sample_sizes, normal_MCM_RMSE_error, 'DisplayName', 'MCM')
    
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
x_dimensions = 100;
X = sym("x", [1, x_dimensions], "real");
f2_integral_exact = cos(sum(X));
f2 = @(xs) cos(sum(xs, 2));
MCMs_grapher(x_dimensions, X, f2_integral_exact, f2)