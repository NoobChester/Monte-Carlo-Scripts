x_dimensions = 5;
f1_integral_exact = sin(1).^x_dimensions; % analytical solution
f1 = @(xs) prod(cos(xs), 2); % topic function

exponent_cap = 15; % tweak this
iterations = 100; % tweak this
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
    QMCM_estimates = sum(f1(QMCM_points))/sample_size;
    for iteration = 1:iterations
        MCM_points = rand(sample_size, x_dimensions);
        MCM_estimates(iteration) = sum(f1(MCM_points))/sample_size;

        scrambled_sobol = scramble(sobol_sequence, "MatousekAffineOwen");
        RQMCM_points = net(scrambled_sobol, sample_size);
        RQMCM_estimates(iteration) = sum(f1(RQMCM_points))/sample_size;
    end
    MCM_RMSE_error(i) = rmse(MCM_estimates, f1_integral_exact);
    QMCM_RMSE_error(i) = rmse(QMCM_estimates, f1_integral_exact);
    RQMCM_RMSE_error(i) = rmse(RQMCM_estimates, f1_integral_exact);
end
% print into console
transpose(MCM_RMSE_error./MCM_RMSE_error(1))
transpose(QMCM_RMSE_error./QMCM_RMSE_error(1))
transpose(RQMCM_RMSE_error./RQMCM_RMSE_error(1))


hold off;
loglog(sample_sizes, (sample_sizes.^-0.5), 'DisplayName', '\mathcal{O}(N^{-0.5})')
hold on;
loglog(sample_sizes, MCM_RMSE_error./MCM_RMSE_error(1), 'DisplayName', 'MCM')

loglog(sample_sizes, (sample_sizes.^-1.0), 'DisplayName', '\mathcal{O}(N^{-1.0})') % trial and error
loglog(sample_sizes, QMCM_RMSE_error./QMCM_RMSE_error(1), 'DisplayName', 'Deterministic QMCM')

loglog(sample_sizes, (sample_sizes.^-1.3), 'DisplayName', '\mathcal{O}(N^{-1.3})') % trial and error
loglog(sample_sizes, RQMCM_RMSE_error./RQMCM_RMSE_error(1), 'DisplayName', 'Randomised QMCM')

title(sprintf('$f_1(\\mathbf{x}) = \\prod_{d=1}^{%d} \\cos(x_d)$', x_dimensions), 'Interpreter', 'latex');
xlabel('Sample Size (to the power of 2)');
ylabel({'Root Mean Square Error', '(normalised to start at 1)'});
legend('Interpreter', 'latex', 'Location', 'southwest');