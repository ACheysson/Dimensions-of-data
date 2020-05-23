% This script solves the baseline loulou model. It does so for a range of
% different parameters and produces graphs accordingly. For one time runs,
% one needs to specify manually parameters at the beginning of the script.


% First specify whether it will be investigation over a range of parameters
N_runs = 1;

% Do you want graphs?
graphs = 1; % graph will slow down significantly the code

% Specify parameter values
fineness = 100;     % Define how precise is the grid of prices we search on
alpha = 1;          % Define how strong is the horizontal differenciation
s_1  = 0.8;         % Define Markov Chain persistence 
p_grid = linspace(0.01, alpha+1,fineness)'; % Possible values of prices

% Specify storing vectors
value_of_info = zeros(N_runs,1);    % Value of information
prices_uninf = zeros(N_runs, 1);    % Price schedule of uninformed platform
prices_inf = zeros(N_runs,1);       % Price schedule of informed platform
prices_first = zeros(N_runs,1);

% Specify around which to run
s_vec = linspace(0.51, s_1, N_runs);

% Ready to start the loop
disp('Start loop over parameter specification')
for ii = 1:N_runs

    % Unpack parameter we loop around
    s_1 = s_vec(ii);
    
    % Compute best response schedule of informed platform
    [sols_inf, market_share_inf, profits_inf] = compute_best_response_info(p_grid, alpha, s_1,graphs);
    
    % To compute best response schedule and intersection of best responses
    if graphs == 1
        [sols_uninf, ~, ~, ~] = compute_best_response_uninfo(p_grid, alpha, s_1, 1);
        
        figure
        plot(p_grid, sols_inf)
        hold on
        plot(sols_uninf, p_grid)
        ylabel('Price of informed')
        xlabel('Price of uninformed')
    end

    % Compute the best response of uninformed to the best response of informed
    [sols_uninf, market_share_uninf_type_1, market_share_uninf_type_2, profits_uninf] = compute_best_response_uninfo(sols_inf, alpha, s_1, 0);
    
    % We can now find the value of the intersection and the parameters of the model at the intersection
    [distance, fixed_point]= min(abs(p_grid-sols_uninf));
    
    % Send a warning if the distance is too high
    if distance > 1/fineness
        warning('It does not look like a good intersection of best responses was found')
    end
    
    % Store the values
    value_of_info(ii) = profits_inf(fixed_point) - profits_uninf(fixed_point);
    prices_inf(ii) = sols_inf(fixed_point);
    prices_uninf(ii) = sols_uninf(fixed_point);
    
    % We can now compute the first period of the model
    [sols, ~] = first_period(p_grid, value_of_info(ii), alpha);
    [distance, fixed_point] = min(abs(p_grid - sols));
    
    % Send another warning in case of problem
    if distance > 1/fineness
        warning('It does not look like a good intersection of best responses was found')
    end
    
    % And compute the first period prices
    prices_first = p_grid(fixed_point);
end